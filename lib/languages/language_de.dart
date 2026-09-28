import 'package:gamico/languages/languages.dart';

abstract class GamicoLanguageDe extends GamicoLanguages {
  @override
  String get globalMax => "MAX";
  @override
  String get globalRefresh => "Aktualisieren";
  @override
  String get globalClose => "Schließen";
  @override
  String get globalOK => "OK";

  /* FRIEND */

  @override
  String get friendPageTitle => "Freunde suchen";

  @override
  String get friendPageSearchHint => "Einen Spieler suchen";

  @override
  String get friendPagePendingInvitations => "Ausstehende Einladungen";

  @override
  String get friendPageGameInvitation => "Spieleinladung";

  @override
  String friendPageInvitationFrom(String name) => "Von: $name";

  @override
  String get friendPageInvitationSent => "Einladung gesendet!";

  @override
  String get friendPageFailedToSendInvitation =>
      "Fehler beim Senden der Einladung";

  @override
  String get friendPageUnknown => "Unbekannt";
  @override
  String get notificationInvitationBody =>
      "Du hast eine Spieleinladung erhalten!";
  @override
  String notificationInvitationFrom(String name) =>
      "$name lädt dich zum Spielen ein!";

  /* ADVENTURE */

  @override
  String get adventureHelpTitle => "Hilfe";
  @override
  String get adventureHelpDescription =>
      "Sie können ein Level auswählen, indem Sie darauf klicken. Wenn Sie jedoch noch nicht gut spielen können, folgen Sie dem Tutorial!";
  @override
  String get adventureClose => "Schließen";
  @override
  String get adventureFollow => "Folgen";

  @override
  String adventureChapterChapter(int chapter) => "Kapitel $chapter";

  /* COLLECTION */

  @override
  String collectionCardPopupFamily(String family) => "Familie: $family";
  @override
  String get collectionCardPopupUpgrade => "Verbessern";
  @override
  String get collectionCardPopupRemove => "Entfernen";
  @override
  String get collectionCardPopupUse => "Verwenden";
  @override
  String get collectionCardPopupAcquire => "Erwerben";

  @override
  String get collectionCardSkillsAttack => "Angriff";
  @override
  String get collectionCardSkillsSupport => "Unterstützung";
  @override
  String get collectionCardSkillsResistance => "Widerstand";
  @override
  String get collectionCardSkillsTheoreticalLife => "Theoretisches Leben";
  @override
  String get collectionCardSkillsTheoreticalSpeed =>
      "Theoretische Geschwindigkeit";
  @override
  String get collectionCardSkillsPower => "Kraft";
  @override
  String get collectionCardSkillsConcreteLife => "Konkretes Leben";
  @override
  String get collectionCardSkillsConcreteSpeed => "Konkrete Geschwindigkeit";
  @override
  String get collectionCardSkillsConnections => "Verbindungen";

  @override
  String collectionCardSquareLevel(int level) => "Stufe $level";

  @override
  String get collectionCardBlocked => "Blockiert";
  @override
  String collectionCardLevel(int level) => "Stufe $level";

  @override
  String get collectionContentDeck => "Decks";
  @override
  String get collectionContentUnlockedCards => "Entsperrte Karten";
  @override
  String get collectionContentRemainingCards => "Übrige Karten";

  /* HOME */

  @override
  String get homeLanguagesTitle => "Sprachen";

  @override
  String get homeMultiplayerButtonShowcase =>
      "Mit dieser Schaltfläche können Sie Spiele mit anderen Online-Spielern spielen.";
  @override
  String get homeSingleplayerButtonShowcase =>
      "Mit dieser Schaltfläche können Sie Spiele gegen die KI des Spiels spielen.";
  @override
  String get homeNotificationsTitle => "Benachrichtigungen";
  @override
  String get homeNotificationsDescription =>
      "Um Ihr Spielerlebnis zu verbessern, müssen Sie Benachrichtigungen zulassen! Möchten Sie Benachrichtigungen zulassen?";
  @override
  String get homeNotificationsAllow => "Zulassen";
  @override
  String get homeNotificationsReminderTitle => "Benachrichtigungen aktivieren";
  @override
  String get homeNotificationsReminderDescription =>
      "Benachrichtigungen sind wichtig für ein besseres Spielerlebnis. Möchten Sie sie jetzt aktivieren?";
  @override
  String get homeUpdateTitle => "Update verfügbar!";
  @override
  String get homeUpdateForceDescription =>
      "In der neuen Version wurden mehrere Fehler und Probleme behoben. Installieren Sie sie jetzt, um von diesen Updates zu profitieren!";
  @override
  String get homeUpdateInstall => "Installieren";

  @override
  String get homeAbout => "Über uns";
  @override
  String homeAboutPopupShareText(String link) =>
      "Ich habe ein sehr interessantes Strategiespiel entdeckt! Laden Sie es kostenlos herunter $link !";
  @override
  String get homeAboutPopupImplementation => "Implementierung";
  @override
  String get homeAboutPopupMusic => "Musik";
  @override
  String get homeAboutPopupVersion => "Version";
  @override
  String get homeAboutPopupRateGame => "Spiel bewerten";
  @override
  String get homeAboutPopupVisitWebstie => "Besuchen Sie Saki Hub";
  @override
  String get homeAboutPopupDiscoverApps => "Meine Apps anzeigen";

  @override
  String get homeCardPresentationShowcase =>
      "Verwenden Sie dieses Menü, um neue Karten zu kaufen und vorhandene Karten zu verbessern.";
  @override
  String get homeCardPresentationShow => "Alle Karten anzeigen";

  @override
  String get homeGratificationPopupConnectionErrorTitle => "Verbindungsfehler!";
  @override
  String get homeGratificationPopupConnectionErrorDescription =>
      "Bitte überprüfen Sie Ihre Internetverbindung. Dieser Abschnitt wird automatisch aktualisiert, wenn Sie verbunden sind!";
  @override
  String get homeGratificationPopupLoadingTitle =>
      "Belohnungen werden geladen!";
  @override
  String get homeGratificationPopupLoadingDescription =>
      "Die Belohnungen werden in nur wenigen Sekunden verfügbar sein. Bitte warten Sie!";
  @override
  String get homeGratificationPopupIncorrectTimestampTitle =>
      "Falscher Zeitstempel!";

  @override
  String get homeMultiplayerButtonConnectionErrorTitle => "Verbindungsproblem!";
  @override
  String get homeMultiplayerButtonConnectionErrorDescription =>
      "Sie scheinen nicht mit dem Internet verbunden zu sein. Bitte überprüfen Sie die Qualität Ihrer Internetverbindung und versuchen Sie es erneut!";
  @override
  String get homeMultiplayerButtonText => "Multi";

  @override
  String get homeProfilePopupBestTacticians => "Best\nTaktiker";
  @override
  String get homeProfilePopupDescription =>
      "Die Spieler werden anhand von zwei Kriterien bewertet: Anzahl der Online-Siege und maximale Anzahl von Kauris!";
  @override
  String get homeProfilePopupBestCollectors => "Beste Sammler";
  @override
  String get homeProfilePopupCheckAchievements => "Meine Erfolge anzeigen";

  @override
  String get homeSingleplayerButtonText => "Solo";

