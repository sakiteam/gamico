import 'package:gamico/languages/languages.dart';

abstract class GamicoLanguageEn extends GamicoLanguages {
  @override
  String get globalMax => "MAX";
  @override
  String get globalRefresh => "Refresh";
  @override
  String get globalClose => "Close";
  @override
  String get globalOK => "OK";

  @override
  String get homeLanguagesTitle => "Languages";

  /* FRIEND */

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
  String get friendPageInvitationSent => "Invitation sent!";

  @override
  String get friendPageFailedToSendInvitation => "Failed to send invitation";

  @override
  String get friendPageUnknown => "Unknown";
  @override
  String get notificationInvitationBody => "You have received a game invitation!";
  @override
  String notificationInvitationFrom(String name) => "$name invites you to play!";

  /* ADVENTURE */

  @override
  String get adventureHelpTitle => "Help";
  @override
  String get adventureHelpDescription =>
      "You can select a level by clicking on it. But if you're not yet good at playing, follow the tutorial!";
  @override
  String get adventureClose => "Close";
  @override
  String get adventureFollow => "Follow";

  @override
  String adventureChapterChapter(int chapter) => "Chapter $chapter";

  /* COLLECTION */

  @override
  String collectionCardPopupFamily(String family) => "Family: $family";
  @override
  String get collectionCardPopupUpgrade => "Upgrade";
  @override
  String get collectionCardPopupRemove => "Remove";
  @override
  String get collectionCardPopupUse => "Use";
  @override
  String get collectionCardPopupAcquire => "Acquire";

  @override
  String get collectionCardSkillsAttack => "Attack";
  @override
  String get collectionCardSkillsSupport => "Support";
  @override
  String get collectionCardSkillsResistance => "Resistance";
  @override
  String get collectionCardSkillsTheoreticalLife => "Theoretical Life";
  @override
  String get collectionCardSkillsTheoreticalSpeed => "Theoretical Speed";
  @override
  String get collectionCardSkillsPower => "Power";
  @override
  String get collectionCardSkillsConcreteLife => "Concrete Life";
  @override
  String get collectionCardSkillsConcreteSpeed => "Concrete Speed";
  @override
  String get collectionCardSkillsConnections => "Connections";

  @override
  String collectionCardSquareLevel(int level) => "Level $level";

  @override
  String get collectionCardBlocked => "Blocked";
  @override
  String collectionCardLevel(int level) => "Level $level";

  @override
  String get collectionContentDeck => "Decks";
  @override
  String get collectionContentUnlockedCards => "Unlocked Cards";
  @override
  String get collectionContentRemainingCards => "Remaining Cards";

  /* HOME */

  @override
  String get homeMultiplayerButtonShowcase =>
      "This button allows you to play games with other players online.";
  @override
  String get homeSingleplayerButtonShowcase =>
      "This button allows you to play games with the game's artificial intelligence.";
  @override
  String get homeNotificationsTitle => "Notifications";
  @override
  String get homeNotificationsDescription =>
      "To enhance your gaming experience, you must enable notifications! Do you want to allow notifications?";
  @override
  String get homeNotificationsAllow => "Allow";
  @override
  String get homeUpdateTitle => "Update Available!";
  @override
  String get homeUpdateForceDescription =>
      "Several errors and issues have been resolved in the new version. Install it quickly to benefit from these fixes!";
  @override
  String get homeUpdateInstall => "Install";

  @override
  String get homeAbout => "About";
  @override
  String homeAboutPopupShareText(String link) =>
      "I have discovered a very interesting strategy game! Download it for free at $link!";
  @override
  String get homeAboutPopupImplementation => "Implementation";
  @override
  String get homeAboutPopupMusic => "Music";
  @override
  String get homeAboutPopupVersion => "Version";
  @override
  String get homeAboutPopupRateGame => "Rate\nthe game";
  @override
  String get homeAboutPopupVisitWebstie => "Visit\nSaki Hub";
  @override
  String get homeAboutPopupDiscoverApps => "See my\napps";

  @override
  String get homeCardPresentationShowcase =>
      "Use this menu to buy new cards and improve the ones you already have.";
  @override
  String get homeCardPresentationShow => "See all cards";

  @override
  String get homeGratificationPopupConnectionErrorTitle => "Connection Error!";
  @override
  String get homeGratificationPopupConnectionErrorDescription =>
      "Please check your internet connection. This section will refresh automatically when you are connected!";
  @override
  String get homeGratificationPopupLoadingTitle => "Loading Rewards!";
  @override
  String get homeGratificationPopupLoadingDescription =>
      "The rewards will be available in just a few seconds. Please wait!";
  @override
  String get homeGratificationPopupIncorrectTimestampTitle =>
      "Incorrect Timestamp!";

  @override
  String get homeMultiplayerButtonConnectionErrorTitle => "Connection Issue!";
  @override
  String get homeMultiplayerButtonConnectionErrorDescription =>
      "You don't seem to be connected to the internet. Please check the quality of your internet connection and try again!";
  @override
  String get homeMultiplayerButtonText => "Multi";

  @override
  String get homeProfilePopupBestTacticians => "Best Tacticians";
  @override
  String get homeProfilePopupDescription =>
      "Players are ranked based on two criteria: the number of online wins and the maximum number of cowries!";
  @override
  String get homeProfilePopupBestCollectors => "Best Collectors";
  @override
  String get homeProfilePopupCheckAchievements => "View My Achievements";

  @override
  String get homeSingleplayerButtonText => "Solo";

