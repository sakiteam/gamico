import 'dart:async';

import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamico/commons/services/admob.dart';
import 'package:gamico/commons/services/animation.dart';
import 'package:gamico/commons/services/crashlytics.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:gamico/commons/services/notification.dart';
import 'package:gamico/commons/services/play.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Handles the asynchronous bootstrap sequence of core systems and services before runApp.
class GamicoBootstrap {
  const GamicoBootstrap._();

  /// Runs the full startup initialization sequence.
  static Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Prevent the game from being in sleep mode
    WakelockPlus.enable();

    // Wait for initial utilities to be loaded
    await Future.wait([
      // Enable full screen
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive),

      // Ensure shared preferences are loaded
      LocalStorageService.initialize(),
    ]);

    // Initialize Crashlytics early because error could occur just after this line
    GamicoCrashlyticsService.initialize();

    // Initialize Flutter Animate
    Animate.restartOnHotReload = true;
    Animate.defaultDuration = AnimationService.duration;

    // Initialize Admob without blocking app startup. Downstream code
    // (e.g. MusicCubit, AdmobCubit) can await AdmobService.initFuture.
    AdmobService.initialize();

    FirebaseDatabase.instance.setPersistenceEnabled(true);

    // One-time cleanup: older builds mirrored the whole account to the "user"
    // key and seeded the user cubit from it, which is how a stale snapshot
    // ended up being republished over the real account. Nothing reads it any
    // more; drop the blob rather than leave it on every installed device.
    LocalStorageService.setMap("user", null);

    // Notifications
    try {
      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();

      if (initialMessage != null) {
        handleInitialMessage(initialMessage);
      }
    } catch (e) {
      debugPrint("Error handling initial Firebase message: $e");
    }

    // Initialize Google Play services. This runs before `runApp`, so it waits
    // for the home page to be painted instead of starting right away — see
    // [PlayService.initGameServicesWhenIdle].
    if (LocalStorageService.authenticated) {
      PlayService.initGameServicesWhenIdle();
    }
  }
}
