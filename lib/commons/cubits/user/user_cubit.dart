import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/global.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:gamico/commons/services/play.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gamico/commons/services/gratification.dart';
import 'package:firebase_game_services/firebase_game_services.dart';
import 'package:gamico/commons/repositories/gamico_users_repository.dart';

part 'user_state.dart';

enum AchievementType {
  beginner(id: "CgkIuoiIu5YHEAIQBA"),
  modest(id: "CgkIuoiIu5YHEAIQBQ"),
  extrovert(id: "CgkIuoiIu5YHEAIQBg"),
  tactician(id: "CgkIuoiIu5YHEAIQBw");

  final String id;

  const AchievementType({
    required this.id,
  });
}

class GamicoUserCubit extends Cubit<GamicoUserState> {
  // UserCubit({
  //   required super.usersRepository,
  // });

  GamicoUserCubit({
    required this.usersRepository,
    // required this.fromJson,
    // required this.toJson,
  }) : super(GamicoUserState(user: UserService.getUser())) {
    if (UserService.authenticated) {
      listenToUserChanges();
    }
  }

  // final dynamic Function(Map<String, dynamic>) fromJson;
  // final Map<String, dynamic> Function(dynamic) toJson;

  bool _managed = false;
  GamicoUsersRepository usersRepository;
  StreamSubscription? _streamSubscription;
  StreamSubscription<DatabaseEvent>? _disconnectionSubscription;
  OnDisconnect? _disconnectionReference;

  void _manageDisconnection() {
    _managed = true;

    final ref = FirebaseDatabase.instance.ref("users/${UserService.uid}");

    _disconnectionSubscription = FirebaseDatabase.instance
        .ref(".info/connected")
        .onValue
        .listen((event) {
      final online = event.snapshot.value as bool? ?? false;

      if (online) {
        final now = DateTime.now();

        _disconnectionReference = ref.onDisconnect();

        _disconnectionReference?.update({
          "online": false,
          "updated_at": "$now",
        });

        ref.update({
          "online": true,
          "updated_at": "$now",
        });
      }
    });
  }

  bool isAchivementUnlocked(String id) {
    final achievements = state.user?.achievements ?? {};
    return (achievements[id] ?? 0) == 100;
  }

  void unlockAchievement(String id, [double percentage = 100, int steps = 0]) {
    if (UserService.authenticated) {
      if (!isAchivementUnlocked(id)) {
        () async {
          await GamicoGlobalService.waitWhile(
              () => !PlayService.gameServicesEnabled);

          FirebaseGameServices.instance.unlock(
            achievement: Achievement(
              androidID: id,
              iOSID: id,
              percentComplete: percentage,
              steps: steps,
            ),
          );
        }();

        FirebaseDatabase.instance
            .ref("users/${UserService.uid}/achievements/$id")
            .set(percentage);

        if (percentage == 100) {
          incrementCowries(3);
        }
      }
    }
  }

  // void rewardReferrer(String referrerId) {
  //   usersRepository.incrementUserCoins(referrerId, 50);
  //
  //   // GlobalService.sendUserNotification(
  //   //   referrerId,
  //   //   Languages.instance.referralNotificationTitle,
  //   //   Languages.instance.referralNotificationBody(UserService.displayName),
  //   //   null,
  //   //   usersRepository,
  //   // );
  // }

  void incrementLevel() {
    usersRepository.incrementUserLevel(UserService.uid);
  }

  void updateStars(List<int> stars) {
    usersRepository.updateUserStars(UserService.uid, stars);
  }

  void incrementVictories() async {
    final finalCrowns = (state.user?.trophies ?? 0) + 1;
    await usersRepository.incrementUserTrophies(UserService.uid);
    await _submitTacticiansScore(finalCrowns);
  }

  void incrementDefeats() async {
    final finalCrowns = (state.user?.trophies ?? 0) - 1;

    await usersRepository.decrementUserTrophies(
        UserService.uid, finalCrowns >= 0 ? 1 : 0);

    if (finalCrowns >= 0) {
      await _submitTacticiansScore(finalCrowns);
    }
  }

  Future<void> incrementCowries([int cowries = 1]) async {
    // Show that diamonds are increasing
    emit(
      state.copyWith(
        cowriesUpdate: state.cowriesUpdate + 1,
        cowriesUpdateDifference: cowries,
      ),
    );

    // Get user final diamonds
    final finalDiamonds = (state.user?.coins ?? 0) + cowries;

    // Increment user diamonds really
    await usersRepository.incrementUserCoins(
      UserService.uid,
      cowries,
    );

    // Submit score to leaderboards
    await _submitCollectorsScore(finalDiamonds);
  }

  Future<void> decrementCowries([int cowries = 1]) async {
    // Show that diamonds are decreasing
    emit(
      state.copyWith(
        cowriesUpdate: state.cowriesUpdate + 1,
        cowriesUpdateDifference: -cowries,
      ),
    );

    // Get user diamonds
    final userDiamonds = (state.user?.coins ?? 0);

    // Decrement user diamonds really
    await usersRepository.decrementUserCoins(
      UserService.uid,
      min(cowries, userDiamonds),
    );

    // Submit score to leaderboards
    await _submitCollectorsScore(max(userDiamonds - cowries, 0));
  }

