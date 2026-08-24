import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/models/gamico_game_model.dart';
import 'package:gamico/commons/repositories/gamico_games_repository.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/services/global.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:gamico/features/adventure/utilities/adventure_utility.dart';
import 'package:gamico/features/adventure/utilities/remote_utility.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';

part 'remote_game_state.dart';

class GamicoRemoteGameCubit extends Cubit<GamicoRemoteGameState> {
  GamicoRemoteGameCubit({
    required this.gameId,
    required bool creator,
    required this.gamesRepository,
    required this.gameCubit,
    required bool fakeOpponent,
    required this.remoteUtility,
    required int? level,
    required this.adventureUtility,
    bool friend = false,
  }) : super(
         GamicoRemoteGameState(
           creator: creator,
           fakeOpponent: fakeOpponent,
           remoteUtility: remoteUtility,
           adventureUtility: adventureUtility,
           friend: friend,
           level: level,
           userInitialLevel: adventureUtility?.getUserLevel(
             gameCubit.userCubit.state.user,
           ),
         ),
       );

  @override
  void emit(GamicoRemoteGameState state) {
    if (isClosed) return;
    super.emit(state);
  }

  final GamicoGameCubit gameCubit;

  final RemoteUtility remoteUtility;
  final AdventureUtility? adventureUtility;

  // Usual repository
  final GamicoGamesRepository gamesRepository;

  // Remote game stream subscriptions
  StreamSubscription? newGameStreamSubscription;
  StreamSubscription? opponentStreamSubscription;
  List<StreamSubscription> opponentStreamSubscriptions = [];
  StreamSubscription? gameEventsStreamSubscription;

  // Remote game user disconnection manager
  OnDisconnect? userDisconnectionReference;

  /// Watches `.info/connected` while the disconnection penalty above is armed:
  /// Android drops the database connection almost as soon as the app is
  /// backgrounded (answering a message is enough), which fires the
  /// `onDisconnect` and docks coins/defeats before the game's own (properly
  /// grace-period-guarded) abandonment logic gets a chance to run. On every
  /// reconnection while the match is still active, the penalty is refunded and
  /// re-armed, so a quick app switch doesn't score a defeat.
  StreamSubscription<DatabaseEvent>? _disconnectionPenaltySubscription;
  bool _sawInitialConnected = false;

  /// Field path → increment applied by the armed disconnection penalty (e.g.
  /// `-5` on `coins`), so a reconnection can write back the exact opposite.
  Map<String, num>? _armedDisconnectionPenalty;

  // Remote game id
  final String gameId;

  // Remote game model
  GamicoGameModel? currentGame;

  // Remote requests managers
  int replayRequests = 0;

  /// Readiness roll-call, by uid. The game deals only when every player still
  /// expected has declared READINESS. Counting by uid (not a raw counter)
  /// survives duplicated events, and a player who EXITs before the game
  /// starts (left the app between matchmaking and launch) is struck from the
  /// expected set instead of blocking the table forever.
  final Set<String> _readyPlayerIds = {};
  final Set<String> _exitedPlayerIds = {};
  Set<String> _expectedPlayerIds = {};
  Timer? _readinessFallbackTimer;

  void _startReadinessFallbackTimer() {
    _readinessFallbackTimer?.cancel();
    _readinessFallbackTimer = Timer(const Duration(seconds: 10), () {
      if (isClosed || gameCubit.state.ready) return;

      final unready = _expectedPlayerIds
          .difference(_readyPlayerIds)
          .difference(_exitedPlayerIds);

      if (unready.isNotEmpty) {
        for (final uid in unready) {
          _exitedPlayerIds.add(uid);
          gameCubit.settings?.onRemoteUserDisconnectedDuringGame(uid);
        }
      }
      _checkReadiness();
    });
  }

  void _checkReadiness() {
    if (gameCubit.state.ready) return;
    final expected = _expectedPlayerIds.difference(_exitedPlayerIds);
    if (expected.isEmpty) return;
    if (_readyPlayerIds.containsAll(expected)) {
      _readinessFallbackTimer?.cancel();
      gameCubit.startGame();
    }
  }

  // Remote game seeds
  late final int seed1;
  late final int seed2;

  // Holds the id of a new hypothetical game
  String newGameId = "";

  void resetGameEndStatus() {
    emit(state.copyWith(gameEndStatus: ""));
  }

  void withdraw() {
    gamesRepository.addGameEvent(
      gameId,
      GamicoGameEventModel(type: "WITHDRAW", userId: UserService.uid),
    );
  }