  @override
  String get homeSpecialOfferPopupOfferDisabledDescription =>
      "Sonderangebote werden alle 3 Tage aktiviert und sind nur 24 Stunden lang gültig. Verpassen Sie nicht das nächste!";
  @override
  String get homeSpecialOfferPopupOfferLoadedDescription =>
      "Sonderangebote werden alle 3 Tage aktiviert und sind nur 24 Stunden lang gültig. Also, worauf warten Sie noch?";
  @override
  String get homeSpecialOfferPopupOfferLoadingDescription =>
      "Die Daten für das Sonderangebot werden in Kürze verfügbar sein. Bitte haben Sie einen Moment Geduld!";
  @override
  String get homeSpecialOfferPopupErrorDescription =>
      "Wir konnten Ihren Kauf nicht bestätigen. Bitte überprüfen Sie Ihre Zahlungsmethode und Ihre Internetverbindung!";
  @override
  String homeSpecialOfferPopupOffsetLoadedTitle(String? packTitle) =>
      "$packTitle !";
  @override
  String get homeSpecialOfferPopupOfferLoadingTitle => "Angebot wird geladen!";
  @override
  String get homeSpecialOfferPopupErrorTitle => "Transaktion abgebrochen!";
  @override
  String get homeSpecialOfferPopupClose => "Schließen";
  @override
  String get homeSpecialOfferPopupTimestampTitle => "Falscher Zeitstempel!";
  @override
  String get homeSpecialOfferPopupLoadingDescription =>
      "Die Daten für das Sonderangebot werden in Kürze verfügbar sein. Bitte haben Sie einen Moment Geduld!";
  @override
  String get homeSpecialOfferPopupLoadingTitle => "Angebot wird geladen!";
  @override
  String get homeSpecialOfferPopupProblemClose => "Schließen";
  @override
  String get homeSpecialOfferPopupProblemTitle => "Verbindungsfehler!";

  @override
  String get premiumPopupTitle => "Werde Premium!";
  @override
  String get premiumPopupDescription =>
      "Schalten Sie die Vollversion frei, um alle Werbeanzeigen zu entfernen!";
  @override
  String get premiumPlayer => "Premium-Spieler";
  @override
  String get nonPremiumPlayer => "Nicht-Premium-Spieler";

  @override
  String get homeHelpBasicsA =>
      "Das Königreich der Blauen tritt gegen das Königreich der Orangen an.";
  @override
  String get homeHelpBasicsB =>
      "Man kann gewinnen, indem man die Farbe des gegnerischen Lords ändert.";
  @override
  String get homeHelpBasicsC =>
      "Man kann gewinnen, indem man die meisten Lebenspunkte in der vorgegebenen Zeit hat.";

  @override
  String get homeHelpConnections1A =>
      "Sie können tippen und ziehen, um zwei Karten zu verbinden.";
  @override
  String get homeHelpConnections1B =>
      "Sie können tippen und tippen, um zwei Karten zu verbinden.";
  @override
  String get homeHelpConnections1C =>
      "Sie können eine Verbindung durch Wischen mit einem Finger trennen.";

  @override
  String get homeHelpConnections2A =>
      "Eine Verbindung kann manchmal die Möglichkeit zum Spielen beeinträchtigen.";
  @override
  String get homeHelpConnections2B =>
      "Es ist nicht möglich, über eine Karte hinweg zu einer anderen zu verbinden.";
  @override
  String get homeHelpConnections2C =>
      "Eine Karte auf MAX gibt alle Bälle zurück, die sie erhält.";

  @override
  String get homeHelpCards1A => "Rote Karten sind gut im Angriff.";
  @override
  String get homeHelpCards1B => "Graue Karten sind gut in der Verteidigung.";
  @override
  String get homeHelpCards1C => "Grüne Karten sind gut in der Unterstützung.";

  @override
  String get homeHelpCards2A =>
      "Braune Karten haben ausgeglichene Fähigkeiten.";
  @override
  String get homeHelpCards2B =>
      "Gelbe Karten haben spezielle Effekte auf andere Karten.";
  @override
  String get homeHelpCards2C =>
      "Weiße Karten sind diejenigen, die unbedingt geschützt werden müssen.";

  @override
  String get homeHelpRestrictionsA =>
      "Jede Verbindung muss nützlich sein. Hier ist sie nutzlos und daher unmöglich.";
  @override
  String get homeHelpRestrictionsB =>
      "Eine Zerstörungskarte kann keinen Lord angreifen.";
  @override
  String get homeHelpRestrictionsC =>
      "Es ist nicht möglich, einen Lord zu klonen oder zu verschieben.";

  /* LOADING */

  @override
  String get loadingTitle => "Bitte warten Sie!";

  /* REMOTE */

  @override
  String get remoteConnexionProblemTitle => "Verbindungsproblem!";
  @override
  String get remoteConnexionProblemDescription =>
      "Entschuldigung! Ihre Internetverbindung wurde unterbrochen. Sie wurden als Verlierer des Spiels erklärt!";
  @override
  String get remoteInvitationTitle => "Kommen Sie und spielen Sie!";
  @override
  String get remoteInvitationDescription => "Ihr Online-Spiel hat begonnen!";
  @override
  String get remoteMultiplayer => "Mehrspieler";

  @override
  String get remoteFailurePosterTitle => "Es ist ein Fehler aufgetreten!";
  @override
  String get remoteFailurePosterDescription =>
      "Bei der Suche ist ein Fehler aufgetreten. Überprüfen Sie Ihre Internetverbindung und versuchen Sie es erneut!";

  @override
  String get remoteImpossibleGamePosterTitle => "Nicht genug Muscheln!";
  @override
  String remoteImpossibleGamePosterDescription(int cowries) =>
      "Sie müssen mindestens $cowries Muscheln haben, um online zu spielen!";

  @override
  String get remoteNewGamePosterTitle => "Ein neues Spiel?";
  @override
  String get remoteNewGamePosterDescription =>
      "Sie können immer noch mit Spielern aus der ganzen Welt spielen, um Ihr Können zu verbessern!";

  @override
  String get remoteSearchPosterTitle => "Spielersuche";
  @override
  String get remoteSearchPosterDescription =>
      "Wir suchen weltweit nach Spielern, um ein Spiel mit Ihnen zu spielen!";
  @override
  String get homeTranslationPopupDescription =>
      "Dieser Abschnitt ermöglicht es Ihnen, die Hauptsprache des Spiels auszuwählen. Klicken Sie auf eine Sprache, um sie automatisch zu aktivieren!";

  /* KARTENTITEL */

  @override
  String get lordLazyKingName => "Träge König";
  @override
  String get lordLazyQueenName => "Zerbrechliche Königin";
  @override
  String get lordLazyPrinceName => "Einsamer Prinz";
  @override
  String get lordLazyPrincessName => "Introvertierte Prinzessin";
  @override
  String get lordCourageousKingName => "Pragmatischer König";
  @override
  String get lordCourageousQueenName => "Furchtlose Königin";
  @override
  String get lordCourageousPrinceName => "Robuster Prinz";
  @override
  String get lordCourageousPrincessName => "Hingebungsvolle Prinzessin";
  @override
  String get normalOrdinaryCitizenName => "Normaler Bürger";
  @override
  String get normalAttackerDefenderName => "Militärwächter";
  @override
  String get normalAttackerHealerName => "Militärkrankenpfleger";
  @override
  String get normalDefenderHealerName => "Wachkrankenpfleger";
  @override
  String get attacker2AName => "Grippe";
  @override
  String get attacker2BName => "Sonne";
  @override
  String get attacker2CName => "Funke";
  @override
  String get attacker4AName => "Wirbelwind";
  @override
  String get attacker4BName => "Mücke";
  @override
  String get attacker4CName => "Zyklon";
  @override
  String get defender2AName => "Fels";
  @override
  String get defender2BName => "Kiesel";
  @override
  String get defender2CName => "Bollwerk";
  @override
  String get defender4AName => "Strahl";
  @override
  String get defender4BName => "Balkon";
  @override
  String get defender4CName => "Fenster";
  @override
  String get healer2AName => "Gras";
  @override
  String get healer2BName => "Blume";
  @override
  String get healer2CName => "Blatt";
  @override
  String get healer4AName => "Büschel";
  @override
  String get healer4BName => "Pflaster";
  @override
  String get healer4CName => "Baum";
  @override
  String get specialExpansionName => "Expansion";
  @override
  String get specialCompressionName => "Kompression";
  @override
  String get specialDecelerationName => "Verzögerung";
  @override
  String get specialAccelerationName => "Beschleunigung";
  @override
  String get specialAttackIncreaseName => "Tapferkeit";
  @override
  String get specialAttackDecreaseName => "Feigheit";
  @override
  String get specialResistanceIncreaseName => "Stärkung";
  @override
  String get specialResistanceDecreaseName => "Schwächung";
  @override
  String get specialSupportIncreaseName => "Altruismus";
  @override
  String get specialSupportDecreaseName => "Egoismus";
  @override
  String get specialCloningName => "Klonen";
  @override
  String get specialCancellationName => "Stornierung";
  @override
  String get specialRefrigerationName => "Kühlung";
  @override
  String get specialAspiratorName => "Abgrund";
  @override
  String get specialSubstractionName => "Subtraktion";
  @override
  String get specialDivisionName => "Division";
  @override
  String get specialDeflagrationName => "Deflagration";
  @override
  String get specialParalysisName => "Lähmung";
  @override
  String get specialInvulnerabilityName => "Unverwundbarkeit";
  @override
  String get specialVortexName => "Wirbel";

