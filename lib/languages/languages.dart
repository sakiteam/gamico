import 'package:flutter/material.dart';

/// Abstract class containing translations.
abstract class GamicoLanguages {
  static late GamicoLanguages instance;

  /// Available locales of this game
  static const List<Locale> locales = [
    Locale('en'),
    Locale('fr'),
    Locale('zh'),
    Locale('hi'),
    Locale('es'),
    Locale('de'),
    Locale('bn'),
    Locale('ru'),
    Locale('pt'),
  ];

  /// Available languages codes of this game
  static List<String> get languageCodes {
    return GamicoLanguages.locales.map((e) => e.languageCode).toList();
  }

  /// Locale to use when the player locale is not supported
  static Locale get fallbackLocale {
    return const Locale('en');
  }

  /// Retrieve the closest [GamicoLanguages] class to the given [context]
  static GamicoLanguages of(BuildContext context) {
    final lang = Localizations.of<GamicoLanguages>(context, GamicoLanguages);
    if (lang != null) return lang;
    return GamicoLanguages.instance;
  }

  /* GLOBAL */

  String get globalMax;
  String get globalAppName;
  String get globalRefresh;
  String get globalClose;
  String get globalOK;
  String get globalAd;

  /* FRIEND */

  String get friendPageTitle;
  String get friendPageSearchHint;
  String get friendPagePendingInvitations;
  String get friendPageGameInvitation;
  String friendPageInvitationFrom(String name);
  String get friendPageInvitationSent;
  String get friendPageFailedToSendInvitation;
  String get friendPageUnknown;
  String get notificationInvitationBody;
  String notificationInvitationFrom(String name);

  /* ADVENTURE */

  String get adventureHelpTitle;
  String get adventureHelpDescription;
  String get adventureClose;
  String get adventureFollow;

  String adventureChapterChapter(int chapter);

  /* COLLECTION */

  String collectionCardPopupFamily(String family);
  String get collectionCardPopupUpgrade;
  String get collectionCardPopupRemove;
  String get collectionCardPopupUse;
  String get collectionCardPopupAcquire;

  String get collectionCardSkillsAttack;
  String get collectionCardSkillsSupport;
  String get collectionCardSkillsResistance;
  String get collectionCardSkillsTheoreticalLife;
  String get collectionCardSkillsTheoreticalSpeed;
  String get collectionCardSkillsPower;
  String get collectionCardSkillsConcreteLife;
  String get collectionCardSkillsConcreteSpeed;
  String get collectionCardSkillsConnections;

  String collectionCardSquareLevel(int level);

  String get collectionCardBlocked;
  String collectionCardLevel(int level);

  String get collectionContentDeck;
  String get collectionContentUnlockedCards;
  String get collectionContentRemainingCards;

  /* HOME */

  String get homeLanguagesTitle;
  String get homeMultiplayerButtonShowcase;
  String get homeSingleplayerButtonShowcase;
  String get homeNotificationsTitle;
  String get homeNotificationsDescription;
  String get homeNotificationsAllow;
  String get homeNotificationsReminderTitle;
  String get homeNotificationsReminderDescription;
  String get homeUpdateTitle;
  String get homeUpdateSimpleDescription;
  String get homeUpdateForceDescription;
  String get homeUpdateInstall;
  String get homeAbout;
  String homeAboutPopupShareText(String link);
  String get homeAboutPopupImplementation;
  String get homeAboutPopupMusic;
  String get homeAboutPopupVersion;
  String get homeAboutPopupRateGame;
  String get homeAboutPopupVisitWebstie;
  String get homeAboutPopupDiscoverApps;
  String get homeCardPresentationShowcase;
  String get homeCardPresentationShow;