  @override
  String get homeSpecialOfferPopupOfferDisabledDescription =>
      "Special offers activate every 3 days and are valid for only 24 hours. Don't miss the next one!";
  @override
  String get homeSpecialOfferPopupOfferLoadedDescription =>
      "Special offers activate every 3 days and are valid for only 24 hours. So, what are you waiting for?";
  @override
  String get homeSpecialOfferPopupOfferLoadingDescription =>
      "Data related to the special offer will be available shortly. Please wait for a moment!";
  @override
  String get homeSpecialOfferPopupErrorDescription =>
      "We couldn't validate your purchase. Please check your payment method and your internet connection!";
  @override
  String homeSpecialOfferPopupOffsetLoadedTitle(String? packTitle) =>
      "$packTitle !";
  @override
  String get homeSpecialOfferPopupOfferLoadingTitle => "Loading Offer!";
  @override
  String get homeSpecialOfferPopupErrorTitle => "Transaction Canceled!";
  @override
  String get homeSpecialOfferPopupClose => "Close";
  @override
  String get homeSpecialOfferPopupTimestampTitle => "Incorrect Timestamp!";
  @override
  String get homeSpecialOfferPopupLoadingDescription =>
      "Data related to the special offer will be available shortly. Please wait for a moment!";
  @override
  String get homeSpecialOfferPopupLoadingTitle => "Loading Offer!";
  @override
  String get homeSpecialOfferPopupProblemClose => "Close";
  @override
  String get homeSpecialOfferPopupProblemTitle => "Connection Error!";

  @override
  String get homeHelpBasicsA =>
      "The kingdom of the Blues faces off against the kingdom of the Oranges.";
  @override
  String get homeHelpBasicsB =>
      "One can win by changing the color of the enemy lord.";
  @override
  String get homeHelpBasicsC =>
      "One can win by having the most life points within the allotted time.";

  @override
  String get homeHelpConnections1A =>
      "You can tap and drag to connect two cards.";
  @override
  String get homeHelpConnections1B =>
      "You can tap and tap to connect two cards.";
  @override
  String get homeHelpConnections1C =>
      "You can cut a connection by swiping a finger.";

  @override
  String get homeHelpConnections2A =>
      "A connection can sometimes hinder the ability to play.";
  @override
  String get homeHelpConnections2B =>
      "It is not possible to jump over one card to connect to another.";
  @override
  String get homeHelpConnections2C =>
      "A card at MAX returns all the balls it receives.";

  @override
  String get homeHelpCards1A => "Red cards are good for attacking.";
  @override
  String get homeHelpCards1B => "Gray cards are good for resisting.";
  @override
  String get homeHelpCards1C => "Green cards are good for supporting.";

  @override
  String get homeHelpCards2A => "Brown cards have balanced abilities.";
  @override
  String get homeHelpCards2B =>
      "Yellow cards have special effects on other cards.";
  @override
  String get homeHelpCards2C =>
      "White cards are the ones that must be protected at all costs.";

  @override
  String get homeHelpRestrictionsA =>
      "Every connection must be useful. Here, it is useless and therefore impossible.";
  @override
  String get homeHelpRestrictionsB =>
      "A destruction card cannot attack a lord.";
  @override
  String get homeHelpRestrictionsC =>
      "It is not possible to clone or move a lord.";

  /* LOADING */

  @override
  String get loadingTitle => "Please Wait!";

  /* REMOTE */

  @override
  String get remoteConnexionProblemTitle => "Connection Problem!";
  @override
  String get remoteConnexionProblemDescription =>
      "Sorry! Your internet connection has been disconnected. You have been declared the loser of the game!";
  @override
  String get remoteInvitationTitle => "Come and Play!";
  @override
  String get remoteInvitationDescription => "Your online game has started!";
  @override
  String get remoteMultiplayer => "Multiplayer";

  @override
  String get remoteFailurePosterTitle => "An Error Occurred!";
  @override
  String get remoteFailurePosterDescription =>
      "An error occurred during the search. Check your internet connection and try again!";

  @override
  String get remoteImpossibleGamePosterTitle => "Insufficient Cowries!";
  @override
  String remoteImpossibleGamePosterDescription(int cowries) =>
      "You need at least $cowries cowries to play online!";

  @override
  String get remoteNewGamePosterTitle => "A New Game?";
  @override
  String get remoteNewGamePosterDescription =>
      "You can still play with players from around the world to improve your level!";

  @override
  String get remoteSearchPosterTitle => "Player Search";
  @override
  String get remoteSearchPosterDescription =>
      "We are searching for players worldwide to play a game with you!";
  @override
  String get homeTranslationPopupDescription =>
      "This section allows you to choose the main language of the game. Click on a language to activate it automatically!";

  /* CARD TITLES */

