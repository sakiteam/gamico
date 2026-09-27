import 'package:gamico/languages/languages.dart';

abstract class GamicoLanguageFr extends GamicoLanguages {
  @override
  String get globalMax => "MAX";
  @override
  String get globalRefresh => "Actualiser";
  @override
  String get globalClose => "Fermer";
  @override
  String get globalOK => "OK";

  /* FRIEND */

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
  String get friendPageInvitationSent => "Invitation envoyée !";

  @override
  String get friendPageFailedToSendInvitation =>
      "Échec de l'envoi de l'invitation";

  @override
  String get friendPageUnknown => "Inconnu";
  @override
  String get notificationInvitationBody =>
      "Vous avez reçu une invitation à jouer !";
  @override
  String notificationInvitationFrom(String name) =>
      "$name vous invite à jouer !";

  /* ADVENTURE */

  @override
  String get adventureHelpTitle => "Aide";
  @override
  String get adventureHelpDescription =>
      "Vous pouvez sélectionner un niveau en cliquant dessus. Mais si vous ne savez pas encore bien jouer, suivez le tutoriel !";
  @override
  String get adventureClose => "Fermer";
  @override
  String get adventureFollow => "Suivre";

  @override
  String adventureChapterChapter(int chapter) => "Chapitre $chapter";

  /* COLLECTION */

  @override
  String collectionCardPopupFamily(String family) => "Famille : $family";
  @override
  String get collectionCardPopupUpgrade => "Améliorer";
  @override
  String get collectionCardPopupRemove => "Retirer";
  @override
  String get collectionCardPopupUse => "Utiliser";
  @override
  String get collectionCardPopupAcquire => "Acquérir";

  @override
  String get collectionCardSkillsAttack => "Attaque";
  @override
  String get collectionCardSkillsSupport => "Soutien";
  @override
  String get collectionCardSkillsResistance => "Résistance";
  @override
  String get collectionCardSkillsTheoreticalLife => "Vie théorique";
  @override
  String get collectionCardSkillsTheoreticalSpeed => "Vitesse théorique";
  @override
  String get collectionCardSkillsPower => "Puissance";
  @override
  String get collectionCardSkillsConcreteLife => "Vie concrète";
  @override
  String get collectionCardSkillsConcreteSpeed => "Vitesse concrète";
  @override
  String get collectionCardSkillsConnections => "Connections";

  @override
  String collectionCardSquareLevel(int level) => "Niveau $level";

  @override
  String get collectionCardBlocked => "Bloquée";
  @override
  String collectionCardLevel(int level) => "Niveau $level";

  @override
  String get collectionContentDeck => "Decks";
  @override
  String get collectionContentUnlockedCards => "Cartes débloquées";
  @override
  String get collectionContentRemainingCards => "Cartes à débloquer";

  /* HOME */

  @override
  String get homeLanguagesTitle => "Langues";

  @override
  String get homeMultiplayerButtonShowcase =>
      "Ce bouton permet de faire des parties avec d'autres joueurs en ligne.";
  @override
  String get homeSingleplayerButtonShowcase =>
      "Ce bouton permet de faire des parties avec l'intelligence artificielle du jeu.";
  @override
  String get homeNotificationsTitle => "Notifications";
  @override
  String get homeNotificationsDescription =>
      "Pour améliorer votre expérience de jeu, vous devez autoriser les notifications ! Voulez-vous autoriser les notifications ?";
  @override
  String get homeNotificationsAllow => "Autoriser";
  @override
  String get homeNotificationsReminderTitle => "Activer les notifications";
  @override
  String get homeNotificationsReminderDescription =>
      "Les notifications sont importantes pour une meilleure expérience de jeu. Voulez-vous les activer maintenant ?";
  @override
  String get homeUpdateTitle => "Mise à jour disponible !";
  @override
  String get homeUpdateForceDescription =>
      "Plusieurs erreurs et problèmes ont été résolus dans la nouvelle version. Installez-la vite afin de profiter de ces correctifs !";
  @override
  String get homeUpdateInstall => "Installer";

  @override
  String get homeAbout => "À propos";
  @override
  String homeAboutPopupShareText(String link) =>
      "J'ai découvert un jeu de stratégie très intéressant ! Téléchargez-le gratuitement sur $link !";
  @override
  String get homeAboutPopupImplementation => "Réalisation";
  @override
  String get homeAboutPopupMusic => "Musique";
  @override
  String get homeAboutPopupVersion => "Version";
  @override
  String get homeAboutPopupRateGame => "Noter\nle jeu";
  @override
  String get homeAboutPopupVisitWebstie => "Visiter\nSaki Hub";
  @override
  String get homeAboutPopupDiscoverApps => "Voir mes\napplis";

  @override
  String get homeCardPresentationShowcase =>
      "Utilisez ce menu pour acheter de nouvelles cartes et améliorer celles que vous avez déjà.";
  @override
  String get homeCardPresentationShow => "Voir toutes les cartes";

  @override
  String get homeGratificationPopupConnectionErrorTitle =>
      "Erreur de connexion !";
  @override
  String get homeGratificationPopupConnectionErrorDescription =>
      "Veuillez vérifier votre connexion internet. Cette section s'actualisera toute seule lorsque vous serez connecté !";
  @override
  String get homeGratificationPopupLoadingTitle =>
      "Chargement des récompenses !";
  @override
  String get homeGratificationPopupLoadingDescription =>
      "Les récompenses seront disponibles dans quelques secondes seulement. Veuillez patienter s'il vous plaît !";
  @override
  String get homeGratificationPopupIncorrectTimestampTitle =>
      "Horodatage incorrect !";

  @override
  String get homeMultiplayerButtonConnectionErrorTitle =>
      "Problème de connexion !";
  @override
  String get homeMultiplayerButtonConnectionErrorDescription =>
      "Vous ne semblez pas connecté à internet. S'il vous plaît, veuillez vérifier la qualité de votre connexion internet puis réessayez !";
  @override
  String get homeMultiplayerButtonText => "Multi";

  @override
  String get homeProfilePopupBestTacticians => "Meilleurs tacticiens";
  @override
  String get homeProfilePopupBestCollectors => "Meilleurs collecteurs";
  @override
  String get homeProfilePopupCheckAchievements => "Voir mes réalisations";

  @override
  String get homeSingleplayerButtonText => "Solo";