  void acceptInvitation() {
    gamesRepository.addGameEvent(
      gameId,
      GamicoGameEventModel(type: "ACCEPTATION", userId: UserService.uid),
    );
  }

  void rejectInvitation() {
    gamesRepository.addGameEvent(
      gameId,
      GamicoGameEventModel(type: "REJECTION", userId: UserService.uid),
    );
  }

  void replay([int? level]) {
    final opponent = state.opponent;

    if (opponent == null) return;

    if (opponent.online == false || state.fakeOpponent) {
      emit(state.copyWith(gameEndStatus: "REPLAY_IMPOSSIBLE"));
    } else if (opponent.broke == true) {
      gamesRepository.addGameEvent(
        gameId,
        GamicoGameEventModel(type: "NEEDINESS", userId: state.opponentId),
      );
    } else {
      gamesRepository.addGameEvent(
        gameId,
        GamicoGameEventModel(
          type: "REPLAY",
          userId: UserService.uid,
          data: level == null ? null : {"level": level},
        ),
      );
    }
  }

  void setRemoteGameInternetError(bool remoteGameInternetError) {
    emit(state.copyWith(remoteGameInternetError: remoteGameInternetError));
  }

  void setNewRemoteGameActive(bool newRemoteGameActive, [int? level]) {
    emit(
      state.copyWith(
        newRemoteGameActive: newRemoteGameActive,
        nextLevel: level == null ? null : () => level,
      ),
    );

    declareCurrentUserExit();
  }

  void declareCurrentUserExit() {
    if (state.fakeOpponent) return;

    gamesRepository.addGameEvent(
      gameId,
      GamicoGameEventModel(
        // data: <String, dynamic>{
        //   "row": tile.row,
        //   "col": tile.col,
        // },
        type: "EXIT",
        userId: UserService.uid,
      ),
    );
  }

  Future<void> _launchNewGame() async {
    if (Gamico.instance.playSettings?.singlePlayerWhenFake != true) {
      emit(state.copyWith(gameEndStatus: "INVITATION_ACCEPTATION"));
    }

    final playersEntries = (currentGame?.players?.entries.toList() ?? [])
      ..sort((a, b) => a.key.compareTo(b.key));
    final sortedPlayerUids = playersEntries.map((e) => e.value.userId).toList();
    final isFirstJoiner =
        sortedPlayerUids.length > 1 && sortedPlayerUids[1] == UserService.uid;

    if (isFirstJoiner) {
      newGameId = await gamesRepository.createGame(
        GamicoGameModel(
          events: const {},
          players: currentGame?.players,
          status: "CREATED",
        ),
      );

      newGameStreamSubscription = FirebaseDatabase.instance
          .ref()
          .child("games/$newGameId/status")
          .onValue
          .listen(
            (event) {
              final status = event.snapshot.value.toString();

              if (status == "STARTED") {
                emit(
                  state.copyWith(
                    newGameCreator: true,
                    newGameId: newGameId,
                    replay: true,
                  ),
                );
              }
            },
            onError: (e) =>
                debugPrint("⚠️ newGameStreamSubscription error => $e"),
          );

      gamesRepository.addGameEvent(
        gameId,
        GamicoGameEventModel(
          data: <String, dynamic>{"id": newGameId},
          type: "IDENTIFICATION",
          userId: UserService.uid,
        ),
      );
    }
  }

  String get developerAppleId => remoteUtility.developerAppleId;
  String get developerAndroidId => remoteUtility.developerAndroidId;