  @override
  String get lordLazyKingName => "Lazy King";
  @override
  String get lordLazyQueenName => "Fragile Queen";
  @override
  String get lordLazyPrinceName => "Lone Prince";
  @override
  String get lordLazyPrincessName => "Introverted Princess";
  @override
  String get lordCourageousKingName => "Pragmatic King";
  @override
  String get lordCourageousQueenName => "Fearless Queen";
  @override
  String get lordCourageousPrinceName => "Sturdy Prince";
  @override
  String get lordCourageousPrincessName => "Dedicated Princess";
  @override
  String get normalOrdinaryCitizenName => "Ordinary Citizen";
  @override
  String get normalAttackerDefenderName => "Military Guard";
  @override
  String get normalAttackerHealerName => "Military Medic";
  @override
  String get normalDefenderHealerName => "Guard Medic";
  @override
  String get attacker2AName => "Flu";
  @override
  String get attacker2BName => "Sun";
  @override
  String get attacker2CName => "Spark";
  @override
  String get attacker4AName => "Whirlwind";
  @override
  String get attacker4BName => "Gnat";
  @override
  String get attacker4CName => "Cyclone";
  @override
  String get defender2AName => "Rock";
  @override
  String get defender2BName => "Pebble";
  @override
  String get defender2CName => "Rampart";
  @override
  String get defender4AName => "Beam";
  @override
  String get defender4BName => "Balcony";
  @override
  String get defender4CName => "Window";
  @override
  String get healer2AName => "Grass";
  @override
  String get healer2BName => "Flower";
  @override
  String get healer2CName => "Leaf";
  @override
  String get healer4AName => "Shrub";
  @override
  String get healer4BName => "Bandage";
  @override
  String get healer4CName => "Tree";
  @override
  String get specialExpansionName => "Expansion";
  @override
  String get specialCompressionName => "Compression";
  @override
  String get specialDecelerationName => "Deceleration";
  @override
  String get specialAccelerationName => "Acceleration";
  @override
  String get specialAttackIncreaseName => "Valor";
  @override
  String get specialAttackDecreaseName => "Cowardice";
  @override
  String get specialResistanceIncreaseName => "Reinforcement";
  @override
  String get specialResistanceDecreaseName => "Weakening";
  @override
  String get specialSupportIncreaseName => "Altruism";
  @override
  String get specialSupportDecreaseName => "Individualism";
  @override
  String get specialCloningName => "Cloning";
  @override
  String get specialCancellationName => "Cancellation";
  @override
  String get specialRefrigerationName => "Refrigeration";
  @override
  String get specialAspiratorName => "Abyss";
  @override
  String get specialSubstractionName => "Subtraction";
  @override
  String get specialDivisionName => "Division";
  @override
  String get specialDeflagrationName => "Deflagration";
  @override
  String get specialParalysisName => "Paralysis";
  @override
  String get specialInvulnerabilityName => "Invulnerability";
  @override
  String get specialVortexName => "Vortex";

  /* CARD DESCRIPTIONS */

