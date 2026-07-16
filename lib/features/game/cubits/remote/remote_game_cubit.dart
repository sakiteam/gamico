import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/models/gamico_game_model.dart';
import 'package:gamico/commons/repositories/gamico_games_repository.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/services/global.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:gamico/features/adventure/utilities/adventure_utility.dart';
import 'package:gamico/features/adventure/utilities/remote_utility.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:meta/meta.dart';

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

  // Remote game id
  final String gameId;

  // Remote game model
  GamicoGameModel? currentGame;

  // Remote requests managers
  int replayRequests = 0;
  int readinessRequests = 0;

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
          .listen((event) {
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
          });

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

      currentGame = await gamesRepository.readGame(gameId);

      final playersIds =
          (currentGame?.players?.values ?? <GamicoGamePlayerModel>[])
              .map<String>((e) {
                return e.userId.toString();
              })
              .toList();

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
            .listen((event) {
              if (event.snapshot.exists) {
                final rawData = event.snapshot.value;
                final validData = jsonDecode(jsonEncode(rawData));

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
            });
        opponentStreamSubscriptions.add(sub);
      } else {
        for (final opponentId in otherPlayerIds) {
          final sub = FirebaseDatabase.instance
              .ref()
              .child("users/$opponentId")
              .onValue
              .listen((event) {
                if (event.snapshot.exists) {
                  final rawData = event.snapshot.value;
                  final validData = jsonDecode(jsonEncode(rawData));

                  var finalOpponent = Gamico.instance.userFromJson(
                    Map<String, dynamic>.from(validData),
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

                  if (!state.fakeOpponent &&
                      gameCubit.state.over &&
                      !(finalOpponent.online ?? true)) {
                    gamesRepository.addGameEvent(
                      gameId,
                      GamicoGameEventModel(
                        type: "DISCONNECTION",
                        userId: opponentId,
                      ),
                    );
                  }
                }
              });
          opponentStreamSubscriptions.add(sub);
        }
      }

      // Seeds
      final seedModulo = remoteUtility.seedModulo;

      seed1 = (currentGame?.createdAt?.millisecond ?? 0) % seedModulo;
      seed2 = (currentGame?.createdAt?.microsecond ?? 0) % seedModulo;

      // Listen to game events
      if (!state.fakeOpponent) {
        gameEventsStreamSubscription = FirebaseDatabase.instance
            .ref()
            .child("games/$gameId/events")
            .onChildAdded
            .listen((event) async {
              if (event.snapshot.exists) {
                final rawData = event.snapshot.value;
                final validData = jsonDecode(jsonEncode(rawData));
                final currentGameEvent = GamicoGameEventModel.fromJson(
                  validData,
                );

                if (currentGameEvent.type == "READINESS") {
                  readinessRequests++;

                  if (readinessRequests >= playersIds.length) {
                    gameCubit.startGame();
                  }
                } else if (currentGameEvent.type == "MOVE") {
                  if (currentGameEvent.userId != UserService.uid) {
                    gameCubit.settings?.receiveMoveFromRemotePlayer(
                      currentGameEvent,
                    );
                  }
                } else if (currentGameEvent.type == "EXIT") {
                  if (currentGameEvent.userId != UserService.uid) {
                    _manageRemoteExit(currentGameEvent.userId ?? "");
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
                      emit(state.copyWith(gameEndStatus: "REPLAY_IMPOSSIBLE"));
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
                        state.copyWith(gameEndStatus: "INVITATION_ACCEPTATION"),
                      );
                    } else if (replayRequests == 1) {
                      emit(
                        state.copyWith(gameEndStatus: "", opponentExited: true),
                      );
                    }
                  }
                } else if (currentGameEvent.type == "REJECTION") {
                  replayRequests = 0;

                  if (currentGameEvent.userId == UserService.uid) {
                    emit(state.copyWith(gameEndStatus: ""));
                  } else {
                    emit(state.copyWith(gameEndStatus: "INVITATION_REJECTION"));
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
            });
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

        await userDisconnectionReference?.update({
          "coins": ServerValue.increment(
            -Gamico.instance.gameSettings.playMinimumCoins,
          ),
          if (mode == null) "defeats": ServerValue.increment(1),
          if (mode == null) "trophies": ServerValue.increment(-1),
          if (mode != null)
            "progression/$mode/defeats": ServerValue.increment(1),
          if (mode != null)
            "progression/$mode/trophies": ServerValue.increment(-1),
          "updated_at": DateTime.now().toString(),
        });
      }

      // Declare game as ready when really ready
      await GamicoGlobalService.waitWhile(
        () =>
            state.opponent == null ||
            state.opponents.length < otherPlayerIds.length,
      );

      gameCubit.settings?.initGame();

      if (state.fakeOpponent) {
        gameCubit.startGame();
      } else {
        gamesRepository.addGameEvent(
          gameId,
          GamicoGameEventModel(type: "READINESS", userId: UserService.uid),
        );
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