  @override
  String get homeSpecialOfferPopupOfferDisabledDescription =>
      "Les offres spéciales s'activent tous les 3 jours et ne sont valables que pendant 24h. Ne ratez pas la prochaine !";
  @override
  String get homeSpecialOfferPopupOfferLoadedDescription =>
      "Les offres spéciales s'activent tous les 3 jours et ne sont valables que pendant 24h. Alors, qu'attendez-vous ?";
  @override
  String get homeSpecialOfferPopupOfferLoadingDescription =>
      "Les données relatives à l'offre spéciale seront bientôt disponibles. S'il vous plaît, veuillez patienter un tout petit peu !";
  @override
  String get homeSpecialOfferPopupErrorDescription =>
      "Nous n'avons pas pu valider votre achat. Veuillez vérifier votre moyen de paiement ainsi que votre connexion internet !";
  @override
  String homeSpecialOfferPopupOffsetLoadedTitle(String? packTitle) =>
      "$packTitle !";
  @override
  String get homeSpecialOfferPopupOfferLoadingTitle =>
      "Chargement de l'offre !";
  @override
  String get homeSpecialOfferPopupErrorTitle => "Transaction annulée !";
  @override
  String get homeSpecialOfferPopupClose => "Fermer";
  @override
  String get homeSpecialOfferPopupTimestampTitle => "Horodatage incorrect !";
  @override
  String get homeSpecialOfferPopupLoadingDescription =>
      "Les données relatives à l'offre spéciale seront bientôt disponibles. S'il vous plaît, veuillez patienter un tout petit peu !";
  @override
  String get homeSpecialOfferPopupLoadingTitle => "Chargement de l'offre !";
  @override
  String get homeSpecialOfferPopupProblemClose => "Fermer";
  @override
  String get homeSpecialOfferPopupProblemTitle => "Erreur de connexion !";

  @override
  String get premiumPopupTitle => "Passez premium !";
  @override
  String get premiumPopupDescription =>
      "Débloquez la version complète pour supprimer les publicités et jouer sans interruption !";
  @override
  String get premiumPlayer => "Joueur premium";
  @override
  String get nonPremiumPlayer => "Joueur non premium";

  @override
  String get homeHelpBasicsA =>
      "Le royaume des bleus affronte le royaume des oranges.";
  @override
  String get homeHelpBasicsB =>
      "On peut gagner en modifiant la couleur du seigneur adverse.";
  @override
  String get homeHelpBasicsC =>
      "On peut gagner en ayant le plus de points de vie dans le temps imparti.";

  @override
  String get homeHelpConnections1A =>
      "Vous pouvez toucher puis glisser pour connecter deux cartes.";
  @override
  String get homeHelpConnections1B =>
      "Vous pouvez toucher puis toucher pour connecter deux cartes.";
  @override
  String get homeHelpConnections1C =>
      "Vous pouvez couper une connexion d'un mouvement de doigt.";

  @override
  String get homeHelpConnections2A =>
      "Une connexion peut parfois entraver la possibilité de jouer.";
  @override
  String get homeHelpConnections2B =>
      "Il n'est pas possible de sauter une carte pour se connecter à une autre.";
  @override
  String get homeHelpConnections2C =>
      "Une carte au MAX renvoit toutes les boules qu'elle reçoit.";

  @override
  String get homeHelpCards1A => "Les cartes rouges sont douées pour attaquer.";
  @override
  String get homeHelpCards1B => "Les cartes grises sont douées pour résister.";
  @override
  String get homeHelpCards1C => "Les cartes vertes sont douées pour soutenir.";

  @override
  String get homeHelpCards2A =>
      "Les cartes marronnes ont des aptitudes équilibrées.";
  @override
  String get homeHelpCards2B =>
      "Les cartes jaunes ont des effets spéciaux sur les autres cartes.";
  @override
  String get homeHelpCards2C =>
      "Les cartes blanches sont les cartes à protéger absolument.";

  @override
  String get homeHelpRestrictionsA =>
      "Toute connexion doit être utile. Ici, elle est inutile et donc impossible.";
  @override
  String get homeHelpRestrictionsB =>
      "Une carte de destruction ne peut pas attaquer un seigneur.";
  @override
  String get homeHelpRestrictionsC =>
      "Il n'est pas possible de cloner ou de déplacer un seigneur.";

  /* LOADING */

  @override
  String get loadingTitle => "Veuillez patienter !";

  /* REMOTE */

  @override
  String get remoteConnexionProblemTitle => "Problème de connexion !";
  @override
  String get remoteConnexionProblemDescription =>
      "Désolé ! Votre connexion internet a été désactivée. Vous avez été déclaré perdant de la partie !";
  @override
  String get remoteInvitationTitle => "Venez jouer !";
  @override
  String get remoteInvitationDescription =>
      "Votre partie en ligne a commencé !";
  @override
  String get remoteMultiplayer => "Multijoueur";

  @override
  String get remoteFailurePosterTitle => "Une erreur est survenue !";
  @override
  String get remoteFailurePosterDescription =>
      "Une erreur est survenue lors de la recherche. Vérifiez votre connexion internet puis réessayez !";

  @override
  String get remoteNewGamePosterTitle => "Une nouvelle partie ?";
  @override
  String get remoteNewGamePosterDescription =>
      "Vous pouvez encore jouer avec les joueurs du monde entier afin d'améliorer votre niveau !";

  @override
  String get remoteSearchPosterTitle => "Recherche de joueurs";
  @override
  String get remoteSearchPosterDescription =>
      "Nous recherchons dans le monde entier des joueurs disponibles pour faire une petite partie avec vous !";

  @override
  String get homeTranslationPopupDescription =>
      "Cette section permet de choisir la langue principale du jeu. Cliquez sur une langue pour l'activer automatiquement !";

  /* CARDS TITLES */

