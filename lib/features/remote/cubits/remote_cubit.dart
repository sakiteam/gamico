import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/models/gamico_game_model.dart';
import 'package:gamico/commons/services/database_shutdown.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:gamico/commons/services/layout.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/models/remote_utility.dart';
import 'package:gamico/commons/repositories/gamico_games_repository.dart';

part 'remote_state.dart';

/// Cubit for managing the remote game mode.
///
/// ## Matchmaking model
///
/// Server-driven: three RTDB nodes, and the client owns exactly one of them.
///
///   pools/pool_key/queue/uid   ← we write this, and only this
///   pools/pool_key/seal_at       ← server's countdown, for display only
///   assignments/uid             ← server's answer: "your game is game_id"
///
/// The invariant everything rests on: a player is queued or assigned, never
/// both. The server moves them from one to the other in a single atomic
/// multi-path write (`functions/matchmaking.js`), so there is no in-between
/// state for the client to reconstruct. See [_enterPool] for the entry point
/// and the "Server-driven matchmaking" section below for the rest.
class RemoteCubit extends Cubit<RemoteState> {
  /// Cubit for managing the remote game mode.
  RemoteCubit({
    required this.userCubit,
    required this.gamesRepository,
    required this.remoteUtility,
    required int? level,
    this.receiverId,
    this.senderId,
  }) : super(RemoteState(level: level)) {
    GamicoDatabaseShutdown.register(this, cancelDatabaseListeners);
  }

  /// See [GamicoDatabaseShutdown]: drops every matchmaking listener while the
  /// app is being torn down, before the Flutter engine dies.
  ///
  /// The queue entry's `onDisconnect` is deliberately left armed — it is the
  /// only thing that will take our seat out of the pool once this process is
  /// gone. This registry exists to stop native RTDB events reaching a dying
  /// engine, nothing more.
  Future<void> cancelDatabaseListeners() async {
    await _assignmentSubscription?.cancel();
    _assignmentSubscription = null;
    await _queueSubscription?.cancel();
    _queueSubscription = null;
    await _sealSubscription?.cancel();
    _sealSubscription = null;
    _sealTicker?.cancel();
    _sealTicker = null;
    await _serverTimeOffsetSubscription?.cancel();
    _serverTimeOffsetSubscription = null;
  }

  /// Reference to the games repository.
  final GamicoGamesRepository gamesRepository;

  final GamicoUserCubit userCubit;

  final RemoteUtility remoteUtility;

  final String? receiverId;
  final String? senderId;

  bool? creator;

  /// Id of the real game we launched.
  String gameId = "";

  /// Pool mode the launched game actually came from. Equals the configured
  /// single mode for normal searches; resolves the winning pool for "no
  /// preference" searches.
  String? matchedMode;

  /// Estimated offset between local clock and Firebase server time.
  int _serverTimeOffset = 0;
  StreamSubscription<DatabaseEvent>? _serverTimeOffsetSubscription;

  /// Current time synchronized across all devices using Firebase server time.
  int get _serverNowMs =>
      DateTime.now().millisecondsSinceEpoch + _serverTimeOffset;

  /// Delay requested by [enableBotFallback], kept across [reset] so every
  /// subsequent search re-arms on its own (it travels inside each queue
  /// entry — see [_queueEntry]).
  Duration? _botFallbackDelay;

  /// Guards a single launch (the assignment listener can fire more than once).
  bool _launching = false;

  /// The remote utility to hand to the launched game, with the matchmaking
  /// mode resolved to the pool the game actually came from. Identical to
  /// [remoteUtility] for single-mode searches.
  RemoteUtility get matchedRemoteUtility {
    final mode = matchedMode;
    final settings = remoteUtility.matchmakingSettings;
    if (mode == null || mode == settings.mode) return remoteUtility;
    return remoteUtility.withMatchmakingMode(mode);
  }

  void init() {
    launch();
    setAnimInit(true);
  }

  void setForcePop(bool forcePop) {
    emit(state.copyWith(forcePop: forcePop));
  }

  void setAnimInit(bool animInit) {
    emit(state.copyWith(animInit: animInit));
  }