  /* KARTENBESCHREIBUNGEN */

  @override
  String get lordLazyKingDescription =>
      "Dies ist der einzige Lord, der weder angreifen noch verteidigen kann. Aber er ist ein ausgewogener König, der keine besonderen Schwächen hat!";
  @override
  String get lordLazyQueenDescription =>
      "Das ist eine Dame, die trotz ihres fortgeschrittenen Alters sehr gut angreifen und ihre Untertanen unterstützen kann. Ihre Widerstandsfähigkeit lässt jedoch zu wünschen übrig!";
  @override
  String get lordLazyPrinceDescription =>
      "Das ist ein junger Mann, der sehr gut angreifen und Angriffen widerstehen kann. Aber er weiß nicht, wie er seine Untertanen unterstützen kann!";
  @override
  String get lordLazyPrincessDescription =>
      "Das ist eine junge Frau, die sehr gut Angriffen widerstehen und ihre Untertanen unterstützen kann. Aber sie ist nicht stark im Angriff!";
  @override
  String get lordCourageousKingDescription =>
      "Dies ist ein ausgewogener König, der keine besonderen Schwächen hat. Er hat jedoch nur halb so viele Lebenspunkte wie gewöhnlich!";
  @override
  String get lordCourageousQueenDescription =>
      "Das ist eine Dame, die trotz ihres fortgeschrittenen Alters extrem gut angreifen kann. Aber sie ist in anderen Bereichen nicht besonders!";
  @override
  String get lordCourageousPrinceDescription =>
      "Das ist ein junger Mann, der extrem gut Angriffen widerstehen kann. Aber dieser Prinz ist in anderen Bereichen nicht besonders!";
  @override
  String get lordCourageousPrincessDescription =>
      "Das ist eine junge Frau, die extrem gut ihre Untertanen unterstützen kann. Aber diese Prinzessin ist in anderen Bereichen nicht besonders!";
  @override
  String get normalOrdinaryCitizenDescription =>
      "Diese Karte ist die ausgewogenste im Spiel. Sie hat weder besondere Stärken noch besondere Schwächen, bleibt aber ein verlässlicher Verbündeter!";
  @override
  String get normalAttackerDefenderDescription =>
      "Wie der Name schon sagt, ist dies ein junger Mann, der gut angreifen kann, während er Angriffen widersteht!";
  @override
  String get normalAttackerHealerDescription =>
      "Wie der Name schon sagt, ist dies ein junger Mann, der gut angreifen kann, während er seine Verbündeten unterstützt!";
  @override
  String get normalDefenderHealerDescription =>
      "Wie der Name schon sagt, ist dies ein junger Mann, der seine Verbündeten gut unterstützen kann, während er Angriffen widersteht!";
  @override
  String get attacker2ADescription =>
      "Diese Karte fügt ihren Feinden doppelten Schaden im Vergleich zu einer normalen Karte zu, kann aber ihre Verbündeten nicht gut unterstützen!";
  @override
  String get attacker2BDescription =>
      "Diese Karte fügt ihren Feinden doppelten Schaden im Vergleich zu einer normalen Karte zu, ist aber gegen Angriffe ihrer Feinde anfällig!";
  @override
  String get attacker2CDescription =>
      "Diese Karte fügt ihren Feinden doppelten Schaden im Vergleich zu einer normalen Karte zu, ist aber nur halb so schnell wie eine normale Karte!";
  @override
  String get attacker4ADescription =>
      "Diese Karte fügt ihren Feinden viermal mehr Schaden zu als eine normale Karte, kann ihre Verbündeten jedoch nicht gut unterstützen!";
  @override
  String get attacker4BDescription =>
      "Diese Karte fügt ihren Feinden viermal mehr Schaden zu als eine normale Karte, ist aber äußerst anfällig für Angriffe ihrer Feinde!";
  @override
  String get attacker4CDescription =>
      "Diese Karte fügt ihren Feinden viermal mehr Schaden zu als eine normale Karte, ist jedoch in anderen Bereichen nicht besonders!";
  @override
  String get defender2ADescription =>
      "Diese Karte hat eine doppelte Widerstandsfähigkeit gegenüber einer normalen Karte, kann aber ihre Feinde nicht gut angreifen!";
  @override
  String get defender2BDescription =>
      "Diese Karte hat eine doppelte Widerstandsfähigkeit gegenüber einer normalen Karte, kann aber ihre Verbündeten nicht gut unterstützen!";
  @override
  String get defender2CDescription =>
      "Diese Karte hat eine doppelte Widerstandsfähigkeit gegenüber einer normalen Karte, ist aber nur halb so schnell wie eine normale Karte!";
  @override
  String get defender4ADescription =>
      "Diese Karte hat eine vierfache Widerstandsfähigkeit gegenüber einer normalen Karte, kann ihre Feinde jedoch nicht gut angreifen!";
  @override
  String get defender4BDescription =>
      "Diese Karte hat eine vierfache Widerstandsfähigkeit gegenüber einer normalen Karte, kann aber ihre Verbündeten nicht gut unterstützen!";
  @override
  String get defender4CDescription =>
      "Diese Karte hat eine vierfache Widerstandsfähigkeit gegenüber einer normalen Karte, ist jedoch in anderen Bereichen nicht besonders!";
  @override
  String get healer2ADescription =>
      "Diese Karte heilt ihre Verbündeten doppelt so schnell wie eine normale Karte, kann aber ihre Feinde nicht gut angreifen!";
  @override
  String get healer2BDescription =>
      "Diese Karte heilt ihre Verbündeten doppelt so schnell wie eine normale Karte, ist aber gegen Angriffe ihrer Feinde anfällig!";
  @override
  String get healer2CDescription =>
      "Diese Karte heilt ihre Verbündeten doppelt so schnell wie eine normale Karte, ist jedoch nur halb so schnell wie eine normale Karte!";
  @override
  String get healer4ADescription =>
      "Diese Karte heilt ihre Verbündeten viermal schneller als eine normale Karte, kann ihre Feinde jedoch nicht gut angreifen!";
  @override
  String get healer4BDescription =>
      "Diese Karte heilt ihre Verbündeten viermal schneller als eine normale Karte, ist aber äußerst anfällig für Angriffe ihrer Feinde!";
  @override
  String get healer4CDescription =>
      "Diese Karte heilt ihre Verbündeten viermal schneller als eine normale Karte, ist jedoch in anderen Bereichen nicht besonders!";
  @override
  String get specialExpansionDescription =>
      "Diese Karte erhöht die Angriffsmöglichkeiten der Zielkarte um eins, unabhängig davon, ob das Ziel ein Verbündeter ist oder nicht!";
  @override
  String get specialCompressionDescription =>
      "Diese Karte verringert die Angriffsmöglichkeiten der Zielkarte um eins, unabhängig davon, ob das Ziel ein Verbündeter ist oder nicht!";
  @override
  String get specialDecelerationDescription =>
      "Diese Karte verlangsamt ihre Ziele, indem sie ihre Geschwindigkeit halbiert. Es spielt keine Rolle, ob das Ziel ein Verbündeter oder ein Feind ist!";
  @override
  String get specialAccelerationDescription =>
      "Diese Karte beschleunigt ihre Ziele, indem sie ihre Geschwindigkeit verdoppelt. Es spielt keine Rolle, ob das Ziel ein Verbündeter oder ein Feind ist!";
  @override
  String get specialAttackIncreaseDescription =>
      "Diese Karte verbessert ihre Ziele, indem sie ihren Angriff verdoppelt. Es spielt keine Rolle, ob das Ziel ein Verbündeter oder ein Feind ist!";
  @override
  String get specialAttackDecreaseDescription =>
      "Diese Karte schwächt ihre Ziele, indem sie ihren Angriff halbiert. Es spielt keine Rolle, ob das Ziel ein Verbündeter oder ein Feind ist!";
  @override
  String get specialResistanceIncreaseDescription =>
      "Diese Karte verbessert ihre Ziele, indem sie ihre Widerstandsfähigkeit verdoppelt. Es spielt keine Rolle, ob das Ziel ein Verbündeter oder ein Feind ist!";
  @override
  String get specialResistanceDecreaseDescription =>
      "Diese Karte schwächt ihre Ziele, indem sie ihre Widerstandsfähigkeit halbiert. Es spielt keine Rolle, ob das Ziel ein Verbündeter oder ein Feind ist!";
  @override
  String get specialSupportIncreaseDescription =>
      "Diese Karte verbessert ihre Ziele, indem sie ihre Unterstützung verdoppelt. Es spielt keine Rolle, ob das Ziel ein Verbündeter oder ein Feind ist!";
  @override
  String get specialSupportDecreaseDescription =>
      "Diese Karte schwächt ihre Ziele, indem sie ihre Unterstützung halbiert. Es spielt keine Rolle, ob das Ziel ein Verbündeter oder ein Feind ist!";
  @override
  String get specialCloningDescription =>
      "Diese Karte mit begrenzter Lebensdauer ermöglicht das Klonen aller Eigenschaften und Fähigkeiten einer Zielkarte auf dem Spielfeld!";
  @override
  String get specialCancellationDescription =>
      "Diese Karte hebt den Spezialeffekt ihrer Ziele auf, unabhängig davon, ob das Ziel ein Verbündeter ist oder nicht. Sie kann jedoch nicht selbst aufgehoben werden!";
  @override
  String get specialRefrigerationDescription =>
      "Diese Karte verhindert, dass ihre Ziele vom Besitzer verändert werden, unabhängig davon, ob das Ziel ein Verbündeter ist oder nicht!";
  @override
  String get specialAspiratorDescription =>
      "Diese Karte eliminiert alle Karten, die sich in einem Feldabstand von einer Einheit von ihr befinden, nach einer vom aktuellen Level abhängigen Verzögerung!";
  @override
  String get specialSubstractionDescription =>
      "Diese Karte eliminiert alle Karten, die sich auf ihrer Zeile und ihrer Spalte befinden, nach einer vom aktuellen Level abhängigen Verzögerung!";
  @override
  String get specialDivisionDescription =>
      "Diese Karte eliminiert alle Karten, die sich auf ihren Diagonalen befinden, nach einer vom aktuellen Level abhängigen Verzögerung!";
  @override
  String get specialDeflagrationDescription =>
      "Diese Karte eliminiert alle Karten auf ihrer Zeile, ihrer Spalte und ihren Diagonalen nach einer vom aktuellen Level abhängigen Verzögerung!";
  @override
  String get specialParalysisDescription =>
      "Diese Karte mit begrenzter Lebensdauer verhindert, dass ihre Ziele angreifen oder sich verteidigen können, unabhängig davon, ob das Ziel ein Verbündeter ist oder nicht!";
  @override
  String get specialInvulnerabilityDescription =>
      "Diese Karte mit begrenzter Lebensdauer macht ihre Ziele für eine Zeit, die vom aktuellen Level abhängt, unverwundbar!";
  @override
  String get specialVortexDescription =>
      "Diese Karte mit begrenzter Lebensdauer ermöglicht es, eine Zielkarte auf dem Spielfeld zu bewegen, indem sie ihren Platz mit ihr tauscht!";

