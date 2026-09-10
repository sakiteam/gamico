import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:gamico/commons/app/app_hooks.dart';
import 'package:gamico/commons/app/app_initializer.dart';
import 'package:gamico/commons/app/app_providers.dart';
import 'package:gamico/commons/app/asset_preloader.dart';
import 'package:gamico/commons/cubits/locale/locale_cubit.dart';
import 'package:gamico/commons/generics/content_wrapper.dart';
import 'package:gamico/commons/generics/material_app_wrapper.dart';
import 'package:gamico/commons/app/account_gate.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/commons/services/device_type.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/services/locale.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/languages/languages.dart';
import 'package:gamico/languages/localizations.dart';

export 'app_hooks.dart';
export 'app_initializer.dart';
export 'app_providers.dart';
export 'asset_preloader.dart';

/// Root widget for Gamico applications.
/// Configures MaterialApp, theme styling, localization resolution, and root layout structure.
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
  final Route<dynamic>? Function(RouteSettings)? onUnknownRoute;

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
    this.onUnknownRoute,
  });

  @override
  State<GamicoApp> createState() => _GamicoAppState();
}

class _GamicoAppState extends State<GamicoApp> {
  final ValueNotifier<bool> _loadingNotifier = ValueNotifier(true);
  final LocaleCubit _localeCubit = LocaleCubit();

  Future<void> _initApp() async {
    _loadingNotifier.value = true;
    await GamicoAppInitializer.initialize();
    _loadingNotifier.value = false;
  }

  void _initLocale() {
    if (LocaleService.language.isNotEmpty) {
      _localeCubit.setLocale(Locale(LocaleService.language));
    } else {
      final defaultLanguageCode = Platform.localeName.substring(0, 2);
      Locale defaultLocale = Locale(defaultLanguageCode);

      if (!GamicoLanguages.languageCodes.contains(defaultLanguageCode)) {
        defaultLocale = GamicoLanguages.fallbackLocale;
      }

      _localeCubit.setLocale(defaultLocale);
    }
  }

  @override
  void initState() {
    super.initState();
    GamicoAppHooks.setupGlobalHooks();
    _initLocale();
    _initApp();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    GamicoAssetPreloader.precache(context);
  }

  @override
  void dispose() {
    _loadingNotifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Disable landscape mode, except on Android TV: its panel is a fixed
    // landscape display, so locking portrait there only letterboxes the UI
    // with black bars instead of rotating anything.
    SystemChrome.setPreferredOrientations(
      DeviceTypeService.isAndroidTv
          ? []
          : [DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );

    return GamicoLifecycleManager(
      child: GamicoProviders(
        localeCubit: _localeCubit,
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
                home: ValueListenableBuilder<bool>(
                  valueListenable: _loadingNotifier,
                  builder: (context, loading, child) {
                    if (loading) {
                      return Gamico.instance.pagesSettings.loadingPage(context);
                    }

                    // Plugins are up, but the account may not be. Stay on the
                    // loading screen rather than paint a home page over a user
                    // that has not arrived — see [GamicoAccountGate].
                    return GamicoAccountGate(
                      loading: (context) =>
                          Gamico.instance.pagesSettings.loadingPage(context),
                      builder: (context) {
                        if (GameService.tutorialPassed) {
                          return Gamico.instance.pagesSettings.homePage(
                            context,
                          );
                        }

                        return Gamico.instance.pagesSettings.gamePage(
                          context,
                          const TutorialGameUtility(
                            tutorialLessonIndex: 0,
                            onBackButtonPressed: null,
                          ),
                        );
                      },
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
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: TextScaler.noScaling),
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
                  GamicoLocalizationsDelegate(
                    loader: (locale) =>
                        Gamico.instance.languagesSettings.forLocale(locale),
                  ),
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
                onUnknownRoute:
                    widget.onUnknownRoute ??
                    (settings) {
                      return MaterialPageRoute(
                        builder: (context) => Scaffold(
                          body: Center(
                            child: Text('Route ${settings.name} not found'),
                          ),
                        ),
                      );
                    },
                debugShowCheckedModeBanner: false,
              ),
            );
          },
        ),
      ),
    );
  }
}
