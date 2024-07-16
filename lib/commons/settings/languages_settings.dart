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

final defaultLanguagesSettings = LanguagesSettings(
  en: GamicoLanguageEnDefault(),
  bn: GamicoLanguageBnDefault(),
  de: GamicoLanguageDeDefault(),
  es: GamicoLanguageEsDefault(),
  fr: GamicoLanguageFrDefault(),
  hi: GamicoLanguageHiDefault(),
  pt: GamicoLanguagePtDefault(),
  ru: GamicoLanguageRuDefault(),
  zh: GamicoLanguageZhDefault(),
);

class GamicoLanguageEnDefault extends GamicoLanguageEn {
  @override
  String get adventureDrawImpossibleToPlayNextLevelDescription => "";

  @override
  String gamePopupWatchAd(int cowries) => "";

  @override
  String get globalAppName => "";

  @override
  String homeCowriesStoreCowriesCount(String cowries) => "";

  @override
  String get homeCowriesStoreEnoughCowriesDescription => "";

  @override
  String homeCowriesStoreMiniMulti(int cowries) => "";

  @override
  String get homeCowriesStoreMiniOne => "";

  @override
  String get homeCowriesStoreNotEnoughCowriesDescription => "";

  @override
  String get homeCowriesStoreOneCowriesTitle => "";

  @override
  String get homeCowriesStoreZeroCowrieTitle => "";

  @override
  String homeGratificationPopupHourReward(int cowries, int hour) => "";

  @override
  String get homeGratificationPopupIncorrectTimestampDescription => "";

  @override
  String get homeGratificationPopupInstructionDescription => "";

  @override
  String homeGratificationPopupNextReward(int nextGratificationsCowries) => "";

  @override
  String get passAndPlayDrawDescription => "";

  @override
  String get passAndPlayDrawTitle => "";

  @override
  String get passAndPlayTeam1VictoryDescription => "";

  @override
  String get passAndPlayTeam1VictoryTitle => "";

  @override
  String get passAndPlayTeam2VictoryDescription => "";

  @override
  String get passAndPlayTeam2VictoryTitle => "";

  @override
  String get watchAdButtonWatchAd => "";
}

class GamicoLanguageFrDefault extends GamicoLanguageFr {
  @override
  String get adventureDrawImpossibleToPlayNextLevelDescription => "";

  @override
  String gamePopupWatchAd(int cowries) => "";

  @override
  String get globalAppName => "";

  @override
  String homeCowriesStoreCowriesCount(String cowries) => "";

  @override
  String get homeCowriesStoreEnoughCowriesDescription => "";

  @override
  String homeCowriesStoreMiniMulti(int cowries) => "";

  @override
  String get homeCowriesStoreMiniOne => "";

  @override
  String get homeCowriesStoreNotEnoughCowriesDescription => "";

  @override
  String get homeCowriesStoreOneCowriesTitle => "";

  @override
  String get homeCowriesStoreZeroCowrieTitle => "";

  @override
  String homeGratificationPopupHourReward(int cowries, int hour) => "";

  @override
  String get homeGratificationPopupIncorrectTimestampDescription => "";

  @override
  String get homeGratificationPopupInstructionDescription => "";

  @override
  String homeGratificationPopupNextReward(int nextGratificationsCowries) => "";

  @override
  String get passAndPlayDrawDescription => "";

  @override
  String get passAndPlayDrawTitle => "";

  @override
  String get passAndPlayTeam1VictoryDescription => "";

  @override
  String get passAndPlayTeam1VictoryTitle => "";

  @override
  String get passAndPlayTeam2VictoryDescription => "";

  @override
  String get passAndPlayTeam2VictoryTitle => "";

  @override
  String get watchAdButtonWatchAd => "";

  //

  @override
  String adventureComplexCloseDescription(int cowries) => "";

  @override
  String get adventureDefeatImpossibleToPlayAgainDescription => "";

  @override
  String get adventureDefeatImpossibleToPlayNextLevelDescription => "";