  /* GAME */

  @override
  String get gameAbandonmentButtonDescription =>
      "Ihr Gegner wird automatisch als Sieger erklärt! Möchten Sie dieses Spiel wirklich aufgeben?";
  @override
  String get gameAbandonmentButtonAbandon => "Aufgeben";
  @override
  String get gameAbandonmentButtonTitle => "Aufgeben";

  @override
  String get gameBottomButtonDisplayResult => "Ergebnis anzeigen";

  @override
  String get gameCardsSummaryPlay => "Spielen";
  @override
  String get gameCardsSummaryRemember => "Merken Sie sich gut!";

  @override
  String get gameInitialTutorialPopupPlay => "Spielen";

  @override
  String get gamePassButtonPopupPass => "Überspringen";
  @override
  String get gamePassButtonPopupDescription =>
      "Bevor Sie fortfahren, stellen Sie sicher, dass Sie die Regeln des Spiels gut kennen. Möchten Sie das Tutorial wirklich überspringen?";
  @override
  String get gamePassButtonPopupTitle => "Tutorial überspringen";

  @override
  String get adventureVictoryPossibleToPlayNextLevelDescription =>
      "Herzlichen Glückwunsch zu Ihrem Sieg! Sie haben dieses Level erfolgreich abgeschlossen. Sie können zum nächsten Level gehen!";
  @override
  String get adventureVictoryImpossibleToPlayNextLevelDescription =>
      "Sie haben nicht genug Kauris, um das nächste Level zu spielen! Sehen Sie sich eine Anzeige an, um 1 Kauri zu erhalten!";
  @override
  String get adventureVictoryGameFinishedDescription =>
      "Sie haben den 'Solitaire'-Modus abgeschlossen!\nSpieler aus der ganzen Welt warten auf Sie in der Welt der Online-Spiele!";
  @override
  String get adventureDefeatPossibleToPlayAgainDescription =>
      "Entschuldigen Sie die Niederlage! Lassen Sie sich nicht entmutigen: Sie können sich immer noch verbessern, indem Sie erneut spielen!";
  @override
  String get adventureDefeatImpossibleToPlayAgainDescription =>
      "Sie haben leider nicht genug Kauris, um erneut zu spielen! Sehen Sie sich eine Anzeige an, um 1 Kauri zu erhalten!";
  @override
  String get adventureDefeatPossibleToPlayNextLevelDescription =>
      "Entschuldigen Sie die Niederlage! So oder so haben Sie dieses Level bereits bestanden und können zum nächsten Level gehen!";
  @override
  String get adventureDefeatImpossibleToPlayNextLevelDescription =>
      "Sie haben nicht genug Kauris, um das nächste Level zu spielen! Sehen Sie sich eine Anzeige an, um 1 Kauri zu erhalten!";
  @override
  String get adventureGameAlreadyFinishedDescription =>
      "Entschuldigen Sie die Niederlage! Wie auch immer, Sie haben bereits alle Level dieses Spielmodus abgeschlossen!";
  @override
  String get remoteDefeatDescription =>
      "Entschuldigen Sie die Niederlage! Lassen Sie sich nicht entmutigen: Sie können sich immer noch verbessern, indem Sie mehr Spiele spielen!";
  @override
  String get remoteVictoryDescription =>
      "Herzlichen Glückwunsch zu Ihrem Sieg! Sie können Ihr Niveau noch weiter verbessern, indem Sie an mehr Online-Spielen teilnehmen!";
  @override
  String get remotePossibleToPlayAgainDescription =>
      "Sie haben leider nicht genug Kauris, um erneut zu spielen! Sehen Sie sich eine Anzeige an, um 1 Kauri zu erhalten!";
  @override
  String get remoteOpponentUnavailableDescription =>
      "Der andere Spieler ist nicht mehr verfügbar, um ein Spiel zu spielen. Aber es gibt immer noch viele andere Möglichkeiten für Sie!";
  @override
  String get externalNeedinessDescription =>
      "Der andere Spieler hat nicht mehr genug Kauris, um zu spielen. Aber Sie können warten oder ein neues Spiel beginnen!";
  @override
  String get internalNeedinessTitle => "Kauris nicht ausreichend!";
  @override
  String get replayImpossibleDescription =>
      "Der andere Spieler ist nicht mehr verbunden. Aber Sie können immer noch ein neues Spiel mit einem anderen Spieler starten!";
  @override
  String get invitationWithdrawalDescription =>
      "Der andere Spieler hat seine Einladung zum erneuten Spielen zurückgezogen. Aber Sie können immer noch ein neues Spiel beginnen!";
  @override
  String get invitationRejectionDescription =>
      "Ihre Einladung wurde leider abgelehnt. Aber Sie können immer noch ein neues Spiel beginnen!";
  @override
  String get invitationAcceptationDescription =>
      "Sie sind beide bereit, erneut zu spielen. Ein wenig Geduld! Das Spiel wird in Kürze fortgesetzt!";
  @override
  String get externalInvitationReplayImpossibleDescription =>
      "Sie haben nicht genug Kauris, um eine Einladung anzunehmen! Sehen Sie sich eine Anzeige an, um 1 Kauri zu erhalten!";
  @override
  String get externalInvitationReplayPossibleDescription =>
      "Der andere Spieler möchte ein neues Spiel mit Ihnen spielen! Möchten Sie seine Einladung annehmen oder ablehnen?";
  @override
  String get internalInvitationDescription =>
      "Der andere Spieler hat eine Benachrichtigung über Ihre Einladung zum erneuten Spielen erhalten. Er kann sie akzeptieren oder ablehnen!";
  @override
  String get gamePopupNewGame => "Neues\nSpiel";
  @override
  String get gamePopupNextLevel => "Nächstes\nLevel";
  @override
  String get gamePopupReplay => "Erneut\nspielen";
  @override
  String get globalExit => "Beenden";
  @override
  String get globalAccept => "Akzeptieren";
  @override
  String get globalReject => "Ablehnen";
  @override
  String get globalCancel => "Abbrechen";
  @override
  String get normalDefeatTitle => "Sie haben verloren!";
  @override
  String get defeatByAbandonment => "Niederlage durch Aufgabe!";
  @override
  String get normalVictoryTitle => "Sie haben gewonnen!";
  @override
  String get victoryByAbandonment => "Sieg durch Aufgabe!";
  @override
  String get externalNeedinessTitle => "Oops!";
  @override
  String get internalNeedinessDescription =>
      "Der andere Spieler möchte ein neues Spiel mit Ihnen spielen, aber Sie haben nicht mehr genug Kauris, um zu spielen!";
  @override
  String get replayImpossibleTitle => "Wiederholung unmöglich!";
  @override
  String get invitationWithdrawalTitle => "Einladung zurückgezogen!";
  @override
  String get invitationRejectionTitle => "Einladung abgelehnt!";
  @override
  String get invitationAcceptationTitle => "Spiel wird geladen!";
  @override
  String get externalInvitationTitle => "Möchten Sie erneut spielen?";
  @override
  String get internalInvitationTitle => "Ein wenig Geduld!";
  @override
  String get gameProfilePosterClose => "Schließen";
  @override
  String get gameProfilePosterDeck => "Deck";
  @override
  String get gameProfilePosterCards => "Karten";
  @override
  String get gameProfilePosterCrowns => "Kronen";

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
  String get gametutorialCongratulationsPopupPlay => "Spielen";
  @override
  String get gametutorialCongratulationsPopupTitle => "Herzlichen Glückwunsch!";
  @override
  String get gameTutorialCongratulationsPopupUnclearDescription =>
      "Sie haben diese Lektion erfolgreich abgeschlossen! Aber Sie können jederzeit neu beginnen, wenn es noch dunkle Bereiche gibt!";