  //
  String get homeCowriesStoreZeroCowrieTitle;
  String get homeCowriesStoreOneCowriesTitle;
  String get homeCowriesStoreNotEnoughCowriesDescription;
  String get homeCowriesStoreEnoughCowriesDescription;
  String get homeCowriesStoreTransactionErrorTitle;
  String get homeCowriesStoreTransactionErrorDescription;
  String get homeCowriesStoreMiniOne;
  String homeCowriesStoreMiniMulti(int cowries);
  String homeCowriesStoreCowriesCount(String cowries);
  //

  String get homeGratificationPopupConnectionErrorTitle;
  String get homeGratificationPopupConnectionErrorDescription;
  String get homeGratificationPopupLoadingTitle;
  String get homeGratificationPopupLoadingDescription;
  String get homeGratificationPopupIncorrectTimestampTitle;

  //
  String get homeGratificationPopupIncorrectTimestampDescription;
  String get homeGratificationPopupInstructionDescription;
  String get homeGratificationBrokeUserPopupInstructionDescription;
  String homeGratificationPopupHourReward(int cowries, int hour);
  String homeGratificationPopupNextReward(int nextGratificationsCowries);
  //

  String get homeMultiplayerButtonConnectionErrorTitle;
  String get homeMultiplayerButtonConnectionErrorDescription;
  String get homeMultiplayerButtonText;
  String get homeProfilePopupBestTacticians;
  String get homeProfilePopupDescription;
  String get homeProfilePopupBestCollectors;
  String get homeProfilePopupCheckAchievements;
  String get homeSingleplayerButtonText;

  String get homeSpecialOfferPopupOfferDisabledDescription;
  String get homeSpecialOfferPopupOfferLoadedDescription;
  String get homeSpecialOfferPopupOfferLoadingDescription;
  String get homeSpecialOfferPopupErrorDescription;
  String homeSpecialOfferPopupOffsetLoadedTitle(String? packTitle);
  String get homeSpecialOfferPopupOfferLoadingTitle;
  String get homeSpecialOfferPopupErrorTitle;
  String get homeSpecialOfferPopupClose;
  String get homeSpecialOfferPopupTimestampTitle;
  String get homeSpecialOfferPopupLoadingDescription;
  String get homeSpecialOfferPopupLoadingTitle;
  String get homeSpecialOfferPopupProblemClose;
  String get homeSpecialOfferPopupProblemTitle;

  String get premiumPopupTitle;
  String get premiumPopupDescription;
  String get premiumPlayer;
  String get nonPremiumPlayer;

  String get homeHelpBasicsA;
  String get homeHelpBasicsB;
  String get homeHelpBasicsC;
  String get homeHelpConnections1A;
  String get homeHelpConnections1B;
  String get homeHelpConnections1C;
  String get homeHelpConnections2A;
  String get homeHelpConnections2B;
  String get homeHelpConnections2C;
  String get homeHelpCards1A;
  String get homeHelpCards1B;
  String get homeHelpCards1C;
  String get homeHelpCards2A;
  String get homeHelpCards2B;
  String get homeHelpCards2C;
  String get homeHelpRestrictionsA;
  String get homeHelpRestrictionsB;
  String get homeHelpRestrictionsC;

  /* LOADING */

  String get loadingTitle;
  String get loadingDescription;

  /* REMOTE */

  String get remoteConnexionProblemTitle;
  String get remoteConnexionProblemDescription;
  String get remoteInvitationTitle;
  String get remoteInvitationDescription;
  String get remoteMultiplayer;

  String get remoteFailurePosterTitle;
  String get remoteFailurePosterDescription;

  String get remoteImpossibleGamePosterTitle;
  String remoteImpossibleGamePosterDescription(int cowries);

  String get remoteNewGamePosterTitle;
  String get remoteNewGamePosterDescription;

  String get remoteSearchPosterTitle;
  String get remoteSearchPosterDescription;

  String get homeTranslationPopupDescription;

  /* CARDS TITLES */