  @override
  String get lordLazyKingName => "Roi mollasson";
  @override
  String get lordLazyQueenName => "Reine fragile";
  @override
  String get lordLazyPrinceName => "Prince solitaire";
  @override
  String get lordLazyPrincessName => "Princesse introvertie";
  @override
  String get lordCourageousKingName => "Roi pragmatique";
  @override
  String get lordCourageousQueenName => "Reine redoutable";
  @override
  String get lordCourageousPrinceName => "Prince robuste";
  @override
  String get lordCourageousPrincessName => "Princesse dévouée";
  @override
  String get normalOrdinaryCitizenName => "Citoyen lambda";
  @override
  String get normalAttackerDefenderName => "Garde militaire";
  @override
  String get normalAttackerHealerName => "Infirmier militaire";
  @override
  String get normalDefenderHealerName => "Garde infirmier";
  @override
  String get attacker2AName => "Grippe";
  @override
  String get attacker2BName => "Soleil";
  @override
  String get attacker2CName => "Étincelle";
  @override
  String get attacker4AName => "Tourbillon";
  @override
  String get attacker4BName => "Magnan";
  @override
  String get attacker4CName => "Cyclone";
  @override
  String get defender2AName => "Rocher";
  @override
  String get defender2BName => "Caillou";
  @override
  String get defender2CName => "Rempart";
  @override
  String get defender4AName => "Rayon";
  @override
  String get defender4BName => "Balcon";
  @override
  String get defender4CName => "Fenêtre";
  @override
  String get healer2AName => "Herbe";
  @override
  String get healer2BName => "Fleur";
  @override
  String get healer2CName => "Feuille";
  @override
  String get healer4AName => "Arbustre";
  @override
  String get healer4BName => "Sparadrap";
  @override
  String get healer4CName => "Arbre";
  @override
  String get specialExpansionName => "Expansion";
  @override
  String get specialCompressionName => "Compression";
  @override
  String get specialDecelerationName => "Décélération";
  @override
  String get specialAccelerationName => "Accélération";
  @override
  String get specialAttackIncreaseName => "Vaillance";
  @override
  String get specialAttackDecreaseName => "Lâcheté";
  @override
  String get specialResistanceIncreaseName => "Renforcement";
  @override
  String get specialResistanceDecreaseName => "Affaiblissement";
  @override
  String get specialSupportIncreaseName => "Altruisme";
  @override
  String get specialSupportDecreaseName => "Individualisme";
  @override
  String get specialCloningName => "Clonage";
  @override
  String get specialCancellationName => "Annulation";
  @override
  String get specialRefrigerationName => "Réfrigération";
  @override
  String get specialAspiratorName => "Abysse";
  @override
  String get specialSubstractionName => "Soustraction";
  @override
  String get specialDivisionName => "Division";
  @override
  String get specialDeflagrationName => "Déflagration";
  @override
  String get specialParalysisName => "Paralysie";
  @override
  String get specialInvulnerabilityName => "Invulnérabilité";
  @override
  String get specialVortexName => "Vortex";

  /* CARDS DESCRIPTIONS */

  @override
  String get lordLazyKingDescription =>
      "C'est le seul seigneur qui ne peut ni attaquer ni défendre. Mais c'est un roi équilibré qui ne possède aucun point faible particulier !";
  @override
  String get lordLazyQueenDescription =>
      "C'est une dame très douée pour attaquer et soutenir ses sujets malgré son âge avancé. Cependant, sa résistance laisse à désirer !";
  @override
  String get lordLazyPrinceDescription =>
      "C'est un jeune homme très doué pour attaquer et résister aux attaques. Cependant, il ne sait pas soutenir ses sujets !";
  @override
  String get lordLazyPrincessDescription =>
      "C'est une jeune femme très douée pour résister aux attaques et soutenir ses sujets. Cependant, elle n'est pas forte en attaque !";
  @override
  String get lordCourageousKingDescription =>
      "C'est un roi équilibré qui ne possède aucun point faible particulier. Il a cependant 2 fois moins de points de vie que la normale !";
  @override
  String get lordCourageousQueenDescription =>
      "C'est une dame extrêmement douée pour attaquer malgré son âge avancé. Mais elle n'excelle pas dans les autres domaines !";
  @override
  String get lordCourageousPrinceDescription =>
      "C'est un jeune homme extrêmement doué pour résister aux attaques. Mais ce prince n'excelle pas dans les autres domaines !";
  @override
  String get lordCourageousPrincessDescription =>
      "C'est une jeune femme extrêmement douée pour soutenir ses sujets. Mais cette princesse n'excelle pas dans les autres domaines !";
  @override
  String get normalOrdinaryCitizenDescription =>
      "Cette carte est la plus équilibrée du jeu. Elle n'a ni point fort ni point faible particulier mais reste un allié digne de confiance !";
  @override
  String get normalAttackerDefenderDescription =>
      "Comme son nom l'indique, c'est un jeune homme doué pour attaquer ses ennemis tout en résistant à leurs attaques !";
  @override
  String get normalAttackerHealerDescription =>
      "Comme son nom l'indique, c'est un jeune homme doué pour attaquer ses ennemis tout en soutenant ses alliés !";
  @override
  String get normalDefenderHealerDescription =>
      "Comme son nom l'indique, c'est un jeune homme doué pour soutenir ses alliés tout en résistant aux attaques de ses ennemis !";
  @override
  String get attacker2ADescription =>
      "Cette carte inflige à ses ennemis 2 fois plus de dégâts qu'une carte normale mais n'est pas très douée pour soutenir ses alliés !";
  @override
  String get attacker2BDescription =>
      "Cette carte inflige à ses ennemis 2 fois plus de dégâts qu'une carte normale mais résiste mal aux attaques de ses ennemis !";
  @override
  String get attacker2CDescription =>
      "Cette carte inflige à ses ennemis 2 fois plus de dégâts qu'une carte normale mais est 2 fois plus lente qu'une carte normale !";
  @override
  String get attacker4ADescription =>
      "Cette carte inflige à ses ennemis 4 fois plus de dégâts qu'une carte normale mais n'est vraiment pas douée pour soutenir ses alliés !";
  @override
  String get attacker4BDescription =>
      "Cette carte inflige à ses ennemis 4 fois plus de dégâts qu'une carte normale mais résiste vraiment peu aux attaques de ses ennemis !";
  @override
  String get attacker4CDescription =>
      "Cette carte inflige à ses ennemis 4 fois plus de dégâts qu'une carte normale mais n'excelle pas dans les autres domaines !";
  @override
  String get defender2ADescription =>
      "Cette carte possède une résistance 2 fois plus élevée que la normale mais n'est pas très douée pour attaquer ses ennemis !";
  @override
  String get defender2BDescription =>
      "Cette carte possède une résistance 2 fois plus élevée que la normale mais n'est pas très douée pour soutenir ses alliés !";
  @override
  String get defender2CDescription =>
      "Cette carte possède une résistance 2 fois plus élevée que la normale mais est 2 fois plus lente qu'une carte normale !";
  @override
  String get defender4ADescription =>
      "Cette carte possède une résistance 4 fois plus élevée que la normale mais n'est vraiment pas douée pour attaquer ses ennemis !";
  @override
  String get defender4BDescription =>
      "Cette carte possède une résistance 4 fois plus élevée que la normale mais n'est vraiment pas douée pour soutenir ses alliés !";
  @override
  String get defender4CDescription =>
      "Cette carte possède une résistance 4 fois plus élevée que la normale mais n'excelle pas dans les autres domaines !";
  @override
  String get healer2ADescription =>
      "Cette carte soigne ses alliés 2 fois plus vite qu'une carte normale mais n'est pas très douée pour attaquer ses ennemis !";
  @override
  String get healer2BDescription =>
      "Cette carte soigne ses alliés 2 fois plus vite qu'une carte normale mais résiste mal aux attaques de ses ennemis !";
  @override
  String get healer2CDescription =>
      "Cette carte soigne ses alliés 2 fois plus vite qu'une carte normale mais est 2 fois plus lente qu'une carte normale !";
  @override
  String get healer4ADescription =>
      "Cette carte soigne ses alliés 4 fois plus vite qu'une carte normale mais n'est vraiment pas douée pour attaquer ses ennemis !";
  @override
  String get healer4BDescription =>
      "Cette carte soigne ses alliés 4 fois plus vite qu'une carte normale mais résiste vraiment peu aux attaques de ses ennemis !";
  @override
  String get healer4CDescription =>
      "Cette carte soigne ses alliés 4 fois plus vite qu'une carte normale mais n'excelle pas dans les autres domaines !";
  @override
  String get specialExpansionDescription =>
      "Cette carte augmente d'un le nombre de possibilités d'attaque de la carte qu'elle cible ; que la cible soit un allié ou pas !";
  @override
  String get specialCompressionDescription =>
      "Cette carte diminue d'un le nombre de possibilités d'attaque de la carte qu'elle cible ; que la cible soit un allié ou pas !";
  @override
  String get specialDecelerationDescription =>
      "Cette carte ralentit ses cibles en divisant par 2 leur vitesse. Il importe peu que la cible soit une carte alliée ou ennemie !";
  @override
  String get specialAccelerationDescription =>
      "Cette carte accélère ses cibles en multipliant par 2 leur vitesse. Il importe peu que la cible soit une carte alliée ou ennemie !";
  @override
  String get specialAttackIncreaseDescription =>
      "Cette carte améliore ses cibles en multipliant par 2 leur attaque. Il importe peu que la cible soit une carte alliée ou ennemie !";
  @override
  String get specialAttackDecreaseDescription =>
      "Cette carte altère ses cibles en divisant par 2 leur attaque. Il importe peu que la cible soit une carte alliée ou ennemie !";
  @override
  String get specialResistanceIncreaseDescription =>
      "Cette carte améliore ses cibles en multipliant par 2 leur résistance. Il importe peu que la cible soit une carte alliée ou ennemie !";
  @override
  String get specialResistanceDecreaseDescription =>
      "Cette carte altère ses cibles en divisant par 2 leur résistance. Il importe peu que la cible soit une carte alliée ou ennemie !";
  @override
  String get specialSupportIncreaseDescription =>
      "Cette carte améliore ses cibles en multipliant par 2 leur soutien. Il importe peu que la cible soit une carte alliée ou ennemie !";
  @override
  String get specialSupportDecreaseDescription =>
      "Cette carte altère ses cibles en divisant par 2 leur soutien. Il importe peu que la cible soit une carte alliée ou ennemie !";
  @override
  String get specialCloningDescription =>
      "Cette carte à durée de vie limitée permet de cloner toutes les propriétés et les capacités d'une carte cible sur le terrain de jeu !";
  @override
  String get specialCancellationDescription =>
      "Cette carte annule l'effet spécial de ses cibles ; que la cible soit un allié ou pas. Mais elle ne peut pas être annulée à son tour !";
  @override
  String get specialRefrigerationDescription =>
      "Cette carte empêche ses cibles d'être modifiées par leur possesseur. Il importe peu que la cible soit une carte alliée ou pas !";
  @override
  String get specialAspiratorDescription =>
      "Cette carte élimine toutes les cartes qui sont situées à une distance d'une case d'elle après un délai proportionnel à son niveau actuel !";
  @override
  String get specialSubstractionDescription =>
      "Cette carte élimine toutes les cartes qui se trouvent sur sa ligne et sa colonne après un délai proportionnel à son niveau actuel !";
  @override
  String get specialDivisionDescription =>
      "Cette carte élimine toutes les cartes qui se trouvent sur ses diagonales après un délai proportionnel à son niveau actuel !";
  @override
  String get specialDeflagrationDescription =>
      "Cette carte élimine toutes les cartes sur sa ligne, sa colonne et ses diagonales après un délai proportionnel à son niveau actuel !";
  @override
  String get specialParalysisDescription =>
      "Cette carte à durée de vie limitée empêche ses cibles d'attaquer ou de se défendre. Il importe peu que la cible soit une carte alliée ou pas !";
  @override
  String get specialInvulnerabilityDescription =>
      "Cette carte à durée de vie limitée permet de rendre invincible ses cibles pendant un délai proportionnel à son niveau !";
  @override
  String get specialVortexDescription =>
      "Cette carte à durée de vie limitée permet de déplacer une carte cible sur le terrain de jeu en échangeant sa place avec elle !";