  @override
  String get gameTutorialPopupTitle => "Hilfe";

  @override
  String get gameTutorialProgressPopupNextLesson => "Nächste Lektion";
  @override
  String get gameTutorialProgressPopupTitle => "Herzlichen Glückwunsch!";

  /* USER CUBIT */

  @override
  String get referralNotificationTitle => "+50 Karotten!";

  @override
  String referralNotificationBody(String name) =>
      "Herzlichen Glückwunsch! Sie haben 50 Karotten erhalten, weil sich $name angemeldet hat!";

  /* NOTIFICATION */

  @override
  String get notificationMissBody =>
      "Wir haben Sie schon seit Tagen nicht mehr gesehen. Kommen Sie vorbei und trainieren Sie Ihr Gehirn, während Sie Spaß haben!";
  @override
  String get notificationMissTitle => "Wir vermissen Sie!";
  @override
  String get notificationGiftBody =>
      "Jede Stunde erhalten Sie kostenlos Karotten! Kommen Sie und holen Sie sich Ihr Geschenk ab!";
  @override
  String get notificationGiftTitle => "Verpassen Sie Ihr Geschenk nicht!";

  /* GLOBAL */

  @override
  String get kingConquestInstruction =>
      "Warten Sie, bis der König die Farbe wechselt, um das Spiel zu gewinnen.";
  @override
  String get invalidDeckTitle => "Ungültiges Deck!";
  @override
  String get invalidDeckDescription =>
      "Ihr aktuelles Deck ist ungültig. Bitte beheben Sie es oder wählen Sie ein anderes aus, bevor Sie ein neues Spiel starten!";

  @override
  String get authenticationPopupAuthenticationErrorDescription =>
      "Wir konnten keine Verbindung zu Ihrem Spielskonto herstellen. Überprüfen Sie bitte Ihre Internetverbindung und versuchen Sie es erneut!";
  @override
  String get authenticationPopupAuthenticationErrorTitle =>
      "Authentifizierungsfehler!";

  @override
  String get globalRetry => "Wiederholen";

  @override
  String get authenticationPopupRequiredAuthentication =>
      "Authentifizierung erforderlich!";
  @override
  String get authenticationPopupLoadingAuthentication =>
      "Authentifizierung läuft!";

  @override
  String authenticationPopupDescription(String account) =>
      "Wir werden Sie mit Ihrem $account-Konto verbinden, um Ihren Fortschritt im Spiel zu speichern!";

  @override
  String get globalAppleGameCenter => "Apple Game Center";

  @override
  String get globalGooglePlay => "Google Play Spiele";

  @override
  String cardOptionButtonPopupDeckN(int index) => "Deck $index";

  @override
  String get cardOptionButtonDescription =>
      "Sie können bis zu 3 Decks besitzen. Überprüfen und wählen Sie Ihr Spieldeck hier aus.";

  @override
  String get globalValidate => "Bestätigen";

  @override
  String get blockedAccountContactSakiHub => "Saki Hub kontaktieren";

  @override
  String get blockedAccountDescription =>
      "Die Sperrung eines Kontos erfolgt aufgrund illegaler oder verdächtiger Aktivitäten. Wenn dies ein Fehler ist, kontaktieren Sie uns bitte!";
  @override
  String get blockedAccountTitle => "Ihr Konto wurde gesperrt!";

  @override
  String get progressOptionButtonNotAuthenticationDescription =>
      "Karotten erhöhen Ihre Spielfreiheit, aber Sie müssen zuerst angemeldet sein, um sie zu verwenden!";

