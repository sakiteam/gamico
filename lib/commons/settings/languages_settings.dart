import 'package:flutter/material.dart';
import 'package:gamico/languages/language_bn.dart';
import 'package:gamico/languages/language_de.dart';
import 'package:gamico/languages/language_en.dart';
import 'package:gamico/languages/language_es.dart';
import 'package:gamico/languages/language_fr.dart';
import 'package:gamico/languages/language_hi.dart';
import 'package:gamico/languages/language_pt.dart';
import 'package:gamico/languages/language_ru.dart';
import 'package:gamico/languages/language_zh.dart';

@immutable
class LanguagesSettings {
  final GamicoLanguageEn en;
  final GamicoLanguageFr fr;
  final GamicoLanguageZh zh;
  final GamicoLanguageHi hi;
  final GamicoLanguageEs es;
  final GamicoLanguageDe de;
  final GamicoLanguageBn bn;
  final GamicoLanguageRu ru;
  final GamicoLanguagePt pt;

  const LanguagesSettings({
    required this.en,
    required this.fr,
    required this.zh,
    required this.hi,
    required this.es,
    required this.de,
    required this.bn,
    required this.ru,
    required this.pt,
  });
}