  /* GAME */

  @override
  String get gameAbandonmentButtonDescription =>
      "Votre adversaire sera automatiquement déclaré vainqueur ! Voulez-vous vraiment abandonner cette partie ?";
  @override
  String get gameAbandonmentButtonAbandon => "Abandonner";
  @override
  String get gameAbandonmentButtonTitle => "Abandon";

  @override
  String get gameBottomButtonDisplayResult => "Afficher le résultat";

  @override
  String get gameCardsSummaryPlay => "Jouer";
  @override
  String get gameCardsSummaryRemember => "Retenez bien !";

  @override
  String get gameInitialTutorialPopupPlay => "Jouer";

  @override
  String get gamePassButtonPopupPass => "Passer";
  @override
  String get gamePassButtonPopupDescription =>
      "Avant de continuer, assurez-vous que vous connaissez bien les règles du jeu. Voulez-vous vraiment passer le tutoriel ?";
  @override
  String get gamePassButtonPopupTitle => "Passer le tutoriel";

  @override
  String get adventureVictoryPossibleToPlayNextLevelDescription =>
      "Félicitations pour votre victoire ! Vous avez passé ce niveau avec succès. Vous pouvez aller au niveau suivant !";
  @override
  String get adventureVictoryGameFinishedDescription =>
      "Vous avez terminé le mode « Solitaire » !\nDes joueurs du monde entier vous attendent dans l'univers des parties en ligne !";
  @override
  String get adventureDefeatPossibleToPlayAgainDescription =>
      "Désolé pour votre défaite ! Ne vous découragez pas : vous pouvez toujours vous améliorer en rejouant !";
  @override
  String get adventureDefeatPossibleToPlayNextLevelDescription =>
      "Désolé pour votre défaite ! De toutes les façons, vous avez déjà passé ce niveau et pouvez aller au niveau suivant !";
  @override
  String get adventureGameAlreadyFinishedDescription =>
      "Désolé pour votre défaite ! Quoiqu'il en soit, vous avez déjà terminé tous les niveaux de ce mode de jeu !";
  @override
  String get remoteDefeatDescription =>
      "Désolé pour votre défaite ! Ne vous découragez pas : vous pouvez toujours vous améliorer en faisant plus de parties !";
  @override
  String get remoteVictoryDescription =>
      "Félicitations pour votre victoire ! Vous pouvez encore améliorer votre niveau en participant à plus de parties !";
  @override
  String get remoteOpponentUnavailableDescription =>
      "L'autre joueur n'est plus disponible pour disputer une partie. Mais plusieurs autres options s'offrent tout de même à vous !";
  @override
  String get replayImpossibleDescription =>
      "L'autre joueur est n'est plus connecté. Mais, vous pouvez toujours faire une nouvelle partie avec un autre joueur !";
  @override
  String get invitationWithdrawalDescription =>
      "L'autre joueur a retiré son invitation à rejouer. Mais vous pouvez toujours faire une nouvelle partie !";
  @override
  String get invitationRejectionDescription =>
      "Votre invitation a malheureusement été rejetée. Mais vous pouvez toujours faire une nouvelle partie !";
  @override
  String get invitationAcceptationDescription =>
      "Vous êtes tous les deux prêts à rejouer. Un peu de patience ! Le jeu reprendra dans quelques instants !";
  @override
  String get externalInvitationReplayPossibleDescription =>
      "L'autre joueur veut refaire une nouvelle partie avec vous ! Voulez-vous accepter ou refuser son invitation ?";
  @override
  String get internalInvitationDescription =>
      "L'autre joueur a reçu une notification indiquant votre invitation à rejouer. Il pourra l'accepter ou la rejeter !";
  @override
  String get gamePopupNewGame => "Nouvelle\npartie";
  @override
  String get gamePopupNextLevel => "Niveau\nsuivant";
  @override
  String get gamePopupReplay => "Rejouer";
  @override
  String get globalExit => "Quitter";
  @override
  String get globalAccept => "Accepter";
  @override
  String get globalReject => "Refuser";
  @override
  String get globalCancel => "Annuler";
  @override
  String get normalDefeatTitle => "Vous avez perdu !";
  @override
  String get defeatByAbandonment => "Défaite par abandon !";
  @override
  String get normalVictoryTitle => "Vous avez gagné !";
  @override
  String get victoryByAbandonment => "Victoire par abandon !";
  @override
  String get externalNeedinessTitle => "Oups !";
  @override
  String get replayImpossibleTitle => "Rejeu impossible !";
  @override
  String get invitationWithdrawalTitle => "Invitation retirée !";
  @override
  String get invitationRejectionTitle => "Invitation rejetée !";
  @override
  String get invitationAcceptationTitle => "Chargement du jeu !";
  @override
  String get externalInvitationTitle => "Voulez-vous rejouer ?";
  @override
  String get internalInvitationTitle => "Un peu de patience !";