  @override
  String get progressOptionButtonNotAuthenticatedTitle =>
      "Sie haben keine Karotten!";
  @override
  String get progressOptionButtonShowcase =>
      "Die Karotte, die Spielwährung, ist entscheidend für den Kauf von Karten und das Spielen. Verwalten Sie Ihre Karotten hier.";

  @override
  String get globalAd => "WERBUNG";

  @override
  String get globalConnect => "Verbinden";

  /* FAMILIES */

  @override
  String get attackerFamilyName => "Angreifer";
  @override
  String get attackerFamilyShortDescription => "Rote Karten: Stark im Angriff";
  @override
  String get attackerFamilyLongDescription =>
      "Diese Karten verursachen den meisten Schaden an ihren Feinden. Sie sind jedoch in anderen Bereichen nicht hervorragend!";

  @override
  String get defenderFamilyName => "Verteidiger";
  @override
  String get defenderFamilyShortDescription =>
      "Graue Karten: Stark in der Verteidigung";
  @override
  String get defenderFamilyLongDescription =>
      "Diese Karten haben die höchsten Verteidigungswerte. Sie sind jedoch in anderen Bereichen nicht hervorragend!";

  @override
  String get healerFamilyName => "Heiler";
  @override
  String get healerFamilyShortDescription =>
      "Grüne Karten: Stark in der Heilung";
  @override
  String get healerFamilyLongDescription =>
      "Diese Karten heilen ihre Verbündeten am besten. Sie sind jedoch in anderen Bereichen nicht hervorragend!";

  @override
  String get lordFamilyName => "Herrscher";
  @override
  String get lordFamilyShortDescription => "Herrscher: Unbedingt schützen";
  @override
  String get lordFamilyLongDescription =>
      "Dies sind die Karten, die im Spiel unbedingt geschützt werden müssen: Sie verlieren automatisch, wenn sich die Farbe Ihres Herrschers ändert!";

  @override
  String get normalFamilyName => "Normal";
  @override
  String get normalFamilyShortDescription =>
      "Braune Karten: Ausgeglichene Fähigkeiten";
  @override
  String get normalFamilyLongDescription =>
      "Die Normalen sind im Spiel am ausgewogensten. Sie sind sehr vielseitig und bieten einen echten Vorteil auf dem Spielfeld!";

  @override
  String get specialFamilyName => "Spezial";
  @override
  String get specialFamilyShortDescription =>
      "Gelbe Karten: Besondere Effekte auf andere";
  @override
  String get specialFamilyLongDescription =>
      "Diese Karten haben Effekte auf andere Karten. Ihre Effekte hängen hauptsächlich von ihrer Art ab!";

  /* LESSONS */

  @override
  String get basicsLessonTitle => "Lektion 1/3: Spielgrundlagen";
  @override
  String get globalLesson => "Lektion";
  @override
  String get basicsLessonSuffix => "Spielgrundlagen";
  @override
  String get basicsLessonWinningMessage =>
      "Herzlichen Glückwunsch zum Sieg! Gehen Sie schnell zur nächsten Lektion, um die Rolle der Spielkarten zu beherrschen!";

  @override
  String get normalLessonTitle => "Lektion 2/3: Rolle der Karten";
  @override
  String get normalLessonSuffix => "Rolle der Karten";
  @override
  String get specialLessonSuffix => "Spezialkarten";
  @override
  String get normalLessonDescription =>
      "Rote Karten sind gut im Angriff, grüne Karten bieten Unterstützung, graue Karten bieten Widerstand, und braune Karten sind ausgewogen!";
  @override
  String get normalLessonWinningMessage =>
      "Herzlichen Glückwunsch zum Sieg! Gehen Sie zur nächsten Lektion über, um die Rolle der gelben Karten zu verstehen!";

  @override
  String get specialLessonTitle => "Lektion 3/3: Spezialkarten";
  @override
  String get specialLessonDescription =>
      "Gelbe Karten haben besondere Effekte auf andere. Der Effekt einer Spezialkarte hängt allein von ihrer Natur ab!";

  /* MESSAGES */

  @override
  String get awesomeMessage => "Genial";
  @override
  String get congratulationsMessage => "Herzlichen Glückwunsch";
  @override
  String get excellentMessage => "Ausgezeichnet";
  @override
  String get goodMessage => "Gut";
  @override
  String get greatMessage => "Großartig";
  @override
  String get magnificentMessage => "Prächtig";
  @override
  String get masterfulMessage => "Meisterhaft";

  /* TUTORIALS INSTRUCTIONS */

  @override
  String get basicsPlaceTileInstruction =>
      "Platzieren Sie eine Ihrer Karten auf dem Spielfeld, um Ihre Verbündeten zu erhöhen.";
  @override
  String get basicsConnectCenterTileInstruction =>
      "Verbinden Sie sich mit der grauen Karte, um sie zu einem Königreichsverbündeten zu machen.";
  @override
  String get basicsConquerCenterTileInstruction =>
      "Warten Sie, bis die graue Karte die Farbe ändert, bevor Sie sie verwenden können.";
  @override
  String get basicsCutPathInstruction =>
      "Entfernen Sie die Verbindung zwischen den beiden Karten wie angegeben.";
  @override
  String get basicsConnectKingInstruction =>
      "Verbinden Sie sich mit dem König des Gegners, um ihn anzugreifen.";
  @override
  String get normalPlaceOrdinaryCitizenInstruction =>
      "Platzieren Sie einen Bürger. Es ist eine Karte mit ausgewogenen Fähigkeiten.";
  @override
  String get normalConnectOrdinaryCitizenInstruction =>
      "Der Gegner hat einen Bürger gespielt. Greifen Sie an, bevor er Sie angreift.";
  @override
  String get normalPlaceHealerInstruction =>
      "Ihr König wird angegriffen und benötigt Heilung. Platzieren Sie einen Heiler auf dem Spielfeld.";
  @override
  String get normalConnectHealerInstruction =>
      "Heilen Sie Ihren König schnell, um zu verhindern, dass er die Farbe ändert.";
  @override
  String get normalPlaceAttackerInstruction =>
      "Sie müssen kontern. Platzieren Sie einen Angreifer auf dem Spielfeld.";
  @override
  String get normalConnectAttackerInstruction =>
      "Greifen Sie die Karte an, die Sie angreift, um den König zu schützen.";
  @override
  String get normalConquerAttackerInstruction =>
      "Warten Sie, bis sich die linke Karte ändert, bevor Sie sie verwenden können.";
  @override
  String get normalPlaceDefenderInstruction =>
      "Ihr Bürger ist besiegt. Platzieren Sie einen Verteidiger, um Ihren König zu schützen.";
  @override
  String get normalConnectDefenderInstruction =>
      "Verteidigen Sie Ihren König, indem Sie die Karte angreifen, die Ihren König bedroht.";
  @override
  String get normalConnectKingInstruction =>
      "Sie werden angegriffen. Aber konzentrieren Sie sich auf den König des Gegners.";
  @override
  String get specialPlaceOrdinaryCitizenInstruction =>
      "Platzieren Sie einen Bürger. Es ist eine Karte mit ausgewogenen Fähigkeiten.";
  @override
  String get specialPlaceCompressionInstruction =>
      "Der Gegner hat zurückschlagen. Verwenden Sie KOMPRESSION, um sich zu verteidigen.";
  @override
  String get specialConnectCompressionInstruction =>
      "KOMPRESSION wird verwendet, um eine Verbindung von ihren Zielen zu entfernen. Benutzen Sie es.";
  @override
  String get specialPlaceRefrigerationInstruction =>
      "Der Gegner hält an. Verwenden Sie KÜHLUNG, um den Feind zu einfrieren.";
  @override
  String get specialConnectRefrigerationInstruction =>
      "KÜHLUNG verhindert, dass sich ihre Ziele ändern. Benutzen Sie es.";
  @override
  String get specialConnectOrdinaryCitizen1Instruction =>
      "Die gefrorene Karte liegt Ihnen zu Füßen. Greifen Sie sie an, um sie zu einem Verbündeten zu machen.";
  @override
  String get specialPlaceExpansionInstruction =>
      "Der Gegner hält an. Verwenden Sie ERWEITERUNG, um sich zu verteidigen.";
  @override
  String get specialConnectExpansionInstruction =>
      "ERWEITERUNG erhöht die Verbindungen ihrer Ziele. Benutzen Sie es.";
  @override
  String get specialConnectOrdinaryCitizen2Instruction =>
      "Dank ERWEITERUNG können Sie 2 Zielkarten angreifen. Los geht's.";
  @override
  String get specialConquerOrdinaryCitizenInstruction =>
      "Warten Sie, bis sich die rechte Karte ändert, bevor Sie sie verwenden können.";
  @override
  String get specialConnectKingInstruction =>
      "Beenden Sie dieses Tutorial mit einem Knall, indem Sie den König des Gegners angreifen.";

