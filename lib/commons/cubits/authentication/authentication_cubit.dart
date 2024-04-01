import 'dart:core';
import 'dart:convert';
// import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/repositories/gamico_users_repository.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:firebase_game_services/firebase_game_services.dart';
import 'package:gamico/commons/services/play.dart';
import 'package:gamico/commons/services/user.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  AuthenticationCubit({
    required this.usersRepository,
    required this.userCubit,
  }) : super(
          AuthenticationState(
            status: AuthenticationStateStatus.initial,
            authenticated: UserService.authenticated,
          ),
        ) {
    if (UserService.authenticated) {
      _saveToken();

      final photo = FirebaseAuth.instance.currentUser?.photoURL;

      if (photo != null && photo != userCubit.state.user?.photo) {
        usersRepository.updateUserPhoto(UserService.uid, photo);
      }
    }
  }

  final GamicoUsersRepository usersRepository;
  final GamicoUserCubit userCubit;

  Future<void> _saveToken() async {
    String? token = await FirebaseMessaging.instance.getToken();

    if (token != null) await _updateUser(token);

    FirebaseMessaging.instance.onTokenRefresh.listen(_updateUser);
  }

  Future<void> _updateUser(String token) async {
    if (UserService.authenticated) {
      usersRepository.updateUserToken(UserService.uid, token);
      LocalStorageService.token = token;
    }
  }

  Future<void> signIn() async {
    // Prevent the code frombeing called multiple times while loading
    if (state.status == AuthenticationStateStatus.loading) return;

    // Initiate loading
    emit(state.copyWith(
      status: AuthenticationStateStatus.loading,
    ));

    // Sign out if not already done
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint(e.toString());
    }

    // Sign in to game services
    try {
      if (await PlayService.enableGameServices()) {
        UserService.displayName =
            (await FirebaseGameServices.instance.getPlayerName()) ?? "";
        String firebaseId = FirebaseAuth.instance.currentUser?.uid ?? "";
        String socialId =
            (await FirebaseGameServices.instance.getPlayerId()) ?? "";
        FirebaseAuth.instance.currentUser
            ?.updateDisplayName(UserService.displayName);

        final snapshot = await FirebaseDatabase.instance
            .ref()
            .child("users")
            .orderByChild("social_id")
            .equalTo(socialId)
            .limitToFirst(1)
            .get();

        if (snapshot.exists) {
          final data = jsonDecode(jsonEncode(snapshot.value));

          UserService.uid = data.keys.first;
          UserService.authenticated = true;

          userCubit.setUser(Gamico.instance
              .userFromJson(Map<String, dynamic>.from(data.values.first)));
        } else {
          // String? referrerId =
          //     GlobalService.dynamicLink?.link.queryParameters["referrer_id"];

          final user =
              Gamico.instance.userSettings.createNewUser(firebaseId, socialId);

          // T(
          //   type: Platform.isAndroid ? "google" : "apple",
          //   defeats: 0,
          //   level: 1,
          //   victories: 0,
          //   photo: FirebaseAuth.instance.currentUser?.photoURL,
          //   firebaseId: firebaseId,
          //   socialId: socialId,
          //   name: UserService.displayName,
          //   token: "",
          //   referrerId: null,
          //   online: true,
          //   achievements: const <String, int>{},

          //   //

          //   cowries: 50,
          //   crowns: 0,
          //   cards: CardService.defaultCards,
          //   decks: [
          //     [...CardService.defaultCards.keys],
          //     const [],
          //     const [],
          //   ],
          //   stars: const [3],
          //   activeDeck: 0,
          // );

          UserService.uid = await usersRepository.createUser(user);
          UserService.authenticated = true;

          // if (referrerId != null) {
          //   userCubit.rewardReferrer(referrerId, context);
          // }

          // Save user information
          userCubit.setUser(user);

          // userCubit.listenToUserChanges();

          // Save Firebase token
          _saveToken();

          // Wait for user cubit listeners to be loaded
          await Future.delayed(const Duration(seconds: 1));

          // Unlock beginner achievement
          // TODOS
          // userCubit.unlockBeginnerAchievement();
        }

        emit(state.copyWith(
          status: AuthenticationStateStatus.success,
          authenticated: true,
        ));
      } else {
        declareError();
      }
    } catch (e) {
      debugPrint(e.toString());
      declareError();
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();

    UserService.authenticated = false;
    UserService.uid = "";
    userCubit.setUser(null);

    emit(state.copyWith(
      authenticated: false,
    ));
  }

  void declareError() {
    UserService.authenticated = false;
    UserService.uid = "";
    userCubit.setUser(null);

    emit(state.copyWith(
      status: AuthenticationStateStatus.failure,
      authenticated: false,
    ));
  }
}