  @override
  String get lordLazyKingDescription =>
      "This is the only lord who cannot attack or defend. But he is a balanced king with no particular weaknesses!";
  @override
  String get lordLazyQueenDescription =>
      "She is a lady very skilled at attacking and supporting her subjects despite her advanced age. However, her resistance leaves much to be desired!";
  @override
  String get lordLazyPrinceDescription =>
      "He is a young man very skilled at attacking and resisting attacks. However, he doesn't know how to support his subjects!";
  @override
  String get lordLazyPrincessDescription =>
      "She is a young woman very skilled at resisting attacks and supporting her subjects. However, she is not strong in attack!";
  @override
  String get lordCourageousKingDescription =>
      "This is a balanced king with no particular weaknesses. However, he has half as many hit points as usual!";
  @override
  String get lordCourageousQueenDescription =>
      "She is a lady extremely skilled at attacking despite her advanced age. But she doesn't excel in other areas!";
  @override
  String get lordCourageousPrinceDescription =>
      "He is a young man extremely skilled at resisting attacks. But this prince doesn't excel in other areas!";
  @override
  String get lordCourageousPrincessDescription =>
      "She is a young woman extremely skilled at supporting her subjects. But this princess doesn't excel in other areas!";
  @override
  String get normalOrdinaryCitizenDescription =>
      "This card is the most balanced in the game. It has neither special strengths nor special weaknesses but remains a trustworthy ally!";
  @override
  String get normalAttackerDefenderDescription =>
      "As the name suggests, this is a young man skilled at attacking enemies while resisting their attacks!";
  @override
  String get normalAttackerHealerDescription =>
      "As the name suggests, this is a young man skilled at attacking enemies while supporting allies!";
  @override
  String get normalDefenderHealerDescription =>
      "As the name suggests, this is a young man skilled at supporting allies while resisting attacks from enemies!";
  @override
  String get attacker2ADescription =>
      "This card deals double damage to its enemies compared to a normal card but is not very good at supporting its allies!";
  @override
  String get attacker2BDescription =>
      "This card deals double damage to its enemies compared to a normal card but is weak against attacks from its enemies!";
  @override
  String get attacker2CDescription =>
      "This card deals double damage to its enemies compared to a normal card but is twice as slow as a normal card!";
  @override
  String get attacker4ADescription =>
      "This card deals four times more damage to its enemies than a normal card but is not very good at supporting its allies!";
  @override
  String get attacker4BDescription =>
      "This card deals four times more damage to its enemies than a normal card but is very weak against attacks from its enemies!";
  @override
  String get attacker4CDescription =>
      "This card deals four times more damage to its enemies than a normal card but does not excel in other areas!";
  @override
  String get defender2ADescription =>
      "This card has resistance twice as high as normal but is not very good at attacking its enemies!";
  @override
  String get defender2BDescription =>
      "This card has resistance twice as high as normal but is not very good at supporting its allies!";
  @override
  String get defender2CDescription =>
      "This card has resistance twice as high as normal but is twice as slow as a normal card!";
  @override
  String get defender4ADescription =>
      "This card has resistance four times as high as normal but is not very good at attacking its enemies!";
  @override
  String get defender4BDescription =>
      "This card has resistance four times as high as normal but is not very good at supporting its allies!";
  @override
  String get defender4CDescription =>
      "This card has resistance four times as high as normal but does not excel in other areas!";
  @override
  String get healer2ADescription =>
      "This card heals its allies twice as fast as a normal card but is not very good at attacking its enemies!";
  @override
  String get healer2BDescription =>
      "This card heals its allies twice as fast as a normal card but is weak against attacks from its enemies!";
  @override
  String get healer2CDescription =>
      "This card heals its allies twice as fast as a normal card but is twice as slow as a normal card!";
  @override
  String get healer4ADescription =>
      "This card heals its allies four times as fast as a normal card but is not very good at attacking its enemies!";
  @override
  String get healer4BDescription =>
      "This card heals its allies four times as fast as a normal card but is very weak against attacks from its enemies!";
  @override
  String get healer4CDescription =>
      "This card heals its allies four times as fast as a normal card but does not excel in other areas!";
  @override
  String get specialExpansionDescription =>
      "This card increases the attack options of the target card by one, whether the target is an ally or not!";
  @override
  String get specialCompressionDescription =>
      "This card decreases the attack options of the target card by one, whether the target is an ally or not!";
  @override
  String get specialDecelerationDescription =>
      "This card slows down its targets by halving their speed. It doesn't matter whether the target is an ally or an enemy!";
  @override
  String get specialAccelerationDescription =>
      "This card speeds up its targets by doubling their speed. It doesn't matter whether the target is an ally or an enemy!";
  @override
  String get specialAttackIncreaseDescription =>
      "This card enhances its targets by doubling their attack. It doesn't matter whether the target is an ally or an enemy!";
  @override
  String get specialAttackDecreaseDescription =>
      "This card weakens its targets by halving their attack. It doesn't matter whether the target is an ally or an enemy!";
  @override
  String get specialResistanceIncreaseDescription =>
      "This card enhances its targets by doubling their resistance. It doesn't matter whether the target is an ally or an enemy!";
  @override
  String get specialResistanceDecreaseDescription =>
      "This card weakens its targets by halving their resistance. It doesn't matter whether the target is an ally or an enemy!";
  @override
  String get specialSupportIncreaseDescription =>
      "This card enhances its targets by doubling their support. It doesn't matter whether the target is an ally or an enemy!";
  @override
  String get specialSupportDecreaseDescription =>
      "This card weakens its targets by halving their support. It doesn't matter whether the target is an ally or an enemy!";
  @override
  String get specialCloningDescription =>
      "This limited-lifetime card allows cloning all the properties and abilities of a target card on the game field!";
  @override
  String get specialCancellationDescription =>
      "This card cancels the special effect of its targets, whether the target is an ally or not. But it cannot be canceled itself!";
  @override
  String get specialRefrigerationDescription =>
      "This card prevents its targets from being altered by their owner, whether the target is an ally or not!";
  @override
  String get specialAspiratorDescription =>
      "This card eliminates all cards located at a one-square distance from it after a delay proportional to its current level!";
  @override
  String get specialSubstractionDescription =>
      "This card eliminates all cards located on its row and column after a delay proportional to its current level!";
  @override
  String get specialDivisionDescription =>
      "This card eliminates all cards located on its diagonals after a delay proportional to its current level!";
  @override
  String get specialDeflagrationDescription =>
      "This card eliminates all cards on its row, column, and diagonals after a delay proportional to its current level!";
  @override
  String get specialParalysisDescription =>
      "This limited-lifetime card prevents its targets from attacking or defending, whether the target is an ally or not!";
  @override
  String get specialInvulnerabilityDescription =>
      "This limited-lifetime card makes its targets invincible for a duration proportional to its level!";
  @override
  String get specialVortexDescription =>
      "This limited-lifetime card allows moving a target card on the game field by swapping its position with it!";

  /* GAME */

  @override
  String get gameAbandonmentButtonDescription =>
      "Your opponent will be automatically declared the winner! Do you really want to abandon this game?";
  @override
  String get gameAbandonmentButtonAbandon => "Abandon";
  @override
  String get gameAbandonmentButtonTitle => "Abandon";

  @override
  String get gameBottomButtonDisplayResult => "Display Result";

  @override
  String get gameCardsSummaryPlay => "Play";
  @override
  String get gameCardsSummaryRemember => "Remember well!";

  @override
  String get gameInitialTutorialPopupPlay => "Play";

  @override
  String get gamePassButtonPopupPass => "Pass";
  @override
  String get gamePassButtonPopupDescription =>
      "Before continuing, make sure you are familiar with the game rules. Do you really want to skip the tutorial?";
  @override
  String get gamePassButtonPopupTitle => "Skip Tutorial";

