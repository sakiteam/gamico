import 'dart:core';
import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamico/commons/services/play.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:games_services/games_services.dart';
import 'package:gamico/commons/services/global.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:gamico/commons/repositories/gamico_users_repository.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  final GamicoUserCubit userCubit;
  final GamicoUsersRepository usersRepository;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<PlayerData?>? _playerSubscription;

  final void Function()? onAuthenticated;

  AuthenticationCubit({
    this.onAuthenticated,
    required this.userCubit,
    required this.usersRepository,
  }) : super(
         AuthenticationState(
           status: LocalStorageService.authenticated
               ? AuthenticationStateStatus.success
               : AuthenticationStateStatus.initial,
         ),
       ) {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? firebaseUser,
    ) async {
      if (firebaseUser == null) {
        userCubit.cancelUserChangesListener();

        LocalStorageService.uid = "";
        userCubit.setUser(null);

        emit(state.copyWith(status: AuthenticationStateStatus.failure));
      } else {
        await GamicoGlobalService.waitWhile(
          () => !LocalStorageService.authenticated,
        );

        userCubit.listenToUserChanges();

        await GamicoGlobalService.waitWhile(() => !userCubit.state.loaded);

        userCubit.setToken();
        userCubit.setPhoto(firebaseUser.photoURL);

        emit(state.copyWith(status: AuthenticationStateStatus.success));
      }
    }, onError: (_, _) {});

    _playerSubscription = PlayService.playerStream.listen((player) {
      userCubit.setSocialName(player?.displayName ?? "");
    }, onError: (_, _) {});
  }

  void signIn() async {
    if (state.status == AuthenticationStateStatus.loading) return;

    emit(state.copyWith(status: AuthenticationStateStatus.loading));

    try {
      if (await PlayService.enableGameServices()) {
        String socialId = PlayService.playerId;
        String firebaseId = FirebaseAuth.instance.currentUser?.uid ?? "";

        if (socialId.isEmpty) {
          _handleError();
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
          final userRaw = jsonDecode(jsonEncode(snapshot.value));
          final userData = Map<String, dynamic>.from(userRaw.values.first);
          final userJson = Gamico.instance.userFromJson(userData);

          LocalStorageService.uid = userRaw.keys.first;
          userCubit.setUser(userJson, loaded: true);

          onAuthenticated?.call();

          if (userJson.firebaseId != firebaseId) {
            usersRepository.usersProvider.updateUser(LocalStorageService.uid, {
              "firebase_id": firebaseId,
            });
          }
        } else {
          final user = Gamico.instance.userSettings.createNewUser(
            firebaseId,
            socialId,
          );

          LocalStorageService.uid = await usersRepository.createUser(user);
          userCubit.setUser(user, loaded: true);
        }

        emit(state.copyWith(status: AuthenticationStateStatus.success));
      } else {
        _handleError();
      }
    } catch (e) {
      _handleError();
    }
  }

  void signOut() {
    FirebaseAuth.instance.signOut();
  }

  void _handleError() {
    emit(state.copyWith(status: AuthenticationStateStatus.failure));
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    _playerSubscription?.cancel();

    return super.close();
  }
}