  void setAnimGame(bool animGame) {
    emit(state.copyWith(animGame: animGame));
  }

  void setAnimated(bool animated) {
    emit(state.copyWith(animated: animated));
  }

  @override
  void emit(RemoteState state) {
    if (isClosed) return;
    super.emit(state);
  }

  /// Set whether the game has already been started or not
  void setFinalized(bool finalized) {
    emit(state.copyWith(finalized: finalized));
  }

  void setInternetError(bool internetError) {
    emit(state.copyWith(internetError: internetError));
  }

  void launch() {
    try {
      _init();
    } catch (e) {
      emit(state.copyWith(status: RemoteGameStatus.failure, creator: null));
    }
  }

  void reset([int? level]) {
    abortGame();

    _serverTimeOffsetSubscription?.cancel();

    gameId = "";
    matchedMode = null;
    _launching = false;

    // The new search knows nobody yet: dropping the roster (and the profiles
    // resolved for it) is what stops the previous game's opponents from being
    // re-displayed as "found" on the waiting page. Bumping the sequence also
    // disowns any profile fetch still in flight for the old search.
    _profileCache.clear();
    _playersFoundSeq++;

    emit(
      state.copyWith(
        status: RemoteGameStatus.initial,
        creator: null,
        gameId: "",
        animGame: false,
        finalized: false,
        fakeOpponent: false,
        playersFound: 0,
        playerNames: const [],
        playerPhotos: const [],
        countdownRemaining: () => null,
        searchGeneration: state.searchGeneration + 1,
        // animInit: false,
        level: level == null ? null : () => level,
      ),
    );

    launch();
  }

  void _init() async {
    if (isClosed) return;

    emit(
      state.copyWith(
        status: RemoteGameStatus.loading,
        creator: null,
        finalized: false,
        fakeOpponent: false,
      ),
    );

    // Bound *before* queueing, and never after: `seal_at`/`joined_at` are
    // absolute timestamps compared against [_serverNowMs], and attaching the
    // offset afterwards means the very first search of a session compares
    // them against the raw device clock. A phone a few minutes fast then
    // reads a live deadline as already past.
    _bindServerTimeOffset();

    await _enterPool();
  }

  /// Keeps [_serverNowMs] in step with Firebase's clock.
  void _bindServerTimeOffset() {
    _serverTimeOffsetSubscription?.cancel();
    _serverTimeOffsetSubscription = FirebaseDatabase.instance
        .ref(".info/serverTimeOffset")
        .onValue
        .listen((event) {
          final value = event.snapshot.value;
          if (value is! num) return;
          _serverTimeOffset = value.toInt();
        });
  }

  /// Monotonic tag for [_emitPlayersFound] passes: room events can arrive in
  /// bursts and each pass fetches profiles over the network, so a slow older
  /// pass must never overwrite the list a newer pass already emitted.
  int _playersFoundSeq = 0;

  /// Profiles already resolved this search (uid → (name, photo)), so a player
  /// who was already listed never flips back to a placeholder while a burst
  /// of room events re-fetches everyone.
  final Map<String, (String, String)> _profileCache = {};

  Future<void> _emitPlayersFound(Set<String?> ids) async {
    final seq = ++_playersFoundSeq;

    // Emit instantly from what is known locally — the local user's own
    // profile and previously fetched ones. The player must at least see
    // themself immediately: network fetches (below) can be slow or hang
    // right after a game while the connection churns.
    final ordered = _orderedIds(ids);
    List<(String, String)> resolve() => [
      for (final uid in ordered) _localProfileFor(uid) ?? ('...', ''),
    ];
    var profiles = resolve();
    emit(
      state.copyWith(
        playersFound: ids.length,
        playerNames: profiles.map((p) => p.$1).toList(),
        playerPhotos: profiles.map((p) => p.$2).toList(),
      ),
    );

    // Then resolve the missing profiles over the network and patch them in,
    // unless a newer pass took over meanwhile.
    for (final uid in ordered) {
      if (_localProfileFor(uid) != null) continue;
      try {
        // `profiles/$uid`, the name+photo projection, rather than the whole
        // user node: the two fields read just below are all this needs, and the
        // full node (~1.9 kB, carrying `progression`, `achievements`, `skins`,
        // `stars` and the FCM token) is fetched here once per player found, on
        // every matchmaking session, purely to draw a name under an avatar.
        final snap = await FirebaseDatabase.instance
            .ref('profiles/$uid')
            .get()
            .timeout(const Duration(seconds: 5));
        final data = snap.value;
        if (data is Map) {
          _profileCache[uid] = (
            data['name']?.toString() ?? '...',
            data['photo']?.toString() ?? '',
          );
        }
      } catch (_) {}
    }
    if (isClosed || seq != _playersFoundSeq) return;
    profiles = resolve();
    emit(
      state.copyWith(
        playerNames: profiles.map((p) => p.$1).toList(),
        playerPhotos: profiles.map((p) => p.$2).toList(),
      ),
    );
  }