  @override
  String get adventureVictoryImpossibleToPlayNextLevelDescription => "";

  @override
  String get externalInvitationReplayImpossibleDescription => "";

  @override
  String get externalNeedinessDescription => "";

  @override
  String get homeProfilePopupDescription => "";

  @override
  String get internalNeedinessDescription => "";

  @override
  String get internalNeedinessTitle => "";

  @override
  String get notificationGiftBody => "";

  @override
  String get progressOptionButtonNotAuthenticatedTitle => "";

  @override
  String get progressOptionButtonNotAuthenticationDescription => "";

  @override
  String get progressOptionButtonShowcase => "";

  @override
  String referralNotificationBody(String name) => "";

  @override
  String get referralNotificationTitle => "";

  @override
  String remoteComplexCloseDescription(int cowries) => "";

  @override
  String remoteImpossibleGamePosterDescription(int cowries) => "";

  @override
  String get remoteImpossibleGamePosterTitle => "";

  @override
  String get remotePossibleToPlayAgainDescription => "";
}

class GamicoLanguageZhDefault extends GamicoLanguageZh {
  @override
  String get adventureDrawImpossibleToPlayNextLevelDescription => "";

  @override
  String gamePopupWatchAd(int cowries) => "";

  @override
  String get globalAppName => "";

  @override
  String homeCowriesStoreCowriesCount(String cowries) => "";

  @override
  String get homeCowriesStoreEnoughCowriesDescription => "";

  @override
  String homeCowriesStoreMiniMulti(int cowries) => "";

  @override
  String get homeCowriesStoreMiniOne => "";

  @override
  String get homeCowriesStoreNotEnoughCowriesDescription => "";

  @override
  String get homeCowriesStoreOneCowriesTitle => "";

  @override
  String get homeCowriesStoreZeroCowrieTitle => "";

  @override
  String homeGratificationPopupHourReward(int cowries, int hour) => "";

  @override
  String get homeGratificationPopupIncorrectTimestampDescription => "";

  @override
  String get homeGratificationPopupInstructionDescription => "";

  @override
  String homeGratificationPopupNextReward(int nextGratificationsCowries) => "";

  @override
  String get passAndPlayDrawDescription => "";

  @override
  String get passAndPlayDrawTitle => "";

  @override
  String get passAndPlayTeam1VictoryDescription => "";

  @override
  String get passAndPlayTeam1VictoryTitle => "";

  @override
  String get passAndPlayTeam2VictoryDescription => "";

  @override
  String get passAndPlayTeam2VictoryTitle => "";

  @override
  String get watchAdButtonWatchAd => "";
}

class GamicoLanguageHiDefault extends GamicoLanguageHi {
  @override
  String get adventureDrawImpossibleToPlayNextLevelDescription => "";

  @override
  String gamePopupWatchAd(int cowries) => "";

  @override
  String get globalAppName => "";

  @override
  String homeCowriesStoreCowriesCount(String cowries) => "";

  @override
  String get homeCowriesStoreEnoughCowriesDescription => "";

  @override
  String homeCowriesStoreMiniMulti(int cowries) => "";

  @override
  String get homeCowriesStoreMiniOne => "";

  @override
  String get homeCowriesStoreNotEnoughCowriesDescription => "";

  @override
  String get homeCowriesStoreOneCowriesTitle => "";

  @override
  String get homeCowriesStoreZeroCowrieTitle => "";

  @override
  String homeGratificationPopupHourReward(int cowries, int hour) => "";

  @override
  String get homeGratificationPopupIncorrectTimestampDescription => "";

  @override
  String get homeGratificationPopupInstructionDescription => "";

  @override
  String homeGratificationPopupNextReward(int nextGratificationsCowries) => "";

  @override
  String get passAndPlayDrawDescription => "";

  @override
  String get passAndPlayDrawTitle => "";

  @override
  String get passAndPlayTeam1VictoryDescription => "";

  @override
  String get passAndPlayTeam1VictoryTitle => "";

  @override
  String get passAndPlayTeam2VictoryDescription => "";

