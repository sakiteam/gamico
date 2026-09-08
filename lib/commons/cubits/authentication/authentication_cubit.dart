// import 'dart:io';
import 'dart:core';
import 'dart:async';
import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:gamico/commons/services/play.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/global.dart';
import 'package:firebase_database/firebase_database.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:games_services/games_services.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/repositories/gamico_users_repository.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  /// Backward-compatibility aliases for [PlayService.player].
  static PlayerData? get gameServicesPlayer => PlayService.player;
  static PlayerData? get player => PlayService.player;

  final GamicoUserCubit userCubit;
  final GamicoUsersRepository usersRepository;
  final void Function()? onAuthenticated;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription? _playerSubscription;

  AuthenticationCubit({
    required this.userCubit,
    required this.usersRepository,
    this.onAuthenticated,
  }) : super(
         AuthenticationState(
           status: AuthenticationStateStatus.initial,
           authenticated: LocalStorageService.authenticated,
         ),
       ) {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((
      User? firebaseUser,
    ) async {
      if (firebaseUser != null) {
        await GamicoGlobalService.waitWhile(
          () => !LocalStorageService.authenticated,
        );

        userCubit.listenToUserChanges();

        // [GAMICO-FIX] name/level-loss investigation.
        // Wait for a REAL user to load from RTDB BEFORE any write to
        // users/<uid>. If the persisted uid points to a ghost/corrupted node
        // (no identity), the writers below (_saveToken -> setUserToken,
        // updateUserPhoto) would otherwise (re)create/maintain that ghost with
        // {token/photo, updated_at} on every launch. manageUserChanges refuses
        // to load a ghost, so state.user stays null for a bad uid and these
        // writes are correctly skipped.

        await GamicoGlobalService.waitWhile(() => !userCubit.state.loaded);

        userCubit.saveToken();
        userCubit.setUserPhoto(firebaseUser.photoURL);

        emit(
          state.copyWith(
            status: AuthenticationStateStatus.success,
            authenticated: true,
            deliberateSignOut: false,
          ),
        );
      } else {
        // authStateChanges emitted null: no persisted Firebase user, a
        // signOut(), a deleted account — or a token-refresh failure, which is
        // transient and indistinguishable from the rest.
        //
        // The session is cleared because this IS the signed-out signal, but the
        // account stays reachable: `LocalStorageService.uid`'s setter mirrors every
        // non-empty value to `last_uid`, which nothing here touches, and the
        // next sign-in restores the pointer from it (see [_recoverSession]).
        // Without that, a transient token failure orphaned the account.
        debugPrint(
          "⚠️ authStateChanges -> null: clearing session\n${StackTrace.current}",
        );

        userCubit.cancelUserChangesListener();

        LocalStorageService.uid = "";
        userCubit.setUser(null);

        emit(
          state.copyWith(
            status: AuthenticationStateStatus.failure,
            authenticated: false,
          ),
        );
      }
    });

    _playerSubscription = PlayService.playerStream.listen(
      (player) async {
        // Writes `social_name` only. The player-facing `name` is seeded from it
        // once (first sign-in) and then belongs to the player, who can rename
        // themselves from the profile popup.
        userCubit.setUserSocialName(player?.displayName ?? "");
      },
      onError: (error, stackTrace) {
        debugPrint("⚠️ PlayService.playerStream error: $error");
      },
    );
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
        String socialId = PlayService.playerId;

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
              status: LocalStorageService.authenticated
                  ? AuthenticationStateStatus.success
                  : AuthenticationStateStatus.failure,
              authenticated: LocalStorageService.authenticated,
            ),
          );
          return;
        }

        // The lookup gets its own try/catch. Letting it fall through to the
        // outer one meant a flaky network erased the account pointer — see
        // [handleError].
        final DataSnapshot snapshot;
        try {
          snapshot = await FirebaseDatabase.instance
              .ref()
              .child("users")
              .orderByChild("social_id")
              .equalTo(socialId)
              .limitToFirst(1)
              .get();
        } catch (e) {
          debugPrint("⚠️ signIn: users lookup failed => $e");
          _recoverSession();
          if (!isClosed) {
            emit(
              state.copyWith(
                status: LocalStorageService.authenticated
                    ? AuthenticationStateStatus.success
                    : AuthenticationStateStatus.failure,
                authenticated: LocalStorageService.authenticated,
              ),
            );
          }
          return;
        }

        // An empty result is only trustworthy when it came from the server.
        // Offline, `get()` answers from a disk cache that does not hold the
        // `users` index, so "no match" is indistinguishable from "not asked" —
        // and the branch below would spawn a second account and orphan the
        // player's real one.
        if (!snapshot.exists && !await _databaseReachable()) {
          debugPrint(
            "⚠️ signIn: no match for social_id but the database is not "
            "reachable; refusing to create a second account",
          );
          _recoverSession();
          if (!isClosed) {
            emit(
              state.copyWith(
                status: LocalStorageService.authenticated
                    ? AuthenticationStateStatus.success
                    : AuthenticationStateStatus.failure,
                authenticated: LocalStorageService.authenticated,
              ),
            );
          }
          return;
        }

        if (snapshot.exists) {
          final data = jsonDecode(jsonEncode(snapshot.value));
          final userData = Map<String, dynamic>.from(data.values.first);

          LocalStorageService.uid = data.keys.first;

          userCubit.setUser(
            Gamico.instance.userFromJson(userData),
            loaded: true,
          );

          onAuthenticated?.call();

          // [GAMICO-FIX] Cloud Functions (e.g. tournament creation) resolve
          // the caller's app account via `firebase_id`, which is otherwise
          // only ever written once at account creation. If the Firebase Auth
          // uid has since changed (reinstall, cleared data, auth refresh)
          // while this profile keeps getting reattached via the stable
          // `social_id`, `firebase_id` goes stale and those Cloud Functions
          // silently resolve to an unrelated/ghost account instead. Keep it
          // in sync on every sign-in so server-side lookups stay correct.
          if (userData["firebase_id"] != firebaseId) {
            unawaited(
              usersRepository.usersProvider.updateUser(
                LocalStorageService.uid,
                {"firebase_id": firebaseId},
              ),
            );
          }
        } else {
          final user = Gamico.instance.userSettings.createNewUser(
            firebaseId,
            socialId,
          );

          LocalStorageService.uid = await usersRepository.createUser(user);

          // Save user information
          userCubit.setUser(user, loaded: true);

          // The name was resolved offline (game services / random): make sure
          // it doesn't collide with an existing player before it is used.
          await userCubit.ensureUniqueName();
        }

        emit(
          state.copyWith(
            status: AuthenticationStateStatus.success,
            authenticated: true,
            deliberateSignOut: false,
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
    // Flagged BEFORE the await: `authStateChanges` fires its null from inside
    // FirebaseAuth.signOut(), so anything reacting to the session ending must
    // already be able to tell this apart from a token-refresh failure.
    emit(state.copyWith(deliberateSignOut: true));

    await FirebaseAuth.instance.signOut();

    LocalStorageService.uid = "";
    userCubit.setUser(null);

    emit(state.copyWith(authenticated: false));
  }

  /// A sign-in attempt failed. It does NOT clear the session.
  ///
  /// This used to erase `LocalStorageService.uid` and null the persisted user on ANY
  /// exception raised anywhere in [signIn] — a game services hiccup, a timeout
  /// on the `users` lookup, a transient rules error. Since
  /// `LocalStorageService.authenticated` is `uid.isNotEmpty`, that left the player
  /// signed out of their own account with no way back except another sign-in,
  /// which could then create a fresh account and orphan the real one. A failed
  /// attempt is not a sign-out: only [signOut] clears, and even that keeps
  /// [LocalStorageService.lastUid] so the account stays recoverable.
  void handleError() {
    _recoverSession();

    if (isClosed) return;

    emit(
      state.copyWith(
        status: LocalStorageService.authenticated
            ? AuthenticationStateStatus.success
            : AuthenticationStateStatus.failure,
        authenticated: LocalStorageService.authenticated,
      ),
    );
  }

  /// Puts the account pointer back when something erased it.
  ///
  /// `uid` can be empty here after a sign-out, or after an older build's error
  /// path wiped it. [LocalStorageService.lastUid] survives both, so the device can
  /// reattach to the account it already owns instead of the sign-in creating a
  /// new one.
  void _recoverSession() {
    if (LocalStorageService.uid.isNotEmpty) return;

    final recovered = LocalStorageService.lastUid;
    if (recovered.isEmpty) return;

    debugPrint("ℹ️ signIn: restoring account pointer from lastUid");

    LocalStorageService.uid = recovered;
    userCubit.listenToUserChanges();
  }

  /// Whether the RTDB backend is actually reachable right now.
  ///
  /// `.info/connected` is a local node: it answers immediately with the current
  /// socket state. A cold start can legitimately still be connecting, so give
  /// it a short grace period before concluding the backend is out of reach.
  Future<bool> _databaseReachable() async {
    final ref = FirebaseDatabase.instance.ref(".info/connected");

    for (var attempt = 0; attempt < 12; attempt++) {
      try {
        final snapshot = await ref.get();
        if (snapshot.value == true) return true;
      } catch (e) {
        debugPrint("⚠️ .info/connected probe failed => $e");
      }

      await Future.delayed(const Duration(milliseconds: 250));
    }

    return false;
  }

  @override
  Future<void> close() {
    _authSubscription?.cancel();
    _playerSubscription?.cancel();
    return super.close();
  }
}