  /* TUTORIALS DESCRIPTIONS */

  @override
  String get basicsPlaceTileDescription =>
      "Um eine Karte auf dem Spielfeld zu platzieren, ziehen Sie sie von der Karte an die gewünschte Position!";
  @override
  String get basicsConnectCenterTileDescription =>
      "Um sich mit der grauen Karte zu verbinden, ziehen Sie von der Karte, die Sie gerade platziert haben, zur grauen Karte!";
  @override
  String get basicsConquerCenterTileDescription =>
      "Um die Farbe der grauen Karte zu ändern, benötigen Sie eine Verbindung zu ihr und müssen ihre Punkte auf 0 reduzieren!";
  @override
  String get basicsCutPathDescription =>
      "Um die Verbindung zwischen den beiden Karten zu entfernen, ziehen Sie zum Zeichnen eines Segments, das die Verbindung durchschneidet!";
  @override
  String get basicsConnectKingDescription =>
      "Um sich mit dem König des Gegners zu verbinden, ziehen Sie von der Karte, die Sie gerade platziert haben, zum König!";
  @override
  String get kingConquestDescription =>
      "Um die Farbe der Karte des Königs zu ändern, benötigen Sie eine Verbindung zu ihr und müssen ihre Punkte auf 0 reduzieren!";
  @override
  String get normalPlaceOrdinaryCitizenDescription =>
      "Um eine Karte auf dem Spielfeld zu platzieren, ziehen Sie sie von der Karte an die gewünschte Position!";
  @override
  String get normalConnectOrdinaryCitizenDescription =>
      "Um sich mit der Zielkarte zu verbinden, ziehen Sie von der ursprünglichen Karte zur Karte, die Sie anvisieren!";
  @override
  String get normalPlaceHealerDescription =>
      "Um eine Karte auf dem Spielfeld zu platzieren, ziehen Sie sie von der Karte an die gewünschte Position!";
  @override
  String get normalConnectHealerDescription =>
      "Um sich mit der Zielkarte zu verbinden, ziehen Sie von der ursprünglichen Karte zur Karte, die Sie anvisieren!";
  @override
  String get normalPlaceAttackerDescription =>
      "Um eine Karte auf dem Spielfeld zu platzieren, ziehen Sie sie von der Karte an die gewünschte Position!";
  @override
  String get normalConnectAttackerDescription =>
      "Um sich mit der Zielkarte zu verbinden, ziehen Sie von der ursprünglichen Karte zur Karte, die Sie anvisieren!";
  @override
  String get normalConquerAttackerDescription =>
      "Um die Farbe der Zielkarte zu ändern, benötigen Sie eine Verbindung zu ihr und müssen ihre Punkte auf 0 reduzieren!";
  @override
  String get normalPlaceDefenderDescription =>
      "Um eine Karte auf dem Spielfeld zu platzieren, ziehen Sie sie von der Karte an die gewünschte Position!";
  @override
  String get normalConnectDefenderDescription =>
      "Um sich mit der Zielkarte zu verbinden, ziehen Sie von der ursprünglichen Karte zur Karte, die Sie anvisieren!";
  @override
  String get normalConnectKingDescription =>
      "Um sich mit der Zielkarte zu verbinden, ziehen Sie von der ursprünglichen Karte zur Karte, die Sie anvisieren!";
  @override
  String get specialPlaceOrdinaryCitizenDescription =>
      "Um eine Karte auf dem Spielfeld zu platzieren, ziehen Sie sie von der Karte an die gewünschte Position!";
  @override
  String get specialPlaceCompressionDescription =>
      "Um eine Karte auf dem Spielfeld zu platzieren, ziehen Sie sie von der Karte an die gewünschte Position!";
  @override
  String get specialConnectCompressionDescription =>
      "Um sich mit der Zielkarte zu verbinden, ziehen Sie von der ursprünglichen Karte zur Karte, die Sie anvisieren!";
  @override
  String get specialPlaceRefrigerationDescription =>
      "Um eine Karte auf dem Spielfeld zu platzieren, ziehen Sie sie von der Karte an die gewünschte Position!";
  @override
  String get specialConnectRefrigerationDescription =>
      "Um sich mit der Zielkarte zu verbinden, ziehen Sie von der ursprünglichen Karte zur Karte, die Sie anvisieren!";
  @override
  String get specialConnectOrdinaryCitizen1Description =>
      "Um sich mit der Zielkarte zu verbinden, ziehen Sie von der ursprünglichen Karte zur Karte, die Sie anvisieren!";
  @override
  String get specialPlaceExpansionDescription =>
      "Um eine Karte auf dem Spielfeld zu platzieren, ziehen Sie sie von der Karte an die gewünschte Position!";
  @override
  String get specialConnectExpansionDescription =>
      "Um sich mit der Zielkarte zu verbinden, ziehen Sie von der ursprünglichen Karte zur Karte, die Sie anvisieren!";
  @override
  String get specialConnectOrdinaryCitizen2Description =>
      "Dank ERWEITERUNG können Sie 2 Zielkarten angreifen. Los geht's.";
  @override
  String get specialConquerOrdinaryCitizenDescription =>
      "Warten Sie, bis sich die rechte Karte ändert, bevor Sie sie verwenden können!";
  @override
  String get specialConnectKingDescription =>
      "Beenden Sie dieses Tutorial mit einem Knall, indem Sie den König des Gegners angreifen!";

  /* SKILLS */

  @override
  String get attackSkillNull => "Null";
  @override
  String get attackSkillVeryBad => "Sehr Schlecht";
  @override
  String get attackSkillBad => "Schlecht";
  @override
  String get attackSkillNormal => "Normal";
  @override
  String get attackSkillGood => "Gut";
  @override
  String get attackSkillVeryGood => "Sehr Gut";

  @override
  String get supportSkillNull => "Null";
  @override
  String get supportSkillVeryBad => "Sehr Schlecht";
  @override
  String get supportSkillBad => "Schlecht";
  @override
  String get supportSkillNormal => "Normal";
  @override
  String get supportSkillGood => "Gut";
  @override
  String get supportSkillVeryGood => "Sehr Gut";

  @override
  String get resistanceSkillNull => "Null";
  @override
  String get resistanceSkillVeryBad => "Sehr Schlecht";
  @override
  String get resistanceSkillBad => "Schlecht";
  @override
  String get resistanceSkillNormal => "Normal";
  @override
  String get resistanceSkillGood => "Gut";
  @override
  String get resistanceSkillVeryGood => "Sehr Gut";

  @override
  String get lifeSkillNull => "Null";
  @override
  String get lifeSkillHalf => "Halb";
  @override
  String get lifeSkillNormal => "Normal";

  @override
  String get speedSkillNull => "Null";
  @override
  String get speedSkillHalf => "Halb";
  @override
  String get speedSkillNormal => "Normal";