  @override
  String get passAndPlayTeam2VictoryTitle => "";

  @override
  String get watchAdButtonWatchAd => "";
}

class GamicoLanguageEsDefault extends GamicoLanguageEs {
  @override
  String get adventureDrawImpossibleToPlayNextLevelDescription => "";

  @override
  String gamePopupWatchAd(int cowries) => "";

  @override
  String get globalAppName => "";

  @override
  String homeCowriesStoreCowriesCount(String cowries) => "";

  @override
  String get homeCowriesStoreEnoughCowriesDescription => "";

  @override
  String homeCowriesStoreMiniMulti(int cowries) => "";

  @override
  String get homeCowriesStoreMiniOne => "";

  @override
  String get homeCowriesStoreNotEnoughCowriesDescription => "";

  @override
  String get homeCowriesStoreOneCowriesTitle => "";

  @override
  String get homeCowriesStoreZeroCowrieTitle => "";

  @override
  String homeGratificationPopupHourReward(int cowries, int hour) => "";

  @override
  String get homeGratificationPopupIncorrectTimestampDescription => "";

  @override
  String get homeGratificationPopupInstructionDescription => "";

  @override
  String homeGratificationPopupNextReward(int nextGratificationsCowries) => "";

  @override
  String get passAndPlayDrawDescription => "";

  @override
  String get passAndPlayDrawTitle => "";

  @override
  String get passAndPlayTeam1VictoryDescription => "";

  @override
  String get passAndPlayTeam1VictoryTitle => "";

  @override
  String get passAndPlayTeam2VictoryDescription => "";

  @override
  String get passAndPlayTeam2VictoryTitle => "";

  @override
  String get watchAdButtonWatchAd => "";
}

class GamicoLanguageDeDefault extends GamicoLanguageDe {
  @override
  String get adventureDrawImpossibleToPlayNextLevelDescription => "";

  @override
  String gamePopupWatchAd(int cowries) => "";

  @override
  String get globalAppName => "";

  @override
  String homeCowriesStoreCowriesCount(String cowries) => "";

  @override
  String get homeCowriesStoreEnoughCowriesDescription => "";

  @override
  String homeCowriesStoreMiniMulti(int cowries) => "";

  @override
  String get homeCowriesStoreMiniOne => "";

  @override
  String get homeCowriesStoreNotEnoughCowriesDescription => "";

  @override
  String get homeCowriesStoreOneCowriesTitle => "";

  @override
  String get homeCowriesStoreZeroCowrieTitle => "";

  @override
  String homeGratificationPopupHourReward(int cowries, int hour) => "";

  @override
  String get homeGratificationPopupIncorrectTimestampDescription => "";

  @override
  String get homeGratificationPopupInstructionDescription => "";

  @override
  String homeGratificationPopupNextReward(int nextGratificationsCowries) => "";

  @override
  String get passAndPlayDrawDescription => "";

  @override
  String get passAndPlayDrawTitle => "";

  @override
  String get passAndPlayTeam1VictoryDescription => "";

  @override
  String get passAndPlayTeam1VictoryTitle => "";

  @override
  String get passAndPlayTeam2VictoryDescription => "";

  @override
  String get passAndPlayTeam2VictoryTitle => "";

  @override
  String get watchAdButtonWatchAd => "";
}

class GamicoLanguageBnDefault extends GamicoLanguageBn {
  @override
  String get adventureDrawImpossibleToPlayNextLevelDescription => "";

  @override
  String gamePopupWatchAd(int cowries) => "";

  @override
  String get globalAppName => "";

  @override
  String homeCowriesStoreCowriesCount(String cowries) => "";

  @override
  String get homeCowriesStoreEnoughCowriesDescription => "";

  @override
  String homeCowriesStoreMiniMulti(int cowries) => "";

  @override
  String get homeCowriesStoreMiniOne => "";

  @override
  String get homeCowriesStoreNotEnoughCowriesDescription => "";

  @override
  String get homeCowriesStoreOneCowriesTitle => "";