  @override
  String get gameProfilePosterClose => "Fermer";
  @override
  String get gameProfilePosterDeck => "Deck";
  @override
  String get gameProfilePosterCards => "Cartes";
  @override
  String get gameProfilePosterCrowns => "Couronnes";

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
  String gameTileNameLevel(int level) => "Niveau $level";
  @override
  String get gameTopBarTutorialText => "Tutoriel";

  @override
  String get gametutorialCongratulationsPopupPlay => "Jouer";
  @override
  String get gametutorialCongratulationsPopupTitle => "Félicitations !";
  @override
  String get gameTutorialCongratulationsPopupUnclearDescription =>
      "Vous avez achevé cette leçon avec succès ! Mais vous pouvez toujours recommencer s'il y a encore des zones d'ombre !";

  @override
  String get gameTutorialPopupTitle => "Aide";

  @override
  String get gameTutorialProgressPopupNextLesson => "Leçon suivante";
  @override
  String get gameTutorialProgressPopupTitle => "Félicitations !";

  /* NOTIFICATION */

  @override
  String get notificationMissBody =>
      "Cela fait déjà plusieurs jours que nous ne vous avons pas vu. Venez faire travailler vos méninges tout en vous amusant !";
  @override
  String get notificationMissTitle => "Vous nous manquez !";
  @override
  String get notificationGiftTitle => "Ne manquez pas votre cadeau !";

  /* GLOBAL */

  @override
  String get kingConquestInstruction =>
      "Attendez que le roi change de couleur pour remporter la partie.";
  @override
  String get invalidDeckTitle => "Deck invalide !";
  @override
  String get invalidDeckDescription =>
      "Votre deck actuel n'est pas valide. Veuillez le corriger ou en sélectionner un autre avant de pouvoir faire une nouvelle partie !";

  @override
  String get authenticationPopupAuthenticationErrorDescription =>
      "Nous n'avons pas pu nous connecter à votre compte de jeu. S'il vous plaît, vérifiez votre connexion internet puis réessayez !";

  @override
  String get authenticationPopupAuthenticationErrorTitle =>
      "Erreur de connexion !";

  @override
  String get globalRetry => "Réessayer";

  @override
  String get authenticationPopupRequiredAuthentication =>
      "Authentification requise !";

  @override
  String get authenticationPopupLoadingAuthentication => "Connexion en cours !";

  @override
  String authenticationPopupDescription(String account) =>
      "Nous allons vous connecter à votre compte $account afin de sauvegarder votre progression dans le jeu !";

  @override
  String get globalAppleGameCenter => "Apple Game Center";

  @override
  String get globalGooglePlay => "Google Play Jeux";

  @override
  String cardOptionButtonPopupDeckN(int index) => "Deck $index";

  @override
  String get cardOptionButtonDescription =>
      "Vous pouvez posséder jusqu'à 3 decks. Consultez et sélectionnez votre deck de jeu ici.";

  @override
  String get globalValidate => "Valider";

  @override
  String get blockedAccountContactSakiHub => "Contacter\nSaki Hub";

  @override
  String get blockedAccountDescription =>
      "Le blocage d'un compte fait suite à une activité illégale ou suspecte. Si ce blocage est une erreur, veuillez nous contacter !";

  @override
  String get blockedAccountTitle => "Votre compte a été bloqué !";

  @override
  String get globalAd => "PUB";

  @override
  String get globalConnect => "Connecter";

  /* FAMILIES */

  @override
  String get attackerFamilyName => "Attaquants";
  @override
  String get attackerFamilyShortDescription =>
      "Cartes rouges : douées pour attaquer";
  @override
  String get attackerFamilyLongDescription =>
      "Ce sont les cartes qui causent le plus de dégâts à leurs ennemis. Mais ils ne sont pas excellents dans les autres domaines !";

  @override
  String get defenderFamilyName => "Défenseurs";
  @override
  String get defenderFamilyShortDescription =>
      "Cartes grises : douées pour résister";
  @override
  String get defenderFamilyLongDescription =>
      "Ce sont les cartes qui ont les résistances les plus élevées. Mais ils ne sont pas excellents dans les autres domaines !";

  @override
  String get healerFamilyName => "Guérisseurs";
  @override
  String get healerFamilyShortDescription =>
      "Cartes vertes : douées pour soigner";
  @override
  String get healerFamilyLongDescription =>
      "Ce sont les cartes qui soignent le mieux leurs alliés. Mais ils ne sont pas excellents dans les autres domaines !";

