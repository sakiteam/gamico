import 'dart:io';
import 'dart:core';
import 'dart:async';
import 'dart:convert';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamico/commons/services/play.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:games_services/games_services.dart';
import 'package:gamico/commons/services/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/repositories/gamico_users_repository.dart';
import 'package:gamico/features/friend/cubits/friend_invitation_cubit.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  static PlayerData? gameServicesPlayer;

  final GamicoUserCubit userCubit;
  final GamicoUsersRepository usersRepository;
  final FriendInvitationCubit friendInvitationCubit;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<PlayerData?>? _playerSubscription;

  AuthenticationCubit({
    required this.userCubit,
    required this.usersRepository,
    required this.friendInvitationCubit,
  }) : super(
         AuthenticationState(
           status: AuthenticationStateStatus.initial,
           authenticated: UserService.authenticated,
         ),
       ) {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? firebaseUser,
    ) async {
      if (firebaseUser != null) {
        await GamicoGlobalService.waitWhile(() => !UserService.authenticated);

        _saveToken();

        final photo = firebaseUser.photoURL;
        if (photo != null && photo != userCubit.state.user?.photo) {
          usersRepository.updateUserPhoto(UserService.uid, photo);
        }

        userCubit.listenToUserChanges();

        await GamicoGlobalService.waitWhile(() => userCubit.state.user == null);

        emit(
          state.copyWith(
            status: AuthenticationStateStatus.success,
            authenticated: true,
          ),
        );
      } else {
        userCubit.cancelUserChangesListener();

        UserService.uid = "";
        userCubit.setUser(null);

        emit(
          state.copyWith(
            status: AuthenticationStateStatus.failure,
            authenticated: false,
          ),
        );
      }
    });

    _playerSubscription = GameAuth.player.listen((player) async {
      gameServicesPlayer = player;
      userCubit.setUserName(gameServicesPlayer?.displayName ?? "");
    });
  }

  Future<void> _saveToken() async {
    try {
      if (Platform.isIOS) {
        String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();

        if (apnsToken == null) {
          await Future.delayed(const Duration(minutes: 1));
          _saveToken();
          return;
        }
      }

      userCubit.setUserToken(await FirebaseMessaging.instance.getToken());
      FirebaseMessaging.instance.onTokenRefresh.listen(userCubit.setUserToken);
    } catch (e) {
      debugPrint("$e");
    }
  }

  Future<void> signIn() async {
    // Prevent the code frombeing called multiple times while loading
    if (state.status == AuthenticationStateStatus.loading) return;

    // Initiate loading
    emit(state.copyWith(status: AuthenticationStateStatus.loading));

    // Sign out if not already done
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      debugPrint(e.toString());
    }

    // Sign in to game services
    try {
      if (await PlayService.enableGameServices()) {
        String firebaseId = FirebaseAuth.instance.currentUser?.uid ?? "";
        String socialId = gameServicesPlayer?.playerID ?? "";
        FirebaseAuth.instance.currentUser?.updateDisplayName(
          gameServicesPlayer?.displayName ?? "",
        );

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

          userCubit.setUser(
            Gamico.instance.userFromJson(
              Map<String, dynamic>.from(data.values.first),
            ),
          );

          friendInvitationCubit.listenToInvitations();
        } else {
          final user = Gamico.instance.userSettings.createNewUser(
            firebaseId,
            socialId,
          );

          UserService.uid = await usersRepository.createUser(user);

          // Save user information
          userCubit.setUser(user);
        }

        emit(
          state.copyWith(
            status: AuthenticationStateStatus.success,
            authenticated: true,
          ),
        );
      } else {
        handleError();
      }
    } catch (e) {
      debugPrint(e.toString());
      handleError();
    }
  }

  Future<void> signOut() async {
    await FirebaseAuth.instance.signOut();

    UserService.uid = "";
    userCubit.setUser(null);

    emit(state.copyWith(authenticated: false));
  }

  void handleError() {
    UserService.uid = "";
    userCubit.setUser(null);

    emit(
      state.copyWith(
        status: AuthenticationStateStatus.failure,
        authenticated: false,
      ),
    );
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    _playerSubscription?.cancel();
    return super.close();
  }
}