  String get lordLazyKingName;
  String get lordLazyQueenName;
  String get lordLazyPrinceName;
  String get lordLazyPrincessName;
  String get lordCourageousKingName;
  String get lordCourageousQueenName;
  String get lordCourageousPrinceName;
  String get lordCourageousPrincessName;
  String get normalOrdinaryCitizenName;
  String get normalAttackerDefenderName;
  String get normalAttackerHealerName;
  String get normalDefenderHealerName;
  String get attacker2AName;
  String get attacker2BName;
  String get attacker2CName;
  String get attacker4AName;
  String get attacker4BName;
  String get attacker4CName;
  String get defender2AName;
  String get defender2BName;
  String get defender2CName;
  String get defender4AName;
  String get defender4BName;
  String get defender4CName;
  String get healer2AName;
  String get healer2BName;
  String get healer2CName;
  String get healer4AName;
  String get healer4BName;
  String get healer4CName;
  String get specialExpansionName;
  String get specialCompressionName;
  String get specialDecelerationName;
  String get specialAccelerationName;
  String get specialAttackIncreaseName;
  String get specialAttackDecreaseName;
  String get specialResistanceIncreaseName;
  String get specialResistanceDecreaseName;
  String get specialSupportIncreaseName;
  String get specialSupportDecreaseName;
  String get specialCloningName;
  String get specialCancellationName;
  String get specialRefrigerationName;
  String get specialAspiratorName;
  String get specialSubstractionName;
  String get specialDivisionName;
  String get specialDeflagrationName;
  String get specialParalysisName;
  String get specialInvulnerabilityName;
  String get specialVortexName;

  /* CARDS DESCRIPTIONS */

  String get lordLazyKingDescription;
  String get lordLazyQueenDescription;
  String get lordLazyPrinceDescription;
  String get lordLazyPrincessDescription;
  String get lordCourageousKingDescription;
  String get lordCourageousQueenDescription;
  String get lordCourageousPrinceDescription;
  String get lordCourageousPrincessDescription;
  String get normalOrdinaryCitizenDescription;
  String get normalAttackerDefenderDescription;
  String get normalAttackerHealerDescription;
  String get normalDefenderHealerDescription;
  String get attacker2ADescription;
  String get attacker2BDescription;
  String get attacker2CDescription;
  String get attacker4ADescription;
  String get attacker4BDescription;
  String get attacker4CDescription;
  String get defender2ADescription;
  String get defender2BDescription;
  String get defender2CDescription;
  String get defender4ADescription;
  String get defender4BDescription;
  String get defender4CDescription;
  String get healer2ADescription;
  String get healer2BDescription;
  String get healer2CDescription;
  String get healer4ADescription;
  String get healer4BDescription;
  String get healer4CDescription;
  String get specialExpansionDescription;
  String get specialCompressionDescription;
  String get specialDecelerationDescription;
  String get specialAccelerationDescription;
  String get specialAttackIncreaseDescription;
  String get specialAttackDecreaseDescription;
  String get specialResistanceIncreaseDescription;
  String get specialResistanceDecreaseDescription;
  String get specialSupportIncreaseDescription;
  String get specialSupportDecreaseDescription;
  String get specialCloningDescription;
  String get specialCancellationDescription;
  String get specialRefrigerationDescription;
  String get specialAspiratorDescription;
  String get specialSubstractionDescription;
  String get specialDivisionDescription;
  String get specialDeflagrationDescription;
  String get specialParalysisDescription;
  String get specialInvulnerabilityDescription;
  String get specialVortexDescription;

  /* GAME */