  @override
  String get lordFamilyName => "Seigneurs";
  @override
  String get lordFamilyShortDescription => "Seigneurs : à protéger à tout prix";
  @override
  String get lordFamilyLongDescription =>
      "Ce sont les cartes à défendre absolument dans le jeu : vous perdez automatiquement si votre seigneur change de couleur !";

  @override
  String get normalFamilyName => "Citoyens";
  @override
  String get normalFamilyShortDescription =>
      "Cartes marronnes : aptitudes équilibrées";
  @override
  String get normalFamilyLongDescription =>
      "Les citoyens sont les plus équilibrés du jeu. Ils sont très polyvalents et constituent un véritable avantage sur le terrain !";

  @override
  String get specialFamilyName => "Spéciales";
  @override
  String get specialFamilyShortDescription =>
      "Cartes jaunes : effets spéciaux sur les autres";
  @override
  String get specialFamilyLongDescription =>
      "Ce sont les cartes qui ont des effets sur les autres cartes. Leurs effets dépendent principalement de leur nature !";

  /* LESSONS */

  @override
  String get basicsLessonTitle => "Leçon 1/3 : Bases du jeu";
  @override
  String get globalLesson => "Leçon";
  @override
  String get basicsLessonSuffix => "Bases du jeu";
  @override
  String get basicsLessonWinningMessage =>
      "Félicitations pour votre victoire ! Passez rapidement à la leçon suivante afin de maîtriser le rôle des cartes du jeu !";

  @override
  String get normalLessonTitle => "Leçon 2/3 : Rôle des cartes";
  @override
  String get normalLessonSuffix => "Rôle des cartes";
  @override
  String get specialLessonSuffix => "Cartes spéciales";
  @override
  String get normalLessonDescription =>
      "Les rouges sont douées en attaque, les vertes en soutien, les grises en résistance et les marronnes sont équilibrées !";
  @override
  String get normalLessonWinningMessage =>
      "Félicitations pour votre victoire ! Passez rapidement à la leçon suivante afin de maîtriser le rôle des cartes jaunes !";

  @override
  String get specialLessonTitle => "Leçon 3/3 : Cartes spéciales";
  @override
  String get specialLessonDescription =>
      "Les cartes jaunes ont des effets spéciaux sur les autres. L'effet d'une carte spéciale dépend uniquement de sa nature !";

  /* MESSAGES */

  @override
  String get awesomeMessage => "Génial";
  @override
  String get congratulationsMessage => "Félicitations";
  @override
  String get excellentMessage => "Excellent";
  @override
  String get goodMessage => "Bien";
  @override
  String get greatMessage => "Super";
  @override
  String get magnificentMessage => "Splendide";
  @override
  String get masterfulMessage => "Magistral";

  /* TUTORIALS INSTRUCTIONS */

  // Basics
  @override
  String get basicsPlaceTileInstruction =>
      "Placez l'une de vos cartes sur le terrain de jeu pour augmenter vos alliés.";
  @override
  String get basicsConnectCenterTileInstruction =>
      "Connectez-vous à la carte grise pour en faire un allié du royaume.";
  @override
  String get basicsConquerCenterTileInstruction =>
      "Attendez que la carte grise change de couleur pour pouvoir l'utiliser.";
  @override
  String get basicsCutPathInstruction =>
      "Supprimez la connexion entre les deux cartes comme indiqué.";
  @override
  String get basicsConnectKingInstruction =>
      "Connectez-vous au roi adverse pour commencer à l'attaquer lui aussi.";

  // Normal
  @override
  String get normalPlaceOrdinaryCitizenInstruction =>
      "Placez un citoyen. C'est une carte aux aptitudes équilibrées.";
  @override
  String get normalConnectOrdinaryCitizenInstruction =>
      "L'adversaire a joué un citoyen. Attaquez avant qu'il vous attaque.";
  @override
  String get normalPlaceHealerInstruction =>
      "Votre roi est attaqué et doit être guéri. Placez un guérisseur sur le terrain.";
  @override
  String get normalConnectHealerInstruction =>
      "Soignez rapidement votre roi afin qu'il ne change pas de couleur.";
  @override
  String get normalPlaceAttackerInstruction =>
      "Il faut contre-attaquer. Placez un attaquant sur le terrain de jeu.";
  @override
  String get normalConnectAttackerInstruction =>
      "Attaquez à votre tour la carte qui vous attaque pour protéger le roi.";
  @override
  String get normalConquerAttackerInstruction =>
      "Attendez que la tuile de gauche change de couleur afin de l'utiliser.";
  @override
  String get normalPlaceDefenderInstruction =>
      "Votre citoyen est vaincu. Placez un défenseur pour protéger votre roi.";
  @override
  String get normalConnectDefenderInstruction =>
      "Défendez votre roi en attaquant la carte qui menace votre roi.";
  @override
  String get normalConnectKingInstruction =>
      "Vous être attaqué. Mais restez concentré sur le roi adverse.";

  // Special
  @override
  String get specialPlaceOrdinaryCitizenInstruction =>
      "Placez un citoyen. C'est une carte aux aptitudes équilibrées.";
  @override
  String get specialPlaceCompressionInstruction =>
      "L'adversaire a riposté. Utilisez COMPRESSION pour vous défendre.";
  @override
  String get specialConnectCompressionInstruction =>
      "COMPRESSION sert à supprimer une connexion de ses cibles. Utilisez-la.";
  @override
  String get specialPlaceRefrigerationInstruction =>
      "L'adversaire insiste. Utilisez RÉFRIGÉRATION afin de géler l'ennemi.";
  @override
  String get specialConnectRefrigerationInstruction =>
      "REFRIGERATION empêche ses cibles d'être modifées. Utilisez-la.";
  @override
  String get specialConnectOrdinaryCitizen1Instruction =>
      "La carte gélée est à votre merci. Attaquez-la pour en faire un allié.";
  @override
  String get specialPlaceExpansionInstruction =>
      "L'adversaire persiste. Utilisez EXPANSION pour vous défendre.";
  @override
  String get specialConnectExpansionInstruction =>
      "EXPANSION augmente les connexions de ses cibles. Utilisez-la.";
  @override
  String get specialConnectOrdinaryCitizen2Instruction =>
      "Grâce à EXPANSION, vous pouvez attaquer 2 cartes cibles. Allez-y.";
  @override
  String get specialConquerOrdinaryCitizenInstruction =>
      "Attendez que la tuile de droite change de couleur afin de l'utiliser.";
  @override
  String get specialConnectKingInstruction =>
      "Terminez ce tutoriel en beauté en attaquant le roi adverse.";

  /* TUTORIALS DESCRIPTIONS */

