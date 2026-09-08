import 'package:gamico/commons/global/gamico_bootstrap.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';
import 'package:gamico/commons/repositories/gamico_users_repository.dart';
import 'package:gamico/commons/settings/about_settings.dart';
import 'package:gamico/commons/settings/admob_settings.dart';
import 'package:gamico/commons/settings/cache_settings.dart';
import 'package:gamico/commons/settings/character_settings.dart';
import 'package:gamico/commons/settings/game_settings.dart';
import 'package:gamico/commons/settings/gratification_settings.dart';
import 'package:gamico/commons/settings/languages_settings.dart';
import 'package:gamico/commons/settings/music_settings.dart';
import 'package:gamico/commons/settings/pages_settings.dart';
import 'package:gamico/commons/settings/play_settings.dart';
import 'package:gamico/commons/settings/purchases_settings.dart';
import 'package:gamico/commons/settings/store_settings.dart';
import 'package:gamico/commons/settings/tutorial_settings.dart';
import 'package:gamico/commons/settings/user_settings.dart';
import 'package:gamico/languages/languages.dart';
import 'package:gamico/commons/services/admob.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Global configuration aggregator and service locator for the Gamico framework.
class Gamico {
  /// Reference to the current global Gamico instance.
  static late final Gamico instance;

  /// Backward-compatibility alias for [AdmobService.initFuture].
  static Future<InitializationStatus>? get mobileAdsInitFuture =>
      AdmobService.initFuture;

  final String title;
  final List<String> titles;

  late final UserSettings userSettings;
  late final PagesSettings pagesSettings;
  late final LanguagesSettings languagesSettings;
  late final MusicSettings musicSettings;

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
  GamicoUserModel Function(Map<String, dynamic>) get userFromJson =>
      usersRepository.fromJson;
  Map<String, dynamic> Function(GamicoUserModel) get userToJson =>
      usersRepository.toJson;

  Gamico({
    required this.title,
    this.titles = const [],
    UserSettings? userSettings,
    PagesSettings? pagesSettings,
    LanguagesSettings? languagesSettings,
    MusicSettings? musicSettings,
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
    this.musicSettings = musicSettings ?? defaultMusicSettings;
    GamicoLanguages.instance = this.languagesSettings.en;
  }

  /// Initializes core engine, system UI, storage, crashlytics, and background services.
  Future<void> initialize() => GamicoBootstrap.initialize();
}
