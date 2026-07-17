import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
// import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gamico/commons/cubits/admob/admob_cubit.dart';
import 'package:gamico/commons/cubits/authentication/authentication_cubit.dart';
import 'package:gamico/commons/cubits/character/character_cubit.dart';
import 'package:gamico/commons/cubits/gratification/gratification_cubit.dart';
import 'package:gamico/commons/cubits/internet/internet_cubit.dart';
import 'package:gamico/commons/cubits/locale/locale_cubit.dart';
import 'package:gamico/commons/cubits/music/music_cubit.dart';
import 'package:gamico/commons/cubits/purchases/purchases_cubit.dart';
import 'package:gamico/commons/cubits/referral/referral_cubit.dart';
import 'package:gamico/commons/cubits/showcase/showcase_cubit.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/providers/gamico_games_provider.dart';
import 'package:gamico/commons/providers/gamico_purchases_provider.dart';
import 'package:gamico/commons/repositories/gamico_games_repository.dart';
import 'package:gamico/commons/repositories/gamico_purchases_repository.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/services/gif.dart';
import 'package:gamico/commons/services/locale.dart';
import 'package:gamico/commons/services/navigation.dart';
// import 'package:gamico/commons/services/notification.dart';
import 'package:gamico/commons/services/time_zone.dart';
import 'package:gamico/commons/services/version.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/commons/generics/content_wrapper.dart';
import 'package:gamico/commons/generics/material_app_wrapper.dart';
import 'package:gamico/features/friend/cubits/friend_invitation_cubit.dart';
// import 'package:gamico/features/friend/cubits/invitation_cubit.dart';
// import 'package:gamico/features/friend/models/invitation_model.dart';
import 'package:gamico/languages/languages.dart';
import 'package:gamico/languages/localizations.dart';
import 'package:package_info_plus/package_info_plus.dart';

class GamicoApp extends StatefulWidget {
  final List<Widget>? decorations;
  final Widget? background;

  final String? fontFamily;

  /// Resolves the font family from the effective locale, so apps can swap
  /// fonts per language (e.g. a Cyrillic-capable font for Russian).
  /// Takes precedence over [fontFamily] when provided.
  final String? Function(Locale locale)? fontFamilyBuilder;
  final Color? textColor;

  final Widget Function(BuildContext context, Widget child)? builder;
  final Iterable<LocalizationsDelegate<dynamic>>? localizationsDelegates;

  final ThemeData? theme;
  final ThemeData? darkTheme;
  final ThemeMode? themeMode;

  final double? dividerThickness;
  final bool showPerformanceOverlay;

  const GamicoApp({
    super.key,
    this.decorations,
    this.background,
    this.builder,
    this.localizationsDelegates,
    this.textColor,
    this.fontFamily,
    this.fontFamilyBuilder,
    this.dividerThickness,
    this.theme,
    this.darkTheme,
    this.themeMode,
    this.showPerformanceOverlay = false,
  });

  @override
  State<GamicoApp> createState() => _GamicoAppState();
}

class _GamicoAppState extends State<GamicoApp> {
  ValueNotifier<bool> loadingNotifier = ValueNotifier(true);
  LocaleCubit localeCubit = LocaleCubit();