  String get gameAbandonmentButtonDescription;
  String get gameAbandonmentButtonAbandon;
  String get gameAbandonmentButtonTitle;
  String get gameBottomButtonDisplayResult;
  String get gameCardsSummaryPlay;
  String get gameCardsSummaryRemember;
  String get gameInitialTutorialPopupPlay;
  String get gamePassButtonPopupPass;
  String get gamePassButtonPopupDescription;
  String get gamePassButtonPopupTitle;
  String get adventureVictoryPossibleToPlayNextLevelDescription;
  String get adventureVictoryImpossibleToPlayNextLevelDescription;
  String get adventureVictoryGameFinishedDescription;
  String get adventureDefeatPossibleToPlayAgainDescription;
  String get adventureDefeatImpossibleToPlayAgainDescription;
  String get adventureDefeatPossibleToPlayNextLevelDescription;
  String get adventureDefeatImpossibleToPlayNextLevelDescription;
  String get adventureGameAlreadyFinishedDescription;
  String get remoteDefeatDescription;
  String get remoteVictoryDescription;
  String get remotePossibleToPlayAgainDescription;
  String get remoteOpponentUnavailableDescription;
  String get externalNeedinessDescription;
  String get internalNeedinessTitle;
  String get replayImpossibleDescription;
  String get invitationWithdrawalDescription;
  String get invitationRejectionDescription;
  String get invitationAcceptationDescription;
  String get externalInvitationReplayImpossibleDescription;
  String get externalInvitationReplayPossibleDescription;
  String get internalInvitationDescription;

  String gamePopupWatchAd(int cowries);
  String get gamePopupNewGame;
  String get gamePopupNextLevel;
  String get gamePopupReplay;
  String get globalExit;
  String get globalAccept;
  String get globalReject;
  String get globalCancel;
  String get normalDefeatTitle;
  String get defeatByAbandonment;
  String get normalVictoryTitle;
  String get victoryByAbandonment;
  String get externalNeedinessTitle;
  String get internalNeedinessDescription;
  String get replayImpossibleTitle;
  String get invitationWithdrawalTitle;
  String get invitationRejectionTitle;
  String get invitationAcceptationTitle;
  String get externalInvitationTitle;
  String get internalInvitationTitle;

  String get gameProfilePosterClose;
  String get gameProfilePosterDeck;
  String get gameProfilePosterCards;
  String get gameProfilePosterCrowns;

  List<String> get names;
  String gameScoresIndicatorNormalGameDescription(int level);
  String get gameScoresIndicatorTutorialGameDescription;
  String gameTileNameLevel(int level);
  String get gameTopBarTutorialText;

  String get gametutorialCongratulationsPopupDescription;
  String get gametutorialCongratulationsPopupPlay;
  String get gametutorialCongratulationsPopupTitle;
  String get gameTutorialCongratulationsPopupUnclearDescription;

  String get gameTutorialPopupTitle;

  String get gameTutorialProgressPopupNextLesson;
  String get gameTutorialProgressPopupTitle;

  /* USER CUBIT */

  String get referralNotificationTitle;
  String referralNotificationBody(String name);

  /* NOTIFICATION */

  String get notificationMissBody;
  String get notificationMissTitle;
  String get notificationGiftBody;
  String get notificationGiftTitle;

  /* GLOBAL */

  String get kingConquestInstruction;
  String get invalidDeckTitle;
  String get invalidDeckDescription;

  String get authenticationPopupAuthenticationErrorDescription;
  String get authenticationPopupAuthenticationErrorTitle;
  String get globalRetry;
  String get authenticationPopupRequiredAuthentication;
  String get authenticationPopupLoadingAuthentication;
  String authenticationPopupDescription(String account);
  String get globalAppleGameCenter;
  String get globalGooglePlay;
  String cardOptionButtonPopupDeckN(int index);
  String get cardOptionButtonPopupSelectDeck;
  String get cardOptionButtonDescription;
  String get globalValidate;
  String get blockedAccountContactSakiHub;
  String get blockedAccountDescription;
  String get blockedAccountTitle;
  String get progressOptionButtonNotAuthenticationDescription;
  String get progressOptionButtonNotAuthenticatedTitle;
  String get progressOptionButtonShowcase;
  String get watchAdButtonWatchAd;
  String get watchAdButtonRefreshAd;
  String get globalConnect;
  String get premiumButtonRemoveAds;

