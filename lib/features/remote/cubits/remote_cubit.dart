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
import 'package:gamico/commons/models/gamico_game_model.dart';
import 'package:gamico/features/adventure/utilities/remote_utility.dart';
import 'package:gamico/commons/repositories/gamico_games_repository.dart';

part 'remote_state.dart';

/// Cubit for managing the remote game mode.
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
  String gameId = "";
  StreamSubscription<DatabaseEvent>? _streamSubscription;
  OnDisconnect? _userDisconnectionReference;
  String createdGameStatus = "";

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

    gameId = "";
    _streamSubscription?.cancel();

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

    final ref = FirebaseDatabase.instance.ref();

    final matchmakingSettings = remoteUtility.matchmakingSettings;

    int matchmakingLevel = matchmakingSettings.getMatchmakingLevel(
      userCubit.state.user!,
    );

    final int minOpponentLevel;
    final int maxOpponentLevel;

    // if (DateTime.now().year < 2025) {

    minOpponentLevel = matchmakingSettings.minLevel;
    maxOpponentLevel = matchmakingSettings.maxLevel + 1;

    // } else {
    // minOpponentLevel = max(
    //   matchmakingSettings.minLevel,
    //   matchmakingLevel - matchmakingSettings.increment,
    // );
    // maxOpponentLevel = min(
    //   matchmakingSettings.maxLevel,
    //   matchmakingLevel + matchmakingSettings.increment,
    // );
    // }

    final maxLevelLength = matchmakingSettings.maxLevel.toString().length;

    String formatLevel(int level) {
      return level.toString().padLeft(maxLevelLength, "0");
    }

    final modePotentialString = [
      if (matchmakingSettings.mode != null) matchmakingSettings.mode,
      if (state.level != null) state.level,
    ].join(" ");

    final modeString = matchmakingSettings.mode == null
        ? " "
        : " $modePotentialString ";

    // bool currentPlayerIsCreator;
    // DataSnapshot snapshot;

    final snapshot = await ref
        .child("games")
        .orderByChild("status")
        .startAt("PENDING$modeString${formatLevel(minOpponentLevel)}")
        .endAt("PENDING$modeString${formatLevel(maxOpponentLevel)}")
        .limitToFirst(1)
        .get();

    // snapshot = await ref
    //     .child("games")
    //     .orderByChild("status")
    //     .equalTo("PENDING")
    //     .limitToFirst(1)
    //     .get();

    creator = !snapshot.exists;

    if (creator == true) {
      DateTime now = DateTime.now();

      // Generate a new child location
      String playerKey = ref.push().key ?? "";

      gameId = await gamesRepository.createGame(
        GamicoGameModel(
          events: const {},
          players: {
            playerKey: GamicoGamePlayerModel(
              status: "ACCEPTED",
              userId: UserService.uid,
              createdAt: now,
              updatedAt: now,
            ),
          },
          status: "PENDING$modeString${formatLevel(matchmakingLevel)}",
        ),
      );

      // Notify Irié Bi Irié Alex
      // _sendUserNotification(
      //   "-N99UonKL3fJdKmGQLQl",
      //   "Nouveau jeu !",
      // "Une partie en ligne a été lancée par $playerName. Voulez-vous le rejoindre ?"
      //   Languages.of(context)
      //       .notificationsNewGameDescription(LocalStorageService.displayName),
      //   null,
      // );

      _userDisconnectionReference = FirebaseDatabase.instance
          .ref("games")
          .child(gameId)
          .onDisconnect();
      await _userDisconnectionReference?.update({"status": "ABORTED"});

      // await gamesRepository.addGamePlayer(
      //   gameId,
      //   GamePlayerModel(
      //     status: "ACCEPTED",
      //     userId: UserService.uid,
      //   ),
      // );

      createdGameStatus = "PENDING";

      _streamSubscription?.cancel();
      // _streamSubscription = FirebaseDatabase.instance
      //     .ref("games/$gameId/status")
      //     .onValue
      //     .listen((event) {
      //   final status = event.snapshot.value.toString();

      //   createdGameStatus = status;

      //   if (status == "STARTED") {
      //     launchGame();
      //     _streamSubscription?.cancel();
      //   }
      // });

      _streamSubscription = FirebaseDatabase.instance
          .ref("games/$gameId")
          .onValue
          .listen((event) {
            final rawData = event.snapshot.value;
            final validData = jsonDecode(jsonEncode(rawData));
            final gameData = GamicoGameModel.fromJson(
              Map<String, dynamic>.from(validData ?? {}),
            );
            final gameStatus = gameData.status ?? "";
            final gamePlayers = gameData.players?.values ?? [];
            final gamePlayersIds = gamePlayers.map((e) => e.userId).toSet();
            final requiredPlayersCount = matchmakingSettings.maxPlayers ?? 2;

            createdGameStatus = gameStatus;

            if (gameStatus == "STARTED") {
              emit(
                state.copyWith(
                  fakeOpponent: gamePlayersIds.length < requiredPlayersCount,
                  playersFound: gamePlayersIds.length,
                ),
              );

              launchGame();
              _streamSubscription?.cancel();
            } else {
              _emitPlayersFound(gamePlayersIds);
            }
          });

      if (!remoteUtility.isDeveloper &&
          !appScreenshots &&
          Gamico.instance.playSettings?.enableFakeOpponent == true) {
        _manageFakeGame();
      }
    } else if (creator == false) {
      final data = jsonDecode(jsonEncode(snapshot.value)) as Map;

      gameId = data.keys.first ?? "";

      DatabaseReference gameRef = FirebaseDatabase.instance.ref().child(
        "games/$gameId",
      );

      final playerRef = gameRef.child("players").push();
      final playerKey = playerRef.key ?? "";

      bool firstRun = true;
      final result = await gameRef.runTransaction((Object? game) {
        if (firstRun) {
          firstRun = false;
          return Transaction.success(null);
        }

        if (game == null) {
          return Transaction.abort();
        }

        Map<String, dynamic> currentGame = Map<String, dynamic>.from(
          game as Map,
        );

        if (!currentGame["status"].toString().contains("PENDING")) {
          return Transaction.abort();
        }

        DateTime now = DateTime.now();

        final playersMap = currentGame["players"] as Map? ?? {};
        final requiredPlayersCount = matchmakingSettings.maxPlayers ?? 2;

        if (playersMap.length + 1 >= requiredPlayersCount) {
          currentGame["status"] = "STARTED";
        }
        currentGame["players"] ??= <String, dynamic>{};
        currentGame["players"][playerKey] = <String, dynamic>{
          "created_at": now.toString(),
          "updated_at": now.toString(),
          "status": "ACCEPTED",
          "user_id": UserService.uid,
        };

        return Transaction.success(currentGame);
      }, applyLocally: false);

      if (result.committed == false) {
        _init();
      } else {
        _userDisconnectionReference = FirebaseDatabase.instance
            .ref("games/$gameId/players/$playerKey")
            .onDisconnect();
        await _userDisconnectionReference?.remove();

        final rawData = result.snapshot.value;
        final validData = jsonDecode(jsonEncode(rawData));
        final gameData = GamicoGameModel.fromJson(
          Map<String, dynamic>.from(validData ?? {}),
        );
        final gameStatus = gameData.status ?? "";
        final gamePlayers = gameData.players?.values ?? [];
        final gamePlayersIds = gamePlayers.map((e) => e.userId).toSet();
        final requiredPlayersCount = matchmakingSettings.maxPlayers ?? 2;

        if (gameStatus == "STARTED") {
          emit(
            state.copyWith(
              fakeOpponent: gamePlayersIds.length < requiredPlayersCount,
            ),
          );
          launchGame();
        } else {
          _streamSubscription?.cancel();
          _streamSubscription = FirebaseDatabase.instance
              .ref("games/$gameId")
              .onValue
              .listen((event) {
                final rawData = event.snapshot.value;
                final validData = jsonDecode(jsonEncode(rawData));
                final gameData = GamicoGameModel.fromJson(
                  Map<String, dynamic>.from(validData ?? {}),
                );
                final gameStatus = gameData.status ?? "";
                final gamePlayers = gameData.players?.values ?? [];
                final gamePlayersIds = gamePlayers.map((e) => e.userId).toSet();

                if (gameStatus == "STARTED") {
                  emit(
                    state.copyWith(
                      fakeOpponent:
                          gamePlayersIds.length < requiredPlayersCount,
                      playersFound: gamePlayersIds.length,
                    ),
                  );
                  launchGame();
                  _streamSubscription?.cancel();
                } else {
                  _emitPlayersFound(gamePlayersIds);
                }
              });
        }
      }
    }
  }

  Future<void> _emitPlayersFound(Set<String?> ids) async {
    emit(state.copyWith(playersFound: ids.length));
    final names = await _fetchPlayerNames(ids);
    if (!isClosed) emit(state.copyWith(playerNames: names));
  }

  Future<List<String>> _fetchPlayerNames(Set<String?> ids) async {
    final myUid = UserService.uid;
    final ordered = [myUid, ...ids.where((id) => id != null && id != myUid)];
    final names = <String>[];
    for (final uid in ordered) {
      if (uid == null) continue;
      try {
        final snap =
            await FirebaseDatabase.instance.ref('users/$uid').get();
        final data = snap.value;
        if (data is Map) {
          names.add(data['name']?.toString() ?? '...');
        } else {
          names.add('...');
        }
      } catch (_) {
        names.add('...');
      }
    }
    return names;
  }

  void _manageFakeGame() async {
    final requiredPlayersCount = remoteUtility.matchmakingSettings.maxPlayers ?? 2;
    if (requiredPlayersCount > 2) return;

    await Future.delayed(5.seconds);

    if (state.status == RemoteGameStatus.success) return;

    if (dirtyStateForFakeGame) return;

    final DateTime now = DateTime.now();

    await gamesRepository.addGamePlayer(
      gameId,
      GamicoGamePlayerModel(
        createdAt: now,
        updatedAt: now,
        status: "ACCEPTED",
        userId: UserService.uid,
      ),
    );

    if (dirtyStateForFakeGame) return;

    await gamesRepository.updateGameStatus(gameId, "STARTED");
  }

  void launchGame() {
    if (isClosed) return;

    _userDisconnectionReference?.cancel();
    _userDisconnectionReference = null;

    emit(
      state.copyWith(
        status: RemoteGameStatus.success,
        creator: () => creator,
        gameId: gameId,
      ),
    );
  }

  void abortGame() {
    _userDisconnectionReference?.cancel();
    _userDisconnectionReference = null;

    if (gameId.isNotEmpty) {
      createdGameStatus = "ABORTED";
      gamesRepository.updateGameStatus(gameId, "ABORTED");
    }
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();

    abortGame();

    return super.close();
  }
}