  void _load() async {
    loadingNotifier.value = true;

    // Initilize plugins for the proper functioning of the app
    // try {
    //   // Handle message processings
    //   // FirebaseMessaging.onMessage.listen(foregroundNotificationHandler);
    //   // FirebaseMessaging.onBackgroundMessage(backgroundNotificationHandler);

    //   // await
    //   // Future.wait([

    //   // ]);

    //   print("aaa ${DateTime.now()}");

    //   print("bbb ${DateTime.now()}");

    //   // GlobalService.dynamicLink =
    //   //     await FirebaseDynamicLinks.instance.getInitialLink();
    // } catch (e) {
    //   debugPrint(e.toString());
    // }

    await VersionService.init();
    TimeZoneService.initTimeZone();

    try {
      await AwesomeNotifications().initialize(
        // 'resource://drawable/res_app_icon',
        "resource://drawable/ic_stat_${Gamico.instance.title.toLowerCase()}",
        // null,
        [
          NotificationChannel(
            // channelGroupKey: "",
            channelKey: "default",
            channelName: "default",
            channelDescription: "default",
            // defaultColor: ColorService.primaryColor,
            // ledColor: Colors.white,
            enableVibration: true,
            channelShowBadge: true,
            importance: NotificationImportance.Max,
          ),
          NotificationChannel(
            channelKey: 'invitations',
            channelName: 'invitations',
            channelDescription: 'invitations',
            // defaultColor: const Color(0xFF9D50DD),
            // ledColor: const Color(0xFF9D50DD),
            enableVibration: true,
            channelShowBadge: true,
            importance: NotificationImportance.Max,
            // channelShowBadge: true,
          ),
        ],

        // Channel groups are only visual and are not required
        // channelGroups: [
        //   NotificationChannelGroup(
        //       channelGroupkey: 'basic_channel_group',
        //       channelGroupName: 'Basic group')
        // ],
        debug: kDebugMode,
      );
    } catch (e) {
      debugPrint(e.toString());
    }

    // Package info
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    VersionService.versionString = packageInfo.version;

    loadingNotifier.value = false;
  }

  /// Init state.
  @override
  void initState() {
    super.initState();

    _load();

    if (LocaleService.language.isNotEmpty) {
      localeCubit.setLocale(Locale(LocaleService.language));
    } else {
      final defaultLanguageCode = Platform.localeName.substring(0, 2);
      Locale defaultLocale = Locale(defaultLanguageCode);

      if (!GamicoLanguages.languageCodes.contains(defaultLanguageCode)) {
        defaultLocale = GamicoLanguages.fallbackLocale;
      }

      localeCubit.setLocale(defaultLocale);
    }
  }

