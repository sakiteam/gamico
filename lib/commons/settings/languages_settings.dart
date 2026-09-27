import 'package:flutter/material.dart';
import 'package:gamico/languages/languages.dart';
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

  GamicoLanguages forLocale(Locale locale) {
    return switch (locale.languageCode) {
      "fr" => fr,
      "zh" => zh,
      "hi" => hi,
      "es" => es,
      "de" => de,
      "bn" => bn,
      "ru" => ru,
      "pt" => pt,
      _ => en,
    };
  }
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
  String get friendPageTitle => "Search Friends";

  @override
  String get friendPageSearchHint => "Search by name...";

  @override
  String get friendPagePendingInvitations => "Pending Invitations";

  @override
  String get friendPageGameInvitation => "Game Invitation";

  @override
  String friendPageInvitationFrom(String name) => "From: $name";

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
  String get homeGratificationBrokeUserPopupInstructionDescription => "";

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
  String get friendPageTitle => "Rechercher des amis";

  @override
  String get friendPageSearchHint => "Rechercher un joueur";

  @override
  String get friendPagePendingInvitations => "Invitations en attente";

  @override
  String get friendPageGameInvitation => "Invitation à jouer";

  @override
  String friendPageInvitationFrom(String name) => "De : $name";

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
  String get homeGratificationBrokeUserPopupInstructionDescription => "";
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
  String get friendPageTitle => "搜索好友";

  @override
  String get friendPageSearchHint => "按名字搜索...";

  @override
  String get friendPagePendingInvitations => "待处理邀请";

  @override
  String get friendPageGameInvitation => "游戏邀请";

  @override
  String friendPageInvitationFrom(String name) => "来自：$name";

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
  String get homeGratificationBrokeUserPopupInstructionDescription => "";
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
  String get friendPageTitle => "दोस्त खोजें";

  @override
  String get friendPageSearchHint => "नाम से खोजें...";

  @override
  String get friendPagePendingInvitations => "लंबित निमंत्रण";

  @override
  String get friendPageGameInvitation => "खेल का निमंत्रण";

  @override
  String friendPageInvitationFrom(String name) => "से: $name";

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
  String get homeGratificationBrokeUserPopupInstructionDescription => "";
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
  String get friendPageTitle => "Buscar amigos";

  @override
  String get friendPageSearchHint => "Buscar por nombre...";

  @override
  String get friendPagePendingInvitations => "Invitaciones pendientes";

  @override
  String get friendPageGameInvitation => "Invitación al juego";

  @override
  String friendPageInvitationFrom(String name) => "De: $name";

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
  String get homeGratificationBrokeUserPopupInstructionDescription => "";
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
  String get friendPageTitle => "Freunde suchen";

  @override
  String get friendPageSearchHint => "Nach Namen suchen...";

  @override
  String get friendPagePendingInvitations => "Ausstehende Einladungen";

  @override
  String get friendPageGameInvitation => "Spieleinladung";

  @override
  String friendPageInvitationFrom(String name) => "Von: $name";

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
  String get homeGratificationBrokeUserPopupInstructionDescription => "";
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
  String get friendPageTitle => "বন্ধু খুঁজুন";

  @override
  String get friendPageSearchHint => "নাম দিয়ে খুঁজুন...";

  @override
  String get friendPagePendingInvitations => "অপেক্ষমান আমন্ত্রণ";

  @override
  String get friendPageGameInvitation => "খেলার আমন্ত্রণ";

  @override
  String friendPageInvitationFrom(String name) => "থেকে: $name";

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
  String get homeGratificationBrokeUserPopupInstructionDescription => "";
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
  String get friendPageTitle => "Поиск друзей";

  @override
  String get friendPageSearchHint => "Поиск по имени...";

  @override
  String get friendPagePendingInvitations => "Ожидающие приглашения";

  @override
  String get friendPageGameInvitation => "Приглашение в игру";

  @override
  String friendPageInvitationFrom(String name) => "От: $name";

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
  String get homeGratificationBrokeUserPopupInstructionDescription => "";
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
  String get friendPageTitle => "Procurar amigos";

  @override
  String get friendPageSearchHint => "Buscar por nome...";

  @override
  String get friendPagePendingInvitations => "Convites pendentes";

  @override
  String get friendPageGameInvitation => "Convite para jogo";

  @override
  String friendPageInvitationFrom(String name) => "De: $name";

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
  String get homeGratificationBrokeUserPopupInstructionDescription => "";
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
