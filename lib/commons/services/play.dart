import 'dart:io';
import 'dart:math';
import 'dart:async';
import 'package:flutter/widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:games_services/games_services.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';

class PlayService {
  static String authCode = "";

  static bool gameServicesEnabled = false;

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

  static Future<bool> enableGameServices() async {
    try {
      if (!UserService.authenticated &&
          !(await SimpleConnectionChecker.isConnectedToInternet())) {
        return false;
      }

      await GameAuth.signIn();

      if (UserService.authenticated) {
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
