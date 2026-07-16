import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/models/gamico_game_model.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:gamico/commons/services/layout.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/features/adventure/utilities/remote_utility.dart';
import 'package:gamico/commons/repositories/gamico_games_repository.dart';

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

  /// Removes only our own slot from this room if we disconnect while still
  /// waiting.
  OnDisconnect? disconnectionReference;

  void cancelSubscriptions() {
    roomSubscription?.cancel();
    gameSubscription?.cancel();
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
  }) : super(RemoteState(level: level));

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

  /// The subscription above replays the current state on attach; only the
  /// events after that first `true` are actual reconnections.
  bool _sawInitialConnected = false;

  /// Guards against overlapping slot restorations.
  bool _restoring = false;

  String createdGameStatus = "";

  /// Guards a single graduation write per search.
  bool _graduated = false;

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

    gameId = "";
    matchedMode = null;
    _chosen = null;
    _graduated = false;
    _launching = false;

    emit(
      state.copyWith(
        status: RemoteGameStatus.initial,
        creator: null,
        gameId: "",
        animGame: false,
        finalized: false,
        fakeOpponent: false,
        playersFound: 0,
        // animInit: false,
        level: level == null ? null : () => level,
      ),
    );

    launch();
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

  /// Creates-or-joins the lobby room for [mode] and wires its listeners.
  Future<void> _joinLobby(String? mode) async {
    if (isClosed || _committed) return;

    final db = FirebaseDatabase.instance;
    final settings = remoteUtility.matchmakingSettings;
    final required = settings.maxPlayers ?? 2;

    final attempt = _LobbyAttempt(mode);
    attempt.roomKey = _buildRoomKey(mode);
    final roomRef = db.ref("matchmakings/${attempt.roomKey}");

    attempt.playerKey = db.ref().push().key ?? "";
    // Pre-generated id of the real game this lobby will graduate into.
    final freshGameId = db.ref("games").push().key ?? "";

    final now = DateTime.now().toString();
    Map<String, dynamic> buildMyPlayer() => <String, dynamic>{
      "user_id": UserService.uid,
      "status": "ACCEPTED",
      "created_at": now,
      "updated_at": now,
    };
    Map<String, dynamic> buildFreshRoom() => <String, dynamic>{
      "status": "PENDING",
      "created_at": now,
      "next_game_id": freshGameId,
      "players": <String, dynamic>{attempt.playerKey: buildMyPlayer()},
    };

    // Atomic create-or-join. Because Firebase serialises transactions on a
    // node, simultaneous searchers can never split into separate games.
    TransactionResult result;
    try {
      result = await roomRef.runTransaction((current) {
        if (current == null) {
          return Transaction.success(buildFreshRoom());
        }

        final room = Map<String, dynamic>.from(current as Map);
        final status = room["status"]?.toString() ?? "";

        // A previous batch already started here: open a fresh room for a new one.
        if (status != "PENDING") {
          return Transaction.success(buildFreshRoom());
        }

        final players = Map<String, dynamic>.from(
          room["players"] as Map? ?? <String, dynamic>{},
        );

        // Defensive: a full-but-not-yet-flipped room shouldn't exist, but if it
        // does, don't overflow it — start a fresh batch instead.
        if (players.length >= required) {
          return Transaction.success(buildFreshRoom());
        }

        players[attempt.playerKey] = buildMyPlayer();
        room["players"] = players;
        if (players.length >= required) {
          room["status"] = "STARTED";
        }
        return Transaction.success(room);
      }, applyLocally: false);
    } catch (e) {
      if (isClosed || _committed) return;
      return _joinLobby(mode);
    }

    if (isClosed || _committed) return;

    if (result.committed != true || result.snapshot.value == null) {
      // Transient contention / abort: retry this room from scratch.
      return _joinLobby(mode);
    }

    final room = Map<String, dynamic>.from(
      jsonDecode(jsonEncode(result.snapshot.value)) as Map,
    );
    attempt.gameId = room["next_game_id"]?.toString() ?? freshGameId;
    createdGameStatus = room["status"]?.toString() ?? "PENDING";
    _attempts.add(attempt);

    // Leave only our own slot behind on disconnect — for every player, creator
    // included — so one player quitting the lobby never ends it for the others.
    attempt.disconnectionReference = db
        .ref("matchmakings/${attempt.roomKey}/players/${attempt.playerKey}")
        .onDisconnect();
    await attempt.disconnectionReference?.remove();

    // Keep the live "players found" count fresh, and graduate once the room
    // fills. A room whose next_game_id changed has already graduated and been
    // replaced by a new batch — the game-node listener drives our launch then.
    attempt.roomSubscription = roomRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value == null) return;
      final data = Map<String, dynamic>.from(
        jsonDecode(jsonEncode(value)) as Map,
      );
      if (data["next_game_id"]?.toString() != attempt.gameId) return;

      final players = Map<String, dynamic>.from(
        data["players"] as Map? ?? <String, dynamic>{},
      );
      attempt.playerIds = players.values
          .map((p) => (p as Map)["user_id"]?.toString())
          .whereType<String>()
          .toSet();
      _refreshPlayersFound();

      if (data["status"]?.toString() == "STARTED") {
        _onRoomStarted(attempt, data);
      }
    });

    // The single authoritative launch signal: the graduated game node going
    // STARTED. Never races, and is never overwritten by later batches.
    attempt.gameSubscription = db.ref("games/${attempt.gameId}").onValue.listen(
      (event) {
        final value = event.snapshot.value;
        if (value == null) return;
        final data = Map<String, dynamic>.from(
          jsonDecode(jsonEncode(value)) as Map,
        );
        if (data["status"]?.toString() != "STARTED") return;

        final players = Map<String, dynamic>.from(
          data["players"] as Map? ?? <String, dynamic>{},
        );
        final realIds = players.values
            .map((p) => (p as Map)["user_id"]?.toString())
            .whereType<String>()
            .toSet();
        // The host is the chronologically first player still present.
        final orderedKeys = players.keys.toList()..sort();
        creator =
            orderedKeys.isNotEmpty && orderedKeys.first == attempt.playerKey;

        _launchWith(attempt, fakeOpponent: realIds.length < required);
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
    if (_chosen == null) {
      _chosen = attempt;
      _withdrawOthers(attempt);
    }
    _graduate(attempt, room);
  }

  /// Launches the game the winning [attempt] graduated into.
  void _launchWith(_LobbyAttempt attempt, {required bool fakeOpponent}) {
    if (isClosed || _launching) return;
    if (_chosen == null) {
      // The game node went STARTED without us ever seeing the room flip (the
      // batch moved on): commit to it now and leave the other rooms.
      _chosen = attempt;
      _withdrawOthers(attempt);
    } else if (!identical(_chosen, attempt)) {
      // Already committed to another room; _withdrawOthers told this game we
      // are not coming.
      return;
    }

    gameId = attempt.gameId;
    matchedMode = attempt.mode;
    launchGame(fakeOpponent: fakeOpponent);
  }

  /// Copies a full lobby room into its real (graduated) game node. Every
  /// finishing client writes the same authoritative data idempotently, so the
  /// game exists even if the player who filled the room drops out in the same
  /// instant. The launch itself is driven uniformly by the game-node listener.
  Future<void> _graduate(_LobbyAttempt attempt, Map<String, dynamic> room) async {
    if (_graduated) return;
    _graduated = true;

    final gid = room["next_game_id"]?.toString() ?? attempt.gameId;
    final createdAt =
        room["created_at"]?.toString() ?? DateTime.now().toString();
    final players = Map<String, dynamic>.from(
      room["players"] as Map? ?? <String, dynamic>{},
    );

    await FirebaseDatabase.instance.ref("games/$gid").update(<String, dynamic>{
      "status": "STARTED",
      "created_at": createdAt,
      "updated_at": DateTime.now().toString(),
      "players": players,
    });
  }

  /// Leaves every room except [winner]. Kept losing rooms would keep counting
  /// us towards their batches and could start a second game with a ghost.
  void _withdrawOthers(_LobbyAttempt winner) {
    for (final attempt in List<_LobbyAttempt>.from(_attempts)) {
      if (identical(attempt, winner)) continue;
      _attempts.remove(attempt);
      _withdraw(attempt);
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

    final db = FirebaseDatabase.instance;
    try {
      final result = await db
          .ref("matchmakings/${attempt.roomKey}")
          .runTransaction((current) {
            if (current == null) return Transaction.abort();
            final room = Map<String, dynamic>.from(current as Map);
            if (room["next_game_id"]?.toString() != attempt.gameId) {
              // The batch moved on and the room was reused: our slot is gone.
              return Transaction.abort();
            }
            if (room["status"]?.toString() != "PENDING") {
              return Transaction.abort();
            }
            final players = Map<String, dynamic>.from(
              room["players"] as Map? ?? <String, dynamic>{},
            );
            if (players.remove(attempt.playerKey) == null) {
              return Transaction.abort();
            }
            room["players"] = players;
            return Transaction.success(room);
          }, applyLocally: false);
      if (result.committed == true) return;
    } catch (_) {}

    // Best effort: if that batch graduated with our slot already seated, tell
    // the game we are not coming.
    try {
      final snapshot = await db
          .ref("games/${attempt.gameId}/players")
          .get();
      final gamePlayers = snapshot.value;
      final seated =
          gamePlayers is Map &&
          gamePlayers.values.any(
            (p) => p is Map && p["user_id"]?.toString() == UserService.uid,
          );
      if (seated) {
        gamesRepository.addGameEvent(
          attempt.gameId,
          GamicoGameEventModel(type: "EXIT", userId: UserService.uid),
        );
      }
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

    final db = FirebaseDatabase.instance;
    final roomPath = "matchmakings/${attempt.roomKey}";

    attempt.disconnectionReference = db
        .ref("$roomPath/players/${attempt.playerKey}")
        .onDisconnect();
    await attempt.disconnectionReference?.remove();
    if (isClosed || _committed) return;

    final required = remoteUtility.matchmakingSettings.maxPlayers ?? 2;
    final now = DateTime.now().toString();

    TransactionResult result;
    try {
      result = await db.ref(roomPath).runTransaction((current) {
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
          "user_id": UserService.uid,
          "status": "ACCEPTED",
          "created_at": now,
          "updated_at": now,
        };
        room["players"] = players;
        if (players.length >= required) {
          room["status"] = "STARTED";
        }
        return Transaction.success(room);
      }, applyLocally: false);
    } catch (e) {
      if (isClosed || _committed) return;
      _rejoin(attempt);
      return;
    }

    if (isClosed || _committed) return;

    if (result.committed == true && result.snapshot.value != null) {
      // Back in the same room; the room listener resumes driving the lobby.
      // If our return just filled it, commit exactly like a join would.
      final room = Map<String, dynamic>.from(
        jsonDecode(jsonEncode(result.snapshot.value)) as Map,
      );
      if (room["status"]?.toString() == "STARTED") {
        _onRoomStarted(attempt, room);
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
          (p) => p is Map && p["user_id"]?.toString() == UserService.uid,
        );
    if (iAmSeated || isClosed || _committed) return;
    _rejoin(attempt);
  }

  /// Replaces a stale [attempt] with a fresh join of the same pool.
  void _rejoin(_LobbyAttempt attempt) {
    _attempts.remove(attempt);
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

  Future<void> _emitPlayersFound(Set<String?> ids) async {
    emit(state.copyWith(playersFound: ids.length));
    final profiles = await _fetchPlayerProfiles(ids);
    if (!isClosed) {
      emit(
        state.copyWith(
          playerNames: profiles.map((p) => p.$1).toList(),
          playerPhotos: profiles.map((p) => p.$2).toList(),
        ),
      );
    }
  }

  /// Returns one (name, photoUrl) record per player, ordered with the local
  /// user first. An empty photoUrl means no photo is available.
  Future<List<(String, String)>> _fetchPlayerProfiles(Set<String?> ids) async {
    final myUid = UserService.uid;
    final ordered = [myUid, ...ids.where((id) => id != null && id != myUid)];
    final profiles = <(String, String)>[];
    for (final uid in ordered) {
      if (uid == null) continue;
      if (uid == myUid) {
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
        if (localName.isEmpty) {
          localName = userCubit.state.user?.name ?? "";
        }
        profiles.add((localName.isNotEmpty ? localName : 'Vous', localPhoto));
        continue;
      }
      try {
        final snap = await FirebaseDatabase.instance.ref('users/$uid').get();
        final data = snap.value;
        if (data is Map) {
          profiles.add((
            data['name']?.toString() ?? '...',
            data['photo']?.toString() ?? '',
          ));
        } else {
          profiles.add(('...', ''));
        }
      } catch (_) {
        profiles.add(('...', ''));
      }
    }
    return profiles;
  }

  /// 2-player fallback: if we are still alone in a pending room after a short
  /// wait, start the game against a bot. Guarded by a transaction so a real
  /// opponent who joined at the last second always wins over the bot. A "no
  /// preference" search waits in several rooms — any of them can host the bot
  /// game, so one is picked at random for variety.
  void _manageFakeGame() async {
    final required = remoteUtility.matchmakingSettings.maxPlayers ?? 2;
    if (required > 2) return;

    await Future.delayed(5.seconds);

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
          if (players.length != 1 ||
              !players.containsKey(attempt.playerKey)) {
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

  void launchGame({bool fakeOpponent = false}) {
    if (isClosed || _launching) return;
    _launching = true;

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

  void abortGame() {
    // Leaving the lobby before the game starts removes only our own slots — for
    // every player alike, creator included — so the others stay in their rooms.
    // Once the match has started (or is launching) the lobby rooms are no
    // longer ours to touch; the in-game cubit owns disconnection from there on.
    final inLobby = state.status != RemoteGameStatus.success && !_launching;

    for (final attempt in _attempts) {
      attempt.disconnectionReference?.cancel();
      attempt.disconnectionReference = null;

      if (inLobby &&
          attempt.roomKey.isNotEmpty &&
          attempt.playerKey.isNotEmpty) {
        FirebaseDatabase.instance
            .ref("matchmakings/${attempt.roomKey}/players/${attempt.playerKey}")
            .remove();
      }
    }
  }

  @override
  Future<void> close() {
    abortGame();

    for (final attempt in _attempts) {
      attempt.cancelSubscriptions();
    }
    _connectedSubscription?.cancel();

    return super.close();
  }
}
