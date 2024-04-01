import 'package:flutter/material.dart';
import 'package:gamico/languages/languages.dart';
import 'package:gamico/commons/global/gamico.dart';

/// Custom localizations delegate for the game.
class GamicoLocalizationsDelegate
    extends LocalizationsDelegate<GamicoLanguages> {
  /// Custom localizations delegate for the game.
  const GamicoLocalizationsDelegate();

  @override
  Future<GamicoLanguages> load(Locale locale) async {
    return switch (locale.languageCode) {
      "en" => Gamico.instance.languagesSettings.en,
      "fr" => Gamico.instance.languagesSettings.fr,
      "zh" => Gamico.instance.languagesSettings.zh,
      "hi" => Gamico.instance.languagesSettings.hi,
      "es" => Gamico.instance.languagesSettings.es,
      "de" => Gamico.instance.languagesSettings.de,
      "bn" => Gamico.instance.languagesSettings.bn,
      "ru" => Gamico.instance.languagesSettings.ru,
      "pt" => Gamico.instance.languagesSettings.pt,
      _ => Gamico.instance.languagesSettings.en,
    };
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