  @override
  String get adventureVictoryPossibleToPlayNextLevelDescription =>
      "Congratulations on your victory! You have successfully passed this level. You can proceed to the next level!";
  @override
  String get adventureVictoryImpossibleToPlayNextLevelDescription =>
      "You don't have enough cowries to play the next level! Watch an ad to get 1 cowrie!";
  @override
  String get adventureVictoryGameFinishedDescription =>
      "You have completed the 'Solitaire' mode!\nPlayers from around the world are waiting for you in the world of online games!";
  @override
  String get adventureDefeatPossibleToPlayAgainDescription =>
      "Sorry for your defeat! Don't get discouraged: you can always improve by playing again!";
  @override
  String get adventureDefeatImpossibleToPlayAgainDescription =>
      "Unfortunately, you don't have enough cowries to play again! Watch an ad to get 1 cowrie!";
  @override
  String get adventureDefeatPossibleToPlayNextLevelDescription =>
      "Sorry for your defeat! Anyway, you have already passed this level and can proceed to the next level!";
  @override
  String get adventureDefeatImpossibleToPlayNextLevelDescription =>
      "You don't have enough cowries to play the next level! Watch an ad to get 1 cowrie!";
  @override
  String get adventureGameAlreadyFinishedDescription =>
      "Sorry for your defeat! In any case, you have already completed all the levels of this game mode!";
  @override
  String get remoteDefeatDescription =>
      "Sorry for your defeat! Don't get discouraged: you can always improve by playing more games!";
  @override
  String get remoteVictoryDescription =>
      "Congratulations on your victory! You can further improve your level by participating in more online games!";
  @override
  String get remotePossibleToPlayAgainDescription =>
      "Unfortunately, you don't have enough cowries to play again! Watch an ad to get 1 cowrie!";
  @override
  String get remoteOpponentUnavailableDescription =>
      "The other player is no longer available to play a game. But there are still several other options available to you!";
  @override
  String get externalNeedinessDescription =>
      "The other player no longer has enough cowries to play. But you can wait for them or start a new game!";
  @override
  String get internalNeedinessTitle => "Insufficient Cowries!";
  @override
  String get replayImpossibleDescription =>
      "The other player is no longer connected. But you can still start a new game with another player!";
  @override
  String get invitationWithdrawalDescription =>
      "The other player has withdrawn their invitation to replay. But you can still start a new game!";
  @override
  String get invitationRejectionDescription =>
      "Unfortunately, your invitation has been rejected. But you can still start a new game!";
  @override
  String get invitationAcceptationDescription =>
      "You both are ready to replay. Just a little patience! The game will resume in a few moments!";
  @override
  String get externalInvitationReplayImpossibleDescription =>
      "You don't have enough cowries to accept an invitation! Watch an ad to get 1 cowrie!";
  @override
  String get externalInvitationReplayPossibleDescription =>
      "The other player wants to start a new game with you! Do you want to accept or decline their invitation?";
  @override
  String get internalInvitationDescription =>
      "The other player has received a notification about your invitation to replay. They can accept or decline it!";
  @override
  String get gamePopupNewGame => "New\nGame";
  @override
  String get gamePopupNextLevel => "Next\nLevel";
  @override
  String get gamePopupReplay => "Replay";
  @override
  String get globalExit => "Exit";
  @override
  String get globalAccept => "Accept";
  @override
  String get globalReject => "Reject";
  @override
  String get globalCancel => "Cancel";
  @override
  String get normalDefeatTitle => "You Lost!";
  @override
  String get defeatByAbandonment => "Defeat by Abandonment!";
  @override
  String get normalVictoryTitle => "You Won!";
  @override
  String get victoryByAbandonment => "Victory by Abandonment!";
  @override
  String get externalNeedinessTitle => "Oops!";
  @override
  String get internalNeedinessDescription =>
      "The other player would like to play again with you, but you don't have enough cowries to play!";
  @override
  String get replayImpossibleTitle => "Replay Impossible!";
  @override
  String get invitationWithdrawalTitle => "Invitation Withdrawn!";
  @override
  String get invitationRejectionTitle => "Invitation Rejected!";
  @override
  String get invitationAcceptationTitle => "Game Loading!";
  @override
  String get externalInvitationTitle => "Do You Want to Replay?";
  @override
  String get internalInvitationTitle => "A Little Patience!";
  @override
  String get gameProfilePosterClose => "Close";
  @override
  String get gameProfilePosterDeck => "Deck";
  @override
  String get gameProfilePosterCards => "Cards";
  @override
  String get gameProfilePosterCrowns => "Crowns";

  @override
  List<String> get names => [
    "Alex",
    "Sonia",
    "Basile",
    "Yoann",
    "Isaac",
    "Roberto",
    "Tanguy",
    "Jessé",
    "Alice",
    "Christian",
    "Fabienne",
    "Mimi",
    "Maurice",
    "Lucie",
    "Josiane",
    "Vianney",
    "Anicette",
    "Adeline",
    "Bénédicte",
    "Rosa",
    "Déborah",
    "Ange",
    "Clémence",
    "Aude",
    "Mireille",
    "Cécile",
    "Laurence",
    "Marius",
    "Nadège",
    "Sylvie",
    "Clarisse",
    "Claude",
    "Clotilde",
    "André",
    "Christine",
    "Léopold",
    "Geneviève",
    "Esther",
    "Flore",
    "Angèle",
    "Jennifer",
    "Hugues",
    "Huguette",
    "Olivier",
    "Judith",
    "Martine",
    "Rachel",
    "Antoine",
    "Alfred",
    "Marthe",
    "Bob",
  ];

  @override
  String gameTileNameLevel(int level) => "Level $level";
  @override
  String get gameTopBarTutorialText => "Tutorial";

  @override
  String get gametutorialCongratulationsPopupPlay => "Play";
  @override
  String get gametutorialCongratulationsPopupTitle => "Congratulations!";
  @override
  String get gameTutorialCongratulationsPopupUnclearDescription =>
      "You have completed this lesson successfully! But you can always restart if there are still areas of darkness!";

  @override
  String get gameTutorialPopupTitle => "Help";

  @override
  String get gameTutorialProgressPopupNextLesson => "Next Lesson";
  @override
  String get gameTutorialProgressPopupTitle => "Congratulations!";

  /* USER CUBIT */

  @override
  String get referralNotificationTitle => "+50 Cowries!";

  @override
  String referralNotificationBody(String name) =>
      "Congratulations! You received 50 cowries thanks to $name's registration!";

  /* NOTIFICATION */