  // Basics
  @override
  String get basicsPlaceTileDescription =>
      "Pour placer une carte sur le terrain de jeu, faîtes un glisser-déposer depuis la carte à placer vers la position souhaitée !";
  @override
  String get basicsConnectCenterTileDescription =>
      "Pour vous connecter à la carte grise, faîtes un glisser-déposer depuis la carte que vous venez de placer vers la carte grise !";
  @override
  String get basicsConquerCenterTileDescription =>
      "Pour que la couleur de la carte grise change, il faut avoir une connexion vers elle et ramener ses points à 0 !";
  @override
  String get basicsCutPathDescription =>
      "Pour supprimer la connexion entre les deux cartes, faîtes un geste de balayage pour tracer un segment qui coupe la liaison !";
  @override
  String get basicsConnectKingDescription =>
      "Pour vous connecter au roi adverse, faîtes un glisser-déposer depuis la carte que vous venez de placer vers le roi !";
  @override
  String get kingConquestDescription =>
      "Pour que la couleur de la carte du roi change, il faut avoir une connexion vers elle et ramener ses points à 0 !";

  // Normal
  @override
  String get normalPlaceOrdinaryCitizenDescription =>
      "Pour placer une carte sur le terrain de jeu, faîtes un glisser-déposer depuis la carte à placer vers la position souhaitée !";
  @override
  String get normalConnectOrdinaryCitizenDescription =>
      "Pour vous connecter à la carte cible, faîtes un glisser-déposer depuis la carte d'origine vers la carte que vous ciblez !";
  @override
  String get normalPlaceHealerDescription =>
      "Pour placer une carte sur le terrain de jeu, faîtes un glisser-déposer depuis la carte à placer vers la position souhaitée !";
  @override
  String get normalConnectHealerDescription =>
      "Pour vous connecter à la carte cible, faîtes un glisser-déposer depuis la carte d'origine vers la carte que vous ciblez !";
  @override
  String get normalPlaceAttackerDescription =>
      "Pour placer une carte sur le terrain de jeu, faîtes un glisser-déposer depuis la carte à placer vers la position souhaitée !";
  @override
  String get normalConnectAttackerDescription =>
      "Pour vous connecter à la carte cible, faîtes un glisser-déposer depuis la carte d'origine vers la carte que vous ciblez !";
  @override
  String get normalConquerAttackerDescription =>
      "Pour que la couleur de la carte cible change, il faut avoir une connexion vers elle et ramener ses points à 0 !";
  @override
  String get normalPlaceDefenderDescription =>
      "Pour placer une carte sur le terrain de jeu, faîtes un glisser-déposer depuis la carte à placer vers la position souhaitée !";
  @override
  String get normalConnectDefenderDescription =>
      "Pour vous connecter à la carte cible, faîtes un glisser-déposer depuis la carte d'origine vers la carte que vous ciblez !";
  @override
  String get normalConnectKingDescription =>
      "Pour vous connecter à la carte cible, faîtes un glisser-déposer depuis la carte d'origine vers la carte que vous ciblez !";

  // Special
  @override
  String get specialPlaceOrdinaryCitizenDescription =>
      "Pour placer une carte sur le terrain de jeu, faîtes un glisser-déposer depuis la carte à placer vers la position souhaitée !";
  @override
  String get specialPlaceCompressionDescription =>
      "Pour placer une carte sur le terrain de jeu, faîtes un glisser-déposer depuis la carte à placer vers la position souhaitée !";
  @override
  String get specialConnectCompressionDescription =>
      "Pour vous connecter à la carte cible, faîtes un glisser-déposer depuis la carte d'origine vers la carte que vous ciblez !";
  @override
  String get specialPlaceRefrigerationDescription =>
      "Pour placer une carte sur le terrain de jeu, faîtes un glisser-déposer depuis la carte à placer vers la position souhaitée !";
  @override
  String get specialConnectRefrigerationDescription =>
      "Pour vous connecter à la carte cible, faîtes un glisser-déposer depuis la carte d'origine vers la carte que vous ciblez !";
  @override
  String get specialConnectOrdinaryCitizen1Description =>
      "Pour vous connecter à la carte cible, faîtes un glisser-déposer depuis la carte d'origine vers la carte que vous ciblez !";
  @override
  String get specialPlaceExpansionDescription =>
      "Pour placer une carte sur le terrain de jeu, faîtes un glisser-déposer depuis la carte à placer vers la position souhaitée !";
  @override
  String get specialConnectExpansionDescription =>
      "Pour vous connecter à la carte cible, faîtes un glisser-déposer depuis la carte d'origine vers la carte que vous ciblez !";
  @override
  String get specialConnectOrdinaryCitizen2Description =>
      "Pour vous connecter à la carte cible, faîtes un glisser-déposer depuis la carte d'origine vers la carte que vous ciblez !";
  @override
  String get specialConquerOrdinaryCitizenDescription =>
      "Pour que la couleur de la carte cible change, il faut avoir une connexion vers elle et ramener ses points à 0 !";
  @override
  String get specialConnectKingDescription =>
      "Pour vous connecter à la carte cible, faîtes un glisser-déposer depuis la carte d'origine vers la carte que vous ciblez !";

  /* SKILLS */

  @override
  String get attackSkillNull => "Nulle";
  @override
  String get attackSkillVeryBad => "Pitoyable";
  @override
  String get attackSkillBad => "Faible";
  @override
  String get attackSkillNormal => "Normale";
  @override
  String get attackSkillGood => "Elevée";
  @override
  String get attackSkillVeryGood => "Excellente";

  @override
  String get supportSkillNull => "Nul";
  @override
  String get supportSkillVeryBad => "Pitoyable";
  @override
  String get supportSkillBad => "Faible";
  @override
  String get supportSkillNormal => "Normal";
  @override
  String get supportSkillGood => "Elevé";
  @override
  String get supportSkillVeryGood => "Excellent";

  @override
  String get resistanceSkillNull => "Nulle";
  @override
  String get resistanceSkillVeryBad => "Pitoyable";
  @override
  String get resistanceSkillBad => "Faible";
  @override
  String get resistanceSkillNormal => "Normale";
  @override
  String get resistanceSkillGood => "Elevée";
  @override
  String get resistanceSkillVeryGood => "Excellente";

  @override
  String get lifeSkillNull => "Nulle";
  @override
  String get lifeSkillHalf => "Faible";
  @override
  String get lifeSkillNormal => "Normale";

  @override
  String get speedSkillNull => "Nulle";
  @override
  String get speedSkillHalf => "Faible";
  @override
  String get speedSkillNormal => "Normale";

  /* GAME PAGE */

  @override
  String get adventureSimpleCloseDescription =>
      "Votre progression dans la partie actuelle sera définitivement perdue ! Voulez-vous vraiment clôturer la partie actuelle ?";
  @override
  String get remoteSimpleCloseDescription =>
      "La clôture de cette partie vous fera perdre sa progression actuelle ! Voulez-vous vraiment clôturer cette partie ?";
  @override
  String get closeClose => "Clôturer";
  @override
  String get closeTitle => "Clôture";