  @override
  String remoteComplexCloseDescription(int cowries) =>
      "Das Schließen dieses Teils kostet genau $cowries Kauris! Möchten Sie das Spiel wirklich schließen?";
  @override
  String adventureComplexCloseDescription(int cowries) =>
      "Das Schließen dieses Teils kostet genau $cowries Kauris! Möchten Sie das Spiel wirklich schließen?";
  @override
  String get adventureSimpleCloseDescription =>
      "Das Schließen des aktuellen Spiels führt zum Verlust Ihres Fortschritts! Möchten Sie das aktuelle Spiel wirklich schließen?";
  @override
  String get remoteSimpleCloseDescription =>
      "Das Schließen dieses Teils führt zum Verlust seines aktuellen Fortschritts! Möchten Sie diesen Teil wirklich schließen?";
  @override
  String get closeClose => "Schließen";
  @override
  String get closeTitle => "Schließen";

  @override
  String get watchAdButtonRefreshAd => "Werbung aktualisieren";
  @override
  String get cardOptionButtonPopupSelectDeck => "Dieses Deck auswählen";

  @override
  String get lessonChangeTitle => "Lektion ändern";
  @override
  String get lessonChangeDescription =>
      "Bitte beherrschen Sie den Unterricht dieser Lektion, bevor Sie zu einem anderen übergehen! Möchten Sie wirklich die Lektion ändern?";
  @override
  String get lessonChangeAction => "Ändern";
  @override
  String get restoreDefaultLanguage => "Zurücksetzen auf die Standardsprache";

  //

  @override
  String get loadingDescription =>
      "Wir laden die Spieldaten gerade. Bitte warten Sie einen Moment!";
  @override
  String get homeUpdateSimpleDescription =>
      "Eine neue Version des Spiels ist verfügbar. Installieren Sie sie schnell, um die neuesten Funktionen zu nutzen!";
  @override
  String get gametutorialCongratulationsPopupDescription =>
      "Sie können jetzt das Spieluniversum betreten und alle seine Feinheiten erkunden!";
  @override
  String gameScoresIndicatorNormalGameDescription(int level) =>
      "Ich bin die künstliche Intelligenz von Level $level des Spiels! Ich werde mein Bestes tun, um Ihnen ein schönes Spiel zu bieten!";
  @override
  String get gameScoresIndicatorTutorialGameDescription =>
      "Ich bin die künstliche Intelligenz des Spiel-Tutorials. Folgen Sie einfach den Anweisungen, um zu gewinnen!";

  @override
  String get homeCowriesStoreTransactionErrorTitle =>
      "Transaktion abgebrochen!";
  @override
  String get homeCowriesStoreTransactionErrorDescription =>
      "Wir konnten Ihren Kauf nicht bestätigen. Bitte überprüfen Sie Ihre Zahlungsmethode und Ihre Internetverbindung!";

  @override
  String get drawTitle => "Unentschieden!";
  @override
  String get adventureDrawGameFinishedDescription =>
      "Sie haben unentschieden beendet! So oder so haben Sie bereits alle Level dieses Spielmodus abgeschlossen!";
  @override
  String get adventureDrawPossibleToPlayNextLevelDescription =>
      "Sie haben unentschieden beendet! So oder so haben Sie dieses Level bereits abgeschlossen und können zum nächsten Level gehen!";
  @override
  String get adventureDrawPossibleToPlayAgainDescription =>
      "Sie haben unentschieden beendet! Sie können immer noch durch ein neues Spiel gegen die KI gewinnen!";
  @override
  String get remoteDrawDescription =>
      "Sie haben weder gewonnen noch verloren! Warum beginnen Sie nicht ein weiteres Spiel mit dem anderen Spieler, um eine Entscheidung herbeizuführen?";
  @override
  String get newPlayer => "Neuer Spieler";

  @override
  String get premiumButtonRemoveAds => "Werbung entfernen";

  @override
  String get localNetworkWaitingForHost => "Warten auf den Gastgeber…";

  @override
  String get localNetworkHostLeftDescription =>
      "Der Gastgeber hat das Spiel verlassen: Der Tisch ist beendet. Du kannst über das Menü ein neues starten.";

  @override
  String get replayVoteChooseOption => "Wähle einen Modus für die Revanche";

  @override
  String replayVoteCountdown(int seconds) =>
      "Start in ${seconds}s mit den bereiten Spielern";

  @override
  String get replayVoteStartingSoon =>
      "Das Spiel startet mit den Spielern, die zugesagt haben";

  @override
  String get replayVoteWaitingForPlayers => "Warten auf die anderen Spieler";

  /* ROLL CALL */

  @override
  String get rollCallWaitingTitle => "Warten auf Spieler";

  @override
  String get rollCallReady => "Bereit";

  @override
  String get rollCallConnecting => "Verbinde…";

  @override
  String get rollCallYou => "Du";

  @override
  String rollCallVoteOpensIn(int s) => "Abstimmung über Abwesende in $s s";

  @override
  String rollCallStartsIn(int s) => "Spiel startet in $s s";

  @override
  String rollCallEjectVotes(int votes, int needed) =>
      "Abwesende entfernen: $votes/$needed";

  @override
  String get rollCallEject => "Entfernen";

  @override
  String get rollCallWait => "Warten";

  @override
  String get rollCallPlayerUnavailableTitle => "Spieler nicht verfügbar";

  @override
  String rollCallPlayerUnavailableDescription(int s) =>
      "Dein Gegner hat sich nicht innerhalb von $s Sekunden verbunden. Das Spiel wird ohne Strafe abgebrochen.";

  @override
  String get rollCallPlayersUnavailableTitle => "Spieler nicht verfügbar";

  @override
  String get rollCallPlayersUnavailableDescription =>
      "Kein anderer Spieler hat sich rechtzeitig verbunden. Das Spiel wird ohne Strafe abgebrochen.";

  @override
  String get rollCallCancelledTitle => "Spiel abgebrochen!";

  @override
  String get rollCallExcludedTitle => "Spiel ohne dich gestartet";

  @override
  String rollCallExcludedDuel(int s) =>
      "Dein Gegner hat $s Sekunden auf dich gewartet, ohne dass du angekommen bist. Du erhältst keine Strafe!";

  @override
  String get rollCallExcludedVote =>
      "Du warst noch nicht verbunden, daher haben die anderen Spieler abgestimmt, ohne dich zu beginnen. Du erhältst keine Strafe.";

  @override
  String rollCallExcludedCap(int s) =>
      "Du warst nach $s Sekunden immer noch nicht verbunden, daher hat das Spiel ohne dich begonnen. Du erhältst keine Strafe.";

  @override
  String get rollCallExcludedGrace =>
      "Du hast dich nicht rechtzeitig verbunden, daher hat das Spiel ohne dich begonnen. Du erhältst keine Strafe.";

  @override
  String get rollCallClose => "Schließen";

  @override
  String get rollCallPlayerLeftDescription =>
      "Dein Gegner hat das Spiel vor dem Start verlassen. Das Spiel wird ohne Strafe abgebrochen.";

  @override
  String get rollCallPlayersLeftDescription =>
      "Die anderen Spieler haben das Spiel vor dem Start verlassen. Das Spiel wird ohne Strafe abgebrochen.";

  @override
  String get rollCallSeatLostTitle => "Rückkehr nicht möglich";

  @override
  String get rollCallSeatLostDescription =>
      "Das Spiel ging während deiner Abwesenheit weiter: Dein Platz kann nicht mehr übernommen werden.";

  @override
  String get rollCallWaitingOpponentTitle => "Warten auf deinen Gegner";

  @override
  String rollCallCancelsIn(int s) => "Abbruch in $s s";

  @override
  String get rollCallAway => "Bereit · nicht in der App";

  @override
  String get rollCallLeave => "Verlassen";
}
