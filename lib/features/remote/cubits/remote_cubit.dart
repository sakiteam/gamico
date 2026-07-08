import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:gamico/commons/services/layout.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/features/adventure/utilities/remote_utility.dart';
import 'package:gamico/commons/repositories/gamico_games_repository.dart';

part 'remote_state.dart';

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

  /// Id of the real game the current lobby will graduate into (a fresh push
  /// key generated when the room is first created and carried by the room so
  /// every occupant agrees on it).
  String gameId = "";

  /// Our own slot key inside the lobby room.
  String _myPlayerKey = "";

  /// Fixed database path of the lobby room we are gathering in.
  String _roomKey = "";

  /// Live subscription to the lobby room (drives the "players found" count and
  /// triggers graduation once the room fills).
  StreamSubscription<DatabaseEvent>? _roomSubscription;

  /// Live subscription to the graduated game node — the single authoritative
  /// signal that the match has started, for every player alike.
  StreamSubscription<DatabaseEvent>? _gameSubscription;

  /// Removes only our own slot from the lobby room if we disconnect while still
  /// waiting.
  OnDisconnect? _userDisconnectionReference;

  String createdGameStatus = "";

  /// Guards a single graduation write per lobby.
  bool _graduated = false;

  /// Guards a single launch (the game-node listener can fire more than once).
  bool _launching = false;

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

    _roomSubscription?.cancel();
    _gameSubscription?.cancel();

    gameId = "";
    _roomKey = "";
    _myPlayerKey = "";
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

  /// Builds the fixed lobby-room key for the current mode / level range. Every
  /// player sharing the same matchmaking settings produces the same key and so
  /// converges on the same room.
  String _buildRoomKey() {
    final settings = remoteUtility.matchmakingSettings;

    final width = settings.maxLevel.toString().length < 3
        ? 3
        : settings.maxLevel.toString().length;
    String pad(int value) => value.toString().padLeft(width, "0");
    final levelRange = "${pad(settings.minLevel)}_${pad(settings.maxLevel)}";

    final modePart = _sanitizeKey(settings.mode ?? "default");
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

    final db = FirebaseDatabase.instance;
    final settings = remoteUtility.matchmakingSettings;
    final required = settings.maxPlayers ?? 2;

    _roomKey = _buildRoomKey();
    final roomRef = db.ref("matchmakings/$_roomKey");

    final myPlayerKey = db.ref().push().key ?? "";
    _myPlayerKey = myPlayerKey;
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
      "players": <String, dynamic>{myPlayerKey: buildMyPlayer()},
    };

    // Atomic create-or-join. Because Firebase serialises transactions on a
    // node, simultaneous searchers can never split into separate games.
    final result = await roomRef.runTransaction((current) {
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

      players[myPlayerKey] = buildMyPlayer();
      room["players"] = players;
      if (players.length >= required) {
        room["status"] = "STARTED";
      }
      return Transaction.success(room);
    }, applyLocally: false);

    if (isClosed) return;

    if (result.committed != true || result.snapshot.value == null) {
      // Transient contention / abort: retry from scratch.
      _init();
      return;
    }

    final room = Map<String, dynamic>.from(
      jsonDecode(jsonEncode(result.snapshot.value)) as Map,
    );
    gameId = room["next_game_id"]?.toString() ?? freshGameId;
    createdGameStatus = room["status"]?.toString() ?? "PENDING";

    // Leave only our own slot behind on disconnect — for every player, creator
    // included — so one player quitting the lobby never ends it for the others.
    _userDisconnectionReference = db
        .ref("matchmakings/$_roomKey/players/$myPlayerKey")
        .onDisconnect();
    await _userDisconnectionReference?.remove();

    // Keep the live "players found" count fresh, and graduate once the room
    // fills. A room whose next_game_id changed has already graduated and been
    // replaced by a new batch — the game-node listener drives our launch then.
    _roomSubscription?.cancel();
    _roomSubscription = roomRef.onValue.listen((event) {
      final value = event.snapshot.value;
      if (value == null) return;
      final data = Map<String, dynamic>.from(
        jsonDecode(jsonEncode(value)) as Map,
      );
      if (data["next_game_id"]?.toString() != gameId) return;

      final players = Map<String, dynamic>.from(
        data["players"] as Map? ?? <String, dynamic>{},
      );
      final ids = players.values
          .map((p) => (p as Map)["user_id"]?.toString())
          .whereType<String>()
          .toSet();
      _emitPlayersFound(ids);

      if (data["status"]?.toString() == "STARTED") {
        _graduate(data);
      }
    });

    // The single authoritative launch signal: the graduated game node going
    // STARTED. Never races, and is never overwritten by later batches.
    _gameSubscription?.cancel();
    _gameSubscription = db.ref("games/$gameId").onValue.listen((event) {
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
      creator = orderedKeys.isNotEmpty && orderedKeys.first == _myPlayerKey;

      launchGame(fakeOpponent: realIds.length < required);
    });

    // Our own join may have already filled the room: graduate right away.
    if (createdGameStatus == "STARTED") {
      _graduate(room);
    }

    // 2-player pools fall back to a bot if nobody shows up in time.
    if (!remoteUtility.isDeveloper &&
        !appScreenshots &&
        Gamico.instance.playSettings?.enableFakeOpponent == true) {
      _manageFakeGame();
    }
  }

  /// Copies a full lobby room into its real (graduated) game node. Every
  /// finishing client writes the same authoritative data idempotently, so the
  /// game exists even if the player who filled the room drops out in the same
  /// instant. The launch itself is driven uniformly by the game-node listener.
  Future<void> _graduate(Map<String, dynamic> room) async {
    if (_graduated) return;
    _graduated = true;

    final gid = room["next_game_id"]?.toString() ?? gameId;
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
  /// opponent who joined at the last second always wins over the bot.
  void _manageFakeGame() async {
    final required = remoteUtility.matchmakingSettings.maxPlayers ?? 2;
    if (required > 2) return;

    await Future.delayed(5.seconds);

    if (isClosed) return;
    if (state.status == RemoteGameStatus.success) return;
    if (_graduated || _launching) return;

    final roomRef = FirebaseDatabase.instance.ref("matchmakings/$_roomKey");
    final result = await roomRef.runTransaction((current) {
      if (current == null) return Transaction.abort();
      final room = Map<String, dynamic>.from(current as Map);
      if (room["status"]?.toString() != "PENDING") return Transaction.abort();
      if (room["next_game_id"]?.toString() != gameId) {
        return Transaction.abort();
      }

      final players = Map<String, dynamic>.from(
        room["players"] as Map? ?? <String, dynamic>{},
      );
      // Only fall back to a bot while we are genuinely alone.
      if (players.length != 1 || !players.containsKey(_myPlayerKey)) {
        return Transaction.abort();
      }

      room["status"] = "STARTED";
      return Transaction.success(room);
    }, applyLocally: false);

    if (isClosed) return;
    if (result.committed == true && result.snapshot.value != null) {
      final room = Map<String, dynamic>.from(
        jsonDecode(jsonEncode(result.snapshot.value)) as Map,
      );
      _graduate(room);
    }
  }

  void launchGame({bool fakeOpponent = false}) {
    if (isClosed || _launching) return;
    _launching = true;

    _userDisconnectionReference?.cancel();
    _userDisconnectionReference = null;
    _roomSubscription?.cancel();
    _gameSubscription?.cancel();

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
    _userDisconnectionReference?.cancel();
    _userDisconnectionReference = null;

    if (_roomKey.isEmpty || _myPlayerKey.isEmpty) return;

    // Leaving the lobby before the game starts removes only our own slot — for
    // every player alike, creator included — so the others stay in the room.
    // Once the match has started (or is launching) the lobby room is no longer
    // ours to touch; the in-game cubit owns disconnection from there on.
    final inLobby = state.status != RemoteGameStatus.success && !_launching;
    if (inLobby) {
      FirebaseDatabase.instance
          .ref("matchmakings/$_roomKey/players/$_myPlayerKey")
          .remove();
    }
  }

  @override
  Future<void> close() {
    _roomSubscription?.cancel();
    _gameSubscription?.cancel();

    abortGame();

    return super.close();
  }
}