  @override
  String get homeCowriesStoreZeroCowrieTitle => "";

  @override
  String homeGratificationPopupHourReward(int cowries, int hour) => "";

  @override
  String get homeGratificationPopupIncorrectTimestampDescription => "";

  @override
  String get homeGratificationPopupInstructionDescription => "";

  @override
  String homeGratificationPopupNextReward(int nextGratificationsCowries) => "";

  @override
  String get passAndPlayDrawDescription => "";

  @override
  String get passAndPlayDrawTitle => "";

  @override
  String get passAndPlayTeam1VictoryDescription => "";

  @override
  String get passAndPlayTeam1VictoryTitle => "";

  @override
  String get passAndPlayTeam2VictoryDescription => "";

  @override
  String get passAndPlayTeam2VictoryTitle => "";

  @override
  String get watchAdButtonWatchAd => "";
}

class GamicoLanguageRuDefault extends GamicoLanguageRu {
  @override
  String get adventureDrawImpossibleToPlayNextLevelDescription => "";

  @override
  String gamePopupWatchAd(int cowries) => "";

  @override
  String get globalAppName => "";

  @override
  String homeCowriesStoreCowriesCount(String cowries) => "";

  @override
  String get homeCowriesStoreEnoughCowriesDescription => "";

  @override
  String homeCowriesStoreMiniMulti(int cowries) => "";

  @override
  String get homeCowriesStoreMiniOne => "";

  @override
  String get homeCowriesStoreNotEnoughCowriesDescription => "";

  @override
  String get homeCowriesStoreOneCowriesTitle => "";

  @override
  String get homeCowriesStoreZeroCowrieTitle => "";

  @override
  String homeGratificationPopupHourReward(int cowries, int hour) => "";

  @override
  String get homeGratificationPopupIncorrectTimestampDescription => "";

  @override
  String get homeGratificationPopupInstructionDescription => "";

  @override
  String homeGratificationPopupNextReward(int nextGratificationsCowries) => "";

  @override
  String get passAndPlayDrawDescription => "";

  @override
  String get passAndPlayDrawTitle => "";

  @override
  String get passAndPlayTeam1VictoryDescription => "";

  @override
  String get passAndPlayTeam1VictoryTitle => "";

  @override
  String get passAndPlayTeam2VictoryDescription => "";

  @override
  String get passAndPlayTeam2VictoryTitle => "";

  @override
  String get watchAdButtonWatchAd => "";
}

class GamicoLanguagePtDefault extends GamicoLanguagePt {
  @override
  String get adventureDrawImpossibleToPlayNextLevelDescription => "";

  @override
  String gamePopupWatchAd(int cowries) => "";

  @override
  String get globalAppName => "";

  @override
  String homeCowriesStoreCowriesCount(String cowries) => "";

  @override
  String get homeCowriesStoreEnoughCowriesDescription => "";

  @override
  String homeCowriesStoreMiniMulti(int cowries) => "";

  @override
  String get homeCowriesStoreMiniOne => "";

  @override
  String get homeCowriesStoreNotEnoughCowriesDescription => "";

  @override
  String get homeCowriesStoreOneCowriesTitle => "";

  @override
  String get homeCowriesStoreZeroCowrieTitle => "";

  @override
  String homeGratificationPopupHourReward(int cowries, int hour) => "";

  @override
  String get homeGratificationPopupIncorrectTimestampDescription => "";

  @override
  String get homeGratificationPopupInstructionDescription => "";

  @override
  String homeGratificationPopupNextReward(int nextGratificationsCowries) => "";

  @override
  String get passAndPlayDrawDescription => "";

  @override
  String get passAndPlayDrawTitle => "";

  @override
  String get passAndPlayTeam1VictoryDescription => "";

  @override
  String get passAndPlayTeam1VictoryTitle => "";

  @override
  String get passAndPlayTeam2VictoryDescription => "";

  @override
  String get passAndPlayTeam2VictoryTitle => "";

  @override
  String get watchAdButtonWatchAd => "";
}