  @override
  String get notificationMissBody =>
      "We haven't seen you for several days. Come exercise your brain while having fun!";
  @override
  String get notificationMissTitle => "We Miss You!";
  @override
  String get notificationGiftBody =>
      "Every hour, you receive cowries for free! Come claim your gift!";
  @override
  String get notificationGiftTitle => "Don't Miss Your Gift!";

  /* GLOBAL */

  @override
  String get kingConquestInstruction =>
      "Wait for the king to change color to win the game.";
  @override
  String get invalidDeckTitle => "Invalid Deck!";
  @override
  String get invalidDeckDescription =>
      "Your current deck is invalid. Please fix it or select another one before starting a new game!";

  @override
  String get authenticationPopupAuthenticationErrorDescription =>
      "We couldn't connect to your game account. Please check your internet connection and try again!";
  @override
  String get authenticationPopupAuthenticationErrorTitle =>
      "Authentication Error!";

  @override
  String get globalRetry => "Retry";

  @override
  String get authenticationPopupRequiredAuthentication =>
      "Authentication Required!";
  @override
  String get authenticationPopupLoadingAuthentication => "Authenticating!";

  @override
  String authenticationPopupDescription(String account) =>
      "We will connect you to your $account account to save your progress in the game!";

  @override
  String get globalAppleGameCenter => "Apple Game Center";

  @override
  String get globalGooglePlay => "Google Play Games";

  @override
  String cardOptionButtonPopupDeckN(int index) => "Deck $index";

  @override
  String get cardOptionButtonDescription =>
      "You can have up to 3 decks. Check and select your game deck here.";

  @override
  String get globalValidate => "Validate";

  @override
  String get blockedAccountContactSakiHub => "Contact Saki Hub";

  @override
  String get blockedAccountDescription =>
      "Account blocking is the result of illegal or suspicious activity. If this blocking is an error, please contact us!";
  @override
  String get blockedAccountTitle => "Your Account Has Been Blocked!";

  @override
  String get progressOptionButtonNotAuthenticationDescription =>
      "Cowries enhance your gaming freedom, but you need to be logged in to use them!";

  @override
  String get progressOptionButtonNotAuthenticatedTitle =>
      "You Have No Cowries!";
  @override
  String get progressOptionButtonShowcase =>
      "The cowrie, the in-game currency, is essential for buying cards and playing. Manage your cowries here.";

  @override
  String get globalAd => "AD";

  @override
  String get globalConnect => "Connect";

  /* FAMILIES */

  @override
  String get attackerFamilyName => "Attackers";
  @override
  String get attackerFamilyShortDescription => "Red cards: Strong in attack";
  @override
  String get attackerFamilyLongDescription =>
      "These cards deal the most damage to their enemies. However, they are not excellent in other areas!";

  @override
  String get defenderFamilyName => "Defenders";
  @override
  String get defenderFamilyShortDescription => "Gray cards: Strong in defense";
  @override
  String get defenderFamilyLongDescription =>
      "These cards have the highest defense values. However, they are not excellent in other areas!";

  @override
  String get healerFamilyName => "Healers";
  @override
  String get healerFamilyShortDescription => "Green cards: Strong in healing";
  @override
  String get healerFamilyLongDescription =>
      "These cards heal their allies the best. However, they are not excellent in other areas!";

  @override
  String get lordFamilyName => "Lords";
  @override
  String get lordFamilyShortDescription => "Lords: Must protect at all costs";
  @override
  String get lordFamilyLongDescription =>
      "These are the cards that must be protected at all costs in the game: you lose automatically if the color of your lord changes!";

  @override
  String get normalFamilyName => "Normals";
  @override
  String get normalFamilyShortDescription => "Brown cards: Balanced abilities";
  @override
  String get normalFamilyLongDescription =>
      "The Normals are the most balanced in the game. They are very versatile and provide a real advantage on the field!";

  @override
  String get specialFamilyName => "Specials";
  @override
  String get specialFamilyShortDescription =>
      "Yellow cards: Special effects on others";
  @override
  String get specialFamilyLongDescription =>
      "These cards have effects on other cards. Their effects depend mainly on their nature!";

  /* LESSONS */

  @override
  String get basicsLessonTitle => "Lesson 1/3: Game Basics";
  @override
  String get globalLesson => "Lesson";
  @override
  String get basicsLessonSuffix => "Game Basics";
  @override
  String get basicsLessonWinningMessage =>
      "Congratulations on your victory! Quickly move on to the next lesson to master the role of game cards!";

  @override
  String get normalLessonTitle => "Lesson 2/3: Role of Cards";
  @override
  String get normalLessonSuffix => "Role of Cards";
  @override
  String get specialLessonSuffix => "Special Cards";
  @override
  String get normalLessonDescription =>
      "Red cards are good at attacking, green cards provide support, gray cards offer resistance, and brown cards are balanced!";
  @override
  String get normalLessonWinningMessage =>
      "Congratulations on your victory! Move on to the next lesson to understand the role of yellow cards!";

  @override
  String get specialLessonTitle => "Lesson 3/3: Special Cards";
  @override
  String get specialLessonDescription =>
      "Yellow cards have special effects on others. The effect of a special card depends solely on its nature!";

  /* MESSAGES */

  @override
  String get awesomeMessage => "Awesome";
  @override
  String get congratulationsMessage => "Congratulations";
  @override
  String get excellentMessage => "Excellent";
  @override
  String get goodMessage => "Good";
  @override
  String get greatMessage => "Great";
  @override
  String get magnificentMessage => "Magnificent";
  @override
  String get masterfulMessage => "Masterful";