  void init() {
    gameCubit.onInit = () async {
      GameService.gameSkipped =
          adventureUtility != null && (state.userInitialLevel == state.level);

      try {
        currentGame = await gamesRepository.readGame(gameId);
      } catch (e) {
        debugPrint('[GamicoRemoteGameCubit] Error reading game data: $e');
        setRemoteGameInternetError(true);
        return;
      }

      final playersIds =
          (currentGame?.players?.values ?? <GamicoGamePlayerModel>[])
              .map<String>((e) {
                return e.userId.toString();
              })
              .toList();

      _expectedPlayerIds = playersIds.toSet();

      final otherPlayerIds = playersIds
          .where((element) => element != UserService.uid)
          .toList();
      final Map<String, dynamic> loadedOpponents = {};

      for (var s in opponentStreamSubscriptions) {
        s.cancel();
      }
      opponentStreamSubscriptions = [];

      if (otherPlayerIds.isEmpty) {
        final developerId = remoteUtility.developerId;
        final sub = FirebaseDatabase.instance
            .ref()
            .child("users/$developerId")
            .onValue
            .listen(
              (event) {
                if (event.snapshot.exists) {
                  final rawData = event.snapshot.value;
                  final validData = _deepCastMap(rawData);

                  var finalOpponent = Gamico.instance.userFromJson(
                    Map<String, dynamic>.from(validData),
                  );

                  final currentUser = gameCubit.userCubit.state.user!;

                  finalOpponent = Gamico.instance.userSettings
                      .userCreateFakeOpponent(currentUser, finalOpponent);

                  emit(
                    state.copyWith(
                      opponents: [finalOpponent],
                      opponent: () => finalOpponent,
                    ),
                  );
                }
              },
              onError: (e) =>
                  debugPrint("⚠️ developer opponent subscription error => $e"),
            );
        opponentStreamSubscriptions.add(sub);
      } else {
        // Only the handful of fields actually rendered/consulted for an
        // opponent (see player_profile_button, game_profile_poster, the
        // `broke`/`online` checks below) are listened to individually,
        // instead of the whole `users/$opponentId` node — that node also
        // carries ~20 fields (achievements, progression, skins, trophies…)
        // that change constantly across a player's other games and used to
        // re-download the entire user object to every opponent watching them.
        // `userCreateFakeOpponent` additionally needs a few identity fields
        // to build its synthetic opponent, so those are listened to too, but
        // only when this game actually runs in fake-opponent mode.
        // `name`/`photo` are identity fields — they don't change for the
        // duration of a match, so they're read once below instead of
        // holding a live listener open on them like `online`/`coins` for
        // the whole game.
        const staticFields = <String>{"name", "photo"};
        final fieldsToWatch = <String>{
          "online",
          "coins",
          if (state.fakeOpponent) ...{
            "type",
            "achievements",
            "firebaseId",
            "socialId",
            "token",
          },
        };

        final initialFields = <String, Map<String, dynamic>>{
          for (final id in otherPlayerIds) id: {"id": id},
        };
        await Future.wait([
          for (final opponentId in otherPlayerIds)
            for (final field in staticFields)
              FirebaseDatabase.instance
                  .ref()
                  .child("users/$opponentId/$field")
                  .get()
                  .then((snapshot) {
                    initialFields[opponentId]![field] = snapshot.exists
                        ? _deepCastValue(snapshot.value)
                        : null;
                  }),
        ]);

        for (final opponentId in otherPlayerIds) {
          final fields = initialFields[opponentId]!;

          for (final field in fieldsToWatch) {
            final sub = FirebaseDatabase.instance
                .ref()
                .child("users/$opponentId/$field")
                .onValue
                .listen(
                  (event) {
                    fields[field] = event.snapshot.exists
                        ? _deepCastValue(event.snapshot.value)
                        : null;

                    var finalOpponent = Gamico.instance.userFromJson(
                      Map<String, dynamic>.from(fields),
                    );

                    if (state.fakeOpponent) {
                      final currentUser = gameCubit.userCubit.state.user!;

                      finalOpponent = Gamico.instance.userSettings
                          .userCreateFakeOpponent(currentUser, finalOpponent);
                    }

                    loadedOpponents[opponentId] = finalOpponent;

                    final sortedOpponents = otherPlayerIds
                        .map((id) => loadedOpponents[id])
                        .where((o) => o != null)
                        .toList();

                    emit(
                      state.copyWith(
                        opponents: sortedOpponents,
                        opponent: () => sortedOpponents.firstOrNull,
                      ),
                    );

                    // A dropped `online` flag (backgrounding, flaky network,
                    // even an app kill) is NOT treated as an exit here: it
                    // would race the game's own turn-timeout cascade, which
                    // already auto-plays/skips the absent player's turns and
                    // only eliminates them after repeated misses. A real
                    // departure still reaches _manageRemoteExit through the
                    // explicit "EXIT" game event sent on quit. Presence loss
                    // is only recorded once the game is already over, purely
                    // for analytics.
                    if (!state.fakeOpponent &&
                        !(finalOpponent.online ?? true) &&
                        gameCubit.state.over) {
                      gamesRepository.addGameEvent(
                        gameId,
                        GamicoGameEventModel(
                          type: "DISCONNECTION",
                          userId: opponentId,
                        ),
                      );
                    }
                  },
                  onError: (e) => debugPrint(
                    "⚠️ opponent $field subscription error => $e",
                  ),
                );
            opponentStreamSubscriptions.add(sub);
          }
        }
      }

      // Seeds
      // Derived from the shared `createdAt` timestamp (written once by the
      // host and read identically by every device) so all clients land on
      // the same seed for deterministic, lockstep-reproducible shuffles.
      // This used to be reduced modulo `remoteUtility.seedModulo` (10),
      // which collapsed the deck shuffle to only 10 possible outcomes
      // across all online games (e.g. Crazy Eights hands repeating).
      // Use the full timestamp instead, masked to a positive 32-bit int
      // since that's what `Random()` expects.
      final createdAtUs = currentGame?.createdAt?.microsecondsSinceEpoch ?? 0;
      seed1 = createdAtUs & 0x7FFFFFFF;
      seed2 = (createdAtUs ~/ 7) & 0x7FFFFFFF;

      // Listen to game events
      if (!state.fakeOpponent) {
        gameEventsStreamSubscription = FirebaseDatabase.instance
            .ref()
            .child("games/$gameId/events")
            .onChildAdded
            .listen(
              (event) async {
                if (event.snapshot.exists) {
                  final rawData = event.snapshot.value;
                  final validData = _deepCastMap(rawData);
                  final currentGameEvent = GamicoGameEventModel.fromJson(
                    validData,
                  );

                  if (currentGameEvent.type == "READINESS") {
                    final uid = currentGameEvent.userId;
                    if (uid != null) _readyPlayerIds.add(uid);
                    _checkReadiness();
                  } else if (currentGameEvent.type == "MOVE") {
                    if (currentGameEvent.userId != UserService.uid) {
                      gameCubit.settings?.receiveMoveFromRemotePlayer(
                        currentGameEvent,
                      );
                    }
                  } else if (currentGameEvent.type == "EXIT") {
                    if (currentGameEvent.userId != UserService.uid) {
                      final uid = currentGameEvent.userId ?? "";
                      // A player leaving before the deal (quit between
                      // matchmaking and launch) will never declare READINESS:
                      // stop expecting them or the table waits forever.
                      if (!gameCubit.state.ready && uid.isNotEmpty) {
                        _exitedPlayerIds.add(uid);
                        _checkReadiness();
                      }
                      _manageRemoteExit(uid);
                    }
                  } else if (currentGameEvent.type == "ABANDONMENT") {
                    if (currentGameEvent.userId != UserService.uid) {
                      gameCubit.settings?.onRemoteUserGaveUp(
                        currentGameEvent.userId ?? "",
                      );
                      // endGame("B", "ABANDONMENT");
                    }
                  } else if (currentGameEvent.type == "DISCONNECTION") {
                    if (currentGameEvent.userId != UserService.uid) {
                      if (state.gameEndStatus == "INTERNAL_INVITATION") {
                        emit(
                          state.copyWith(gameEndStatus: "REPLAY_IMPOSSIBLE"),
                        );
                      }
                    }
                  } else if (currentGameEvent.type == "NEEDINESS") {
                    if (currentGameEvent.userId == UserService.uid) {
                      emit(state.copyWith(gameEndStatus: "INTERNAL_NEEDINESS"));
                    } else {
                      emit(state.copyWith(gameEndStatus: "EXTERNAL_NEEDINESS"));
                    }
                  } else if (currentGameEvent.type == "REPLAY") {
                    replayRequests++;

                    final level = currentGameEvent.data?["level"]?.toInt();

                    if (level != null) {
                      final stateNextLevel = state.nextLevel;

                      if (stateNextLevel != null && level != stateNextLevel) {
                        replayRequests = 0;

                        emit(state.copyWith(gameEndStatus: ""));
                      }
                    }

                    if (replayRequests == playersIds.length) {
                      _launchNewGame();
                    } else {
                      if (currentGameEvent.userId == UserService.uid) {
                        emit(
                          state.copyWith(gameEndStatus: "INTERNAL_INVITATION"),
                        );
                      } else if (state.gameEndStatus != "INTERNAL_INVITATION") {
                        emit(
                          state.copyWith(gameEndStatus: "EXTERNAL_INVITATION"),
                        );
                      }
                    }
                  } else if (currentGameEvent.type == "WITHDRAW") {
                    replayRequests--;

                    if (currentGameEvent.userId == UserService.uid) {
                      emit(state.copyWith(gameEndStatus: ""));
                    } else {
                      emit(
                        state.copyWith(gameEndStatus: "INVITATION_WITHDRAWAL"),
                      );
                    }
                  } else if (currentGameEvent.type == "ACCEPTATION") {
                    replayRequests++;

                    if (replayRequests == playersIds.length) {
                      _launchNewGame();
                    } else {
                      if (currentGameEvent.userId == UserService.uid) {
                        emit(
                          state.copyWith(
                            gameEndStatus: "INVITATION_ACCEPTATION",
                          ),
                        );
                      } else if (replayRequests == 1) {
                        emit(
                          state.copyWith(
                            gameEndStatus: "",
                            opponentExited: true,
                          ),
                        );
                      }
                    }
                  } else if (currentGameEvent.type == "REJECTION") {
                    replayRequests = 0;

                    if (currentGameEvent.userId == UserService.uid) {
                      emit(state.copyWith(gameEndStatus: ""));
                    } else {
                      emit(
                        state.copyWith(gameEndStatus: "INVITATION_REJECTION"),
                      );
                    }
                  } else if (currentGameEvent.type == "IDENTIFICATION") {
                    if (currentGameEvent.userId != UserService.uid) {
                      newGameId = currentGameEvent.data?["id"];

                      if (state.creator) {
                        await gamesRepository.updateGameStatus(
                          newGameId,
                          "STARTED",
                        );
                      }

                      emit(
                        state.copyWith(
                          newGameCreator: false,
                          newGameId: newGameId,
                          replay: true,
                        ),
                      );
                    }
                  }
                }
              },
              onError: (e) =>
                  debugPrint("⚠️ gameEventsStreamSubscription error => $e"),
            );
      }

      // Disconnection management
      userDisconnectionReference = FirebaseDatabase.instance
          .ref("users")
          .child(UserService.uid)
          .onDisconnect();

      if (Gamico.instance.playSettings?.exitUserWhenDisconnected == true ||
          !state.fakeOpponent) {
        // For moded games (e.g. an embedded game), the disconnection penalty
        // targets that mode's own progression namespace instead of the
        // top-level stats. Coins stay a single shared wallet.
        final mode = state.remoteUtility.matchmakingSettings.mode;

        _armedDisconnectionPenalty = {
          "coins": -Gamico.instance.gameSettings.playMinimumCoins,
          if (mode == null) "defeats": 1,
          if (mode == null) "trophies": -1,
          if (mode != null) "progression/$mode/defeats": 1,
          if (mode != null) "progression/$mode/trophies": -1,
        };

        try {
          await userDisconnectionReference?.update(
            _disconnectionPenaltyPayload(_armedDisconnectionPenalty!),
          );
        } catch (e) {
          // onDisconnect().update() peut échouer si l'utilisateur est
          // hors-ligne ou si les règles Firebase bloquent l'écriture.
          // Non-fatal : on continue l'initialisation de la partie.
          debugPrint('[GamicoRemoteGameCubit] onDisconnect update failed: $e');
        }

        // Self-healing: a brief background trip drops the database connection
        // (see field doc above) and fires the penalty above almost instantly.
        // Refund and re-arm on every genuine reconnection while the match is
        // still active, so only a real, lasting abandonment is ever scored.
        _sawInitialConnected = false;
        _disconnectionPenaltySubscription?.cancel();
        _disconnectionPenaltySubscription = FirebaseDatabase.instance
            .ref(".info/connected")
            .onValue
            .listen((event) {
              if (event.snapshot.value != true) return;
              if (!_sawInitialConnected) {
                _sawInitialConnected = true;
                return;
              }
              _refundAndRearmDisconnectionPenalty();
            });
      }

      // Declare game as ready when really ready. The wait is bounded:
      // profiles normally resolve in well under a second, and one unreadable
      // opponent profile must not strand the whole table on the loader
      // forever (our READINESS would never be sent) — names and avatars all
      // have their own fallbacks downstream.
      final profilesDeadline = DateTime.now().add(const Duration(seconds: 2));
      await GamicoGlobalService.waitWhile(
        () =>
            DateTime.now().isBefore(profilesDeadline) &&
            (state.opponent == null ||
                state.opponents.length < otherPlayerIds.length),
      );

      gameCubit.settings?.initGame();

      if (state.fakeOpponent) {
        gameCubit.startGame();
      } else {
        gamesRepository.addGameEvent(
          gameId,
          GamicoGameEventModel(type: "READINESS", userId: UserService.uid),
        );
        _startReadinessFallbackTimer();
      }
    };

    gameCubit.onExitGame = () {
      // A game can declare the current moment a legitimate stopping point
      // (e.g. between two settled rounds of a score-based match): leaving is
      // then treated like leaving a finished game, not an abandonment.
      final penaltyFree =
          gameCubit.settings?.exitIsPenaltyFree?.call() ?? false;

      if (!gameCubit.state.over && !penaltyFree) {
        final mode = state.remoteUtility.matchmakingSettings.mode;
        final onModedRemoteResult =
            Gamico.instance.playSettings?.onModedRemoteResult;

        if (mode != null && onModedRemoteResult != null) {
          // Host owns result handling for this mode (exit mid-game = defeat).
          onModedRemoteResult(gameCubit.userCubit, mode, false, 0);
        } else {
          if (adventureUtility == null ||
              (state.userInitialLevel == state.level)) {
            gameCubit.userCubit.decrementCowries(
              Gamico.instance.gameSettings.playMinimumCoins,
            );
          }

          gameCubit.userCubit.incrementDefeats();
        }
      }

      declareCurrentUserExit();
    };

    gameCubit.onGiveUp = () {
      if (state.fakeOpponent) return;

      gamesRepository.addGameEvent(
        gameId,
        GamicoGameEventModel(type: "ABANDONMENT", userId: UserService.uid),
      );
    };

    gameCubit.onGameEnd = cleanUserDisconnectionReference;
  }