  /// The room's uids ordered with the local user first.
  List<String> _orderedIds(Set<String?> ids) {
    final myUid = LocalStorageService.uid;
    return [myUid, ...ids.whereType<String>().where((id) => id != myUid)];
  }

  /// Profile for [uid] available without touching the network: the local
  /// user's own loaded profile, or one already fetched this search.
  (String, String)? _localProfileFor(String uid) {
    if (uid == LocalStorageService.uid) {
      String localName = "";
      String localPhoto = "";
      final userModel = userCubit.state.user;
      if (userModel != null) {
        try {
          localName = userModel.name?.toString() ?? "";
        } catch (_) {}
        try {
          localPhoto = userModel.photo?.toString() ?? "";
        } catch (_) {}
      }
      return (localName.isNotEmpty ? localName : 'Vous', localPhoto);
    }
    return _profileCache[uid];
  }

  /// Opt-in bot fallback for pools where nobody real shows up in time — a
  /// table that never fills with real players would otherwise wait forever.
  ///
  /// The delay travels inside the queue entry ([_queueEntry]), so it must be
  /// armed before (or updated after, via [_publishBotFallback]) that entry is
  /// written. The server fills every empty seat with a synthetic placeholder
  /// (`user_id` of the form `bot_<key>`) once the delay elapses — turning that
  /// into whatever a specific engine understands as a bot is up to the
  /// caller's own game setup, once it reads back who is actually seated.
  void enableBotFallback({required Duration after}) {
    _botFallbackDelay = after;
    unawaited(_publishBotFallback());
  }

  /// Tells the server about a bot fallback enabled after we were already
  /// queued.
  ///
  /// Deliberately an `update`, never a `set`: rewriting the entry would stamp
  /// a fresh `joined_at` and send us to the back of a queue we have been
  /// waiting in.
  Future<void> _publishBotFallback() async {
    final ref = _queueEntryRef;
    final delay = _botFallbackDelay;
    if (ref == null || delay == null) return;
    try {
      await ref.update({"bot_after_ms": delay.inMilliseconds});
    } catch (_) {}
  }

  // ---------------------------------------------------------------------
  // Server-driven matchmaking (`pools/` + `assignments/`)
  //
  // Three nodes, and the client owns exactly one of them:
  //
  //   pools/<poolKey>/queue/<uid>   ← we write this, and only this
  //   pools/<poolKey>/seal_at       ← server's countdown, for display only
  //   assignments/<uid>             ← server's answer: "your game is <id>"
  //
  // The invariant everything rests on: a player is queued or assigned, never
  // both. The server moves them from one to the other in a single atomic
  // multi-path write, so there is no in-between state to reconstruct.
  // ---------------------------------------------------------------------

  /// Our entry in the pool, while we are waiting in it.
  DatabaseReference? _queueEntryRef;

  StreamSubscription<DatabaseEvent>? _assignmentSubscription;
  StreamSubscription<DatabaseEvent>? _queueSubscription;
  StreamSubscription<DatabaseEvent>? _sealSubscription;

  /// Drives [RemoteState.countdownRemaining] from `seal_at`. Displays, never
  /// decides: reaching zero here does nothing at all.
  Timer? _sealTicker;

  bool _reassertingQueueEntry = false;
  bool _consumingAssignment = false;