  /* TUTORIALS INSTRUCTIONS */

  @override
  String get basicsPlaceTileInstruction =>
      "Place one of your cards on the game board to increase your allies.";
  @override
  String get basicsConnectCenterTileInstruction =>
      "Connect to the gray card to make it a kingdom ally.";
  @override
  String get basicsConquerCenterTileInstruction =>
      "Wait for the gray card to change color before you can use it.";
  @override
  String get basicsCutPathInstruction =>
      "Remove the connection between the two cards as indicated.";
  @override
  String get basicsConnectKingInstruction =>
      "Connect to the opponent's king to start attacking it.";
  @override
  String get normalPlaceOrdinaryCitizenInstruction =>
      "Place a citizen. It's a card with balanced abilities.";
  @override
  String get normalConnectOrdinaryCitizenInstruction =>
      "The opponent played a citizen. Attack before it attacks you.";
  @override
  String get normalPlaceHealerInstruction =>
      "Your king is under attack and needs healing. Place a healer on the field.";
  @override
  String get normalConnectHealerInstruction =>
      "Heal your king quickly to prevent it from changing color.";
  @override
  String get normalPlaceAttackerInstruction =>
      "You need to counterattack. Place an attacker on the game board.";
  @override
  String get normalConnectAttackerInstruction =>
      "Attack the card that is attacking you to protect the king.";
  @override
  String get normalConquerAttackerInstruction =>
      "Wait for the left tile to change color before you can use it.";
  @override
  String get normalPlaceDefenderInstruction =>
      "Your citizen is defeated. Place a defender to protect your king.";
  @override
  String get normalConnectDefenderInstruction =>
      "Defend your king by attacking the card threatening your king.";
  @override
  String get normalConnectKingInstruction =>
      "You are under attack. But stay focused on the opponent's king.";
  @override
  String get specialPlaceOrdinaryCitizenInstruction =>
      "Place a citizen. It's a card with balanced abilities.";
  @override
  String get specialPlaceCompressionInstruction =>
      "The opponent has retaliated. Use COMPRESSION to defend yourself.";
  @override
  String get specialConnectCompressionInstruction =>
      "COMPRESSION is used to remove a connection from its targets. Use it.";
  @override
  String get specialPlaceRefrigerationInstruction =>
      "The opponent persists. Use REFRIGERATION to freeze the enemy.";
  @override
  String get specialConnectRefrigerationInstruction =>
      "REFRIGERATION prevents its targets from being altered. Use it.";
  @override
  String get specialConnectOrdinaryCitizen1Instruction =>
      "The frozen card is at your mercy. Attack it to make it an ally.";
  @override
  String get specialPlaceExpansionInstruction =>
      "The opponent persists. Use EXPANSION to defend yourself.";
  @override
  String get specialConnectExpansionInstruction =>
      "EXPANSION increases the connections of its targets. Use it.";
  @override
  String get specialConnectOrdinaryCitizen2Instruction =>
      "Thanks to EXPANSION, you can attack 2 target cards. Go for it.";
  @override
  String get specialConquerOrdinaryCitizenInstruction =>
      "Wait for the right tile to change color before you can use it.";
  @override
  String get specialConnectKingInstruction =>
      "Finish this tutorial with a bang by attacking the opponent's king.";

  /* TUTORIALS DESCRIPTIONS */

  @override
  String get basicsPlaceTileDescription =>
      "To place a card on the game board, drag and drop it from the card to the desired position!";
  @override
  String get basicsConnectCenterTileDescription =>
      "To connect to the gray card, drag and drop from the card you just placed to the gray card!";
  @override
  String get basicsConquerCenterTileDescription =>
      "To change the color of the gray card, you need a connection to it and reduce its points to 0!";
  @override
  String get basicsCutPathDescription =>
      "To remove the connection between the two cards, swipe to draw a segment that cuts the link!";
  @override
  String get basicsConnectKingDescription =>
      "To connect to the opponent's king, drag and drop from the card you just placed to the king!";
  @override
  String get kingConquestDescription =>
      "To change the color of the king's card, you need a connection to it and reduce its points to 0!";
  @override
  String get normalPlaceOrdinaryCitizenDescription =>
      "To place a card on the game board, drag and drop it from the card to the desired position!";
  @override
  String get normalConnectOrdinaryCitizenDescription =>
      "To connect to the target card, drag and drop from the original card to the card you're targeting!";
  @override
  String get normalPlaceHealerDescription =>
      "To place a card on the game board, drag and drop it from the card to the desired position!";
  @override
  String get normalConnectHealerDescription =>
      "To connect to the target card, drag and drop from the original card to the card you're targeting!";
  @override
  String get normalPlaceAttackerDescription =>
      "To place a card on the game board, drag and drop it from the card to the desired position!";
  @override
  String get normalConnectAttackerDescription =>
      "To connect to the target card, drag and drop from the original card to the card you're targeting!";
  @override
  String get normalConquerAttackerDescription =>
      "To change the color of the target card, you need a connection to it and reduce its points to 0!";
  @override
  String get normalPlaceDefenderDescription =>
      "To place a card on the game board, drag and drop it from the card to the desired position!";
  @override
  String get normalConnectDefenderDescription =>
      "To connect to the target card, drag and drop from the original card to the card you're targeting!";
  @override
  String get normalConnectKingDescription =>
      "To connect to the target card, drag and drop from the original card to the card you're targeting!";
  @override
  String get specialPlaceOrdinaryCitizenDescription =>
      "To place a card on the game board, drag and drop it from the card to the desired position!";
  @override
  String get specialPlaceCompressionDescription =>
      "To place a card on the game board, drag and drop it from the card to the desired position!";
  @override
  String get specialConnectCompressionDescription =>
      "To connect to the target card, drag and drop from the original card to the card you're targeting!";
  @override
  String get specialPlaceRefrigerationDescription =>
      "To place a card on the game board, drag and drop it from the card to the desired position!";
  @override
  String get specialConnectRefrigerationDescription =>
      "To connect to the target card, drag and drop from the original card to the card you're targeting!";
  @override
  String get specialConnectOrdinaryCitizen1Description =>
      "To connect to the target card, drag and drop from the original card to the card you're targeting!";
  @override
  String get specialPlaceExpansionDescription =>
      "To place a card on the game board, drag and drop it from the card to the desired position!";
  @override
  String get specialConnectExpansionDescription =>
      "To connect to the target card, drag and drop from the original card to the card you're targeting!";
  @override
  String get specialConnectOrdinaryCitizen2Description =>
      "To connect to the target card, drag and drop from the original card to the card you're targeting!";
  @override
  String get specialConquerOrdinaryCitizenDescription =>
      "To change the color of the target card, you need a connection to it and reduce its points to 0!";
  @override
  String get specialConnectKingDescription =>
      "To connect to the target card, drag and drop from the original card to the card you're targeting!";

