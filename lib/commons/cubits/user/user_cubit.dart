import 'dart:math';
import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:games_services/games_services.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/global.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:gamico/commons/services/play.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:simple_connection_checker/simple_connection_checker.dart';
import 'package:gamico/commons/services/gratification.dart';
import 'package:gamico/commons/repositories/gamico_users_repository.dart';

part 'user_state.dart';

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
  // Timer? _pendingSignOutTimer;

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

            ref.update({"online": true, "updated_at": "$now"});
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
            () => !PlayService.gameServicesEnabled,
          );

          Achievements.unlock(
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

  void incrementLevel() {
    if (UserService.uid.isEmpty) return;
    usersRepository.incrementUserLevel(UserService.uid);
  }

  void updateUserLevel(int level) {
    if (UserService.uid.isEmpty) return;

    // [GAMICO-FIX] name/level-loss investigation.
    // Guard + instrumentation: a level is written as an ABSOLUTE value, and the
    // level getters default to 1 when the user isn't loaded. So writing while
    // `state.user` is null — or writing a value below the known level — is how
    // a real progression gets clobbered down to 1. Refuse both and log the
    // culprit (value + whether the user was null + call stack).
    final current = state.user?.level;
    if (state.user == null || level < (current ?? 0)) {
      debugPrint(
        "⚠️ updateUserLevel($level) BLOCKED "
        "userNull=${state.user == null} currentLevel=$current\n"
        "${StackTrace.current}",
      );
      return;
    }

    usersRepository.updateUserLevel(UserService.uid, level);
  }

  void updateStars(List<int> stars) {
    if (UserService.uid.isEmpty) return;
    usersRepository.updateUserStars(UserService.uid, stars);
  }

  void incrementVictories() async {
    if (UserService.uid.isEmpty) return;
    final finalCrowns = (state.user?.trophies ?? 0) + 1;
    await usersRepository.incrementUserTrophies(UserService.uid);
    await _submitTacticiansScore(finalCrowns);
  }

  void incrementDefeats() async {
    if (UserService.uid.isEmpty) return;
    final finalCrowns = (state.user?.trophies ?? 0) - 1;

    await usersRepository.decrementUserTrophies(
      UserService.uid,
      finalCrowns >= 0 ? 1 : 0,
    );

    if (finalCrowns >= 0) {
      await _submitTacticiansScore(finalCrowns);
    }
  }

  Future<void> incrementCowries([int cowries = 1]) async {
    if (UserService.uid.isEmpty) return;
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
    await usersRepository.incrementUserCoins(UserService.uid, cowries);

    // Submit score to leaderboards
    await _submitCollectorsScore(finalDiamonds);
  }

  Future<void> decrementCowries([int cowries = 1]) async {
    if (UserService.uid.isEmpty) return;
    final userDiamonds = (state.user?.coins ?? 0);
    final cowriesToDecrement = min(cowries, userDiamonds);

    if (cowriesToDecrement == 0) return;

    // Show that diamonds are decreasing
    emit(
      state.copyWith(
        cowriesUpdate: state.cowriesUpdate + 1,
        cowriesUpdateDifference: -cowriesToDecrement,
      ),
    );

    // Decrement user diamonds really
    await usersRepository.decrementUserCoins(
      UserService.uid,
      cowriesToDecrement,
    );

    // Submit score to leaderboards
    await _submitCollectorsScore(max(userDiamonds - cowries, 0));
  }

  void updateUserProgression(Map<String, dynamic> progression) {
    if (UserService.uid.isEmpty) return;

    // [GAMICO-FIX] name/level-loss investigation.
    // Guard + instrumentation: callers build `progression` by merging onto the
    // current `state.user.progression`. If `state.user` is null they merge onto
    // an empty map, so this write would overwrite EVERY game's progression with
    // a near-empty one. Refuse when the user isn't loaded and log the culprit.
    if (state.user == null) {
      debugPrint(
        "⚠️ updateUserProgression BLOCKED (user not loaded) "
        "progression=$progression\n${StackTrace.current}",
      );
      return;
    }

    usersRepository.updateUserProgression(UserService.uid, progression);
  }

  void updateUserSkins(Map<String, dynamic> skins) {
    if (UserService.uid.isEmpty) return;
    usersRepository.updateUserSkins(UserService.uid, skins);
  }

  void setPremium() {
    if (UserService.uid.isEmpty) return;
    usersRepository.updateUserPremium(UserService.uid, true);
  }

  Future<void> _submitCollectorsScore(int score) async {
    await GamicoGlobalService.waitWhile(() => !PlayService.gameServicesEnabled);

    if ((Gamico.instance.playSettings?.inactivePlayersLeaderboardId ?? "")
        .isEmpty) {
      return;
    }

    await Leaderboards.submitScore(
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

    if ((Gamico.instance.playSettings?.activePlayersLeaderboardId ?? "")
        .isEmpty) {
      return;
    }

    await Leaderboards.submitScore(
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
    // [GAMICO-FIX] name/level-loss investigation.
    // Instrumentation: clearing a previously-loaded user also wipes the
    // persisted local copy (UserService.setUser(null) below), which is what
    // makes a name/level "disappear". Log it so it can be correlated with the
    // auth event that triggered it.
    if (user == null && state.user != null) {
      debugPrint(
        "⚠️ setUser(null) clearing loaded user\n${StackTrace.current}",
      );
    }

    emit(state.copyWith(user: () => user));

    UserService.setUser(user);
  }

  void setUserName(String name) {
    final currentName = state.user?.name;

    if (UserService.authenticated && name.isNotEmpty && currentName != name) {
      // [GAMICO-FIX] name/level-loss investigation.
      // Instrumentation: the only spontaneous writer of the name is the
      // GameAuth.player stream (game services displayName). On an unstable
      // Game Center (e.g. the simulator) this can push a placeholder/wrong
      // alias over the real name — log every change so it's visible.
      debugPrint(
        "⚠️ setUserName: '$currentName' -> '$name' (game services displayName)",
      );
      usersRepository.updateUserName(UserService.uid, name);
      FirebaseAuth.instance.currentUser?.updateDisplayName(name);
    }
  }

  void setUserToken(String? token) async {
    if (token == null) return;

    if (!UserService.authenticated) return;
    if (FirebaseAuth.instance.currentUser == null) return;

    await usersRepository.updateUserToken(UserService.uid, token);
  }

  void listenToUserChanges() {
    _streamSubscription?.cancel();

    if (!UserService.authenticated) return;

    _streamSubscription = FirebaseDatabase.instance
        .ref()
        .child("users/${UserService.uid}")
        .onValue
        .listen(manageUserChanges);
  }

  void manageUserChanges(DatabaseEvent event) async {
    if (event.snapshot.value != null) {
      final value = Gamico.instance.userFromJson(
        jsonDecode(jsonEncode(event.snapshot.value)),
      );

      // A real value arrived: cancel any pending sign-out scheduled by a
      // previous (transient) null event.
      // _pendingSignOutTimer?.cancel();
      // _pendingSignOutTimer = null;

      if (value != null) {
        setUser(value);
      }

      if (!_managed) {
        _manageDisconnection();
      }
    } else {
      // setUser(null);

      // if (!await SimpleConnectionChecker.isConnectedToInternet()) return;

      // final uid = UserService.uid;
      // if (uid.isEmpty) return;

      // try {
      //   final snapshot = await FirebaseDatabase.instance
      //       .ref("users/$uid")
      //       .get();

      //   if (snapshot.exists && snapshot.value != null) {
      //     // False alarm: the node is still there. Resync the user so the UI
      //     // reflects the real value (the listener may stay stale on null).
      //     final value = Gamico.instance.userFromJson(
      //       jsonDecode(jsonEncode(snapshot.value)),
      //     );

      //     if (value != null && value.name != null) {
      //       setUser(value);
      //     }

      //     return;
      //   }
      // } catch (_) {
      //   // Could not confirm deletion (e.g. permission/transient error) —
      //   // err on the safe side and keep the user signed in.
      //   return;
      // }

      // await FirebaseAuth.instance.signOut();
    }
  }

  void cancelUserChangesListener() {
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
      cancelUserChangesListener();
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