  /// Game id of an assignment this search has already thrown away.
  ///
  /// The freshness test only guards the read [_enterPool] performs before
  /// queueing. The live listener attaches right after and replays whatever is
  /// in the mailbox — so a discard whose `remove()` did not land (a blip, a
  /// refused write) came straight back through it and walked the player into
  /// the very game they had just been kept out of. Remembering the id settles
  /// it without depending on a clock or on a delete succeeding.
  String? _discardedGameId;

  /// `seal_at` a nudge has already been sent for, so a deadline that passes
  /// unfulfilled is poked exactly once.
  int? _nudgedSealAt;

  /// Bumped on every entry into and exit from a pool.
  ///
  /// [reset] (the "Nouvelle partie" rematch) calls `abortGame()` WITHOUT
  /// awaiting it and starts the next search immediately, so a leave and the
  /// join that follows it overlap — on the very same path, since the entry is
  /// keyed by uid. Without this, the leave's `remove()` lands after the new
  /// entry has been written and deletes it: the player waits in a pool that no
  /// longer counts them.
  int _poolGeneration = 0;

  /// How many times the initial queue write is attempted.
  static const int _queueWriteAttempts = 3;

  /// How recent an assignment must be to be worth walking back into.
  ///
  /// Comfortably inside the 20 s readiness grace the game layer grants a
  /// player who has not answered the roll-call yet, so a resume that succeeds
  /// still has time to answer it. Anything older is a table that has already
  /// moved on.
  static const Duration _assignmentResumeWindow = Duration(seconds: 15);

  /// Whether [raw] was handed out recently enough for its table to still be
  /// waiting on us. Missing timestamps read as stale.
  bool _isAssignmentFresh(Object? raw) {
    if (raw is! Map) return false;
    final createdAt = (raw["created_at"] as num?)?.toInt();
    if (createdAt == null) return false;
    final age = _serverNowMs - createdAt;
    return age >= 0 && age < _assignmentResumeWindow.inMilliseconds;
  }