  /* SKILLS */

  @override
  String get attackSkillNull => "Null";
  @override
  String get attackSkillVeryBad => "Very Bad";
  @override
  String get attackSkillBad => "Bad";
  @override
  String get attackSkillNormal => "Normal";
  @override
  String get attackSkillGood => "Good";
  @override
  String get attackSkillVeryGood => "Very Good";

  @override
  String get supportSkillNull => "Null";
  @override
  String get supportSkillVeryBad => "Very Bad";
  @override
  String get supportSkillBad => "Bad";
  @override
  String get supportSkillNormal => "Normal";
  @override
  String get supportSkillGood => "Good";
  @override
  String get supportSkillVeryGood => "Very Good";

  @override
  String get resistanceSkillNull => "Null";
  @override
  String get resistanceSkillVeryBad => "Very Bad";
  @override
  String get resistanceSkillBad => "Bad";
  @override
  String get resistanceSkillNormal => "Normal";
  @override
  String get resistanceSkillGood => "Good";
  @override
  String get resistanceSkillVeryGood => "Very Good";

  @override
  String get lifeSkillNull => "Null";
  @override
  String get lifeSkillHalf => "Half";
  @override
  String get lifeSkillNormal => "Normal";

  @override
  String get speedSkillNull => "Null";
  @override
  String get speedSkillHalf => "Half";
  @override
  String get speedSkillNormal => "Normal";

  @override
  String remoteComplexCloseDescription(int cowries) =>
      "Closing this part will cost you exactly $cowries cowries! Do you really want to close the game?";
  @override
  String adventureComplexCloseDescription(int cowries) =>
      "Closing this part will cost you exactly $cowries cowries! Do you really want to close the game?";
  @override
  String get adventureSimpleCloseDescription =>
      "Closing the current game will result in the loss of your progress! Do you really want to close the current game?";
  @override
  String get remoteSimpleCloseDescription =>
      "Closing this part will result in the loss of its current progress! Do you really want to close this part?";
  @override
  String get closeClose => "Close";
  @override
  String get closeTitle => "Close";

  @override
  String get watchAdButtonRefreshAd => "Refresh Ad";
  @override
  String get cardOptionButtonPopupSelectDeck => "Select this deck";

  @override
  String get lessonChangeTitle => "Lesson Change";
  @override
  String get lessonChangeDescription =>
      "Please master the teachings of this lesson before moving on to another! Do you really want to change the lesson?";
  @override
  String get lessonChangeAction => "Change";
  @override
  String get restoreDefaultLanguage => "Restore Default Language";

  //

  @override
  String get loadingDescription =>
      "We are loading the game data. Please wait a moment!";
  @override
  String get homeUpdateSimpleDescription =>
      "A new version of the game is available. Install it quickly to enjoy the latest features!";
  @override
  String get gametutorialCongratulationsPopupDescription =>
      "You can now enter the game universe and explore all its intricacies!";
  @override
  String gameScoresIndicatorNormalGameDescription(int level) =>
      "I am the artificial intelligence of level $level of the game! I will do my best to provide you with a great game!";
  @override
  String get gameScoresIndicatorTutorialGameDescription =>
      "I am the artificial intelligence of the game tutorial. Just follow the instructions to win!";

  @override
  String get homeCowriesStoreTransactionErrorTitle => "Transaction canceled!";
  @override
  String get homeCowriesStoreTransactionErrorDescription =>
      "We could not validate your purchase. Please check your payment method and internet connection!";

  @override
  String get drawTitle => "Draw!";
  @override
  String get adventureDrawGameFinishedDescription =>
      "You finished in a draw! Either way, you've already completed all the levels of this game mode!";
  @override
  String get adventureDrawPossibleToPlayNextLevelDescription =>
      "You finished in a draw! Either way, you've already passed this level and can proceed to the next one!";
  @override
  String get adventureDrawPossibleToPlayAgainDescription =>
      "You finished in a draw! You can still win by playing another game against the AI!";
  @override
  String get remoteDrawDescription =>
      "You neither won nor lost! Why not start another game with the other player to break the tie?";
  @override
  String get newPlayer => "New Player";

  @override
  String get premiumButtonRemoveAds => "Remove Ads";
}
