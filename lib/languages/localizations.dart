import 'package:flutter/material.dart';
import 'package:gamico/languages/languages.dart';

/// Custom localizations delegate for the game.
class GamicoLocalizationsDelegate
    extends LocalizationsDelegate<GamicoLanguages> {
  final GamicoLanguages Function(Locale locale)? loader;

  /// Custom localizations delegate for the game.
  const GamicoLocalizationsDelegate({this.loader});

  @override
  Future<GamicoLanguages> load(Locale locale) async {
    if (loader != null) {
      return loader!(locale);
    }

    return GamicoLanguages.instance;
  }

  @override
  bool shouldReload(LocalizationsDelegate<GamicoLanguages> old) {
    return false;
  }

  @override
  bool isSupported(Locale locale) {
    return GamicoLanguages.languageCodes.contains(locale.languageCode);
  }
}