  Future<void> _submitCollectorsScore(int score) async {
    await GamicoGlobalService.waitWhile(() => !PlayService.gameServicesEnabled);
    await FirebaseGameServices.instance.submitScore(
      score: Score(
        androidLeaderboardID:
            Gamico.instance.playSettings?.inactivePlayersLeaderboardId ?? "",
        iOSLeaderboardID:
            Gamico.instance.playSettings?.inactivePlayersLeaderboardId ?? "",
        value: score,
      ),
    );
  }

  Future<void> _submitTacticiansScore(int score) async {
    await GamicoGlobalService.waitWhile(() => !PlayService.gameServicesEnabled);
    await FirebaseGameServices.instance.submitScore(
      score: Score(
        androidLeaderboardID:
            Gamico.instance.playSettings?.activePlayersLeaderboardId ?? "",
        iOSLeaderboardID:
            Gamico.instance.playSettings?.activePlayersLeaderboardId ?? "",
        value: score,
      ),
    );
  }

  // dynamic?
  void setUser(dynamic user) {
    emit(state.copyWith(
      user: () => user,
    ));

    UserService.setUser(user);
  }

  void listenToUserChanges() {
    _streamSubscription?.cancel();

    if (UserService.authenticated) {
      _streamSubscription = FirebaseDatabase.instance
          .ref()
          .child("users/${UserService.uid}")
          .onValue
          .listen(manageUserChanges);
    }
  }

  void manageUserChanges(DatabaseEvent event) {
    if (event.snapshot.value != null) {
      final value = Gamico.instance.userFromJson(
        jsonDecode(jsonEncode(event.snapshot.value)),
      );

      setUser(value);

      if (!_managed) {
        _manageDisconnection();
      }
    }
  }

  void _cancelUserChangesListener() {
    _managed = false;
    _streamSubscription?.cancel();
    _disconnectionSubscription?.cancel();
    _disconnectionReference?.cancel();
  }

  Future<void> updateUserGratification(
    int lastGratificationDiamonds,
    int nextGratificationDiamonds,
  ) async {
    incrementCowries(lastGratificationDiamonds);

    // print(state.user?.toJson());
    // print("---");

    usersRepository.updateUserGratification(
      UserService.uid,
      lastGratificationDiamonds,
      nextGratificationDiamonds,
    );

    GratificationService.gratifiedAt = DateTime.now();

    // print(state.user?.toJson());

    // forceLastGratificationDate();
  }

  // void forceLastGratificationDate() {
  //   if (state.user != null) {
  //     final json = state.user!.toJson();
  //     json["gratified_at"] = DateTime.now().toString();
  //     emit(state.copyWith(
  //       user: T.fromJson(json),
  //     ));
  //   }
  // }

  @override
  void onChange(Change<GamicoUserState> change) {
    final oldUser = change.currentState.user;
    final newUser = change.nextState.user;

    if (newUser != null && oldUser == null) {
      listenToUserChanges();
    } else if (newUser == null && oldUser != null) {
      _cancelUserChangesListener();
    }

    super.onChange(change);
  }

  @override
  Future<void> close() {
    _streamSubscription?.cancel();
    _disconnectionSubscription?.cancel();
    _disconnectionReference?.cancel();

    return super.close();
  }

  /// Pass the tutorial
  // unlockBeginnerAchievement() {
  //   unlockAchievement(AchievementType.beginner.id);
  // }

  /// Play a multiplayer game
  // unlockExtrovertAchievement() {
  //   unlockAchievement(AchievementType.extrovert.id);
  // }

  /// Complete the singleplayer mode
  // unlockTacticianAchievement() {
  //   unlockAchievement(AchievementType.tactician.id);
  // }

  /// Give up in a game
  // unlockModestAchievement() {
  //   unlockAchievement(AchievementType.modest.id);
  // }

  ///////////////////////

  // void setCards(Map<String, int>? cards) {
  //   usersRepository.setCards(UserService.uid, cards);
  // }

  // void setDecks(List<List<String>>? decks) {
  //   usersRepository.setDecks(UserService.uid, decks);
  // }

  // void setActiveDeck(int activeDeck) {
  //   usersRepository.setActiveDeck(UserService.uid, activeDeck);
  // }

  // void upgradeCard(String cardId) {
  //   final cards = state.user?.cards ?? {};
  //   final currentLevel = (cards[cardId] ?? 0);
  //   cards[cardId] = currentLevel + 1;
  //   decrementCowries(currentLevel * 10);
  //   setCards(cards);
  // }

  // void deleteCard(String cardId) {
  //   final activeDeck = state.user?.activeDeck ?? 0;
  //   List<List<String>> decks = state.user?.decks ?? [];
  //   decks += List.filled(3 - decks.length, List.filled(8, ""));
  //   final currentDeck = decks[activeDeck];
  //   final currentCardIndex = currentDeck.indexOf(cardId);
  //   currentDeck[currentCardIndex] = "";
  //   setDecks(decks);
  // }

  // void useCard(CardUtility card) {
  //   final activeDeck = state.user?.activeDeck ?? 0;
  //   List<List<String>> decks = state.user?.decks ?? [];
  //   decks += List.filled(3 - decks.length, List.filled(8, ""));
  //   final currentDeck = decks[activeDeck];
  //   for (int i = 0; i < currentDeck.length; i++) {
  //     if (currentDeck[i].isEmpty) {
  //       currentDeck[i] = card.type.id;
  //       break;
  //     }
  //   }
  //   setDecks(decks);
  // }

  // void acquireCard(CardUtility card) {
  //   final cards = state.user?.cards ?? {};
  //   cards[card.type.id] = 1;
  //   decrementCowries(card.cost);
  //   setCards(cards);
  // }
}