  /* FAMILIES */

  String get attackerFamilyName;
  String get attackerFamilyShortDescription;
  String get attackerFamilyLongDescription;
  String get defenderFamilyName;
  String get defenderFamilyShortDescription;
  String get defenderFamilyLongDescription;
  String get healerFamilyName;
  String get healerFamilyShortDescription;
  String get healerFamilyLongDescription;
  String get lordFamilyName;
  String get lordFamilyShortDescription;
  String get lordFamilyLongDescription;
  String get normalFamilyName;
  String get normalFamilyShortDescription;
  String get normalFamilyLongDescription;
  String get specialFamilyName;
  String get specialFamilyShortDescription;
  String get specialFamilyLongDescription;

  /* LESSONS */

  String get basicsLessonTitle;
  String get globalLesson;
  String get basicsLessonSuffix;
  String get basicsLessonWinningMessage;
  String get normalLessonTitle;
  String get normalLessonSuffix;
  String get normalLessonDescription;
  String get normalLessonWinningMessage;
  String get specialLessonTitle;
  String get specialLessonSuffix;
  String get specialLessonDescription;

  /* MESSAGES */

  String get awesomeMessage;
  String get congratulationsMessage;
  String get excellentMessage;
  String get goodMessage;
  String get greatMessage;
  String get magnificentMessage;
  String get masterfulMessage;

  /* TUTORIALS INSTRUCTIONS */

  String get basicsPlaceTileInstruction;
  String get basicsConnectCenterTileInstruction;
  String get basicsConquerCenterTileInstruction;
  String get basicsCutPathInstruction;
  String get basicsConnectKingInstruction;
  String get normalPlaceOrdinaryCitizenInstruction;
  String get normalConnectOrdinaryCitizenInstruction;
  String get normalPlaceHealerInstruction;
  String get normalConnectHealerInstruction;
  String get normalPlaceAttackerInstruction;
  String get normalConnectAttackerInstruction;
  String get normalConquerAttackerInstruction;
  String get normalPlaceDefenderInstruction;
  String get normalConnectDefenderInstruction;
  String get normalConnectKingInstruction;
  String get specialPlaceOrdinaryCitizenInstruction;
  String get specialPlaceCompressionInstruction;
  String get specialConnectCompressionInstruction;
  String get specialPlaceRefrigerationInstruction;
  String get specialConnectRefrigerationInstruction;
  String get specialConnectOrdinaryCitizen1Instruction;
  String get specialPlaceExpansionInstruction;
  String get specialConnectExpansionInstruction;
  String get specialConnectOrdinaryCitizen2Instruction;
  String get specialConquerOrdinaryCitizenInstruction;
  String get specialConnectKingInstruction;

  /* TUTORIALS DESCRIPTIONS */

  String get basicsPlaceTileDescription;
  String get basicsConnectCenterTileDescription;
  String get basicsConquerCenterTileDescription;
  String get basicsCutPathDescription;
  String get basicsConnectKingDescription;
  String get kingConquestDescription;

  String get normalPlaceOrdinaryCitizenDescription;
  String get normalConnectOrdinaryCitizenDescription;
  String get normalPlaceHealerDescription;
  String get normalConnectHealerDescription;
  String get normalPlaceAttackerDescription;
  String get normalConnectAttackerDescription;
  String get normalConquerAttackerDescription;
  String get normalPlaceDefenderDescription;
  String get normalConnectDefenderDescription;
  String get normalConnectKingDescription;

  String get specialPlaceOrdinaryCitizenDescription;
  String get specialPlaceCompressionDescription;
  String get specialConnectCompressionDescription;
  String get specialPlaceRefrigerationDescription;
  String get specialConnectRefrigerationDescription;
  String get specialConnectOrdinaryCitizen1Description;
  String get specialPlaceExpansionDescription;
  String get specialConnectExpansionDescription;
  String get specialConnectOrdinaryCitizen2Description;
  String get specialConquerOrdinaryCitizenDescription;
  String get specialConnectKingDescription;