  /// THE entry point. Everything the client does to find a game is here.
  Future<void> _enterPool() async {
    final uid = LocalStorageService.uid;
    if (uid.isEmpty || isClosed) return;

    final generation = ++_poolGeneration;

    final db = FirebaseDatabase.instance;
    // The level is part of the key for an adventure search: two players are
    // only matched on the same level, since they play the same puzzle. The
    // legacy path did this too (`_buildRoomKey`'s `_lvl<N>`), and dropping it
    // would seat a player on level 3 against one on level 40.
    final poolKey = remoteUtility.matchmakingSettings.poolKeyFor(
      remoteUtility.adventure ? state.level : null,
    );

    // The mailbox is read BEFORE queueing, always. A player killed between
    // being seated and the table opening still holds an assignment; queueing
    // on top of it would put them in two places at once — a ghost seat at the
    // table they never reached, whose opponents wait out the readiness grace
    // on them, plus a second game they never asked for.
    //
    // An old one is thrown away rather than resumed, and the reason is not
    // taste: nothing readable can tell us whether the table still holds our
    // seat. Being struck off the roll-call is a purely local verdict — the
    // game layer records it in its own `_leftIds` and never touches
    // `games/<id>/players` — so validating against the game node can only ever
    // answer "you were seated", never "you are still expected". Past the
    // readiness grace, resuming means walking into a table that has written us
    // off, which the session then has to settle back out of. A fresh search is
    // both simpler and closer to what the player just asked for.
    try {
      final pending = await db
          .ref("assignments/$uid")
          .get()
          .timeout(const Duration(seconds: 5));
      if (pending.exists) {
        if (_isAssignmentFresh(pending.value) &&
            await _consumeAssignment(pending.value)) {
          return;
        }
        final raw = pending.value;
        if (raw is Map) {
          _discardedGameId = raw["game_id"]?.toString();
        }
        await _dropAssignment();
      }
    } catch (_) {
      // Mailbox unreachable: queue anyway rather than block the search on it.
    }

    if (isClosed || _launching) return;

    final entryRef = db.ref("pools/$poolKey/queue/$uid");
    _queueEntryRef = entryRef;

    // Armed before the entry exists: a process dying in between would
    // otherwise leave a slot with nothing registered to reap it.
    try {
      await entryRef.onDisconnect().remove();
    } catch (_) {}

    // The search never gives up on its own. Giving up after a few tries left
    // the player watching a search that was not happening, with a dismissible
    // popup and no way back other than leaving the page.
    var written = false;
    for (var attempt = 0; !written; attempt++) {
      if (isClosed || _launching || generation != _poolGeneration) {
        _queueEntryRef = null;
        return;
      }
      try {
        await entryRef.set(_queueEntry());
        written = true;
      } catch (_) {
        // Tell them once the failure looks real, then keep trying quietly.
        if (attempt == _queueWriteAttempts && !isClosed) setInternetError(true);
        final backoffMs = 400 * (attempt + 1);
        await Future.delayed(
          Duration(milliseconds: backoffMs > 5000 ? 5000 : backoffMs),
        );
      }
    }

    if (isClosed || _launching || generation != _poolGeneration) return;

    debugPrint("🔍 [MM] enterPool: $poolKey/$uid");

    // The one signal that matters. Everything else on this screen is decor.
    _assignmentSubscription = db.ref("assignments/$uid").onValue.listen(
      (event) {
        final value = event.snapshot.value;
        if (value == null) return;
        unawaited(_consumeAssignment(value));
      },
      onError: (error, _) =>
          debugPrint("⚠️ RemoteCubit assignment listener error: $error"),
    );

    _queueSubscription = db
        .ref("pools/$poolKey/queue")
        .onValue
        .listen(
          _onQueueChanged,
          onError: (error, _) =>
              debugPrint("⚠️ RemoteCubit queue listener error: $error"),
        );

    _sealSubscription = db.ref("pools/$poolKey/seal_at").onValue.listen(
      (event) {
        final sealAt = (event.snapshot.value as num?)?.toInt();
        if (sealAt == null) {
          _stopSealTicker();
          return;
        }
        _startSealTicker(sealAt);
      },
      onError: (error, _) =>
          debugPrint("⚠️ RemoteCubit seal listener error: $error"),
    );
  }

  /// THE exit point. Cancels every listener and gives the seat back.
  Future<void> _leavePool() async {
    final generation = ++_poolGeneration;

    await _assignmentSubscription?.cancel();
    _assignmentSubscription = null;
    await _queueSubscription?.cancel();
    _queueSubscription = null;
    await _sealSubscription?.cancel();
    _sealSubscription = null;
    _stopSealTicker();

    final ref = _queueEntryRef;
    _queueEntryRef = null;
    if (ref == null) return;

    // Cancelled first: an `onDisconnect` left armed on a path we are about to
    // stop owning is what fires late, after a relaunch, and deletes the entry
    // of the *next* search.
    try {
      await ref.onDisconnect().cancel();
    } catch (_) {}

    // A new search took this exact path over while we were leaving it (a
    // rematch): the entry sitting there is theirs, not ours to delete.
    if (generation != _poolGeneration && _queueEntryRef?.path == ref.path) {
      return;
    }

    try {
      await ref.remove();
    } catch (_) {}
  }

  /// What we put in the pool. Read by the server, by nobody else.
  Map<String, dynamic> _queueEntry() {
    final settings = remoteUtility.matchmakingSettings;
    final seats = settings.isInfinite ? 0 : settings.seats;

    return <String, dynamic>{
      // The table shape, declared rather than encoded in the key. The server
      // holds no per-game configuration at all, so changing a table's size is
      // a client release — never a function deploy.
      "seats": settings.seats,
      if (settings.isInfinite) "infinite": true,
      // Server time, deliberately: the ordering it feeds is the one fairness
      // rule of this matchmaking ("longest wait first"), and a device clock
      // has no business arbitrating it.
      "joined_at": ServerValue.timestamp,
      "modes": settings.queueModes,
      if (_botFallbackDelay != null)
        "bot_after_ms": _botFallbackDelay!.inMilliseconds,
      if (seats == 2 && _wantsFakeOpponent) "fake_opponent": true,
    };
  }

