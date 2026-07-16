import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamico/commons/repositories/gamico_users_repository.dart';
import 'package:gamico/commons/services/notification.dart';
import 'package:gamico/commons/settings/about_settings.dart';
import 'package:gamico/commons/settings/admob_settings.dart';
import 'package:gamico/commons/settings/cache_settings.dart';
import 'package:gamico/commons/settings/character_settings.dart';
import 'package:gamico/commons/settings/game_settings.dart';
import 'package:gamico/commons/settings/languages_settings.dart';
import 'package:gamico/commons/settings/pages_settings.dart';
import 'package:gamico/commons/settings/play_settings.dart';
import 'package:gamico/commons/settings/gratification_settings.dart';
import 'package:gamico/commons/settings/purchases_settings.dart';
import 'package:gamico/commons/settings/store_settings.dart';
import 'package:gamico/commons/settings/tutorial_settings.dart';
import 'package:gamico/commons/settings/user_settings.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gamico/commons/services/animation.dart';
import 'package:gamico/commons/services/play.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class Gamico {
  /// Reference to the current global Gamico instance.
  static late final Gamico instance;

  /// Completes when `MobileAds.instance.initialize()` finishes.
  /// Await this before calling any SDK method that requires initialisation.
  static late final Future<InitializationStatus> mobileAdsInitFuture;

  final String title;

  late final UserSettings userSettings;
  late final PagesSettings pagesSettings;
  late final LanguagesSettings languagesSettings;

  final GameSettings gameSettings;
  final PlaySettings? playSettings;
  final StoreSettings? storeSettings;
  final AdmobSettings? admobSettings;
  final GamicoCacheSettings? cacheSettings;
  final TutorialSettings? tutorialSettings;
  final PurchasesSettings? purchasesSettings;
  final CharacterSettings? characterSettings;
  final GratificationSettings? gratificationSettings;
  final AboutSettings? aboutSettings;

  GamicoUsersRepository get usersRepository => userSettings.usersRepository;
  dynamic Function(Map<String, dynamic>) get userFromJson =>
      usersRepository.fromJson;
  Map<String, dynamic> Function(dynamic) get userToJson =>
      usersRepository.toJson;

  Gamico({
    required this.title,
    UserSettings? userSettings,
    PagesSettings? pagesSettings,
    LanguagesSettings? languagesSettings,
    this.gameSettings = const GameSettings(),
    this.admobSettings,
    this.characterSettings,
    this.gratificationSettings,
    this.purchasesSettings,
    this.storeSettings,
    this.playSettings,
    this.tutorialSettings,
    this.cacheSettings,
    this.aboutSettings,
  }) {
    instance = this;

    this.userSettings = userSettings ?? defaultUserSettings;
    this.pagesSettings = pagesSettings ?? defaultPagesSettings;
    this.languagesSettings = languagesSettings ?? defaultLanguagesSettings;
  }

  Future<void> initialize() async {
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
    if (kReleaseMode) {
      // Replace default Flutter error manager
      FlutterError.onError = (details) {
        final errorStr = details.exception.toString();
        if (errorStr.contains("Loading interrupted")) {
          debugPrint("Crashlytics: Ignored loading interrupted error");
          return;
        }
        FirebaseCrashlytics.instance.recordFlutterFatalError(details);
      };

      // Replace default Flutter platform dispatcher error manager
      PlatformDispatcher.instance.onError = (error, stack) {
        final errorStr = error.toString();
        if (errorStr.contains("Loading interrupted")) {
          debugPrint("PlatformDispatcher: Ignored loading interrupted error");
          return true;
        }
        // Send error to Crashlytics
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

        // States that the error has been handled
        return true;
      };
    }

    // Initialize Flutter Animate
    Animate.restartOnHotReload = true;
    Animate.defaultDuration = AnimationService.duration;

    // Initialize Admob without blocking app startup. Downstream code
    // (e.g. MusicCubit.setAppMuted) must await this future before
    // calling SDK methods that require initialisation.
    mobileAdsInitFuture = MobileAds.instance.initialize();

    // Enable data persistence
    try {
      FirebaseDatabase.instance.setPersistenceEnabled(true);
    } catch (e) {
      debugPrint(e.toString());
    }

    // Notifications
    try {
      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();

      if (initialMessage != null) {
        handleInitialMessage(initialMessage);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    // Initialize Google Play services
    if (UserService.authenticated) {
      PlayService.initGameServices();
    }
  }
}
