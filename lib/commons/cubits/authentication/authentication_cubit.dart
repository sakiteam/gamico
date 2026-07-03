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
        // [GAMICO-FIX] name/level-loss investigation.
        // Instrumentation: authStateChanges emitted null (no persisted user,
        // a signOut(), or a token-refresh failure). This clears the user — log
        // it so a vanished name/level can be traced back here.
        debugPrint(
          "⚠️ authStateChanges -> null: clearing session\n${StackTrace.current}",
        );

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
    // try {
    //   await FirebaseAuth.instance.signOut();
    // } catch (e) {
    //   debugPrint(e.toString());
    // }

    // Sign in to game services
    try {
      if (await PlayService.enableGameServices()) {
        String firebaseId = FirebaseAuth.instance.currentUser?.uid ?? "";
        String socialId = gameServicesPlayer?.playerID ?? "";

        // [GAMICO-FIX] name/level-loss investigation.
        // Guard: an unstable game services layer (typically the simulator's
        // Game Center) can resolve an empty playerID. Proceeding would either
        // match the wrong user or, worse, fall through to createNewUser and
        // spawn a blank account. Bail without touching the existing session.
        if (socialId.isEmpty) {
          debugPrint(
            "⚠️ signIn: empty game services socialId (unstable Game Center?); "
            "keeping current session, not creating/overwriting a user",
          );
          emit(
            state.copyWith(
              status: UserService.authenticated
                  ? AuthenticationStateStatus.success
                  : AuthenticationStateStatus.failure,
              authenticated: UserService.authenticated,
            ),
          );
          return;
        }

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