  @override
  String get watchAdButtonRefreshAd => "Actualiser la pub";
  @override
  String get cardOptionButtonPopupSelectDeck => "Choisir ce deck";

  @override
  String get lessonChangeTitle => "Changement de leçon";
  @override
  String get lessonChangeDescription =>
      "Veuillez maîtriser les enseignements de cette leçon avant de passer à une autre ! Voulez-vous vraiment changer de leçon ?";
  @override
  String get lessonChangeAction => "Changer";
  @override
  String get restoreDefaultLanguage => "Rétablir la langue par défaut";

  //

  @override
  String get loadingDescription =>
      "Nous sommes en train de charger les données du jeu. Attendez juste un tout petit peu !";
  @override
  String get homeUpdateSimpleDescription =>
      "Une nouvelle version du jeu est disponible. Installez-la vite afin de profiter des dernières nouveautés !";
  @override
  String get gametutorialCongratulationsPopupDescription =>
      "Vous pouvez maintenant accéder à l'univers du jeu et aller à la découverte de chacune de ses subtilités !";
  @override
  String gameScoresIndicatorNormalGameDescription(int level) =>
      "Je suis l'intelligence artificielle du niveau $level du jeu ! Je ferai tout mon possible pour vous offrir une belle partie !";
  @override
  String get gameScoresIndicatorTutorialGameDescription =>
      "Je suis l'intelligence artificielle du tutoriel du jeu. Vous n'avez qu'à suivre les instructions pour gagner !";

  @override
  String get homeCowriesStoreTransactionErrorTitle => "Transaction annulée !";
  @override
  String get homeCowriesStoreTransactionErrorDescription =>
      "Nous n'avons pas pu valider votre achat. Veuillez vérifier votre moyen de paiement ainsi que votre connexion internet !";

  ///

  @override
  String get drawTitle => "Partie nulle !";
  @override
  String get adventureDrawGameFinishedDescription =>
      "Vous avez terminé à égalité ! De toutes les façons, vous avez déjà terminé tous les niveaux de ce mode de jeu !";
  @override
  String get adventureDrawPossibleToPlayNextLevelDescription =>
      "Vous avez terminé à égalité ! De toutes les façons, vous avez déjà passé ce niveau et pouvez aller au niveau suivant !";
  @override
  String get adventureDrawPossibleToPlayAgainDescription =>
      "Vous avez terminé à égalité ! Vous pouvez toujours remporter la victoire en faisant une nouvelle partie contre l'IA !";
  @override
  String get remoteDrawDescription =>
      "Vous n'avez ni gagné ni perdu ! Pourquoi ne pas démarrer une autre partie avec l'autre joueur pour vous départager ?";
  @override
  String get newPlayer => "Nouveau joueur";

  @override
  String get premiumButtonRemoveAds => "Supprimer les publicités";

  @override
  String get localNetworkWaitingForHost => "En attente de l'hôte…";

  @override
  String get localNetworkHostLeftDescription =>
      "L'hôte a quitté la partie : la table est terminée. Vous pouvez en démarrer une nouvelle depuis le menu.";

  @override
  String get replayVoteChooseOption => "Choisissez un mode pour la revanche";

  @override
  String replayVoteCountdown(int seconds) =>
      "Départ dans ${seconds}s avec les joueurs prêts";

  @override
  String get replayVoteStartingSoon =>
      "La partie va commencer avec les joueurs ayant accepté";

  @override
  String get replayVoteWaitingForPlayers => "En attente des autres joueurs";

  /* ROLL CALL */

  @override
  String get rollCallWaitingTitle => "En attente des joueurs";

  @override
  String get rollCallReady => "Prêt";

  @override
  String get rollCallConnecting => "Connexion…";

  @override
  String get rollCallYou => "Vous";

  @override
  String rollCallVoteOpensIn(int s) =>
      "Vote pour éjecter les absents dans $s s";

  @override
  String rollCallStartsIn(int s) => "La partie démarre dans $s s";

  @override
  String rollCallEjectVotes(int votes, int needed) =>
      "Éjecter les absents : $votes/$needed";

  @override
  String get rollCallEject => "Éjecter";

  @override
  String get rollCallWait => "Attendre";

  @override
  String get rollCallPlayerUnavailableTitle => "Joueur indisponible";

  @override
  String rollCallPlayerUnavailableDescription(int s) =>
      "Votre adversaire ne s'est pas connecté après $s secondes d'attente. La partie est annulée, sans pénalité.";

  @override
  String get rollCallPlayersUnavailableTitle => "Joueurs indisponibles";

  @override
  String get rollCallPlayersUnavailableDescription =>
      "Aucun autre joueur ne s'est connecté à temps. La partie est annulée, sans pénalité.";

  @override
  String get rollCallCancelledTitle => "Partie annulée";

  @override
  String get rollCallExcludedTitle => "Partie lancée sans vous";

  @override
  String rollCallExcludedDuel(int s) =>
      "Votre adversaire vous a attendu $s secondes sans vous voir arriver : la partie a été annulée. Aucune pénalité ne vous est appliquée.";

  @override
  String get rollCallExcludedVote =>
      "Vous n'étiez pas encore connecté : les autres joueurs ont voté pour commencer la partie sans vous. Aucune pénalité ne vous est appliquée.";

  @override
  String rollCallExcludedCap(int s) =>
      "Vous n'étiez toujours pas connecté après $s secondes d'attente : la partie a commencé sans vous. Aucune pénalité ne vous est appliquée.";

  @override
  String get rollCallExcludedGrace =>
      "Vous ne vous êtes pas connecté à temps : la partie a commencé sans vous. Aucune pénalité ne vous est appliquée.";

  @override
  String get rollCallClose => "Fermer";

  @override
  String get rollCallPlayerLeftDescription =>
      "Votre adversaire a quitté la partie avant qu'elle ne commence. La partie est annulée, sans pénalité.";

  @override
  String get rollCallPlayersLeftDescription =>
      "Les autres joueurs ont quitté la partie avant qu'elle ne commence. La partie est annulée, sans pénalité.";

  @override
  String get rollCallSeatLostTitle => "Reprise impossible";

  @override
  String get rollCallSeatLostDescription =>
      "La partie a continué pendant votre absence : votre place ne peut plus être reprise.";

  @override
  String get rollCallWaitingOpponentTitle => "En attente de votre adversaire";

  @override
  String rollCallCancelsIn(int s) => "Annulation dans $s s";

  @override
  String get rollCallAway => "Prêt · hors de l'app";

  @override
  String get rollCallLeave => "Quitter";
}