  void cleanUserDisconnectionReference() {
    // Do not punish the player if he/her leaves the game after its end
    userDisconnectionReference?.cancel();
    userDisconnectionReference = null;
    _disconnectionPenaltySubscription?.cancel();
    _disconnectionPenaltySubscription = null;
    _armedDisconnectionPenalty = null;
  }

  Map<String, dynamic> _disconnectionPenaltyPayload(Map<String, num> deltas) =>
      {
        for (final entry in deltas.entries)
          entry.key: ServerValue.increment(entry.value),
        "updated_at": DateTime.now().toString(),
      };

  Future<void> _refundAndRearmDisconnectionPenalty() async {
    final deltas = _armedDisconnectionPenalty;
    if (deltas == null || gameCubit.state.over) return;

    try {
      await FirebaseDatabase.instance
          .ref("users")
          .child(UserService.uid)
          .update(
            _disconnectionPenaltyPayload(
              deltas.map((key, value) => MapEntry(key, -value)),
            ),
          );
    } catch (e) {
      debugPrint(
        '[GamicoRemoteGameCubit] disconnection penalty refund failed: $e',
      );
    }

    try {
      userDisconnectionReference = FirebaseDatabase.instance
          .ref("users")
          .child(UserService.uid)
          .onDisconnect();
      await userDisconnectionReference?.update(
        _disconnectionPenaltyPayload(deltas),
      );
    } catch (e) {
      debugPrint('[GamicoRemoteGameCubit] onDisconnect re-arm failed: $e');
    }
  }

