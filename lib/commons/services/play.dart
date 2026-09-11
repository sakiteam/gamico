import 'dart:io';
import 'dart:math';
import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:games_services/games_services.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';

class PlayService {
  static String authCode = "";

  static bool gameServicesEnabled = false;

  static PlayerData? player;
  static String get playerId => player?.playerID ?? "";
  static String get playerDisplayName => player?.displayName ?? "";

  static Stream<PlayerData?> get playerStream => GameAuth.player;

  static StreamSubscription<PlayerData?>? _playerSubscription;

  static void initPlayerListener() {
    _playerSubscription ??= GameAuth.player.listen(
      (playerData) {
        player = playerData;
      },
      onError: (error, stackTrace) {
        debugPrint("⚠️ GameAuth.player stream error: $error");
      },
    );
  }

  /// Sign-in attempts before giving up for this session.
  ///
  /// A Play Games sign-in that failed three times is failing structurally (no
  /// linked account, Play Games unavailable in the region, outdated GMS), not
  /// transiently. Each extra attempt only buys another chance to be killed
  /// mid-flight, which crashes GMS' own `SignInHubActivity` on restore.
  static const _maxSignInAttempts = 3;

  /// Completes once the home page is up and its first frame is on screen.
  static final Completer<void> _homeReady = Completer<void>();

  /// Signals that the home page is mounted and painted.
  ///
  /// Called by `GamicoHomePage`; see [initGameServicesWhenIdle] for why the
  /// game services wait for it.
  static void notifyHomeReady() {
    if (!_homeReady.isCompleted) _homeReady.complete();
  }

  /// Starts the game services once the app has finished booting.
  ///
  /// On iOS, `GameAuth.signIn()` makes GameKit show its "Welcome back" banner,
  /// and GameCenterUI renders the player avatar by encoding a PNG
  /// *synchronously on the main thread* while its own banner queue waits on a
  /// semaphore. Called during startup, the main thread is still busy warming up
  /// the engine, decoding the menu assets and initializing Admob, so on slower
  /// devices that wait times out and the app is killed. Waiting for the home
  /// page to be painted puts the banner past the busiest window.
  ///
  /// The timeout is a safety net, not a tuning knob: it only matters if the
  /// home page is never reached, in which case the services would otherwise
  /// never start.
  static void initGameServicesWhenIdle() async {
    await _homeReady.future.timeout(
      const Duration(seconds: 30),
      onTimeout: () {},
    );

    initGameServices();
  }

  static void initGameServices([int exponent = 0]) async {
    initPlayerListener();
    if (await enableGameServices()) return;

    if (exponent >= _maxSignInAttempts - 1) return;

    await Future.delayed(pow(2, exponent).seconds);

    // Retrying while backgrounded is what actually crashes: `SignInHubActivity`
    // comes back with a null config when the system killed the process while it
    // was up, and GMS dereferences it in onCreate. Stop instead of retrying
    // blind — the next launch calls this again anyway.
    if (WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed) {
      return;
    }

    initGameServices(exponent + 1);
  }

  /// How long to let the Firebase SDK rehydrate a persisted session.
  ///
  /// Only ever paid in full by a device that genuinely has no session, and
  /// only once per attempt — a restored one answers on the first check.
  static const _sessionRestoreGrace = Duration(seconds: 2);

  /// Whether a Firebase Auth session is restored on this device.
  ///
  /// Deliberately network-free: [FirebaseAuth.currentUser] is rehydrated from
  /// local storage, so a player with no connection but a valid session still
  /// answers `true` and keeps working offline.
  ///
  /// It is not populated *synchronously* at cold start though, and reading it
  /// too early reports "no session" for a device that has a perfectly good
  /// one — which would force a pointless network sign-in on every launch that
  /// happens to win the race. `authStateChanges` fires as soon as the SDK has
  /// restored, so wait briefly on it before concluding there is nothing.
  static Future<bool> _hasFirebaseSession() async {
    if (FirebaseAuth.instance.currentUser != null) return true;

    try {
      await FirebaseAuth.instance
          .authStateChanges()
          .firstWhere((user) => user != null)
          .timeout(_sessionRestoreGrace);

      return true;
    } catch (e) {
      // Timed out, or the stream closed without ever emitting a user.
      return FirebaseAuth.instance.currentUser != null;
    }
  }

  static Future<bool> enableGameServices() async {
    initPlayerListener();

    try {
      if (!LocalStorageService.authenticated &&
          !(await SimpleConnectionChecker.isConnectedToInternet())) {
        return false;
      }

      await GameAuth.signIn();

      // Skip the sign-in only when a Firebase session is actually there.
      //
      // This used to test `LocalStorageService.authenticated`, which is
      // `uid.isNotEmpty` — the local `users/<uid>` push key. That key never
      // expires and says nothing about the Firebase session, yet the session
      // is what the database rules evaluate as `auth.uid`. The two correlate
      // only the first time (a uid exists because a sign-in once succeeded)
      // and decorrelate the moment a session is lost: failed token refresh,
      // revoked credential, a device restore that did not carry the keychain.
      // From then on the short-circuit fired forever and NOTHING rebuilt the
      // session — every read and write went out with `auth.uid == null`. It
      // stayed invisible while `users` and `profiles` were world-readable
      // (only writes failed, silently); hardening those rules turned it into
      // players who could no longer sign in at all.
      if (await _hasFirebaseSession()) {
        gameServicesEnabled = true;
        return true;
      }

      if (Platform.isAndroid) {
        final serverAuthCode = await GameAuth.getAuthCode(authCode);

        if (serverAuthCode != null) {
          final playGamesCredential = PlayGamesAuthProvider.credential(
            serverAuthCode: serverAuthCode,
          );

          await FirebaseAuth.instance.signInWithCredential(playGamesCredential);

          gameServicesEnabled = true;
        } else {
          gameServicesEnabled = false;
        }
      } else {
        final credential = GameCenterAuthProvider.credential();
        await FirebaseAuth.instance.signInWithCredential(credential);
        gameServicesEnabled = true;
      }
    } catch (e) {
      gameServicesEnabled = false;
    }

    return gameServicesEnabled;
  }
}