  /// Whether a lone player in a 2-seat pool should be given a synthetic
  /// opponent instead of waiting indefinitely — the server seals a lone
  /// player and the game layer builds the synthetic opponent as it always
  /// has.
  bool get _wantsFakeOpponent =>
      !remoteUtility.isDeveloper &&
      !appScreenshots &&
      Gamico.instance.playSettings?.enableFakeOpponent == true;

  /// Keeps the waiting screen's roster fresh, and re-asserts our own entry if
  /// it disappears.
  void _onQueueChanged(DatabaseEvent event) {
    if (isClosed || _launching || _consumingAssignment) return;

    final value = event.snapshot.value;
    final queue = value is Map
        ? Map<String, dynamic>.from(jsonDecode(jsonEncode(value)) as Map)
        : <String, dynamic>{};

    // The roster is only ever repainted while we are actually standing in the
    // queue.
    //
    // A seal empties the queue and hands out the assignments in ONE atomic
    // write, and the two listeners that carry those halves fire in no
    // guaranteed order. Repainting from the queue half shows the player their
    // table dissolving — everyone but themselves wiped from the grid — a beat
    // before the game page opens on those very same opponents. Freezing here
    // keeps the last true roster on screen until [_consumeAssignment] replaces
    // it with the actual seating.
    //
    // Our entry can also go missing without any seal: an `onDisconnect` armed
    // by an earlier, already-dead connection fires late and removes the path we
    // have just rewritten. One re-assert closes that window, and it is the only
    // recovery path this implementation needs.
    if (!queue.containsKey(LocalStorageService.uid)) {
      unawaited(_reassertQueueEntry());
      return;
    }

    _emitPlayersFound(_rosterFrom(queue));
  }

  /// The uids the waiting screen may list: those whose entry accepts at least
  /// one of the modes we accept.
  ///
  /// A pool key is a plain namespace — every mode of a given table size waits
  /// in the SAME queue, and the server seats only players who agree on one
  /// mode (`pickBatch`). Listing the whole queue therefore promised opponents
  /// the seal could never deliver: a player who had picked another mode
  /// appeared in the grid, counted toward "N players found", and the table
  /// then left without them, with nothing on screen to explain it. The grid
  /// now shows exactly who we could actually be seated with.
  Set<String> _rosterFrom(Map<String, dynamic> queue) {
    final mine = remoteUtility.matchmakingSettings.queueModes.toSet();
    final myUid = LocalStorageService.uid;

    return {
      for (final entry in queue.entries)
        // Our own entry is never filtered out: we are in the room by
        // definition, and a half-written entry of ours must not make us
        // disappear from our own grid.
        if (entry.key == myUid || _modesOf(entry.value).any(mine.contains))
          entry.key,
    };
  }

  /// Modes a queue entry accepts, read exactly as the server reads them: an
  /// entry with no usable `modes` list was written before the field existed
  /// and counts as the pool's single default mode.
  List<String> _modesOf(Object? entry) {
    if (entry is! Map) return const ["default"];
    final modes = entry["modes"];
    if (modes is! List || modes.isEmpty) return const ["default"];
    return [for (final mode in modes) mode.toString()];
  }

  /// Puts our entry back after it vanished without us leaving.
  Future<void> _reassertQueueEntry() async {
    if (_reassertingQueueEntry || _consumingAssignment) return;
    final ref = _queueEntryRef;
    if (ref == null) return;

    _reassertingQueueEntry = true;
    try {
      // Let it settle first: the overwhelmingly likely reason our entry just
      // left the queue is that the server sealed us into a game, and the
      // assignment is on its way. Re-queueing over that would undo the very
      // invariant this class relies on.
      await Future.delayed(const Duration(seconds: 2));
      if (isClosed || _launching || _consumingAssignment) return;
      if (!identical(_queueEntryRef, ref)) return;

      final assignment = await FirebaseDatabase.instance
          .ref("assignments/${LocalStorageService.uid}")
          .get()
          .timeout(const Duration(seconds: 5));
      if (assignment.exists) {
        await _consumeAssignment(assignment.value);
        return;
      }

      final current = await ref.get().timeout(const Duration(seconds: 5));
      if (current.exists || isClosed || _launching) return;
      if (!identical(_queueEntryRef, ref)) return;

      debugPrint("🔍 [MM] queue entry vanished → re-asserting");
      await ref.onDisconnect().remove();
      await ref.set(_queueEntry());
    } catch (_) {
    } finally {
      _reassertingQueueEntry = false;
    }
  }

