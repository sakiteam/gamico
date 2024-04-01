import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamico/commons/repositories/gamico_users_repository.dart';
import 'package:gamico/commons/settings/admob_settings.dart';
import 'package:gamico/commons/settings/cache_settings.dart';
import 'package:gamico/commons/settings/character_settings.dart';
import 'package:gamico/commons/settings/game_settings.dart';
import 'package:gamico/commons/settings/languages_settings.dart';
import 'package:gamico/commons/settings/matchmaking_settings.dart';
import 'package:gamico/commons/settings/pages_settings.dart';
import 'package:gamico/commons/settings/play_settings.dart';
import 'package:gamico/commons/settings/gratification_settings.dart';
import 'package:gamico/commons/settings/purchases_settings.dart';
import 'package:gamico/commons/settings/store_settings.dart';
import 'package:gamico/commons/settings/tutorial_settings.dart';
import 'package:gamico/commons/settings/user_settings.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';
import 'package:gamico/commons/services/animation.dart';
import 'package:gamico/commons/services/play.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

class Gamico {
  /// Reference to the current global Gamico instance.
  static late final Gamico instance;

  final String title;

  final UserSettings userSettings;
  final PagesSettings pagesSettings;

  final GameSettings gameSettings;
  final LanguagesSettings languagesSettings;

  final PlaySettings? playSettings;
  final StoreSettings? storeSettings;
  final AdmobSettings? admobSettings;
  final GamicoCacheSettings? cacheSettings;
  final TutorialSettings? tutorialSettings;
  final PurchasesSettings? purchasesSettings;
  final CharacterSettings? characterSettings;
  final MatchmakingSettings? matchmakingSettings;
  final GratificationSettings? gratificationSettings;

  GamicoUsersRepository get usersRepository => userSettings.usersRepository;

  dynamic Function(Map<String, dynamic>) get userFromJson =>
      usersRepository.fromJson;
  Map<String, dynamic> Function(dynamic) get userToJson =>
      usersRepository.toJson;

  Gamico({
    required this.title,
    //
    required this.userSettings,
    required this.pagesSettings,
    //
    required this.gameSettings,
    required this.languagesSettings,
    //
    this.admobSettings,
    this.characterSettings,
    this.gratificationSettings,
    this.purchasesSettings,
    this.storeSettings,
    this.matchmakingSettings,
    this.playSettings,
    this.tutorialSettings,
    this.cacheSettings,
  }) {
    instance = this;
  }

  Future<void> initialize() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Prevent the game from being in sleep mode
    WakelockPlus.enable();

    // Wait for initial utilities to be loaded
    await Future.wait([
      Firebase.initializeApp(),

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

    // Enable data persistence
    FirebaseDatabase.instance.setPersistenceEnabled(true);

    try {
      if (UserService.authenticated) {
        // Attempt to connect the user
        PlayService.initGameServices();

        if (await SimpleConnectionChecker.isConnectedToInternet()) {
          // Save user locally
          await UserService.setUser(
            await usersRepository.readUser(UserService.uid),
          );
        }
      } else {
        // Erase eventual locally-saved user
        await UserService.setUser(null);
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