  /// Build.
  @override
  Widget build(BuildContext context) {
    // Disable landscape mode
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // Return concrete app content
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(
          value: Gamico.instance.usersRepository,
          // create: (context) => UsersRepository(
          //   usersProvider: UsersProvider(),
          // ),
        ),
        RepositoryProvider(
          create: (context) =>
              GamicoGamesRepository(gamesProvider: GamicoGamesProvider()),
        ),
        RepositoryProvider(
          create: (context) => GamicoPurchasesRepository(
            purchasesProvider: GamicoPurchasesProvider(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            lazy: false,
            create: (context) => FriendInvitationCubit(),
          ),
          BlocProvider(
            lazy: false,
            create: (context) => GamicoUserCubit(
              usersRepository: Gamico.instance.usersRepository,
              // fromJson: Gamico.instance.userFromJson,
              // toJson: Gamico.instance.userToJson,
            ),
          ),
          // BlocProvider(
          //   lazy: false,
          //   create: (context) => UserCubit(
          //     usersRepository: context.read<UsersRepository>(),
          //     fromJson: gamico.userFromJson,
          //     toJson: gamico.userToJson,
          //   ),
          // ),
          BlocProvider(lazy: false, create: (context) => GamicoMusicCubit()),
          BlocProvider(
            lazy: false,
            create: (context) => AuthenticationCubit(
              friendInvitationCubit: context.read<FriendInvitationCubit>(),
              userCubit: context.read<GamicoUserCubit>(),
              usersRepository: Gamico.instance.usersRepository,
            ),
          ),
          BlocProvider(lazy: false, create: (context) => InternetCubit()),
          BlocProvider(lazy: false, create: (context) => AdmobCubit()),
          BlocProvider(lazy: false, create: (context) => ShowcaseCubit()),
          BlocProvider(
            lazy: false,
            create: (context) => PurchasesCubit(
              userCubit: context.read<GamicoUserCubit>(),
              purchasesRepository: context.read<GamicoPurchasesRepository>(),
            ),
          ),
          BlocProvider(
            lazy: false,
            create: (context) => ReferralCubit(
              // authenticationCubit: context.read<AuthenticationCubit>(),
              // internetCubit: context.read<InternetCubit>(),
            ),
          ),
          BlocProvider(lazy: false, create: (context) => CharacterCubit()),
          BlocProvider(
            lazy: false,
            create: (context) => GratificationCubit(
              userCubit: context.read<GamicoUserCubit>(),
              internetCubit: context.read<InternetCubit>(),
            ),
          ),
          BlocProvider.value(
            value: localeCubit,
            // create: (context) => localeCubit,
          ),
        ],
        child: BlocBuilder<LocaleCubit, LocaleState>(
          builder: (context, localeState) {
            // A null cubit locale means "follow the system": resolve it so
            // fontFamilyBuilder still gets the locale the app will display.
            final Locale effectiveLocale =
                localeState.locale ??
                WidgetsBinding.instance.platformDispatcher.locale;
            return GamicoMaterialAppWrapper(
              child: MaterialApp(
                navigatorKey: NavigationService.globalNavigatorKey,
                showPerformanceOverlay: widget.showPerformanceOverlay,
                home: ValueListenableBuilder(
                  valueListenable: loadingNotifier,
                  builder: (context, loading, child) {
                    if (loading) {
                      return Gamico.instance.pagesSettings.loadingPage(context);
                    }

                    if (GameService.tutorialPassed) {
                      return Gamico.instance.pagesSettings.homePage(context);
                    }

                    return Gamico.instance.pagesSettings.gamePage(
                      context,
                      const TutorialGameUtility(
                        tutorialLessonIndex: 0,
                        onBackButtonPressed: null,
                      ),
                    );
                  },
                ),
                title: Gamico.instance.title,
                supportedLocales: GamicoLanguages.locales,
                builder: (context, child) {
                  GamicoLanguages.instance = GamicoLanguages.of(context);

                  final finalContent = GamicoContentWrapper(
                    decorations: widget.decorations,
                    background: widget.background,
                    child: child,
                  );

                  // Ignore the system font-size setting so text keeps the
                  // same proportions on every device (layout is handled by
                  // the game's own FittedBox scaling).
                  return MediaQuery(
                    data: MediaQuery.of(
                      context,
                    ).copyWith(textScaler: TextScaler.noScaling),
                    child:
                        widget.builder?.call(context, finalContent) ??
                        finalContent,
                  );
                },
                theme:
                    widget.theme ??
                    ThemeData(
                      colorScheme: ColorScheme.fromSeed(
                        seedColor: ColorService.primaryColor,
                      ),
                      fontFamily:
                          widget.fontFamilyBuilder?.call(effectiveLocale) ??
                          widget.fontFamily,
                      textTheme: TextTheme(
                        bodyMedium: TextStyle(
                          fontSize: 14 * 450 / 400,
                          height: 1,
                          color: widget.textColor,
                        ),
                      ),
                      dividerTheme: DividerThemeData(
                        space: 0,
                        thickness: widget.dividerThickness ?? 1,
                        color: Colors.black,
                      ),
                      dividerColor: Colors.black,
                    ),
                darkTheme: widget.darkTheme,
                themeMode: widget.themeMode,
                locale: localeState.locale,
                localizationsDelegates: [
                  const GamicoLocalizationsDelegate(),
                  ...GlobalMaterialLocalizations.delegates,
                  ...(widget.localizationsDelegates ?? []),
                ],
                localeResolutionCallback: (locale, supportedLocales) {
                  for (final supportedLocale in supportedLocales) {
                    if (supportedLocale.languageCode == locale?.languageCode) {
                      return supportedLocale;
                    }
                  }

                  return GamicoLanguages.fallbackLocale;
                },
                debugShowCheckedModeBanner: false,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Did changed dependencies.
  @override
  void didChangeDependencies() {
    // Precache asset images
    for (final image in (Gamico.instance.cacheSettings?.images ?? <String>[])) {
      final imageProvider = AssetImage(image);

      precacheImage(imageProvider, context);

      if (image.endsWith("gif")) {
        GifService.precacheImage(imageProvider);
      }
    }

    // Call inherited method
    super.didChangeDependencies();
  }
}

// Manage notification that comes from background
Future<void> backgroundNotificationHandler(RemoteMessage remoteMessage) async {}

// Manage notification that comes from foreground
Future<void> foregroundNotificationHandler(RemoteMessage remoteMessage) async {}