  /// Turns an assignment into a launch — or throws it away.
  ///
  /// The assignment is a pointer, never the truth: `games/<id>` decides. That
  /// is what keeps a stale mailbox (a game long finished, one swept by the
  /// cleanup, or one whose table already struck us out) from dragging us into
  /// a hand nobody dealt us.
  Future<bool> _consumeAssignment(Object? raw) async {
    if (isClosed || _launching || _consumingAssignment) return false;
    if (raw is! Map) return false;

    final data = Map<String, dynamic>.from(jsonDecode(jsonEncode(raw)) as Map);
    final assignedGameId = data["game_id"]?.toString() ?? "";
    if (assignedGameId.isEmpty) return false;
    // Already judged too old to walk back into, at the top of this search.
    if (assignedGameId == _discardedGameId) return false;

    _consumingAssignment = true;
    try {
      Map<String, dynamic> game;
      try {
        final snapshot = await FirebaseDatabase.instance
            .ref("games/$assignedGameId")
            .get()
            .timeout(const Duration(seconds: 5));
        final value = snapshot.value;
        if (value == null) {
          // The game is gone for good (swept, or never written).
          await _dropAssignment();
          return false;
        }
        if (value is! Map) return false;
        game = Map<String, dynamic>.from(jsonDecode(jsonEncode(value)) as Map);
      } catch (_) {
        // Could not check: keep the assignment rather than discard a game we
        // may well be part of. A later event, or the next search, retries.
        return false;
      }

      if (game["status"]?.toString() != "STARTED" || game["finished"] == true) {
        await _dropAssignment();
        return false;
      }

      final seats = Map<String, dynamic>.from(
        game["players"] as Map? ?? <String, dynamic>{},
      );
      // Placeholder seats carry a synthetic `bot_<key>` id and no account
      // behind them: they must not count as real players, or a table finished
      // against bots would be rewarded as a full human match.
      final realIds = seats.values
          .whereType<Map>()
          .map((p) => p["user_id"]?.toString())
          .whereType<String>()
          .where((id) => !id.startsWith("bot_"))
          .toSet();

      if (!realIds.contains(LocalStorageService.uid)) {
        // Seated without us — the table has moved on. Back to the pool.
        await _dropAssignment();
        return false;
      }

      // Show the table itself, not the queue it came out of: everyone who is
      // about to play, together, for the whole exit transition. The profiles
      // of these players were resolved while they were waiting in the pool, so
      // this repaints from cache — no blank cards, no network round trip on
      // the way to the game page.
      unawaited(_emitPlayersFound(realIds));

      creator = game["host"]?.toString() == LocalStorageService.uid;
      gameId = assignedGameId;
      matchedMode = data["mode"]?.toString() ?? game["mode"]?.toString();

      debugPrint("🔍 [MM] assignment → launching $gameId (host=$creator)");

      await _leavePool();
      launchGame(fakeOpponent: realIds.length < 2);
      // Consumed only once the launch is under way: a crash before this point
      // leaves the mailbox intact, and the player walks back into their game
      // on the next launch instead of losing it.
      await _dropAssignment();
      return true;
    } finally {
      _consumingAssignment = false;
    }
  }

  Future<void> _dropAssignment() async {
    try {
      await FirebaseDatabase.instance
          .ref("assignments/${LocalStorageService.uid}")
          .remove();
    } catch (_) {}
  }

