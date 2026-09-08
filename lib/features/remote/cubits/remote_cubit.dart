import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/models/gamico_game_model.dart';
import 'package:gamico/commons/services/database_shutdown.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:gamico/commons/services/layout.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/models/remote_utility.dart';
import 'package:gamico/commons/repositories/gamico_games_repository.dart';
import 'package:gamico/commons/settings/matchmaking_migration.dart';

part 'remote_state.dart';

/// One lobby room a search occupies.
///
/// A normal search holds exactly one; a "no preference" search
/// ([MatchmakingSettings.modes]) holds one per candidate mode and launches
/// with whichever room fills first, withdrawing from the others.
class _LobbyAttempt {
  _LobbyAttempt(this.mode);

  /// Pool mode this room is keyed on (null falls back to "default").
  final String? mode;

  /// Fixed database path of the lobby room this attempt gathers in.
  String roomKey = "";

  /// Our own slot key inside the lobby room.
  String playerKey = "";

  /// Id of the real game this attempt's lobby will graduate into (a fresh
  /// push key generated when the room is first created and carried by the
  /// room so every occupant agrees on it).
  String gameId = "";

  /// Uids currently gathered in this room (drives the "players found" count).
  Set<String> playerIds = {};

  /// Live subscription to the lobby room (players count + graduation).
  StreamSubscription<DatabaseEvent>? roomSubscription;

  /// Live subscription to the graduated game node — the single authoritative
  /// signal that the match has started, for every player alike.
  StreamSubscription<DatabaseEvent>? gameSubscription;

  /// Active countdown timer for infinite mode batch graduation.
  Timer? countdownTimer;

  /// Timestamp (ms) when the countdown timer for this attempt ends.
  int? countdownEndAt;

  /// The `countdown_end_at` the ticker was last armed for, kept across the
  /// ticker being stopped (unlike [countdownEndAt]) so a revival of the very
  /// same countdown is told apart from a genuinely new batch.
  int? armedCountdownEndAt;

  /// How many times the countdown of [armedCountdownEndAt] has been revived
  /// after an expiry that extracted nothing (see
  /// [RemoteCubit._reviveCountdown]). Bounded so a room that cannot be
  /// extracted from never turns the safety net into a poll.
  int countdownRevivals = 0;

  /// Removes only our own slot from this room if we disconnect while still
  /// waiting.
  OnDisconnect? disconnectionReference;

  /// Whether a deferred "did this game actually start without telling us?"
  /// check is currently scheduled for this room, and how many have already
  /// run (see [RemoteCubit._verifyLaunchLater]). Bounded so a room that keeps
  /// churning cannot turn the safety net into a poll.
  bool launchVerificationArmed = false;
  int launchVerifications = 0;

  /// Drops everything this attempt listens to locally, *without* touching the
  /// server-side [disconnectionReference].
  ///
  /// [OnDisconnect.cancel] is not a local operation: it tells the server to
  /// forget the "reap this slot when the socket dies" instruction. Calling it
  /// while merely detaching listeners is how a slot outlives its player.
  void cancelLocalListeners() {
    countdownTimer?.cancel();
    countdownTimer = null;
    countdownEndAt = null;
    armedCountdownEndAt = null;
    countdownRevivals = 0;
    roomSubscription?.cancel();
    roomSubscription = null;
    gameSubscription?.cancel();
    gameSubscription = null;
  }

  /// Local listeners *and* the server-side reaping instruction. Only for a
  /// slot that is being removed explicitly (or has already left the room).
  void cancelSubscriptions() {
    cancelLocalListeners();
    disconnectionReference?.cancel();
    disconnectionReference = null;
  }
}