  void _manageRemoteExit(String userId) {
    emit(state.copyWith(gameEndStatus: "", opponentExited: true));

    if (gameCubit.state.over) {
      replayRequests = 0;
    } else {
      gameCubit.settings?.onRemoteUserDisconnectedDuringGame(
        userId,
      ); // endGame("B", "EXIT")
    }
  }

  Future<void> sendMoveToRemotePlayer(Map<String, dynamic> data) async {
    if (state.fakeOpponent) return;

    await gamesRepository.addGameEvent(
      gameId,
      GamicoGameEventModel(data: data, type: "MOVE", userId: UserService.uid),
    );
  }

  @override
  Future<void> close() {
    _readinessFallbackTimer?.cancel();
    // Cancel all usual streams
    newGameStreamSubscription?.cancel();
    opponentStreamSubscription?.cancel();
    for (var s in opponentStreamSubscriptions) {
      s.cancel();
    }
    gameEventsStreamSubscription?.cancel();

    cleanUserDisconnectionReference();

    return super.close();
  }
}

Map<String, dynamic> _deepCastMap(dynamic map) {
  if (map is! Map) return {};
  return map.map(
    (key, value) => MapEntry(key.toString(), _deepCastValue(value)),
  );
}

dynamic _deepCastValue(dynamic value) {
  if (value is Map) {
    return _deepCastMap(value);
  } else if (value is List) {
    return value.map(_deepCastValue).toList();
  }
  return value;
}