  /// Counts `seal_at` down for the UI. Reaching zero does nothing: the server
  /// owns the deadline, and this stops merely so the screen does not show a
  /// countdown running into negative numbers while the seal lands.
  void _startSealTicker(int sealAt) {
    _sealTicker?.cancel();

    void tick() {
      if (isClosed || _launching) {
        _stopSealTicker();
        return;
      }
      final remaining = ((sealAt - _serverNowMs) / 1000).ceil();
      if (remaining <= 0) {
        _stopSealTicker();
        unawaited(_nudgeAfterDeadline(sealAt));
        return;
      }
      if (state.countdownRemaining != remaining) {
        emit(state.copyWith(countdownRemaining: () => remaining));
      }
    }

    tick();
    _sealTicker = Timer.periodic(const Duration(seconds: 1), (_) => tick());
  }

  /// Pokes the pool once when a deadline passes and no table appears.
  ///
  /// The server owns the countdown, and the Cloud Task it queues is what seals
  /// the pool — but that enqueue is deliberately swallowed server-side (a
  /// failed queueing must not wedge the write that preceded it), and a task can
  /// be lost. The deadline then sits in the past with nothing left to act on
  /// it: only a write under `queue` arms another, and a pool where everyone is
  /// simply waiting produces none. On a quiet infinite pool that is a wait with
  /// no end.
  ///
  /// So: one harmless write on our own entry, `joined_at` untouched — our place
  /// in the queue is exactly where it was — and the server re-reads the pool
  /// and decides, as always. Once per deadline, and never if our entry has
  /// gone: an `update` on a removed path would RECREATE it, and an entry
  /// carrying no `joined_at` is a phantom player for the next batch.
  Future<void> _nudgeAfterDeadline(int sealAt) async {
    if (_nudgedSealAt == sealAt) return;
    _nudgedSealAt = sealAt;

    await Future.delayed(const Duration(seconds: 8));

    if (isClosed || _launching || _consumingAssignment) return;
    final ref = _queueEntryRef;
    if (ref == null) return;

    try {
      final current = await ref.get().timeout(const Duration(seconds: 5));
      if (!current.exists || isClosed || _launching || _consumingAssignment) {
        return;
      }
      if (!identical(_queueEntryRef, ref)) return;

      debugPrint("🔍 [MM] deadline passed with no table → nudging the pool");
      await ref.update({"nudged_at": ServerValue.timestamp});
    } catch (_) {}
  }

  void _stopSealTicker() {
    _sealTicker?.cancel();
    _sealTicker = null;
    if (!isClosed && state.countdownRemaining != null) {
      emit(state.copyWith(countdownRemaining: () => null));
    }
  }

  void launchGame({bool fakeOpponent = false}) {
    if (isClosed || _launching) return;
    _launching = true;
    _stopSealTicker();

    emit(
      state.copyWith(
        status: RemoteGameStatus.success,
        creator: () => creator,
        gameId: gameId,
        fakeOpponent: fakeOpponent,
      ),
    );
  }

  Future<void> abortGame() async {
    await _leavePool();

    // Assigned a table, then walked away before reaching it — the back
    // button stays live through the transition on purpose (see
    // GamicoRemotePage's `animGame && !finalized` branch).
    //
    // Two things have to happen, and neither is optional:
    //
    //  * the mailbox is emptied. It normally is, right after the launch, but
    //    a deliberate exit can land in that window — and an assignment left
    //    behind is not inert: the next search reads it first and walks the
    //    player straight back into the very game they just left.
    //  * the table is told. Without the EXIT, the seat stays occupied by
    //    somebody who will never answer, and the others burn the full 20 s
    //    readiness grace on them. `_leftIds` is exactly what the game layer
    //    checks before seating a player (see the pre-deal unseating in
    //    CrazyEightsRemoteSession).
    //
    // `gameId` is only ever set by [_consumeAssignment], so an ordinary
    // cancellation from the waiting screen does none of this.
    if (gameId.isNotEmpty) {
      await _dropAssignment();
      try {
        await gamesRepository.addGameEvent(
          gameId,
          GamicoGameEventModel(type: "EXIT", userId: LocalStorageService.uid),
        );
      } catch (_) {}
    }
  }

  @override
  Future<void> close() async {
    GamicoDatabaseShutdown.unregister(this);

    _stopSealTicker();
    await abortGame();

    _serverTimeOffsetSubscription?.cancel();

    return super.close();
  }
}
