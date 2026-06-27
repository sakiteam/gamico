import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/locale/locale_cubit.dart';
import 'package:gamico/commons/generics/button.dart';
// import 'package:gamico/commons/generics/grey_tinter.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/services/color.dart';
// import 'package:gamico/commons/generics/simple_popup.dart';
import 'package:gamico/languages/languages.dart';
import 'package:gamico/commons/services/navigation.dart';
// import 'package:gamico/commons/generics/button.dart';
import 'package:gamico/commons/generics/elevated_button.dart';
import 'package:gamico/commons/generics/grid.dart';
import 'package:gamico/commons/generics/poster.dart';
// import 'package:gamico/commons/generics/outlined_text.dart';
import 'package:gamico/commons/generics/popup_button.dart';
import 'package:gamico/features/home/widgets/home_translation_flag.dart';

class HomeTranslationPopup extends StatefulWidget {
  static bool simple = false;
  static BorderRadius borderRadius = BorderRadius.circular(16);

  const HomeTranslationPopup({super.key});

  @override
  State<HomeTranslationPopup> createState() => _HomeTranslationPopupState();
}

class _HomeTranslationPopupState extends State<HomeTranslationPopup> {
  late String platformLocaleCode;
  late String currentLocaleCode;

  @override
  void initState() {
    super.initState();

    final locale = context.read<LocaleCubit>().state.locale;

    platformLocaleCode = Platform.localeName.substring(0, 2);
    currentLocaleCode =
        locale?.languageCode ?? GamicoLanguages.fallbackLocale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    final disabled = platformLocaleCode == currentLocaleCode;

    return GamicoPopup(
      characterPositions: const [],
      additionalChild: SizedBox(
        width: GamicoPopupButton.defaultWidth,
        height: GamicoPopupButton.defaultHeight,
        child: GamicoPopupButton(
          icon: Icons.restore,
          text: l.restoreDefaultLanguage,
          // child: Padding(
          //             padding: const EdgeInsets.only(
          //                 bottom: GamicoSimplePopup.watchButtonMargin),
          //             child: Center(
          //               child: GamicoOutlinedText(
          //                 l.restoreDefaultLanguage,
          //                 color: Colors.white,
          //                 strokeWidth: 0.5,
          //                 maxLines: 1,
          //                 style: const TextStyle(fontSize: 16),
          //               ),
          //             ),
          //           ),
          onPressed: disabled
              ? null
              : () {
                  final localeCubit = context.read<LocaleCubit>();

                  NavigationService.pop(context);

                  localeCubit.setLocale(Locale(platformLocaleCode));
                },
        ),
      ),
      child: GamicoPoster(
        titleWidget: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: GamicoPosterTitle(l.homeLanguagesTitle),
        ),
        description: l.homeTranslationPopupDescription,
        expandContent: true,
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              const colSpacing = 16.0;
              const rowSpacing = 16.0;

              final w = (constraints.maxWidth - 2 * colSpacing) / 3;
              final h = (constraints.maxHeight - 2 * rowSpacing) / 3;

              return GamicoGrid(
                rows: 3,
                cols: 3,
                rowsSpacing: rowSpacing,
                colsSpacing: colSpacing,

                // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: GamicoLanguages.locales.map((e) {
                  final currentLanguageCode = e.languageCode;

                  final child = HomeTranslationFlag(
                    path: "assets/flags/$currentLanguageCode.png",
                    active: currentLocaleCode == currentLanguageCode,
                  );

                  void onPressed() {
                    final localeCubit = context.read<LocaleCubit>();

                    NavigationService.pop(context);

                    if (currentLocaleCode != currentLanguageCode) {
                      localeCubit.setLocale(e);
                    }
                  }

                  return Center(
                    child: HomeTranslationPopup.simple
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(
                              GamicoButton.defaultBorderRadius,
                            ),
                            child: Container(
                              width: w,
                              height: h,
                              color: ColorService.translationForegroundColor,
                              child: GamicoButton(
                                // bruitage: enabled ? null : "",
                                onPressed: onPressed,
                                child: child,
                              ),
                            ),
                          )
                        : GamicoElevatedButton(
                            width: w,
                            height: h,
                            foregroundColor:
                                ColorService.translationForegroundColor,
                            backgroundColor:
                                ColorService.translationBackgroundColor,
                            onPressed: onPressed,
                            child: child,
                          ),
                  );
                }).toList(),
              );
            },
          ),
        ),
      ),
    );
  }
}