  /* SKILLS */

  String get attackSkillNull;
  String get attackSkillVeryBad;
  String get attackSkillBad;
  String get attackSkillNormal;
  String get attackSkillGood;
  String get attackSkillVeryGood;

  String get supportSkillNull;
  String get supportSkillVeryBad;
  String get supportSkillBad;
  String get supportSkillNormal;
  String get supportSkillGood;
  String get supportSkillVeryGood;

  String get resistanceSkillNull;
  String get resistanceSkillVeryBad;
  String get resistanceSkillBad;
  String get resistanceSkillNormal;
  String get resistanceSkillGood;
  String get resistanceSkillVeryGood;

  String get lifeSkillNull;
  String get lifeSkillHalf;
  String get lifeSkillNormal;

  String get speedSkillNull;
  String get speedSkillHalf;
  String get speedSkillNormal;

  /* GAME PAGE */

  String remoteComplexCloseDescription(int cowries);
  String adventureComplexCloseDescription(int cowries);
  String get adventureSimpleCloseDescription;
  String get remoteSimpleCloseDescription;
  String get closeClose;
  String get closeTitle;

  String get lessonChangeTitle;
  String get lessonChangeDescription;
  String get lessonChangeAction;

  String get restoreDefaultLanguage;

  String get drawTitle;
  String get adventureDrawGameFinishedDescription;
  String get adventureDrawImpossibleToPlayNextLevelDescription;
  String get adventureDrawPossibleToPlayNextLevelDescription;
  String get adventureDrawPossibleToPlayAgainDescription;
  String get remoteDrawDescription;
  String get newPlayer;

  String get passAndPlayTeam1VictoryTitle;
  String get passAndPlayTeam2VictoryTitle;
  String get passAndPlayDrawTitle;

  String get passAndPlayTeam1VictoryDescription;
  String get passAndPlayTeam2VictoryDescription;
  String get passAndPlayDrawDescription;

  /// WiFi-local: the guest's end-of-match popup, where only the host deals.
  String get localNetworkWaitingForHost;

  /// WiFi-local: the host left, so the table cannot continue.
  String get localNetworkHostLeftDescription;

  /// Online end of game: header of the rematch option picker.
  String get replayVoteChooseOption;

  /// Online end of game: seconds left before the rematch starts without the
  /// players who have not answered.
  String replayVoteCountdown(int seconds);

  /// Online end of game: what happens when that countdown runs out.
  String get replayVoteStartingSoon;

  /// Online end of game: the rematch is waiting on the other players.
  String get replayVoteWaitingForPlayers;

  /// Pre-deal roll-call: the waiting list, the vote on absent players, and
  /// the popups of a table that started or was cancelled without someone.
  String get rollCallWaitingTitle;
  String get rollCallReady;
  String get rollCallConnecting;
  String get rollCallYou;
  String rollCallVoteOpensIn(int s);
  String rollCallStartsIn(int s);
  String rollCallEjectVotes(int votes, int needed);
  String get rollCallEject;
  String get rollCallWait;
  String get rollCallPlayerUnavailableTitle;
  String rollCallPlayerUnavailableDescription(int s);
  String get rollCallPlayersUnavailableTitle;
  String get rollCallPlayersUnavailableDescription;
  String get rollCallCancelledTitle;
  String get rollCallExcludedTitle;
  String rollCallExcludedDuel(int s);
  String get rollCallExcludedVote;
  String rollCallExcludedCap(int s);
  String get rollCallExcludedGrace;
  String get rollCallClose;
  String get rollCallWaitingOpponentTitle;
  String rollCallCancelsIn(int s);
  String get rollCallAway;
  String get rollCallLeave;
  String get rollCallPlayerLeftDescription;
  String get rollCallPlayersLeftDescription;
}