/// Cubit for managing the remote game mode.
///
/// ## Matchmaking model
///
/// Players looking for the same game converge on a single, deterministic
/// **lobby room** at a fixed database path derived from the mode and level
/// range (e.g. `matchmakings/mm_crazy_eights_4_elimination_000_050`). A single
/// create-or-join **transaction** on that node makes gathering race-free: even
/// if several players start searching at the exact same instant, Firebase
/// serialises their transactions, so they all land in the same room instead of
/// each spawning a private game that never meets the others.
///
/// When the room reaches the required player count the transaction flips its
/// status to `STARTED`, and the room **graduates**: its players are copied into
/// a brand new `games/{pushKey}` node (the structure the rest of the app
/// consumes) and everyone launches into it. The fixed room is then free to be
/// reused (overwritten) by the next batch of players.
///
/// The lobby host is the player holding the smallest (chronologically first)
/// player key among those actually present at graduation, so a player leaving
/// the waiting room — the creator included — only ever removes their own slot
/// and never tears the room down for the others.
///
/// ## "No preference" searches
///
/// When [MatchmakingSettings.modes] lists several candidate pools, the player
/// waits in every one of them at once (one [_LobbyAttempt] per pool) and plays
/// in whichever fills first. Committing to a room immediately withdraws the
/// player from every other room, so the remaining batches stop counting a
/// player who is already gone. The pool that won is exposed as [matchedMode]
/// so the launched game knows which mode it is actually playing.
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
  /// Deliberately [_LobbyAttempt.cancelLocalListeners], not
  /// `cancelSubscriptions`. This runs on `AppLifecycleState.detached` — the
  /// player swiping the app away from the waiting screen — and the latter
  /// cancels the slot's `onDisconnect`, i.e. the one and only thing that was
  /// going to remove that slot from the lobby room once the socket died. The
  /// slot then stays in the room for good: it arms the infinite pool's
  /// countdown with the next real player who shows up, gets graduated
  /// alongside them, and that player waits out the readiness roll-call for a
  /// table whose second seat belongs to a process that no longer exists. This
  /// registry exists to stop native RTDB events reaching a dying engine —
  /// nothing more.
  Future<void> cancelDatabaseListeners() async {
    for (final attempt in _attempts) {
      attempt.cancelLocalListeners();
    }
    // Same rule as above for the server-driven path: the listeners go, the
    // queue entry's `onDisconnect` stays — it is the only thing that will take
    // our seat out of the pool once this process is gone.
    await _assignmentSubscription?.cancel();
    _assignmentSubscription = null;
    await _queueSubscription?.cancel();
    _queueSubscription = null;
    await _sealSubscription?.cancel();
    _sealSubscription = null;
    _sealTicker?.cancel();
    _sealTicker = null;
    await _connectedSubscription?.cancel();
    _connectedSubscription = null;
    await _serverTimeOffsetSubscription?.cancel();
    _serverTimeOffsetSubscription = null;
  }

  /// Reference to the games repository.
  final GamicoGamesRepository gamesRepository;

  final GamicoUserCubit userCubit;

  final RemoteUtility remoteUtility;

  final String? receiverId;
  final String? senderId;

  bool get dirtyStateForFakeGame {
    return isClosed || !createdGameStatus.contains("PENDING");
  }

  bool? creator;

  /// Id of the real game we launched (the winning attempt's game).
  String gameId = "";

  /// Pool mode of the room the launched game actually came from. Equals the
  /// configured single mode for normal searches; resolves the winning pool for
  /// "no preference" searches.
  String? matchedMode;

  /// The lobby rooms this search currently occupies (a single-mode search has
  /// exactly one).
  final List<_LobbyAttempt> _attempts = [];

  /// The room we committed to once it filled; every other room is withdrawn
  /// from at that instant.
  _LobbyAttempt? _chosen;

  /// Watches `.info/connected` while gathering: Android drops the database
  /// connection almost as soon as the app is backgrounded (answering a message
  /// is enough), which fires the onDisconnect and reaps our slots. On every
  /// reconnection the slots are re-asserted so a quick app switch doesn't
  /// silently kick the player out of matchmaking.
  StreamSubscription<DatabaseEvent>? _connectedSubscription;

  /// Estimated offset between local clock and Firebase server time.
  int _serverTimeOffset = 0;
  StreamSubscription<DatabaseEvent>? _serverTimeOffsetSubscription;

  /// Current time synchronized across all devices using Firebase server time.
  int get _serverNowMs =>
      DateTime.now().millisecondsSinceEpoch + _serverTimeOffset;

  /// The subscription above replays the current state on attach; only the
  /// events after that first `true` are actual reconnections.
  bool _sawInitialConnected = false;

  /// Guards against overlapping slot restorations.
  bool _restoring = false;

  String createdGameStatus = "";

  /// Guards a single graduation write per search.
  bool _graduated = false;

  /// Delay requested by [enableBotFallback], kept across [reset] so every
  /// subsequent search re-arms on its own.
  Duration? _botFallbackDelay;

  /// [state.searchGeneration] the bot fallback is currently armed for.
  ///
  /// Guards a single arming *per search*, not per cubit: a rematch goes
  /// through [reset], which starts a brand-new search on the same cubit, and
  /// a one-shot boolean left that second search waiting forever on a table
  /// that could no longer fill.
  int? _botFallbackGeneration;

  /// Guards a single launch (the game-node listener can fire more than once).
  bool _launching = false;

  /// Whether this search is already bound to a starting game and must not
  /// join, restore or fake anything anymore.
  bool get _committed => _chosen != null || _launching;

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

    for (final attempt in _attempts) {
      attempt.cancelSubscriptions();
    }
    _attempts.clear();
    _connectedSubscription?.cancel();
    _serverTimeOffsetSubscription?.cancel();

    gameId = "";
    matchedMode = null;
    _chosen = null;
    _graduated = false;
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

    // The previous arming is bound to the previous `searchGeneration` and has
    // already bailed out; this search needs its own countdown.
    unawaited(_armBotFallback());
  }

  /// Candidate pool modes of this search: the explicit "no preference" list,
  /// or the single configured mode.
  List<String?> get _candidateModes {
    final settings = remoteUtility.matchmakingSettings;
    final modes = settings.modes;
    if (modes != null && modes.isNotEmpty) return List<String?>.from(modes);
    return [settings.mode];
  }

  /// Builds the fixed lobby-room key for [mode] and the current level range.
  /// Every player sharing the same matchmaking settings produces the same key
  /// and so converges on the same room.
  String _buildRoomKey(String? mode) {
    final settings = remoteUtility.matchmakingSettings;

    final width = settings.maxLevel.toString().length < 3
        ? 3
        : settings.maxLevel.toString().length;
    String pad(int value) => value.toString().padLeft(width, "0");
    final levelRange = "${pad(settings.minLevel)}_${pad(settings.maxLevel)}";

    final modePart = _sanitizeKey(mode ?? "default");
    final levelPart = state.level != null ? "_lvl${state.level}" : "";

    return "$modePart${levelPart}_$levelRange";
  }

  /// Strips characters Firebase forbids in a path key.
  String _sanitizeKey(String value) {
    return value.replaceAll(RegExp(r'[.#$/\[\]\s]'), '_');
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

    // Bound *before* the first join, and never after it: the infinite pool's
    // `countdown_end_at` is an absolute timestamp written from [_serverNowMs]
    // inside the join transaction itself. Attached afterwards, as it used to
    // be, the very first join of a session always armed the countdown from the
    // raw device clock — a phone a few minutes fast then parks every other
    // player in the room under a countdown minutes long.
    _bindServerTimeOffset();

    // Server-driven matchmaking: one queue entry, three listeners, and not a
    // single decision taken here. Everything below this line is the legacy
    // client-arbitrated path, kept intact for builds older than the cutover.
    if (MatchmakingMigration.useServer) {
      await _enterPool();
      return;
    }

    // Join the candidate rooms one by one, stopping early when a join already
    // started a game — no point queueing in rooms we would leave immediately.
    for (final mode in _candidateModes) {
      if (isClosed || _committed) return;
      await _joinLobby(mode);
    }

    if (isClosed || _committed) return;

    // Self-healing presence: whenever the database connection is lost then
    // re-established (backgrounded app, network blip…), our slots — reaped by
    // the onDisconnects — are put back, so waiting players survive a quick
    // trip outside the app.
    _sawInitialConnected = false;
    _connectedSubscription?.cancel();
    _connectedSubscription = FirebaseDatabase.instance
        .ref(".info/connected")
        .onValue
        .listen((event) {
          if (event.snapshot.value != true) return;
          if (!_sawInitialConnected) {
            // Attach-time replay of the current state: we just registered.
            _sawInitialConnected = true;
            return;
          }
          _restoreLobbySlots();
        });

    // 2-player pools fall back to a bot if nobody shows up in time.
    if (!remoteUtility.isDeveloper &&
        !appScreenshots &&
        Gamico.instance.playSettings?.enableFakeOpponent == true) {
      _manageFakeGame();
    }
  }

  /// Keeps [_serverNowMs] in step with Firebase's clock.
  ///
  /// The offset was read as `is int`, and `.info/serverTimeOffset` is served
  /// as a double: the test never passed, so the offset stayed at zero for the
  /// whole session and every timestamp this cubit wrote or compared was in
  /// fact raw device time. That is what makes two phones disagree on how long
  /// an infinite pool's countdown still has to run.
  void _bindServerTimeOffset() {
    _serverTimeOffsetSubscription?.cancel();
    _serverTimeOffsetSubscription = FirebaseDatabase.instance
        .ref(".info/serverTimeOffset")
        .onValue
        .listen((event) {
          final value = event.snapshot.value;
          if (value is! num) return;
          _serverTimeOffset = value.toInt();
          _serverTimeSynced = true;
        });
  }

  void _stopCountdownTimer([_LobbyAttempt? attempt]) {
    if (attempt == null) _sealTicker?.cancel();
    if (attempt != null) {
      attempt.countdownTimer?.cancel();
      attempt.countdownTimer = null;
      attempt.countdownEndAt = null;
    } else {
      for (final a in _attempts) {
        a.countdownTimer?.cancel();
        a.countdownTimer = null;
        a.countdownEndAt = null;
      }
    }
    if (!isClosed && state.countdownRemaining != null) {
      emit(state.copyWith(countdownRemaining: () => null));
    }
  }

  void _handleInfiniteCountdown(
    _LobbyAttempt attempt,
    DatabaseReference roomRef,
    Map<String, dynamic> data,
  ) {
    final rawEndAt = data["countdown_end_at"];
    final countdownEndAt = (rawEndAt as num?)?.toInt();
    final players = Map<String, dynamic>.from(
      data["players"] as Map? ?? <String, dynamic>{},
    );

    if (countdownEndAt == null || players.length < 2) {
      _stopCountdownTimer(attempt);
      if (countdownEndAt != null && players.length < 2) {
        _clearStaleCountdown(roomRef, countdownEndAt);
      }
      return;
    }

    _startCountdownTicker(attempt, roomRef, countdownEndAt);
  }

  /// Drops a countdown left behind by a batch that emptied out, without ever
  /// touching a fresh one.
  ///
  /// This used to be a blind `remove()` on the child. A second player joining
  /// in that same instant arms the countdown inside their join transaction —
  /// and the blind remove, racing right behind them, erased it. Nothing ever
  /// re-arms it (only a *join* does, and the room already has its two
  /// players), so both of them sat in a full-enough room that would never
  /// start until a third player happened to join. Scoped to the room node so
  /// it is serialised against those joins, and conditional on the value we
  /// actually saw being stale.
  Future<void> _clearStaleCountdown(
    DatabaseReference roomRef,
    int staleCountdownEndAt,
  ) async {
    try {
      await roomRef.runTransaction((current) {
        if (current == null) return Transaction.abort();
        final room = Map<String, dynamic>.from(current as Map);

        final endAt = (room["countdown_end_at"] as num?)?.toInt();
        // Already gone, or replaced by the countdown of a newer batch.
        if (endAt == null || endAt != staleCountdownEndAt) {
          return Transaction.abort();
        }

        final players = Map<String, dynamic>.from(
          room["players"] as Map? ?? <String, dynamic>{},
        );
        // Somebody joined meanwhile: this countdown is live again.
        if (players.length >= 2) return Transaction.abort();

        room.remove("countdown_end_at");
        return Transaction.success(room);
      }, applyLocally: false);
    } catch (_) {}
  }

  void _startCountdownTicker(
    _LobbyAttempt attempt,
    DatabaseReference roomRef,
    int rawCountdownEndAt,
  ) {
    // A `countdown_end_at` further out than any this pool ever arms was
    // written by a device whose clock runs ahead of the server's: the value is
    // an absolute timestamp produced from [_serverNowMs], and the client that
    // arms it does so inside its *first* join transaction, i.e. possibly
    // before it has ever learnt the server offset. Read literally, a phone a
    // few minutes fast parks everyone else in the room under a countdown
    // minutes long — the whole pool stops starting games. Clamping is safe:
    // the extraction only ever requires two players, never a specific instant.
    final ceiling = _serverNowMs + (_maxCountdownSeconds * 1000);
    final countdownEndAt = rawCountdownEndAt > ceiling
        ? ceiling
        : rawCountdownEndAt;

    if (attempt.countdownEndAt == countdownEndAt &&
        attempt.countdownTimer != null) {
      return;
    }

    // A brand-new batch gets a fresh revival budget; re-driving the very same
    // countdown (see [_reviveCountdown]) deliberately keeps spending the
    // current one.
    if (attempt.armedCountdownEndAt != countdownEndAt) {
      attempt.armedCountdownEndAt = countdownEndAt;
      attempt.countdownRevivals = 0;
    }

    attempt.countdownTimer?.cancel();
    attempt.countdownEndAt = countdownEndAt;

    Future<void> updateTicker() async {
      if (isClosed || _committed) {
        _stopCountdownTimer(attempt);
        return;
      }

      final now = _serverNowMs;
      final diffMs = countdownEndAt - now;
      final remaining = (diffMs / 1000).ceil();

      if (remaining <= 0) {
        _stopCountdownTimer(attempt);
        var extracted = false;
        try {
          String? matchedGameId;
          Map<String, dynamic>? matchedPlayers;

          final result = await roomRef.runTransaction((current) {
            // Reset on every invocation: the handler runs once against the
            // local cache and again against the server value, and only the
            // last run describes what was actually committed. Leaving the
            // previous run's batch behind is what let a speculative snapshot
            // — taken before the last player joined — reach _graduateBatch.
            matchedGameId = null;
            matchedPlayers = null;

            if (current == null) return Transaction.abort();
            final room = Map<String, dynamic>.from(current as Map);
            final currentPlayers = Map<String, dynamic>.from(
              room["players"] as Map? ?? <String, dynamic>{},
            );
            if (currentPlayers.length < 2) return Transaction.abort();

            matchedGameId = room["next_game_id"]?.toString() ?? attempt.gameId;
            matchedPlayers = Map<String, dynamic>.from(currentPlayers);
            room["players"] = <String, dynamic>{};
            room["next_game_id"] =
                FirebaseDatabase.instance.ref("games").push().key ?? "";
            room.remove("countdown_end_at");
            return Transaction.success(room);
          });

          // Every client of the room ticks this countdown down at the same
          // second, but exactly one transaction wins and extracts the batch;
          // the losers abort. Only the winner may seat the batch — a loser
          // graduating from its own (necessarily stale) view of the room
          // would overwrite games/<id>/players with a subset of it, and the
          // player it dropped launches into a hand nobody dealt them.
          if (result.committed == true &&
              matchedGameId != null &&
              matchedPlayers != null &&
              matchedPlayers!.length >= 2) {
            extracted = true;
            await _graduateBatch(attempt, matchedGameId!, matchedPlayers!);
          }
        } catch (_) {}

        // Nothing left this room. Either somebody else won the extraction —
        // in which case the room moved on and the game node speaks for us —
        // or the transaction threw / aborted and the room is still sitting
        // there, players and all, under a countdown that has already ended.
        // The ticker has just cancelled itself, and only a *room event* can
        // ever start another one: in the second case none is coming, so both
        // players wait under a dead countdown until somebody else happens to
        // join. Go and ask the room what actually happened.
        if (!extracted) unawaited(_reviveCountdown(attempt, roomRef));
      } else {
        if (state.countdownRemaining != remaining) {
          emit(state.copyWith(countdownRemaining: () => remaining));
        }
      }
    }

    updateTicker();
    attempt.countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      updateTicker();
    });
  }

  /// Whether [_serverTimeOffset] has actually been delivered by Firebase.
  ///
  /// [_pruneStale] compares timestamps across devices and must not run off an
  /// unsynced clock: a phone running an hour fast would read every live slot
  /// in the room as stale and evict the lot.
  bool _serverTimeSynced = false;

  /// Drops slots left behind by clients that died without a clean disconnect,
  /// in place, and says whether anything was removed.
  ///
  /// A slot is normally reaped by its own `onDisconnect` when the socket dies,
  /// and that covers the ordinary cases. It does not cover a process that
  /// disappears between the join transaction committing and the `onDisconnect`
  /// being registered, nor slots left by builds that used to cancel that
  /// `onDisconnect` on `AppLifecycleState.detached` (see
  /// [cancelDatabaseListeners]). Nothing else in this file ever removed a slot
  /// it did not own, so a single such ghost poisoned its room permanently: in
  /// an infinite pool it is a second "player" for the countdown to arm on, so
  /// the next real searcher is batched with it and graduated into a table
  /// whose other seat belongs to nobody.
  ///
  /// Deliberately generous, and deliberately never applied to the caller's own
  /// slot. `joined_at_ms` is server-referenced, so [_staleSlotMs] can be tight;
  /// slots written before it existed only carry a local-time `created_at`,
  /// which is compared against a margin no live search can ever reach.
  bool _pruneStale(Map<String, dynamic> players) {
    if (!_serverTimeSynced) return false;

    final nowMs = _serverNowMs;
    var pruned = false;

    players.removeWhere((key, value) {
      if (value is! Map) return false;
      if (value["user_id"]?.toString() == LocalStorageService.uid) return false;

      final joinedAtMs = (value["joined_at_ms"] as num?)?.toInt();
      if (joinedAtMs != null) {
        // A slot stamped in the future is a clock we cannot trust: leave it.
        if (joinedAtMs > nowMs) return false;
        if (nowMs - joinedAtMs < _staleSlotMs) return false;
        pruned = true;
        return true;
      }

      final createdAt = DateTime.tryParse(
        value["created_at"]?.toString() ?? "",
      );
      if (createdAt == null) return false;
      final ageMs =
          DateTime.now().millisecondsSinceEpoch -
          createdAt.millisecondsSinceEpoch;
      if (ageMs < _legacyStaleSlotMs) return false;
      pruned = true;
      return true;
    });

    return pruned;
  }

  /// How long a slot carrying a server-referenced `joined_at_ms` may sit in a
  /// room before it is treated as abandoned (10 minutes).
  static const int _staleSlotMs = 10 * 60 * 1000;

  /// Same, for slots that only carry a local-time `created_at` and so can only
  /// be aged against the reader's own clock (1 hour — well past any skew, and
  /// well past any search a human is still watching).
  static const int _legacyStaleSlotMs = 60 * 60 * 1000;

  /// Rooms with a "our slot vanished" recovery already in flight, keyed by the
  /// slot key, so a burst of room events queues exactly one.
  final Set<String> _seatRecoveries = {};

  /// Re-reads the room and, if our slot really is missing from the batch we
  /// are supposed to be gathering with, queues up again.
  ///
  /// Confirmed against the server before acting: a room event can carry the
  /// optimistic local application of one of our own transactions (the
  /// extraction ticker does not write with `applyLocally: false`), and those
  /// briefly show a room we are not in.
  Future<void> _ensureSeatedInRoom(
    _LobbyAttempt attempt,
    DatabaseReference roomRef,
  ) async {
    if (attempt.playerKey.isEmpty) return;
    if (!_seatRecoveries.add(attempt.playerKey)) return;

    try {
      await Future.delayed(const Duration(seconds: 2));
      if (isClosed || _committed || _launching) return;
      if (!_attempts.contains(attempt)) return;

      Object? value;
      try {
        final snapshot = await roomRef.get().timeout(
          const Duration(seconds: 5),
        );
        value = snapshot.value;
      } catch (_) {
        return;
      }

      if (isClosed || _committed || _launching) return;
      if (!_attempts.contains(attempt)) return;
      if (value is! Map) return;

      final data = Map<String, dynamic>.from(
        jsonDecode(jsonEncode(value)) as Map,
      );
      // The room moved on: that is the graduated-batch path, handled by the
      // game node and [_verifyLaunchLater], not by a rejoin from here.
      if (data["next_game_id"]?.toString() != attempt.gameId) return;

      final players = Map<String, dynamic>.from(
        data["players"] as Map? ?? <String, dynamic>{},
      );
      if (players.containsKey(attempt.playerKey)) return;

      debugPrint(
        "🔍 [MM] our slot vanished from ${attempt.roomKey} → rejoining pool",
      );
      _rejoin(attempt);
    } finally {
      _seatRecoveries.remove(attempt.playerKey);
    }
  }

  /// Longest countdown this pool can legitimately arm (10s at two players),
  /// plus a margin for clock jitter. See [_startCountdownTicker].
  static const int _maxCountdownSeconds = 12;

  /// How many times a single countdown may be re-driven after an expiry that
  /// extracted nothing.
  static const int _maxCountdownRevivals = 3;

  /// Re-reads the room shortly after a countdown expiry that extracted no
  /// batch, and hands the fresh snapshot back to the normal room logic.
  ///
  /// The infinite pool's ticker is a one-shot: it cancels itself the instant
  /// it reaches zero, and the only thing that can ever start another one is a
  /// room event. That is fine when the expiry actually changed the room — the
  /// winner empties it and everybody hears about it — but not when our
  /// extraction simply failed: a connection blip in that exact instant makes
  /// `runTransaction` throw (swallowed), and an abort on a room that nobody
  /// else extracted either leaves the room untouched. Untouched means no
  /// event, no event means no ticker, and the players sit in a room holding a
  /// `countdown_end_at` in the past — visibly "En attente de joueurs" with the
  /// countdown gone — until an unrelated player happens to join. One read is
  /// enough to put the room back in charge.
  Future<void> _reviveCountdown(
    _LobbyAttempt attempt,
    DatabaseReference roomRef,
  ) async {
    if (attempt.countdownRevivals >= _maxCountdownRevivals) return;
    attempt.countdownRevivals++;

    await Future.delayed(const Duration(seconds: 2));

    if (isClosed || _committed || _launching) return;
    if (!_attempts.contains(attempt)) return;

    Object? value;
    try {
      final snapshot = await roomRef.get().timeout(const Duration(seconds: 5));
      value = snapshot.value;
    } catch (_) {
      return;
    }

    if (value == null || isClosed || _committed || _launching) return;
    if (!_attempts.contains(attempt)) return;

    final data = Map<String, dynamic>.from(
      jsonDecode(jsonEncode(value)) as Map,
    );

    // Our batch left the room while we were not looking: the game node is the
    // only thing that can still speak for us, so make sure somebody asks it.
    if (data["next_game_id"]?.toString() != attempt.gameId) {
      debugPrint("🔍 [MM] reviveCountdown: room moved on → verifying launch");
      unawaited(_verifyLaunchLater(attempt));
      return;
    }

    debugPrint("🔍 [MM] reviveCountdown: re-driving the room's countdown");
    _handleInfiniteCountdown(attempt, roomRef, data);
  }

  /// Creates-or-joins the lobby room for [mode] and wires its listeners.
  ///
  /// [retry] counts the consecutive failed attempts at this same room, and
  /// only paces the retries (see [_retryJoinLobby]) — the search never gives
  /// up on its own.
  Future<void> _joinLobby(String? mode, [int retry = 0]) async {
    if (isClosed || _committed) return;

    final db = FirebaseDatabase.instance;
    final settings = remoteUtility.matchmakingSettings;
    final isInfinite = settings.isInfinite || settings.maxPlayers == 0;
    final required = isInfinite ? 12 : (settings.maxPlayers ?? 2);

    final attempt = _LobbyAttempt(mode);
    attempt.roomKey = _buildRoomKey(mode);
    final roomRef = db.ref("matchmakings/${attempt.roomKey}");

    attempt.playerKey = db.ref().push().key ?? "";
    // Pre-generated id of the real game this lobby will graduate into.
    final freshGameId = db.ref("games").push().key ?? "";
    _attempts.add(attempt);

    final now = DateTime.now().toString();
    Map<String, dynamic> buildMyPlayer() => <String, dynamic>{
      "user_id": LocalStorageService.uid,
      "status": "ACCEPTED",
      "created_at": now,
      "updated_at": now,
      // Server-referenced, unlike `created_at` (a local-time string): this is
      // the only timestamp two devices can actually compare. See [_pruneStale].
      "joined_at_ms": _serverNowMs,
    };

    // Map<String, dynamic> buildFreshRoom() => <String, dynamic>{
    //   "status": "PENDING",
    //   "created_at": now,
    //   "next_game_id": freshGameId,
    //   "players": <String, dynamic>{attempt.playerKey: buildMyPlayer()},
    // };

    String? matchedGameId;
    Map<String, dynamic>? matchedPlayersMap;
    String? joinedGameId;

    // Atomic create-or-join. Because Firebase serialises transactions on a
    // node, simultaneous searchers can never split into separate games.
    TransactionResult result;
    try {
      result = await roomRef.runTransaction((current) {
        // See the countdown ticker: the handler can run several times and only
        // the last run is the committed one, so the batch it extracts (if any)
        // must be re-derived from scratch every time.
        matchedGameId = null;
        matchedPlayersMap = null;

        final nowStr = DateTime.now().toString();

        final room = current == null
            ? <String, dynamic>{
                "status": "PENDING",
                "created_at": nowStr,
                "next_game_id": freshGameId,
                "players": <String, dynamic>{},
              }
            : Map<String, dynamic>.from(current as Map);

        // Keep room status PENDING so the room acts as a permanent buffer queue.
        room["status"] = "PENDING";

        final players = Map<String, dynamic>.from(
          room["players"] as Map? ?? <String, dynamic>{},
        );

        // Remove any stale slot previously held by this user in this room
        players.removeWhere(
          (k, p) =>
              p is Map && p["user_id"]?.toString() == LocalStorageService.uid,
        );

        final pruned = _pruneStale(players);

        players[attempt.playerKey] = buildMyPlayer();

        // The room only holds ghosts and us now: whatever countdown they had
        // armed belongs to a batch that will never be played.
        if (pruned && players.length < 2) room.remove("countdown_end_at");

        final currentGameId = room["next_game_id"]?.toString() ?? freshGameId;
        joinedGameId = currentGameId;

        if (isInfinite) {
          if (players.length >= 12) {
            matchedPlayersMap = Map<String, dynamic>.from(players);
            matchedGameId = currentGameId;
            players.clear();
            room["next_game_id"] = db.ref("games").push().key ?? "";
            room.remove("countdown_end_at");
          } else if (players.length >= 2) {
            final durationSeconds = players.length >= 3 ? 5 : 10;
            if (room["countdown_end_at"] == null || players.length >= 3) {
              room["countdown_end_at"] =
                  _serverNowMs + (durationSeconds * 1000);
            }
          }
        } else {
          if (players.length >= required) {
            final sortedEntries = players.entries.toList()
              ..sort((a, b) {
                final aTime = (a.value as Map)["created_at"]?.toString() ?? "";
                final bTime = (b.value as Map)["created_at"]?.toString() ?? "";
                return aTime.compareTo(bTime);
              });

            final matchBatch = sortedEntries.take(required).toList();
            matchedPlayersMap = <String, dynamic>{};
            for (final entry in matchBatch) {
              matchedPlayersMap![entry.key] = entry.value;
              players.remove(entry.key);
            }
            matchedGameId = currentGameId;
            room["next_game_id"] = db.ref("games").push().key ?? "";
          }
        }

        room["players"] = players;
        return Transaction.success(room);
      }, applyLocally: false);
    } catch (e) {
      if (isClosed || _committed) {
        await _withdraw(attempt);
        return;
      }
      return _retryJoinLobby(attempt, mode, retry);
    }

    if (isClosed || _committed) {
      await _withdraw(attempt);
      return;
    }

    if (result.committed != true || result.snapshot.value == null) {
      // Transient contention / abort: retry this room from scratch.
      return _retryJoinLobby(attempt, mode, retry);
    }

    final room = Map<String, dynamic>.from(
      jsonDecode(jsonEncode(result.snapshot.value)) as Map,
    );
    attempt.gameId = matchedGameId ?? joinedGameId ?? freshGameId;
    createdGameStatus = room["status"]?.toString() ?? "PENDING";
    debugPrint(
      "🔍 [MM] joinLobby: gameId=${attempt.gameId} roomKey=${attempt.roomKey} playerKey=${attempt.playerKey} roomStatus=$createdGameStatus isInfinite=$isInfinite myUid=${LocalStorageService.uid}",
    );

    // Leave only our own slot behind on disconnect — for every player, creator
    // included — so one player quitting the lobby never ends it for the others.
    attempt.disconnectionReference = db
        .ref("matchmakings/${attempt.roomKey}/players/${attempt.playerKey}")
        .onDisconnect();
    await attempt.disconnectionReference?.remove();

    // If our transaction extracted a full match batch, process the graduation to games/{gameId}.
    if (matchedGameId != null &&
        matchedPlayersMap != null &&
        matchedPlayersMap!.isNotEmpty) {
      await _graduateBatch(attempt, matchedGameId!, matchedPlayersMap!);
    }

    // Keep the live "players found" count fresh.
    attempt.roomSubscription = roomRef.onValue.listen(
      (event) {
        final value = event.snapshot.value;
        if (value == null || isClosed || _committed || _launching) {
          debugPrint(
            "🔍 [MM] roomSub skip: value=$value closed=$isClosed committed=$_committed launching=$_launching",
          );
          return;
        }
        final data = Map<String, dynamic>.from(
          jsonDecode(jsonEncode(value)) as Map,
        );
        final roomNextGameId = data["next_game_id"]?.toString();
        if (roomNextGameId != attempt.gameId) {
          // The room moved on to its next batch: ours has graduated (or left
          // without us). This listener has nothing left to say about it, so
          // the game node is the only thing that can still speak for us —
          // make sure somebody actually asks it.
          debugPrint(
            "🔍 [MM] roomSub gameId mismatch: room=$roomNextGameId attempt=${attempt.gameId}",
          );
          unawaited(_verifyLaunchLater(attempt));
          return;
        }

        final players = Map<String, dynamic>.from(
          data["players"] as Map? ?? <String, dynamic>{},
        );
        attempt.playerIds = players.values
            .whereType<Map>()
            .map((p) => p["user_id"]?.toString())
            .whereType<String>()
            .toSet();
        debugPrint(
          "🔍 [MM] roomSub: ${players.length} players, status=${data["status"]}, countdown=${data["countdown_end_at"]}",
        );
        _refreshPlayersFound();

        // Our own slot is gone, yet the room is still gathering the very batch
        // we joined. Nothing here counts us anymore: the countdown will not be
        // armed for us, and if it is armed by two others the extraction leaves
        // without us. Every existing recovery hangs off the room *moving on*
        // (`next_game_id` rotating) — which is exactly what does not happen
        // when the room stays put, so a player whose slot was reaped by a
        // disconnect the reconnection never repaired, or evicted by any other
        // write, waited here for good, looking at a grid that still listed
        // them next to the player they would never be matched with.
        if (!players.containsKey(attempt.playerKey)) {
          unawaited(_ensureSeatedInRoom(attempt, roomRef));
        }

        if (data["status"]?.toString() == "STARTED") {
          _stopCountdownTimer();
          _onRoomStarted(attempt, data);
        } else if (isInfinite) {
          _handleInfiniteCountdown(attempt, roomRef, data);
        }
      },
      onError: (error, stackTrace) {
        debugPrint("⚠️ RemoteCubit roomSubscription error: $error");
      },
    );

    // The single authoritative launch signal: the graduated game node going
    // STARTED. Never races, and is never overwritten by later batches.
    //
    // Scoped to `/status` on purpose. The node this points at is the live game
    // node: it also carries `events`, the per-move log every player appends to
    // for the whole match. Subscribing to the parent downloaded that entire log
    // on attach and re-delivered every move appended to it — the same traffic
    // the game's own `events` listener is already paying for — just to read one
    // string. `players` is read once, on the single tick that matters.
    attempt.gameSubscription = db
        .ref("games/${attempt.gameId}/status")
        .onValue
        .listen(
          (event) async {
            debugPrint(
              "🔍 [MM] gameSub: status=${event.snapshot.value} gameId=${attempt.gameId}",
            );
            if (event.snapshot.value?.toString() != "STARTED") return;
            if (isClosed || _launching) {
              debugPrint(
                "🔍 [MM] gameSub skip: closed=$isClosed launching=$_launching",
              );
              return;
            }

            debugPrint("🔍 [MM] gameSub: waiting for players node...");
            DataSnapshot? playersSnap;
            try {
              final event = await db
                  .ref("games/${attempt.gameId}/players")
                  .onValue
                  .firstWhere((e) {
                    final val = e.snapshot.value;
                    return val != null && val is Map && val.isNotEmpty;
                  })
                  .timeout(const Duration(seconds: 5));
              playersSnap = event.snapshot;
            } catch (_) {
              debugPrint(
                "🔍 [MM] gameSub: timeout waiting for players, falling back to get()",
              );
              playersSnap = await db
                  .ref("games/${attempt.gameId}/players")
                  .get();
            }

            if (isClosed || _launching) {
              debugPrint(
                "🔍 [MM] gameSub skip after get: closed=$isClosed launching=$_launching",
              );
              return;
            }

            final rawPlayers = playersSnap.value;
            final players = rawPlayers is Map
                ? Map<String, dynamic>.from(
                    jsonDecode(jsonEncode(rawPlayers)) as Map,
                  )
                : <String, dynamic>{};
            // Seats written by [enableBotFallback] carry a synthetic
            // `bot_<key>` id and no account behind them: they must not count
            // as real players, or a table finished by the bot fallback would
            // be rewarded as a full human match.
            final realIds = players.values
                .whereType<Map>()
                .map((p) => p["user_id"]?.toString())
                .whereType<String>()
                .where((id) => !id.startsWith("bot_"))
                .toSet();

            debugPrint(
              "🔍 [MM] gameSub players: $realIds, myUid=${LocalStorageService.uid}",
            );

            // The batch graduated without us. Launching anyway drops us into a
            // table whose engines never seated us: no hand, no turn, and a
            // defeat at the end. Go back to the pool instead — same treatment
            // as a batch that moved on while we were reconnecting.
            if (!realIds.contains(LocalStorageService.uid)) {
              debugPrint("🔍 [MM] gameSub: NOT SEATED → _rejoinIfUnseated");
              unawaited(_rejoinIfUnseated(attempt));
              return;
            }

            // The host is the chronologically first player still present.
            final orderedKeys = players.keys.toList()..sort();
            creator =
                orderedKeys.isNotEmpty &&
                orderedKeys.first == attempt.playerKey;

            // "Fake opponent" means nobody real to play against — not "some
            // seats are bots". It gates move broadcasting and the replay
            // handshake, so a table where two humans sit among bot-filled
            // seats has to read as genuine, or those two would stop exchanging
            // moves entirely. On the 2-seat pools this flag was written for,
            // `< 2` is exactly the old `< minRequired`.
            debugPrint(
              "🔍 [MM] gameSub → _launchWith (realIds=${realIds.length})",
            );
            _launchWith(attempt, fakeOpponent: realIds.length < 2);
          },
          onError: (error, stackTrace) {
            debugPrint("⚠️ RemoteCubit gameSubscription error: $error");
          },
        );

    // Our own join may have already filled the room: commit right away.
    if (createdGameStatus == "STARTED") {
      _onRoomStarted(attempt, room);
    }
  }

  /// A room we occupy just filled: commit to it, leave every other room right
  /// away (so their batches stop counting a player who is already gone), and
  /// graduate it.
  void _onRoomStarted(_LobbyAttempt attempt, Map<String, dynamic> room) {
    if (_chosen != null && !identical(_chosen, attempt)) return;
    _graduate(attempt, room);
  }

  /// Launches the game the winning [attempt] graduated into.
  Future<void> _launchWith(
    _LobbyAttempt attempt, {
    required bool fakeOpponent,
  }) async {
    debugPrint(
      "🔍 [MM] _launchWith: closed=$isClosed launching=$_launching chosen=${_chosen != null} identical=${identical(_chosen, attempt)}",
    );
    if (isClosed || _launching) return;
    if (_chosen == null) {
      // The game node went STARTED without us ever seeing the room flip (the
      // batch moved on): commit to it now and leave the other rooms.
      _chosen = attempt;
      await _withdrawOthers(attempt);
    } else if (!identical(_chosen, attempt)) {
      // Already committed to another room; _withdrawOthers told this game we
      // are not coming.
      debugPrint("🔍 [MM] _launchWith: ABORT - chosen is a different attempt");
      return;
    }

    gameId = attempt.gameId;
    matchedMode = attempt.mode;
    debugPrint(
      "🔍 [MM] _launchWith → launchGame(gameId=$gameId, fakeOpponent=$fakeOpponent)",
    );
    launchGame(fakeOpponent: fakeOpponent);
  }

  /// Copies a full lobby room into its real (graduated) game node. Every
  /// finishing client writes the same authoritative data idempotently, so the
  /// game exists even if the player who filled the room drops out in the same
  /// instant. The launch itself is driven uniformly by the game-node listener.
  Future<void> _graduate(
    _LobbyAttempt attempt,
    Map<String, dynamic> room,
  ) async {
    final gid = attempt.gameId.isNotEmpty
        ? attempt.gameId
        : (room["next_game_id"]?.toString() ?? attempt.gameId);
    final players = Map<String, dynamic>.from(
      room["players"] as Map? ?? <String, dynamic>{},
    );
    await _graduateBatch(attempt, gid, players);
  }

  /// Copies a matched batch of players into its real (graduated) game node.
  Future<void> _graduateBatch(
    _LobbyAttempt attempt,
    String targetGameId,
    Map<String, dynamic> candidatePlayers,
  ) async {
    if (_graduated) return;

    final players = Map<String, dynamic>.from(candidatePlayers);

    final settings = remoteUtility.matchmakingSettings;
    final isInfinite = settings.isInfinite || settings.maxPlayers == 0;
    final required = isInfinite ? 12 : (settings.maxPlayers ?? 2);
    final minRequired = isInfinite ? 2 : required;

    if (players.length < minRequired) {
      _chosen = null;
      _graduated = false;
      return;
    }

    // Does the batch we are about to seat actually hold our own seat?
    //
    // It is not a given, and the answer used to be assumed. The infinite
    // pool's countdown is a plain local timer: it keeps running while the
    // database connection is down — which Android does as soon as the app is
    // backgrounded, and its onDisconnect reaps our slot when it happens — so
    // the extraction it fires on reconnection can perfectly well carry a batch
    // of *other* players, gathered in a room we are momentarily not in.
    // Committing to that batch (`_chosen`, and with it `_committed`) was
    // unconditional, and it silently disabled every single way back: the room
    // listener returns on `_committed`, so does the ticker, the slot
    // restoration, the rejoin, and even `_rejoinIfUnseated` — which is exactly
    // the path the game node takes when it sees we are not seated in it. The
    // player was left on "En attente de joueurs", countdown gone, with no
    // listener able to ever wake them again.
    //
    // The batch is still written: those players are owed the game they were
    // extracted for. We just do not pretend it is ours.
    final weAreInBatch = players.values.whereType<Map>().any(
      (p) => p["user_id"]?.toString() == LocalStorageService.uid,
    );

    if (weAreInBatch) {
      _graduated = true;
      _chosen = attempt;
      await _withdrawOthers(attempt);
    } else {
      debugPrint(
        "🔍 [MM] graduateBatch: extracted a batch we are not part of "
        "($targetGameId) — seating it, staying in the pool",
      );
    }

    final createdAt = DateTime.now().toString();

    // One atomic transaction, and the seats are MERGED, never replaced.
    //
    // Several clients of the same batch write this node and their snapshots of
    // the room can differ by whoever joined last; a plain overwrite lets the
    // client holding the oldest snapshot erase a real player's seat. That
    // player still launches — the node is STARTED and it is listening on it —
    // but is absent from `players`, so no engine ever deals it a hand: it
    // watches the others play and is charged a defeat at the end. A union can
    // only ever be too generous, and a seat nobody occupies is already handled
    // by the READINESS roll-call. Keeping status and players in the same
    // commit preserves the invariant every client relies on: when the node
    // reads STARTED, its seats are final.
    //
    // The write is retried: a network blip in this exact instant used to throw
    // `[firebase_database/disconnected]` out of an unawaited future — a fatal
    // crash — and, crash aside, left the search stuck (the guards below are
    // already set and the other rooms already withdrawn from), so the player
    // never entered the game they had just been matched into.
    final gameRef = FirebaseDatabase.instance.ref("games/$targetGameId");

    Future<bool> commitSeats() async {
      await gameRef.runTransaction((current) {
        final game = current == null
            ? <String, dynamic>{}
            : Map<String, dynamic>.from(current as Map);
        final seats = Map<String, dynamic>.from(
          game["players"] as Map? ?? <String, dynamic>{},
        );

        final seatedUids = <String>{};
        for (final seat in seats.values) {
          if (seat is! Map) continue;
          final uid = seat["user_id"]?.toString();
          if (uid != null) seatedUids.add(uid);
        }
        for (final entry in players.entries) {
          if (seats.containsKey(entry.key)) continue;
          final uid = (entry.value is Map)
              ? (entry.value as Map)["user_id"]?.toString()
              : null;
          // Same player under a second lobby key (a rejoin): one seat only.
          if (uid != null && !seatedUids.add(uid)) continue;
          seats[entry.key] = entry.value;
        }

        game["players"] = seats;
        game["status"] = "STARTED";
        game["created_at"] ??= createdAt;
        game["updated_at"] = createdAt;
        return Transaction.success(game);
      });
      return true;
    }

    for (
      var attemptIndex = 0;
      attemptIndex < _graduationAttempts;
      attemptIndex++
    ) {
      if (isClosed) return;
      try {
        if (await commitSeats()) {
          // Seated, but without us: the room this batch left is not ours to
          // wait in anymore (our slot went with it), so queue up again instead
          // of watching a game we are not in.
          if (!weAreInBatch && !isClosed && !_committed) _rejoin(attempt);
          return;
        }
      } catch (_) {
        if (attemptIndex == _graduationAttempts - 1) break;
        await Future.delayed(Duration(milliseconds: 600 * (attemptIndex + 1)));
      }
    }

    if (isClosed) return;

    // Every write failed *from here*. That does not mean the batch failed: a
    // transaction can be applied server-side and still throw on the client
    // (the connection dropping while the acknowledgement is in flight is
    // exactly that), and the other clients of the same batch write the very
    // same node. So ask the node itself before declaring anything.
    if (await _gameAlreadyStarted(targetGameId)) {
      // It did start. The game-node listener drives the launch, as always —
      // there is nothing to undo and, above all, nothing to tear down.
      return;
    }

    // Genuinely not started. Undo the guards, and go back to the pool: the
    // batch that was extracted for us took our slot out of the room with it,
    // so there is nothing left to wait in — staying put is waiting for a room
    // we are no longer part of.
    //
    // This used to cancel every subscription and emit a
    // [RemoteGameStatus.failure] that the search screens of this app do not
    // listen for, which left the player frozen on the waiting screen with no
    // listener to ever wake them — not even when the batch turned out to have
    // started after all (checked just above).
    // Only undo what we actually set: a batch we were not part of never
    // committed this search to anything, and clearing the guards blindly would
    // disown a room another attempt has legitimately won.
    if (weAreInBatch) {
      _graduated = false;
      _chosen = null;
    }
    _stopCountdownTimer();
    if (isClosed || _committed) return;
    debugPrint("🔍 [MM] graduation gave up on $targetGameId → rejoining pool");
    _rejoin(attempt);
  }

  /// Whether [gameId]'s node already carries a started match.
  Future<bool> _gameAlreadyStarted(String gameId) async {
    if (gameId.isEmpty) return false;
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref("games/$gameId/status")
          .get()
          .timeout(const Duration(seconds: 5));
      return snapshot.value?.toString() == "STARTED";
    } catch (_) {
      return false;
    }
  }

  /// Re-reads [attempt]'s game node a few seconds later and acts on what it
  /// actually says, instead of trusting a single live signal.
  ///
  /// The launch has exactly one trigger: `games/<id>/status` going STARTED.
  /// A listener that misses that flip — an error on the subscription, a
  /// connection lost across that very instant, a batch that graduated while
  /// we were away — leaves a player who *is* seated in a real game with
  /// nothing left to tell them about it: they sit on the waiting screen for
  /// good, while their opponents burn the readiness grace waiting on them.
  /// This is the cheap safety net: one read, and either we launch or we go
  /// back to the pool.
  Future<void> _verifyLaunchLater(
    _LobbyAttempt attempt, [
    Duration after = const Duration(seconds: 6),
  ]) async {
    if (attempt.launchVerificationArmed) return;
    if (attempt.launchVerifications >= _maxLaunchVerifications) return;
    attempt.launchVerificationArmed = true;
    attempt.launchVerifications++;

    await Future.delayed(after);

    if (isClosed || _launching || attempt.gameId.isEmpty) return;
    // Withdrawn from meanwhile (a "no preference" search committed elsewhere).
    if (!_attempts.contains(attempt) && !identical(_chosen, attempt)) return;
    if (!await _gameAlreadyStarted(attempt.gameId)) {
      // Not started (yet). No rejoin while checks remain: the batch may simply
      // be slow to be seated by whoever extracted it, and walking away from a
      // table we are about to be dealt into is the very failure this method
      // exists to prevent. The live game-node listener is still attached and
      // stays the primary signal.
      attempt.launchVerificationArmed = false;
      if (isClosed || _committed) return;

      if (attempt.launchVerifications < _maxLaunchVerifications) {
        // Re-check on our own clock, rather than disarming and waiting for the
        // next room event to arm us again.
        //
        // The event that armed us in the first place is our batch leaving the
        // room — and an infinite pool's room goes completely quiet right after
        // that (it is emptied, and nobody is in it to change it). So there was
        // no next event: exactly one check ever ran, six seconds after the
        // extraction, and every player of a batch whose extractor had not
        // seated it yet — a slow write, an app backgrounded or killed in that
        // instant, a connection lost between the extraction transaction and
        // the seating one — stayed on the waiting screen for the rest of the
        // session, countdown gone, with nothing left to wake them.
        unawaited(_verifyLaunchLater(attempt, after));
        return;
      }

      // Out of checks, and this room has long moved on to another batch (that
      // is what armed us): our slot left with the batch that was extracted for
      // us, and that batch was never seated. Sitting here is waiting on a room
      // we are not in and a game nobody wrote — go back to the pool rather
      // than stay stranded.
      debugPrint("🔍 [MM] verifyLaunch: batch never seated → rejoining pool");
      _rejoin(attempt);
      return;
    }
    if (isClosed || _launching) return;

    Object? rawPlayers;
    try {
      final snapshot = await FirebaseDatabase.instance
          .ref("games/${attempt.gameId}/players")
          .get()
          .timeout(const Duration(seconds: 5));
      rawPlayers = snapshot.value;
    } catch (_) {
      attempt.launchVerificationArmed = false;
      return;
    }

    if (isClosed || _launching) return;

    final seats = rawPlayers is Map
        ? Map<String, dynamic>.from(jsonDecode(jsonEncode(rawPlayers)) as Map)
        : <String, dynamic>{};
    final realIds = seats.values
        .whereType<Map>()
        .map((p) => p["user_id"]?.toString())
        .whereType<String>()
        .where((id) => !id.startsWith("bot_"))
        .toSet();

    if (!realIds.contains(LocalStorageService.uid)) {
      debugPrint("🔍 [MM] verifyLaunch: started without us → rejoin");
      unawaited(_rejoinIfUnseated(attempt));
      return;
    }

    final orderedKeys = seats.keys.toList()..sort();
    creator = orderedKeys.isNotEmpty && orderedKeys.first == attempt.playerKey;

    debugPrint(
      "🔍 [MM] verifyLaunch: seated in ${attempt.gameId} → launching (missed signal)",
    );
    _launchWith(attempt, fakeOpponent: realIds.length < 2);
  }

  /// How many deferred launch checks a single room may run.
  static const int _maxLaunchVerifications = 3;

  /// How many times the graduation write is attempted before giving up.
  static const int _graduationAttempts = 3;

  /// Leaves every room except [winner]. Kept losing rooms would keep counting
  /// us towards their batches and could start a second game with a ghost.
  Future<void> _withdrawOthers(_LobbyAttempt winner) async {
    for (final attempt in List<_LobbyAttempt>.from(_attempts)) {
      if (identical(attempt, winner)) continue;
      _attempts.remove(attempt);
      await _withdraw(attempt);
    }
  }

  /// Removes our slot from [attempt]'s room, transactionally, only while its
  /// batch is still gathering. If the batch already started with us seated —
  /// the room filled in the instant we were committing elsewhere — the
  /// graduated game is told we are not coming (an EXIT event), so its players
  /// don't wait on a ghost.
  Future<void> _withdraw(_LobbyAttempt attempt) async {
    attempt.cancelSubscriptions();
    if (attempt.roomKey.isEmpty || attempt.playerKey.isEmpty) return;

    // Simple, reliable removal: directly delete our slot from the room.
    // The previous transaction-based approach silently aborted in edge cases
    // (player not found by key/userId, concurrent room changes).
    try {
      await FirebaseDatabase.instance
          .ref("matchmakings/${attempt.roomKey}/players/${attempt.playerKey}")
          .remove();
    } catch (_) {}
  }

  /// Puts our lobby slots back after a connection loss, one room at a time.
  Future<void> _restoreLobbySlots() async {
    if (isClosed || _committed || _restoring) return;
    _restoring = true;

    try {
      for (final attempt in List<_LobbyAttempt>.from(_attempts)) {
        if (isClosed || _committed) return;
        await _restoreLobbySlot(attempt);
      }
    } finally {
      _restoring = false;
    }
  }

  /// Puts our slot in [attempt]'s room back after a connection loss.
  ///
  /// An onDisconnect is consumed when it fires, so it is re-armed on every
  /// reconnection even when the slot survived (short blips the server never
  /// noticed). Then, in one transaction: if the same batch is still gathering,
  /// our slot is re-added (flipping the room to STARTED if that fills it, like
  /// a normal join). If the batch moved on without us — graduated or replaced —
  /// we either let the game-node listener launch the game we are part of, or
  /// rejoin that room's pool from scratch.
  Future<void> _restoreLobbySlot(_LobbyAttempt attempt) async {
    if (attempt.roomKey.isEmpty || attempt.playerKey.isEmpty) return;
    // Replaced while we were waiting our turn in [_restoreLobbySlots]: a
    // rejoin has already taken this pool over with a fresh slot, and putting
    // this one back would seat a key nobody listens to.
    if (!_attempts.contains(attempt)) return;

    final db = FirebaseDatabase.instance;
    final roomPath = "matchmakings/${attempt.roomKey}";

    attempt.disconnectionReference = db
        .ref("$roomPath/players/${attempt.playerKey}")
        .onDisconnect();
    await attempt.disconnectionReference?.remove();
    if (isClosed || _committed) return;
    if (!_attempts.contains(attempt)) return;

    final settings = remoteUtility.matchmakingSettings;
    final isInfinite = settings.isInfinite || settings.maxPlayers == 0;
    final required = isInfinite ? 12 : (settings.maxPlayers ?? 2);
    final now = DateTime.now().toString();

    String? matchedGameId;
    Map<String, dynamic>? matchedPlayers;

    TransactionResult result;
    try {
      result = await db.ref(roomPath).runTransaction((current) {
        // See the countdown ticker: the handler can run several times and only
        // the last one describes what was committed.
        matchedGameId = null;
        matchedPlayers = null;

        if (current == null) return Transaction.abort();
        final room = Map<String, dynamic>.from(current as Map);
        if (room["status"]?.toString() != "PENDING") {
          return Transaction.abort();
        }
        if (room["next_game_id"]?.toString() != attempt.gameId) {
          return Transaction.abort();
        }

        final players = Map<String, dynamic>.from(
          room["players"] as Map? ?? <String, dynamic>{},
        );
        // Slot survived the blip: nothing to change, commit as-is.
        if (players.containsKey(attempt.playerKey)) {
          return Transaction.success(room);
        }
        // Full without us: this batch is leaving, don't overflow it.
        if (players.length >= required) return Transaction.abort();

        players[attempt.playerKey] = <String, dynamic>{
          "user_id": LocalStorageService.uid,
          "status": "ACCEPTED",
          "created_at": now,
          "updated_at": now,
          "joined_at_ms": _serverNowMs,
        };
        room["players"] = players;
        if (isInfinite) {
          if (players.length >= 12) {
            // Extract the batch, exactly like a join that fills the room does.
            //
            // This used to flip the shared room to STARTED and stop there,
            // leaving its twelve players *in* it. Every occupant then
            // graduated the same batch (harmless), but the room stayed STARTED
            // with twelve slots nobody would ever remove: the next searcher
            // reset it to PENDING, counted those twelve as players, and was
            // graduated into a table of ghosts.
            matchedPlayers = Map<String, dynamic>.from(players);
            matchedGameId = attempt.gameId;
            room["players"] = <String, dynamic>{};
            room["next_game_id"] = db.ref("games").push().key ?? "";
            room.remove("countdown_end_at");
          } else if (players.length >= 2 && room["countdown_end_at"] == null) {
            final durationSeconds = players.length >= 3 ? 5 : 10;
            room["countdown_end_at"] = _serverNowMs + (durationSeconds * 1000);
          }
        } else {
          if (players.length >= required) {
            room["status"] = "STARTED";
          }
        }
        return Transaction.success(room);
      }, applyLocally: false);
    } catch (e) {
      if (isClosed || _committed) return;
      _rejoin(attempt);
      return;
    }

    if (isClosed || _committed) return;
    if (!_attempts.contains(attempt) && !identical(_chosen, attempt)) return;

    if (result.committed == true &&
        matchedGameId != null &&
        matchedPlayers != null &&
        matchedPlayers!.length >= 2) {
      await _graduateBatch(attempt, matchedGameId!, matchedPlayers!);
      return;
    }

    if (result.committed == true && result.snapshot.value != null) {
      // Back in the same room; the room listener resumes driving the lobby.
      // If our return just filled it, commit exactly like a join would.
      final room = Map<String, dynamic>.from(
        jsonDecode(jsonEncode(result.snapshot.value)) as Map,
      );
      if (room["status"]?.toString() == "STARTED") {
        _onRoomStarted(attempt, room);
        return;
      }
      // A countdown very probably expired while we were away — losing the
      // connection across that instant is exactly what makes the extraction
      // transaction throw — and our ticker cancelled itself on that expiry.
      // Only a room event can start another one, and re-asserting a slot that
      // survived the blip changes nothing, so it produces none: the room would
      // sit there, two players deep, under a countdown that has already ended.
      // Drive it from the snapshot we are already holding.
      if (isInfinite) {
        _handleInfiniteCountdown(attempt, db.ref(roomPath), room);
      }
      return;
    }

    // The batch moved on without us. If the graduated game includes us, the
    // game-node listener drives the launch; otherwise rejoin this pool.
    final gameSnap = await db.ref("games/${attempt.gameId}/players").get();
    final gamePlayers = gameSnap.value;
    final iAmSeated =
        gamePlayers is Map &&
        gamePlayers.values.any(
          (p) =>
              p is Map && p["user_id"]?.toString() == LocalStorageService.uid,
        );
    if (isClosed || _committed) return;
    if (iAmSeated) {
      // The game-node listener normally drives the launch — but we just came
      // back from a connection loss, which is precisely when it may have
      // missed the flip it was waiting for. Confirm it the slow way too.
      unawaited(_verifyLaunchLater(attempt, const Duration(seconds: 2)));
      return;
    }
    _rejoin(attempt);
  }

  /// Confirms, against the server, that the graduated game really did start
  /// without us before sending the search back to the pool.
  ///
  /// The seats are written before the STARTED flip precisely so this never
  /// races, but a re-read costs one round trip and makes bouncing a player who
  /// *is* seated impossible — the failure mode a plain local check would have.
  Future<void> _rejoinIfUnseated(_LobbyAttempt attempt) async {
    if (isClosed || _launching) return;
    // `_committed` normally reads "another room won, this one is irrelevant".
    // It must not read that way when the room that won is *this* one: a
    // commitment to a game whose seats turn out not to include us is precisely
    // what this method exists to undo, and returning here left the player
    // pinned to a table they would never be dealt into, with every recovery
    // path short-circuited on the same flag.
    if (_chosen != null && !identical(_chosen, attempt)) return;

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref("games/${attempt.gameId}/players")
          .get();
      final seats = snapshot.value;
      final iAmSeated =
          seats is Map &&
          seats.values.any(
            (p) =>
                p is Map && p["user_id"]?.toString() == LocalStorageService.uid,
          );
      if (iAmSeated) return;
    } catch (_) {
      // Couldn't check: leave the attempt alone rather than abandon a game we
      // may well be part of. The readiness fallback covers us either way.
      return;
    }

    if (isClosed || _launching) return;
    if (identical(_chosen, attempt)) {
      _chosen = null;
      _graduated = false;
    }
    _rejoin(attempt);
  }

  /// Retries a join that could not commit, after a short pause.
  ///
  /// The retry used to be immediate and unbounded: on an error that fails
  /// straight away (rejected by the rules, a malformed room…) that is a hot
  /// loop hammering the database for as long as the player stays on the
  /// waiting screen. Pacing it keeps a genuine contention retry fast (the
  /// first ones are near-immediate) while an error that is not going away
  /// settles into one attempt a second.
  Future<void> _retryJoinLobby(
    _LobbyAttempt attempt,
    String? mode,
    int retry,
  ) async {
    // The failed attempt holds a room key and listeners it never wired: drop
    // it so the retry does not stack a second entry for the same pool.
    _attempts.remove(attempt);

    final delayMs = retry < 2 ? 0 : (retry < 5 ? 300 : 1000);
    if (delayMs > 0) {
      await Future.delayed(Duration(milliseconds: delayMs));
    }
    if (isClosed || _committed) return;

    return _joinLobby(mode, retry + 1);
  }

  /// Replaces a stale [attempt] with a fresh join of the same pool.
  ///
  /// Idempotent: several paths can reach the same "this room moved on without
  /// us" verdict at once (the game-node listener and the deferred check, for
  /// instance), and replacing an attempt twice would queue us in the pool
  /// twice — two attempts, two sets of listeners, for a single player.
  void _rejoin(_LobbyAttempt attempt) {
    if (!_attempts.remove(attempt)) return;
    attempt.cancelSubscriptions();
    _joinLobby(attempt.mode);
  }

  /// Shows the fullest room of the search (a single-mode search has just one).
  void _refreshPlayersFound() {
    Set<String> best = const {};
    for (final attempt in _attempts) {
      if (attempt.playerIds.length > best.length) best = attempt.playerIds;
    }
    _emitPlayersFound(best);
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

  /// 2-player fallback: if we are still alone in a pending room after a short
  /// wait, start the game against a bot. Guarded by a transaction so a real
  /// opponent who joined at the last second always wins over the bot. A "no
  /// preference" search waits in several rooms — any of them can host the bot
  /// game, so one is picked at random for variety.
  void _manageFakeGame() async {
    final settings = remoteUtility.matchmakingSettings;
    // Infinite pools never graduate a lone player ([_graduateBatch] requires
    // two), so all this could do there was flip the *shared* room to STARTED
    // for a player it then failed to launch — and while the room reads
    // STARTED, every occupant's room listener takes the graduation branch and
    // stops driving the countdown, i.e. the pool stops starting games until
    // the next join resets the status.
    if (settings.isInfinite) return;

    final required = settings.maxPlayers ?? 2;
    if (required > 2) return;

    await Future.delayed(10.seconds);

    if (isClosed) return;
    if (state.status == RemoteGameStatus.success) return;
    if (_committed || _graduated) return;

    final candidates = List<_LobbyAttempt>.from(_attempts)..shuffle();

    for (final attempt in candidates) {
      if (isClosed || _committed || _graduated) return;

      final roomRef = FirebaseDatabase.instance.ref(
        "matchmakings/${attempt.roomKey}",
      );
      TransactionResult result;
      try {
        result = await roomRef.runTransaction((current) {
          if (current == null) return Transaction.abort();
          final room = Map<String, dynamic>.from(current as Map);
          if (room["status"]?.toString() != "PENDING") {
            return Transaction.abort();
          }
          if (room["next_game_id"]?.toString() != attempt.gameId) {
            return Transaction.abort();
          }

          final players = Map<String, dynamic>.from(
            room["players"] as Map? ?? <String, dynamic>{},
          );
          // Only fall back to a bot while we are genuinely alone.
          if (players.length != 1 || !players.containsKey(attempt.playerKey)) {
            return Transaction.abort();
          }

          room["status"] = "STARTED";
          return Transaction.success(room);
        }, applyLocally: false);
      } catch (e) {
        continue;
      }

      if (isClosed) return;
      if (result.committed == true && result.snapshot.value != null) {
        final room = Map<String, dynamic>.from(
          jsonDecode(jsonEncode(result.snapshot.value)) as Map,
        );
        _onRoomStarted(attempt, room);
        return;
      }
    }
  }

  /// Opt-in bot fallback for pools with more than 2 seats, where
  /// [_manageFakeGame]'s own fallback doesn't apply (see its guard) — without
  /// this, a table that never fills with real players waits forever.
  ///
  /// Arms once at least 2 real players are actually gathered (a lone searcher
  /// isn't "the table didn't fill", it just hasn't started filling yet), then
  /// after [after] with the pool still short of
  /// [MatchmakingSettings.maxPlayers] real players, fills every empty seat
  /// with a synthetic placeholder entry and graduates the room itself — same
  /// transaction shape as a normal join filling it, so a real player racing
  /// in at the last second still wins their seat over a bot.
  ///
  /// [state.countdownRemaining] ticks down during the wait, exactly like the
  /// infinite pool's own ticker, so callers can show the same "starting in
  /// Xs…" UI without reimplementing a timer.
  ///
  /// The graduated room/game node only carries placeholder seats (a unique
  /// `user_id` of the form `bot_<key>`, nothing more) — turning an empty seat
  /// into whatever a specific engine understands as a bot is entirely up to
  /// the caller's own game setup, once it reads back who is actually seated.
  void enableBotFallback({required Duration after}) {
    _botFallbackDelay = after;
    unawaited(_armBotFallback());
    unawaited(_publishBotFallback());
  }

  /// Tells the server about a bot fallback enabled after we were already
  /// queued.
  ///
  /// On the legacy path the delay only ever fed a local timer, so it worked
  /// whenever [enableBotFallback] happened to be called. On the server path
  /// the delay travels inside the queue entry, which is written once — a
  /// caller arming the fallback a beat too late would be waiting for a table
  /// the server has no reason to ever fill.
  ///
  /// Deliberately an `update`, never a `set`: rewriting the entry would stamp
  /// a fresh `joined_at` and send us to the back of a queue we have been
  /// waiting in.
  Future<void> _publishBotFallback() async {
    if (!MatchmakingMigration.useServer) return;
    final ref = _queueEntryRef;
    final delay = _botFallbackDelay;
    if (ref == null || delay == null) return;
    try {
      await ref.update({"bot_after_ms": delay.inMilliseconds});
    } catch (_) {}
  }

  /// Arms the bot fallback for the search currently in flight. Called by
  /// [enableBotFallback] and again by [reset], so a rematch gets its own
  /// countdown.
  Future<void> _armBotFallback() async {
    final after = _botFallbackDelay;
    if (after == null || isClosed) return;
    // The server fills the empty seats itself, from `bot_after_ms` in the
    // queue entry. Arming this too would race it with a second table.
    if (MatchmakingMigration.useServer) return;

    final generation = state.searchGeneration;
    if (_botFallbackGeneration == generation) return;
    _botFallbackGeneration = generation;

    final settings = remoteUtility.matchmakingSettings;
    final required = settings.maxPlayers ?? 2;
    if (required <= 2 || settings.isInfinite) return;

    // Deliberately *not* gated on `PlaySettings.enableFakeOpponent` nor on
    // [RemoteUtility.isDeveloper]. Both belong to [_manageFakeGame], which
    // impersonates the developer account to give a lone player a fake human
    // opponent — a host app can legitimately want that off (or be signed in
    // as the developer) while still needing its 4- and 6-seat tables to
    // start. The seats written below carry no account at all, and calling
    // [enableBotFallback] is itself the opt-in.
    if (appScreenshots) return;

    if (!await _waitForPlayers(2, generation)) return;

    for (int remaining = after.inSeconds; remaining > 0; remaining--) {
      if (!_botFallbackStillRelevant(generation)) break;
      emit(state.copyWith(countdownRemaining: () => remaining));
      await Future.delayed(const Duration(seconds: 1));
    }
    if (!isClosed && state.countdownRemaining != null) {
      emit(state.copyWith(countdownRemaining: () => null));
    }

    if (!_botFallbackStillRelevant(generation)) return;

    final db = FirebaseDatabase.instance;
    final candidates = List<_LobbyAttempt>.from(_attempts)..shuffle();

    for (final attempt in candidates) {
      if (!_botFallbackStillRelevant(generation)) return;

      final roomRef = db.ref("matchmakings/${attempt.roomKey}");
      String? matchedGameId;
      Map<String, dynamic>? matchedPlayers;

      TransactionResult result;
      try {
        result = await roomRef.runTransaction((current) {
          // See the countdown ticker's note: re-derive from scratch every run.
          matchedGameId = null;
          matchedPlayers = null;

          if (current == null) return Transaction.abort();
          final room = Map<String, dynamic>.from(current as Map);
          if (room["status"]?.toString() != "PENDING") {
            return Transaction.abort();
          }
          if (room["next_game_id"]?.toString() != attempt.gameId) {
            return Transaction.abort();
          }

          final players = Map<String, dynamic>.from(
            room["players"] as Map? ?? <String, dynamic>{},
          );
          // Already full (or emptied by a batch that just graduated): the
          // normal path handles it, nothing for the bot fallback to do here.
          if (players.isEmpty || players.length >= required) {
            return Transaction.abort();
          }
          if (!players.containsKey(attempt.playerKey)) {
            return Transaction.abort();
          }

          final now = DateTime.now().toString();
          final missing = required - players.length;
          for (int i = 0; i < missing; i++) {
            final botKey = db.ref().push().key ?? "bot_${attempt.roomKey}_$i";
            players[botKey] = <String, dynamic>{
              "user_id": "bot_$botKey",
              "status": "ACCEPTED",
              "created_at": now,
              "updated_at": now,
            };
          }

          matchedPlayers = Map<String, dynamic>.from(players);
          matchedGameId = room["next_game_id"]?.toString() ?? attempt.gameId;
          room["players"] = <String, dynamic>{};
          room["next_game_id"] = db.ref("games").push().key ?? "";
          room.remove("countdown_end_at");
          return Transaction.success(room);
        }, applyLocally: false);
      } catch (e) {
        continue;
      }

      if (isClosed) return;
      if (result.committed == true &&
          matchedGameId != null &&
          matchedPlayers != null) {
        await _graduateBatch(attempt, matchedGameId!, matchedPlayers!);
        return;
      }
    }
  }

  /// Whether the bot fallback armed for [generation] still has anything to
  /// do: the cubit is alive, the search it was armed for is still the current
  /// one, and no match has started in the meantime.
  bool _botFallbackStillRelevant(int generation) {
    if (isClosed || _committed || _graduated) return false;
    if (state.searchGeneration != generation) return false;
    return state.status != RemoteGameStatus.success;
  }

  /// Waits until at least [count] players are gathered in the search
  /// identified by [generation].
  ///
  /// Returns false the moment waiting became pointless (cubit closed, search
  /// reset by [reset], match already started), so callers just bail out.
  /// Polled rather than awaited on [stream]: `firstWhere` on the state stream
  /// throws when the cubit closes first, and that error surfaces as an
  /// unhandled async exception in whatever armed the fallback.
  Future<bool> _waitForPlayers(int count, int generation) async {
    while (true) {
      if (!_botFallbackStillRelevant(generation)) return false;
      if (state.playersFound >= count) return true;
      await Future.delayed(const Duration(milliseconds: 250));
    }
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
  // multi-path write, so there is no in-between state to reconstruct — which
  // is what the legacy path above spends seven recovery routines doing.
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
    final poolKey = remoteUtility.matchmakingSettings.resolvedPoolKey;

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

    // The search never gives up on its own — the same rule the legacy path
    // followed. Giving up after a few tries left the player watching a search
    // that was not happening, with a dismissible popup and no way back other
    // than leaving the page.
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
    _assignmentSubscription = db
        .ref("assignments/$uid")
        .onValue
        .listen(
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

    _sealSubscription = db
        .ref("pools/$poolKey/seal_at")
        .onValue
        .listen(
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
    final seats = settings.isInfinite ? 0 : (settings.maxPlayers ?? 2);

    return <String, dynamic>{
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

  /// Same conditions [_manageFakeGame] applies on the legacy path — the server
  /// simply seals a lone player instead, and the game layer builds the
  /// synthetic opponent as it always has.
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

    _emitPlayersFound(queue.keys.toSet());
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

      // Named by the server rather than derived from key ordering: the legacy
      // election ("smallest player key") only worked because those keys
      // happened to be chronological.
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
    _stopCountdownTimer();

    for (final attempt in _attempts) {
      attempt.cancelSubscriptions();
    }
    _connectedSubscription?.cancel();

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
    if (MatchmakingMigration.useServer) {
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
      return;
    }

    for (final attempt in List<_LobbyAttempt>.from(_attempts)) {
      _attempts.remove(attempt);
      await _withdraw(attempt);

      if (attempt.gameId.isNotEmpty) {
        try {
          await gamesRepository.addGameEvent(
            attempt.gameId,
            GamicoGameEventModel(type: "EXIT", userId: LocalStorageService.uid),
          );
        } catch (_) {}
      }
    }
  }

  @override
  Future<void> close() async {
    GamicoDatabaseShutdown.unregister(this);

    _stopCountdownTimer();
    await abortGame();

    for (final attempt in _attempts) {
      attempt.cancelSubscriptions();
    }
    _connectedSubscription?.cancel();
    _serverTimeOffsetSubscription?.cancel();

    return super.close();
  }
}
