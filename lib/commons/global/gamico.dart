// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
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

    // usersRepository = GamicoUsersRepository(
    //   usersProvider: GamicoUsersProvider(),
    //   fromJson: userFromJson,
    //   toJson: userToJson,
    // );

    // Initialize Crashlytics early because error could occur just after this line
    if (kReleaseMode) {
      // Replace default Flutter error manager
      FlutterError.onError =
          FirebaseCrashlytics.instance.recordFlutterFatalError;

      // Replace default Flutter platform dispatcher error manager
      PlatformDispatcher.instance.onError = (error, stack) {
        // Send error to Crashlytics
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);

        // States that the error has been handled
        return true;
      };
    }

    // Initialize Flutter Animate
    Animate.restartOnHotReload = true;
    Animate.defaultDuration = AnimationService.duration;

    // Initialize Admob as soon as possible
    MobileAds.instance.initialize();

    try {
      // Enable data persistence
      FirebaseDatabase.instance.setPersistenceEnabled(true);
    } catch (e) {
      debugPrint(e.toString());
    }

    try {
      final initialMessage = await FirebaseMessaging.instance
          .getInitialMessage();

      if (initialMessage != null) {
        handleInitialMessage(initialMessage);
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    try {
      if (UserService.authenticated) {
        // Attempt to connect the user
        PlayService.initGameServices();
      } else {
        await FirebaseAuth.instance.signOut();
        UserService.authenticated = false;
        UserService.uid = "";

        // Erase eventual locally-saved user
        await UserService.setUser(null);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
