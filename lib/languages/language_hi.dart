import 'package:gamico/languages/languages.dart';

abstract class GamicoLanguageHi extends GamicoLanguages {
  @override
  String get globalMax => "अधिकतम";
  @override
  String get globalRefresh => "ताजगी";
  @override
  String get globalClose => "बंद करें";
  @override
  String get globalOK => "ठीक है";

  /* FRIEND */

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
  String get friendPageInvitationSent => "निमंत्रण भेजा गया!";

  @override
  String get friendPageFailedToSendInvitation => "निमंत्रण भेजने में विफल";

  @override
  String get friendPageUnknown => "अज्ञात";
  @override
  String get notificationInvitationBody => "आपको खेलने का निमंत्रण मिला है!";
  @override
  String notificationInvitationFrom(String name) =>
      "$name आपको खेलने के लिए आमंत्रित करते हैं!";

  /* ADVENTURE */

  @override
  String get adventureHelpTitle => "सहायता";
  @override
  String get adventureHelpDescription =>
      "आप किसी स्तर को चुन सकते हैं उस पर क्लिक करके। लेकिन अगर आपको खेलना अभी भी अच्छा नहीं आता, तो ट्यूटरियल का पालन करें!";
  @override
  String get adventureClose => "बंद करें";
  @override
  String get adventureFollow => "अनुसरण करें";

  @override
  String adventureChapterChapter(int chapter) => "अध्याय $chapter";

  /* COLLECTION */

  @override
  String collectionCardPopupFamily(String family) => "परिवार: $family";
  @override
  String get collectionCardPopupUpgrade => "अपग्रेड";
  @override
  String get collectionCardPopupRemove => "हटाना";
  @override
  String get collectionCardPopupUse => "उपयोग करें";
  @override
  String get collectionCardPopupAcquire => "प्राप्त करें";

  @override
  String get collectionCardSkillsAttack => "हमला";
  @override
  String get collectionCardSkillsSupport => "समर्थन";
  @override
  String get collectionCardSkillsResistance => "प्रतिरोध";
  @override
  String get collectionCardSkillsTheoreticalLife => "कृत्रिम जीवन";
  @override
  String get collectionCardSkillsTheoreticalSpeed => "कृत्रिम गति";
  @override
  String get collectionCardSkillsPower => "शक्ति";
  @override
  String get collectionCardSkillsConcreteLife => "वास्तविक जीवन";
  @override
  String get collectionCardSkillsConcreteSpeed => "वास्तविक गति";
  @override
  String get collectionCardSkillsConnections => "कनेक्शन्स";

  @override
  String collectionCardSquareLevel(int level) => "स्तर $level";

  @override
  String get collectionCardBlocked => "ब्लॉक किया गया";
  @override
  String collectionCardLevel(int level) => "स्तर $level";

  @override
  String get collectionContentDeck => "डेक";
  @override
  String get collectionContentUnlockedCards => "अनलॉक कार्ड्स";
  @override
  String get collectionContentRemainingCards => "शेष कार्ड";

  /* HOME */

  @override
  String get homeLanguagesTitle => "भाषाएँ";

  @override
  String get homeMultiplayerButtonShowcase =>
      "इस बटन से आप अन्य ऑनलाइन खिलाड़ियों के साथ खेल सकते हैं।";
  @override
  String get homeSingleplayerButtonShowcase =>
      "इस बटन से आप खेल की कृत्रिम बुद्धिमत्ता के साथ खेल सकते हैं।";
  @override
  String get homeNotificationsTitle => "सूचनाएँ";
  @override
  String get homeNotificationsDescription =>
      "अपने खेल अनुभव को बेहतर बनाने के लिए, आपको सूचनाएँ सक्रिय करनी होंगी! क्या आप सूचनाएँ सक्रिय करना चाहते हैं?";
  @override
  String get homeNotificationsAllow => "सक्रिय करें";
  @override
  String get homeNotificationsReminderTitle => "सूचनाएं सक्रिय करें";
  @override
  String get homeNotificationsReminderDescription =>
      "बेहतर गेमिंग अनुभव के लिए सूचनाएं महत्वपूर्ण हैं। क्या आप उन्हें अभी सक्रिय करना चाहते हैं?";
  @override
  String get homeUpdateTitle => "अपडेट उपलब्ध है!";
  @override
  String get homeUpdateForceDescription =>
      "नए संस्करण में कई त्रुटियों और समस्याओं को ठीक किया गया है। इसे तेजी से स्थापित करके इन सुधारों का लाभ उठाएं!";
  @override
  String get homeUpdateInstall => "स्थापित करें";

  @override
  String get homeAbout => "के बारे में";
  @override
  String homeAboutPopupShareText(String link) =>
      "मैंने एक बहुत रोचक रणनीतिक खेल खोज लिया है! इसे मुफ्त में $link पर डाउनलोड करें!";
  @override
  String get homeAboutPopupImplementation => "निर्वाचन";
  @override
  String get homeAboutPopupMusic => "संगीत";
  @override
  String get homeAboutPopupVersion => "संस्करण";
  @override
  String get homeAboutPopupRateGame => "खेल को मूल्यांकन दें";
  @override
  String get homeAboutPopupVisitWebstie => "Saki Hub पर जाएं";
  @override
  String get homeAboutPopupDiscoverApps => "मेरी ऐप्स देखें";

  @override
  String get homeCardPresentationShowcase =>
      "नए कार्ड खरीदने और आपके पास पहले से जो कार्ड हैं, उन्हें बेहतर बनाने के लिए इस मेनू का उपयोग करें।";
  @override
  String get homeCardPresentationShow => "सभी कार्ड देखें";

  @override
  String get homeGratificationPopupConnectionErrorTitle => "कनेक्शन त्रुटि!";
  @override
  String get homeGratificationPopupConnectionErrorDescription =>
      "कृपया अपने इंटरनेट कनेक्शन की जाँच करें। जब आप कनेक्ट हो जाएंगे, तो यह खुद अपडेट हो जाएगा!";
  @override
  String get homeGratificationPopupLoadingTitle => "पुरस्कार लोड हो रहे हैं!";
  @override
  String get homeGratificationPopupLoadingDescription =>
      "पुरस्कार थोड़ी ही देर में उपलब्ध होंगे। कृपया प्रतीक्षा करें!";
  @override
  String get homeGratificationPopupIncorrectTimestampTitle => "गलत समय चिह्न!";

  @override
  String get homeMultiplayerButtonConnectionErrorTitle => "कनेक्शन में समस्या!";
  @override
  String get homeMultiplayerButtonConnectionErrorDescription =>
      "आप इंटरनेट से जुड़े नहीं दिख रहे हैं। कृपया अपने इंटरनेट कनेक्शन की गुणवत्ता की जाँच करें और पुनः प्रयास करें!";
  @override
  String get homeMultiplayerButtonText => "मल्टी";

  @override
  String get homeProfilePopupBestTacticians => "सर्वश्रेष्ठ योद्धा";
  @override
  String get homeProfilePopupDescription =>
      "खिलाड़ी दो मापदंडों के आधार पर श्रेणीबद्ध किए जाते हैं: ऑनलाइन जीतों की संख्या और कौरी की अधिकतम संख्या!";
  @override
  String get homeProfilePopupBestCollectors => "सर्वश्रेष्ठ संग्रहक";
  @override
  String get homeProfilePopupCheckAchievements => "मेरी प्रशंसाएँ देखें";

  @override
  String get homeSingleplayerButtonText => "सिंगल";

  @override
  String get homeSpecialOfferPopupOfferDisabledDescription =>
      "विशेष प्रस्ताव हर 3 दिन में सक्रिय होते हैं और केवल 24 घंटे के लिए मान्य होते हैं। अगले को न छोड़ें!";
  @override
  String get homeSpecialOfferPopupOfferLoadedDescription =>
      "विशेष प्रस्ताव हर 3 दिन में सक्रिय होते हैं और केवल 24 घंटे के लिए मान्य होते हैं। तो, आप किस पर इंतजार कर रहे हैं?";
  @override
  String get homeSpecialOfferPopupOfferLoadingDescription =>
      "विशेष प्रस्ताव के संबंधित डेटा जल्द ही उपलब्ध होंगे। कृपया एक क्षण के लिए प्रतीक्षा करें!";
  @override
  String get homeSpecialOfferPopupErrorDescription =>
      "हम आपकी खरीद की पुष्टि नहीं कर सके। कृपया अपना भुगतान विधि और अपना इंटरनेट कनेक्शन जांचें!";
  @override
  String homeSpecialOfferPopupOffsetLoadedTitle(String? packTitle) =>
      "$packTitle !";
  @override
  String get homeSpecialOfferPopupOfferLoadingTitle =>
      "प्रस्ताव लोड हो रहा है!";
  @override
  String get homeSpecialOfferPopupErrorTitle => "लेन-देन रद्द हो गई!";
  @override
  String get homeSpecialOfferPopupClose => "बंद करें";
  @override
  String get homeSpecialOfferPopupTimestampTitle => "गलत समय चिन्ह!";
  @override
  String get homeSpecialOfferPopupLoadingDescription =>
      "विशेष प्रस्ताव से संबंधित डेटा जल्द ही उपलब्ध होंगे। कृपया एक क्षण के लिए प्रतीक्षा करें!";
  @override
  String get homeSpecialOfferPopupLoadingTitle => "प्रस्ताव लोड हो रहा है!";
  @override
  String get homeSpecialOfferPopupProblemClose => "बंद करें";
  @override
  String get homeSpecialOfferPopupProblemTitle => "कनेक्शन त्रुटि!";

  @override
  String get premiumPopupTitle => "प्रीमियम बनें!";
  @override
  String get premiumPopupDescription =>
      "सभी विज्ञापनों को हटाने के लिए पूर्ण संस्करण अनलॉक करें!";
  @override
  String get premiumPlayer => "प्रीमियम खिलाड़ी";
  @override
  String get nonPremiumPlayer => "नॉन-प्रीमियम खिलाड़ी";

  @override
  String get homeHelpBasicsA =>
      "नीले राजा का राज्य नारंगी राजा के खिलाफ होता है।";
  @override
  String get homeHelpBasicsB =>
      "दुश्मन राजा के रंग को बदलकर कोई भी जीत सकता है।";
  @override
  String get homeHelpBasicsC =>
      "निर्धारित समय में सबसे अधिक जीवन अंक रखकर कोई भी जीत सकता है।";

  @override
  String get homeHelpConnections1A =>
      "आप दो कार्डों को जोड़ने के लिए छू सकते हैं और खींच सकते हैं।";
  @override
  String get homeHelpConnections1B =>
      "आप दो कार्डों को जोड़ने के लिए टैप कर सकते हैं और टैप कर सकते हैं।";
  @override
  String get homeHelpConnections1C =>
      "आप एक कनेक्शन को एक उंगली से काट सकते हैं।";

  @override
  String get homeHelpConnections2A =>
      "कभी-कभी एक कनेक्शन खेलने की क्षमता को बाधित कर सकता है।";
  @override
  String get homeHelpConnections2B =>
      "दूसरे कार्ड से जुड़ने के लिए एक कार्ड के ऊपर कूदना संभाव नहीं है।";
  @override
  String get homeHelpConnections2C =>
      "एक कार्ड मैक्स पर वापस भेजता है जो भी गेंद वह प्राप्त करता है।";

  @override
  String get homeHelpCards1A => "लाल कार्ड हमला करने के लिए अच्छे हैं।";
  @override
  String get homeHelpCards1B => "ग्रे कार्ड सहने के लिए अच्छे हैं।";
  @override
  String get homeHelpCards1C => "हरित कार्ड समर्थन करने के लिए अच्छे हैं।";

  @override
  String get homeHelpCards2A => "भूरे कार्डों में संतुलित क्षमताएँ होती हैं।";
  @override
  String get homeHelpCards2B =>
      "पीले कार्डों के पास अन्य कार्डों पर विशेष प्रभाव होता है।";
  @override
  String get homeHelpCards2C =>
      "सफेद कार्ड वे कार्ड हैं जिन्हें हर हाल में सुरक्षित करना होता है।";

  @override
  String get homeHelpRestrictionsA =>
      "प्रत्येक कनेक्शन का काम आनीय होना चाहिए। यहां, यह अवानफलक है और इसलिए संभाव नहीं है।";
  @override
  String get homeHelpRestrictionsB =>
      "नष्टि कार्ड एक राजा को हमला नहीं कर सकता।";
  @override
  String get homeHelpRestrictionsC =>
      "एक राजा को क्लोन करने या स्थानांतरित करने संभाव नहीं है।";

  /* LOADING */

  @override
  String get loadingTitle => "कृपया प्रतीक्षा करें!";

  /* REMOTE */

  @override
  String get remoteConnexionProblemTitle => "कनेक्शन समस्या!";
  @override
  String get remoteConnexionProblemDescription =>
      "माफ करें! आपका इंटरनेट कनेक्शन टूट गया है। आपको खेल के हारे घोषित किया गया है!";
  @override
  String get remoteInvitationTitle => "आओ और खेलो!";
  @override
  String get remoteInvitationDescription => "आपका ऑनलाइन खेल शुरू हो गया है!";
  @override
  String get remoteMultiplayer => "मल्टीप्लेयर";

  @override
  String get remoteFailurePosterTitle => "कुछ त्रुटि हुई है!";
  @override
  String get remoteFailurePosterDescription =>
      "खोज के दौरान एक त्रुटि हुई है। अपना इंटरनेट कनेक्शन जाँचें और पुन: प्रयास करें!";

  @override
  String get remoteImpossibleGamePosterTitle => "पर्याप्त कौड़ी नहीं!";
  @override
  String remoteImpossibleGamePosterDescription(int cowries) =>
      "आपको ऑनलाइन खेलने के लिए कम से कम $cowries कौड़ी होनी चाहिए!";

  @override
  String get remoteNewGamePosterTitle => "एक नया खेल?";
  @override
  String get remoteNewGamePosterDescription =>
      "आप अपने स्तर को बढ़ाने के लिए दुनिया भर के खिलाड़ियों के साथ खेल सकते हैं!";

  @override
  String get remoteSearchPosterTitle => "खिलाड़ी खोज";
  @override
  String get remoteSearchPosterDescription =>
      "हम आपके साथ एक खेल खेलने के लिए दुनिया भर में खिलाड़ियों की खोज कर रहे हैं!";

  @override
  String get homeTranslationPopupDescription =>
      "इस खंड में आपको खेल की मुख्य भाषा का चयन करने की अनुमति है। स्वचालित रूप से सक्रिय करने के लिए किसी भाषा पर क्लिक करें!";

  /* कार्ड शीर्षक */

  @override
  String get lordLazyKingName => "आलसी राजा";
  @override
  String get lordLazyQueenName => "कमजोर रानी";
  @override
  String get lordLazyPrinceName => "अकेला प्रिंस";
  @override
  String get lordLazyPrincessName => "आंतरिक प्रिंसेस";
  @override
  String get lordCourageousKingName => "योग्य राजा";
  @override
  String get lordCourageousQueenName => "निडर रानी";
  @override
  String get lordCourageousPrinceName => "मजबूत प्रिंस";
  @override
  String get lordCourageousPrincessName => "समर्पित प्रिंसेस";
  @override
  String get normalOrdinaryCitizenName => "सामान्य नागरिक";
  @override
  String get normalAttackerDefenderName => "सैन्य गार्ड";
  @override
  String get normalAttackerHealerName => "सैन्य चिकित्सक";
  @override
  String get normalDefenderHealerName => "गार्ड चिकित्सक";
  @override
  String get attacker2AName => "फ्लू";
  @override
  String get attacker2BName => "सूरज";
  @override
  String get attacker2CName => "स्पार्क";
  @override
  String get attacker4AName => "व्हरलविंड";
  @override
  String get attacker4BName => "मच्छर";
  @override
  String get attacker4CName => "साइक्लोन";
  @override
  String get defender2AName => "पत्थर";
  @override
  String get defender2BName => "कंकड़";
  @override
  String get defender2CName => "रैम्पार्ट";
  @override
  String get defender4AName => "बीम";
  @override
  String get defender4BName => "बालकनी";
  @override
  String get defender4CName => "खिड़की";
  @override
  String get healer2AName => "घास";
  @override
  String get healer2BName => "फूल";
  @override
  String get healer2CName => "पत्ती";
  @override
  String get healer4AName => "छज्जा";
  @override
  String get healer4BName => "बैंडेज";
  @override
  String get healer4CName => "पेड़";
  @override
  String get specialExpansionName => "विस्तार";
  @override
  String get specialCompressionName => "संपीड़न";
  @override
  String get specialDecelerationName => "धीमा होना";
  @override
  String get specialAccelerationName => "त्वरण";
  @override
  String get specialAttackIncreaseName => "वीरता";
  @override
  String get specialAttackDecreaseName => "कायरता";
  @override
  String get specialResistanceIncreaseName => "मजबूतीकरण";
  @override
  String get specialResistanceDecreaseName => "कमजोरीकरण";
  @override
  String get specialSupportIncreaseName => "उदारता";
  @override
  String get specialSupportDecreaseName => "व्यक्तिगतता";
  @override
  String get specialCloningName => "क्लोनिंग";
  @override
  String get specialCancellationName => "रद्दीकरण";
  @override
  String get specialRefrigerationName => "प्रशीतन";
  @override
  String get specialAspiratorName => "अबिस";
  @override
  String get specialSubstractionName => "घटाव";
  @override
  String get specialDivisionName => "विभाजन";
  @override
  String get specialDeflagrationName => "डीफ्लेग्रेशन";
  @override
  String get specialParalysisName => "पैरालिसिस";
  @override
  String get specialInvulnerabilityName => "अक्षयता";
  @override
  String get specialVortexName => "घूर्णन";

  /* कार्ड विवरण */

  @override
  String get lordLazyKingDescription =>
      "यह एकमात्र साम्राज्य राजा है जो न तो हमला कर सकता है और न बचा सकता है। लेकिन यह एक संतुलित राजा है जिसमें कोई विशेष कमजोरी नहीं है!";
  @override
  String get lordLazyQueenDescription =>
      "यह एक उम्र के बढ़ते हुए व्यक्ति के लिए बहुत अच्छा है जो हमला करने और अपने अनुयायियों का समर्थन करने के लिए माहिर है। हालांकि, इसकी प्रतिरक्षा इच्छाशक्ति छोड़ देती है!";
  @override
  String get lordLazyPrinceDescription =>
      "यह एक युवक है जो हमला करने और हमले का सामना करने के लिए माहिर है। हालांकि, यह अपने अनुयायियों का समर्थन करने में अच्छा नहीं है!";
  @override
  String get lordLazyPrincessDescription =>
      "यह एक युवती है जो हमले का सामना करने और अपने अनुयायियों का समर्थन करने के लिए माहिर है। हालांकि, यह हमले में मजबूत नहीं है!";
  @override
  String get lordCourageousKingDescription =>
      "यह एक संतुलित राजा है जिसमें कोई विशेष कमजोरी नहीं है। हालांकि, इसके पास सामान्य से दोगुना जीवन है!";
  @override
  String get lordCourageousQueenDescription =>
      "यह एक उम्र के बढ़ते हुए व्यक्ति के लिए हमला करने के लिए बहुत माहिर है। लेकिन इसके अन्य क्षेत्रों में बढ़ नहीं है!";
  @override
  String get lordCourageousPrinceDescription =>
      "यह एक युवक है जो हमले का सामना करने के लिए बहुत माहिर है। लेकिन इसके अन्य क्षेत्रों में बढ़ नहीं है!";
  @override
  String get lordCourageousPrincessDescription =>
      "यह एक युवती है जो अपने अनुयायियों का समर्थन करने के लिए बहुत माहिर है। लेकिन इसके अन्य क्षेत्रों में बढ़ नहीं है!";
  @override
  String get normalOrdinaryCitizenDescription =>
      "यह खेल का सबसे संतुलित कार्ड है। इसमें कोई विशेष ताक़त और कमजोरी नहीं है, लेकिन यह एक विश्वासपूर्ण साथी है!";
  @override
  String get normalAttackerDefenderDescription =>
      "इसका नाम ही बताता है कि यह हमला करने के लिए और अपने दुश्मनों के हमलों का सामना करने के लिए माहिर है!";
  @override
  String get normalAttackerHealerDescription =>
      "इसका नाम ही बताता है कि यह हमला करने के लिए और अपने साथियों का समर्थन करने के लिए माहिर है!";
  @override
  String get normalDefenderHealerDescription =>
      "इसका नाम ही बताता है कि यह अपने साथियों का समर्थन करने के लिए और अपने दुश्मनों के हमलों का सामना करने के लिए माहिर है!";
  @override
  String get attacker2ADescription =>
      "यह कार्ड अपने दुश्मनों को एक सामान्य कार्ड की तुलना में 2 गुना अधिक क्षति पहुंचाता है, लेकिन अपने साथियों का समर्थन करने में अच्छा नहीं है!";
  @override
  String get attacker2BDescription =>
      "यह कार्ड अपने दुश्मनों को एक सामान्य कार्ड की तुलना में 2 गुना अधिक क्षति पहुंचाता है, लेकिन अपने दुश्मनों के हमलों का सामना करने में अच्छा नहीं है!";
  @override
  String get attacker2CDescription =>
      "यह कार्ड अपने दुश्मनों को एक सामान्य कार्ड की तुलना में 2 गुना अधिक क्षति पहुंचाता है, लेकिन यह एक सामान्य कार्ड की तुलना में 2 गुना धीमा है!";
  @override
  String get attacker4ADescription =>
      "यह कार्ड अपने दुश्मनों को एक सामान्य कार्ड की तुलना में 4 गुना अधिक क्षति पहुंचाता है, लेकिन अपने साथियों का समर्थन करने में वाकई खराब है!";
  @override
  String get attacker4BDescription =>
      "यह कार्ड अपने दुश्मनों को एक सामान्य कार्ड की तुलना में 4 गुना अधिक क्षति पहुंचाता है, लेकिन अपने दुश्मनों के हमलों का सामना करने में वाकई खराब है!";
  @override
  String get attacker4CDescription =>
      "यह कार्ड अपने दुश्मनों को एक सामान्य कार्ड की तुलना में 4 गुना अधिक क्षति पहुंचाता है, लेकिन यह अपने अन्य क्षेत्रों में वाकई बढ़ नहीं है!";
  @override
  String get defender2ADescription =>
      "यह कार्ड एक सामान्य कार्ड की तुलना में दोगुनी प्रतिरक्षा प्राप्त करता है, लेकिन अपने दुश्मनों को हमला करने में अच्छा नहीं है!";
  @override
  String get defender2BDescription =>
      "यह कार्ड एक सामान्य कार्ड की तुलना में दोगुनी प्रतिरक्षा प्राप्त करता है, लेकिन अपने साथियों का समर्थन करने में अच्छा नहीं है!";
  @override
  String get defender2CDescription =>
      "यह कार्ड एक सामान्य कार्ड की तुलना में दोगुनी प्रतिरक्षा प्राप्त करता है, लेकिन यह एक सामान्य कार्ड की तुलना में दोगुनी धीमा है!";
  @override
  String get defender4ADescription =>
      "यह कार्ड एक सामान्य कार्ड की तुलना में चारगुनी प्रतिरक्षा प्राप्त करता है, लेकिन अपने दुश्मनों को हमला करने में वाकई खराब है!";
  @override
  String get defender4BDescription =>
      "यह कार्ड एक सामान्य कार्ड की तुलना में चारगुनी प्रतिरक्षा प्राप्त करता है, लेकिन अपने साथियों का समर्थन करने में वाकई खराब है!";
  @override
  String get defender4CDescription =>
      "यह कार्ड एक सामान्य कार्ड की तुलना में चारगुनी प्रतिरक्षा प्राप्त करता है, लेकिन यह अपने अन्य क्षेत्रों में वाकई बढ़ नहीं है!";
  @override
  String get healer2ADescription =>
      "यह कार्ड अपने साथियों को एक सामान्य कार्ड की तुलना में 2 गुना तेजी से ठीक करता है, लेकिन अपने दुश्मनों को हमला करने में अच्छा नहीं है!";
  @override
  String get healer2BDescription =>
      "यह कार्ड अपने साथियों को एक सामान्य कार्ड की तुलना में 2 गुना तेजी से ठीक करता है, लेकिन अपने दुश्मनों के हमलों का सामना करने में अच्छा नहीं है!";
  @override
  String get healer2CDescription =>
      "यह कार्ड अपने साथियों को एक सामान्य कार्ड की तुलना में 2 गुना तेजी से ठीक करता है, लेकिन यह एक सामान्य कार्ड की तुलना में 2 गुना धीमा है!";
  @override
  String get healer4ADescription =>
      "यह कार्ड अपने साथियों को एक सामान्य कार्ड की तुलना में 4 गुना तेजी से ठीक करता है, लेकिन अपने दुश्मनों को हमला करने में वाकई खराब है!";
  @override
  String get healer4BDescription =>
      "यह कार्ड अपने साथियों को एक सामान्य कार्ड की तुलना में 4 गुना तेजी से ठीक करता है, लेकिन अपने दुश्मनों के हमलों का सामना करने में वाकई खराब है!";
  @override
  String get healer4CDescription =>
      "यह कार्ड अपने साथियों को एक सामान्य कार्ड की तुलना में 4 गुना तेजी से ठीक करता है, लेकिन इसके अन्य क्षेत्रों में बढ़ नहीं है!";
  @override
  String get specialExpansionDescription =>
      "यह कार्ड उस कार्ड के अधिकारियों के लिए हमले के अनुभाग को एक बढ़ देता है; चाहे वह एक साथी हो या न हो!";
  @override
  String get specialCompressionDescription =>
      "यह कार्ड उस कार्ड के अधिकारियों के लिए हमले के अनुभाग को एक घटा देता है; चाहे वह एक साथी हो या न हो!";
  @override
  String get specialDecelerationDescription =>
      "यह कार्ड अपने लक्ष्यों को उनकी गति को आधे से घटा करके धीमा करता है। चाहे वह एक साथी हो या दुश्मन हो!";
  @override
  String get specialAccelerationDescription =>
      "यह कार्ड अपने लक्ष्यों को उनकी गति को दोगुना करके तेज करता है। चाहे वह एक साथी हो या दुश्मन हो!";
  @override
  String get specialAttackIncreaseDescription =>
      "यह कार्ड अपने लक्ष्यों को उनके हमले को दोगुना करके बेहतर बनाता है। चाहे वह एक साथी हो या दुश्मन हो!";
  @override
  String get specialAttackDecreaseDescription =>
      "यह कार्ड अपने लक्ष्यों को उनके हमले को आधे से घटा करके कम करता है। चाहे वह एक साथी हो या दुश्मन हो!";
  @override
  String get specialResistanceIncreaseDescription =>
      "यह कार्ड अपने लक्ष्यों को उनकी प्रतिरक्षा को दोगुना करके बेहतर बनाता है। चाहे वह एक साथी हो या दुश्मन हो!";
  @override
  String get specialResistanceDecreaseDescription =>
      "यह कार्ड अपने लक्ष्यों को उनकी प्रतिरक्षा को आधे से घटा करके कम करता है। चाहे वह एक साथी हो या दुश्मन हो!";
  @override
  String get specialSupportIncreaseDescription =>
      "यह कार्ड अपने लक्ष्यों को उनकी समर्थन को दोगुना करके बेहतर बनाता है। चाहे वह एक साथी हो या दुश्मन हो!";
  @override
  String get specialSupportDecreaseDescription =>
      "यह कार्ड अपने लक्ष्यों को उनकी समर्थन को आधे से घटा करके कम करता है। चाहे वह एक साथी हो या दुश्मन हो!";
  @override
  String get specialCloningDescription =>
      "यह कार्ड सीमित जीवन के लिए होता है और खेल की खेल कार्ड पर दी गई सभी गुणों और क्षमताओं को उस कार्ड की एक निश्चित स्थान पर क्लोन करने के लिए उपयोगी होता है!";
  @override
  String get specialCancellationDescription =>
      "यह कार्ड अपने लक्ष्यों के विशेष प्रभाव को रद्द करता है; चाहे वह एक साथी हो या न हो। लेकिन इसका प्रभाव फिर से रद्द नहीं किया जा सकता!";
  @override
  String get specialRefrigerationDescription =>
      "यह कार्ड अपने लक्ष्यों को उनके धारक द्वारा संशोधित नहीं होने देता है। चाहे वह एक साथी हो या न हो!";
  @override
  String get specialAspiratorDescription =>
      "यह कार्ड खेल में अपनी वर्तमान स्तर के हिसाब से एक स्थान पर खड़ा कार्ड की एक चौक पर होने वाली समय-सीमित कार्डों को हटा देता है!";
  @override
  String get specialSubstractionDescription =>
      "यह कार्ड अपनी लाइन और स्तम्भ पर खड़े कार्ड की वर्तमान स्तर के हिसाब से समय-सीमित कार्डों को हटा देता है!";
  @override
  String get specialDivisionDescription =>
      "यह कार्ड अपनी बिजलियों पर खड़े कार्ड की वर्तमान स्तर के हिसाब से समय-सीमित कार्डों को हटा देता है!";
  @override
  String get specialDeflagrationDescription =>
      "यह कार्ड अपनी लाइन, स्तम्भ और बिजलियों पर खड़े कार्ड की वर्तमान स्तर के हिसाब से समय-सीमित कार्डों को हटा देता है!";
  @override
  String get specialParalysisDescription =>
      "यह सीमित जीवन के लिए होने वाली कार्ड होती है और अपने लक्ष्यों को हमला करने या स्वरक्षा करने से रोकती है। चाहे वह एक साथी हो या न हो!";
  @override
  String get specialInvulnerabilityDescription =>
      "यह सीमित जीवन के लिए होने वाली कार्ड होती है और अपने लक्ष्यों को अपने स्तर के हिसाब से अविकारी बनाती है!";
  @override
  String get specialVortexDescription =>
      "यह सीमित जीवन के लिए होने वाली कार्ड होती है और एक चौक पर खड़े कार्ड को उसके स्थान के साथ आकस्मिक रूप से बदल देती है!";

  /* गेम */

  @override
  String get gameAbandonmentButtonDescription =>
      "आपके प्रतिद्वंद्वी को स्वच्छंद घोषित कर दिया जाएगा! क्या आप वाकई इस खेल को छोड़ना चाहते हैं?";
  @override
  String get gameAbandonmentButtonAbandon => "त्याग";
  @override
  String get gameAbandonmentButtonTitle => "त्याग";

  @override
  String get gameBottomButtonDisplayResult => "परिणाम दिखाएं";

  @override
  String get gameCardsSummaryPlay => "खेलें";
  @override
  String get gameCardsSummaryRemember => "याद रखें!";

  @override
  String get gameInitialTutorialPopupPlay => "खेलें";

  @override
  String get gamePassButtonPopupPass => "छोड़ें";
  @override
  String get gamePassButtonPopupDescription =>
      "जारी रखने से पहले, सुनिश्चित हो जाएं कि आप खेल के नियमों के अच्छे से जानते हैं। क्या आप वाकई ट्यूटरियल को छोड़ना चाहते हैं?";
  @override
  String get gamePassButtonPopupTitle => "ट्यूटरियल को छोड़ें";

  @override
  String get adventureVictoryPossibleToPlayNextLevelDescription =>
      "आपकी जीत के लिए बधाई हो! आपने सफलतापूर्वक इस स्तर को पार किया है। आप अगले स्तर पर जा सकते हैं!";
  @override
  String get adventureVictoryImpossibleToPlayNextLevelDescription =>
      "आपके पास अगले स्तर को खेलने के लिए पर्याप्त काउरी नहीं है! 1 काउरी प्राप्त करने के लिए एक विज्ञापन देखें!";
  @override
  String get adventureVictoryGameFinishedDescription =>
      "आपने 'सॉलिटेयर' मोड को पूरा किया है!\nदुनिया भर के खिलाड़ी ऑनलाइन गेमिंग यूनिवर्स में आपका स्वागत कर रहे हैं!";
  @override
  String get adventureDefeatPossibleToPlayAgainDescription =>
      "अपनी हार के लिए क्षमा करें! हार के बावजूद आप फिर से खेलकर हमेशा सुधार सकते हैं!";
  @override
  String get adventureDefeatImpossibleToPlayAgainDescription =>
      "दुखद तौर पर, आपके पास फिर से खेलने के लिए पर्याप्त काउरी नहीं है! 1 काउरी प्राप्त करने के लिए एक विज्ञापन देखें!";
  @override
  String get adventureDefeatPossibleToPlayNextLevelDescription =>
      "अपनी हार के लिए क्षमा करें! फिर भी, आपने इस स्तर को पार किया है और अगले स्तर पर जा सकते हैं!";
  @override
  String get adventureDefeatImpossibleToPlayNextLevelDescription =>
      "आपके पास अगले स्तर को खेलने के लिए पर्याप्त काउरी नहीं है! 1 काउरी प्राप्त करने के लिए एक विज्ञापन देखें!";
  @override
  String get adventureGameAlreadyFinishedDescription =>
      "अपनी हार के लिए क्षमा करें! बिल्कुल ही, आपने इस खेल मोड के सभी स्तरों को पूरा किया है!";
  @override
  String get remoteDefeatDescription =>
      "अपनी हार के लिए क्षमा करें! डिस्करेज़ न हों: आप अधिक खेलकर सुधार सकते हैं!";
  @override
  String get remoteVictoryDescription =>
      "आपकी जीत के लिए बधाई हो! आप ऑनलाइन खेलकर अपने स्तर को और भी बेहतर बना सकते हैं!";
  @override
  String get remotePossibleToPlayAgainDescription =>
      "दुखद तौर पर, आपके पास फिर से खेलने के लिए पर्याप्त काउरी नहीं है! 1 काउरी प्राप्त करने के लिए एक विज्ञापन देखें!";
  @override
  String get remoteOpponentUnavailableDescription =>
      "दूसरे खिलाड़ी के पास एक खेलने के लिए अब उपलब्ध नहीं है। लेकिन आपके पास फिर भी कई अन्य विकल्प हैं!";
  @override
  String get externalNeedinessDescription =>
      "दूसरे खिलाड़ी के पास खेलने के लिए अब पर्याप्त काउरी नहीं है। लेकिन आप उन्हें प्रतीक्षा कर सकते हैं या एक नया खेल शुरू कर सकते हैं!";
  @override
  String get internalNeedinessTitle => "पर्याप्त काउरी नहीं!";
  @override
  String get replayImpossibleDescription =>
      "दूसरे खिलाड़ी अब कनेक्ट नहीं है। लेकिन आप फिर से किसी अन्य खिलाड़ी के साथ एक नया खेल शुरू कर सकते हैं!";
  @override
  String get invitationWithdrawalDescription =>
      "दूसरे खिलाड़ी ने अपनी पुनः खेलने की आमंत्रण को वापस ले लिया है। लेकिन आप फिर से एक नया खेल शुरू कर सकते हैं!";
  @override
  String get invitationRejectionDescription =>
      "दुखद तौर पर, आपके आमंत्रण को अस्वीकृत किया गया है। लेकिन आप फिर से एक नया खेल शुरू कर सकते हैं!";
  @override
  String get invitationAcceptationDescription =>
      "आप दोनों पुनः खेलने के लिए तैयार हैं। थोड़ी धैर्य रखें! खेल कुछ ही क्षणों में फिर से शुरू होगा!";
  @override
  String get externalInvitationReplayImpossibleDescription =>
      "आपके पास एक आमंत्रण स्वीकार करने के लिए पर्याप्त काउरी नहीं है! 1 काउरी प्राप्त करने के लिए एक विज्ञापन देखें!";
  @override
  String get externalInvitationReplayPossibleDescription =>
      "दूसरा खिलाड़ी आपके साथ एक नया खेल खेलना चाहता है! क्या आप उनकी आमंत्रण को स्वीकार करना चाहेंगे या इसे अस्वीकार करेंगे?";
  @override
  String get internalInvitationDescription =>
      "दूसरे खिलाड़ी को आपके पुनः खेलने की आमंत्रण के बारे में एक सूचना मिली है। वे इसे स्वीकार या अस्वीकार कर सकते हैं!";
  @override
  String get gamePopupNewGame => "नया\nखेल";
  @override
  String get gamePopupNextLevel => "अगला\nस्तर";
  @override
  String get gamePopupReplay => "पुनः खेलें";
  @override
  String get globalExit => "बाहर जाएं";
  @override
  String get globalAccept => "स्वीकार करें";
  @override
  String get globalReject => "अस्वीकार करें";
  @override
  String get globalCancel => "रद्द करें";
  @override
  String get normalDefeatTitle => "आप हार गए!";
  @override
  String get defeatByAbandonment => "त्याग के द्वारा हार!";
  @override
  String get normalVictoryTitle => "आप जीते!";
  @override
  String get victoryByAbandonment => "त्याग के द्वारा जीत!";
  @override
  String get externalNeedinessTitle => "ओहो!";
  @override
  String get internalNeedinessDescription =>
      "दूसरे खिलाड़ी को आपके साथ एक और खेल खेलना है, लेकिन आपके पास खेलने के लिए पर्याप्त काउरी नहीं है!";
  @override
  String get replayImpossibleTitle => "पुनः खेल नामुमकिन!";
  @override
  String get invitationWithdrawalTitle => "आमंत्रण वापस लिया गया!";
  @override
  String get invitationRejectionTitle => "आमंत्रण अस्वीकृत!";
  @override
  String get invitationAcceptationTitle => "गेम लोड हो रहा है!";
  @override
  String get externalInvitationTitle => "क्या आप पुनः खेलना चाहेंगे?";
  @override
  String get internalInvitationTitle => "थोड़ी धैर्य!";
  @override
  String get gameProfilePosterClose => "बंद करें";
  @override
  String get gameProfilePosterDeck => "डेक";
  @override
  String get gameProfilePosterCards => "कार्ड्स";
  @override
  String get gameProfilePosterCrowns => "मुकुट";

  @override
  List<String> get names => [
    "अलेक्ज",
    "सोनिया",
    "बासिल",
    "योएन",
    "इसक",
    "रोबर्टो",
    "तांगुय",
    "जेसे",
    "ऐलिस",
    "क्रिस्टियन",
    "फेबिएन",
    "मीमी",
    "मॉरीस",
    "लूसी",
    "जोसियान",
    "वियाने",
    "अनिसेट",
    "एडलाइन",
    "बेनेडिक्ट",
    "रोज़ा",
    "डेबोराह",
    "एंज",
    "क्लेमेंस",
    "औदे",
    "माइरेल",
    "सेसील",
    "लॉरेंस",
    "मैरियस",
    "नाडेज",
    "सिल्वी",
    "क्लारिस",
    "क्लॉड",
    "क्लोटिल्ड",
    "एंड्रे",
    "क्रिस्टीन",
    "लियोपोल्ड",
    "जीनवीव",
    "एस्टर",
    "फ्लोर",
    "एंजेल",
    "जेनिफर",
    "ह्यूग",
    "ह्यूगेट",
    "ओलिवियर",
    "जूडिथ",
    "मार्टीन",
    "रेचल",
    "एंट्वान",
    "अल्फ्रेड",
    "मार्थ",
    "बॉब",
  ];

  @override
  String gameTileNameLevel(int level) => "स्तर $level";
  @override
  String get gameTopBarTutorialText => "ट्यूटरियल";

  @override
  String get gametutorialCongratulationsPopupPlay => "खेलें";
  @override
  String get gametutorialCongratulationsPopupTitle => "बधाई हो!";
  @override
  String get gameTutorialCongratulationsPopupUnclearDescription =>
      "आपने इस पाठ को सफलतापूर्वक पूरा किया है! लेकिन अगर अभी भी कोई अंधेरे क्षेत्र हैं, तो आप फिर से शुरू कर सकते हैं!";

  @override
  String get gameTutorialPopupTitle => "सहायता";

  @override
  String get gameTutorialProgressPopupNextLesson => "अगला पाठ";
  @override
  String get gameTutorialProgressPopupTitle => "बधाई हो!";

  /* USER CUBIT */

  @override
  String get referralNotificationTitle => "+50 कौरीस!";

  @override
  String referralNotificationBody(String name) =>
      "बधाई हो! $name के पंजीकरण के लिए आपने 50 कौरीस प्राप्त किए हैं।";

  /* NOTIFICATION */

  @override
  String get notificationMissBody =>
      "हमने कुछ दिनों से आपको नहीं देखा है। मनोरंजन करते समय अपने मस्तिष्क का व्यायाम करें!";
  @override
  String get notificationMissTitle => "हमें आपकी याद आती है!";
  @override
  String get notificationGiftBody =>
      "हर घंटे, आपको मुफ्त में कौरीस मिलती हैं! अपना गिफ्ट दावतने आइए!";
  @override
  String get notificationGiftTitle => "अपना गिफ्ट न चोरें!";

  /* GLOBAL */

  @override
  String get kingConquestInstruction =>
      "खेल जीतने के लिए राजा के रंग के बदलने का इंतजार करें।";
  @override
  String get invalidDeckTitle => "अवैध मैजेक!";
  @override
  String get invalidDeckDescription =>
      "आपका मौजूदा मैजेक अवैध है। कृपया इसे ठीक करें या नए खेल शुरू करने से पहले दूसरा चुनें!";

  @override
  String get authenticationPopupAuthenticationErrorDescription =>
      "हम आपके खेल खाते से कनेक्ट नहीं हो सके। कृपया अपनी इंटरनेट कनेक्शन की जांच करें और पुनः प्रयास करें!";
  @override
  String get authenticationPopupAuthenticationErrorTitle =>
      "प्रमाणीकरण त्रुटि!";

  @override
  String get globalRetry => "पुनः प्रयास करें";

  @override
  String get authenticationPopupRequiredAuthentication =>
      "प्रमाणीकरण आवश्यक है!";
  @override
  String get authenticationPopupLoadingAuthentication =>
      "प्रमाणीकरण हो रहा है!";

  @override
  String authenticationPopupDescription(String account) =>
      "हम आपको खेल में आपकी प्रगति सहेजने के लिए आपके $account खाते से कनेक्ट करेंगे!";

  @override
  String get globalAppleGameCenter => "एप्पल गेम सेंटर";

  @override
  String get globalGooglePlay => "गूगल प्ले गेम्स";

  @override
  String cardOptionButtonPopupDeckN(int index) => "मैजेक $index";

  @override
  String get cardOptionButtonDescription =>
      "आपके पास 3 मैजेक तक हो सकते हैं। यहां अपने खेल मैजेक की जाँच करें और चुनें।";

  @override
  String get globalValidate => "मान्य करें";

  @override
  String get blockedAccountContactSakiHub => "साकी हब से संपर्क करें";

  @override
  String get blockedAccountDescription =>
      "खाते की ब्लॉकिंग गैरकानूनी या संदेहात्मक गतिविधि के परिणामस्वरूप होती है। यदि यह ब्लॉकिंग कोई त्रुटि है, तो कृपया हमसे संपर्क करें!";
  @override
  String get blockedAccountTitle => "आपका खाता ब्लॉक किया गया है!";

  @override
  String get progressOptionButtonNotAuthenticationDescription =>
      "कौरीस आपके खेलने की स्वतंत्रता को बढ़ाते हैं, लेकिन आपको उन्हें उपयोग करने के लिए लॉग इन होना चाहिए!";
  @override
  String get progressOptionButtonNotAuthenticatedTitle =>
      "आपके पास कौरीस नहीं हैं!";
  @override
  String get progressOptionButtonShowcase =>
      "कौरीस, गेम की मुद्रा, कार्ड खरीदने और खेलने के लिए आवश्यक है। यहां अपने कौरीस प्रबंधित करें।";

  @override
  String get globalAd => "विज्ञापन";

  @override
  String get globalConnect => "कनेक्ट करें";

  /* FAMILIES */

  @override
  String get attackerFamilyName => "हमलावर";
  @override
  String get attackerFamilyShortDescription => "लाल कार्ड: हमले में मजबूत";
  @override
  String get attackerFamilyLongDescription =>
      "ये कार्ड अपने दुश्मनों पर सबसे ज्यादा क्षति पहुँचाते हैं। हालांकि वे अन्य क्षेत्रों में उत्कृष्ट नहीं हैं!";

  @override
  String get defenderFamilyName => "रक्षक";
  @override
  String get defenderFamilyShortDescription => "ग्रे कार्ड: रक्षा में मजबूत";
  @override
  String get defenderFamilyLongDescription =>
      "इन कार्डों की सर्वाधिक रक्षा मूल्य होती है। हालांकि वे अन्य क्षेत्रों में उत्कृष्ट नहीं हैं!";

  @override
  String get healerFamilyName => "चिकित्सक";
  @override
  String get healerFamilyShortDescription => "हरे कार्ड: चिकित्सा में मजबूत";
  @override
  String get healerFamilyLongDescription =>
      "ये कार्ड अपने साथीदारों का सर्वश्रेष्ठ इलाज करते हैं। हालांकि वे अन्य क्षेत्रों में उत्कृष्ट नहीं हैं!";

  @override
  String get lordFamilyName => "राजा";
  @override
  String get lordFamilyShortDescription => "राजा: हर जिम्मेदारी की आवश्यकता है";
  @override
  String get lordFamilyLongDescription =>
      "ये वो कार्ड हैं जिन्हें खेल में हर जिम्मेदारी की आवश्यकता है: आप हार जाते हैं अगर आपके राजा का रंग बदल जाता है!";

  @override
  String get normalFamilyName => "सामान्य";
  @override
  String get normalFamilyShortDescription => "भूरे कार्ड: संतुलित क्षमताएँ";
  @override
  String get normalFamilyLongDescription =>
      "सामान्य खेल में सबसे संतुलित हैं। वे बहुत विविध हैं और खेल में वास्तविक फायदा प्रदान करते हैं!";

  @override
  String get specialFamilyName => "विशेष";
  @override
  String get specialFamilyShortDescription =>
      "पीले कार्ड: दूसरों पर विशेष प्रभाव";
  @override
  String get specialFamilyLongDescription =>
      "इन कार्डों के दूसरों पर प्रभाव होते हैं। उनके प्रभाव मुख्य रूप से उनके स्वभाव पर निर्भर करते हैं!";

  /* LESSONS */

  @override
  String get basicsLessonTitle => "पाठ 1/3: मूल खेल";
  @override
  String get globalLesson => "पाठ";
  @override
  String get basicsLessonSuffix => "मूल खेल";
  @override
  String get basicsLessonWinningMessage =>
      "आपको जीत की हार्दिक शुभकामनाएँ! खेल के कार्डों की भूमिका के बारे में जानने के लिए जल्द ही अगले पाठ पर जाएं!";

  @override
  String get normalLessonTitle => "पाठ 2/3: कार्ड की भूमिका";
  @override
  String get normalLessonSuffix => "कार्ड की भूमिका";
  @override
  String get specialLessonSuffix => "विशेष कार्ड";
  @override
  String get normalLessonDescription =>
      "लाल कार्ड हमला करते हैं, हरा समर्थन करते हैं, पीला संरक्षण करता है, और नीला समान करता है!";
  @override
  String get normalLessonWinningMessage =>
      "आपको जीत की हार्दिक शुभकामनाएँ! टाइल्स को नहीं रोकने के लिए जल्द ही अगले पाठ पर जाएं!";

  @override
  String get specialLessonTitle => "पाठ 3/3: विशेष कार्ड";
  @override
  String get specialLessonDescription =>
      "पीले कार्ड का खास प्रभाव होता है। एक विशेष कार्ड का प्रभाव मुख्य रूप से उसकी प्राकृतिक विशेषताओं पर निर्भर करता है!";

  /* MESSAGES */

  @override
  String get awesomeMessage => "अद्वितीय";
  @override
  String get congratulationsMessage => "बधाई हो";
  @override
  String get excellentMessage => "उत्कृष्ट";
  @override
  String get goodMessage => "अच्छा";
  @override
  String get greatMessage => "शानदार";
  @override
  String get magnificentMessage => "अद्भुत";
  @override
  String get masterfulMessage => "माहिर";

  /* TUTORIALS INSTRUCTIONS */

  @override
  String get basicsPlaceTileInstruction =>
      "खेल के माध्यम से एक कार्ड प्राप्त करने के लिए एक कार्ड प्राप्त करें जो आपके सामने है।";
  @override
  String get basicsConnectCenterTileInstruction =>
      "हरा कार्ड पर जाने के लिए एक कार्ड को स्थानांतरित करें और हरे कार्ड पर स्थानांतरित करें!";
  @override
  String get basicsConquerCenterTileInstruction =>
      "हरा कार्ड का रंग बदलने के लिए एक संयोजन होना चाहिए और इसके पॉइंट 0 होने चाहिए!";
  @override
  String get basicsCutPathInstruction =>
      "दो कार्डों के बीच के कनेक्शन को काटने के लिए जैसे कि दिशा में दिखाया गया है, इस पर क्लिक करें!";
  @override
  String get basicsConnectKingInstruction =>
      "अपने राजा कार्ड को कनेक्ट करने के लिए, उस कार्ड को स्थानांतरित करें और उसे राजा कार्ड पर स्थानांतरित करें!";
  String get basicsConquerKingInstruction =>
      "राजा कार्ड का रंग बदलने के लिए एक संयोजन होना चाहिए और इसके पॉइंट 0 होने चाहिए!";
  @override
  String get normalPlaceOrdinaryCitizenInstruction =>
      "खेल के माध्यम से एक सामान्य नागरिक कार्ड प्राप्त करने के लिए एक कार्ड प्राप्त करें जो आपके सामने है!";
  @override
  String get normalConnectOrdinaryCitizenInstruction =>
      "प्रातिष्ठानिक कर्ड पर कनेक्ट करने के लिए, मूल कार्ड से लक्ष्य किया हुआ कार्ड एक कार्ड को स्थानांतरित करें!";
  @override
  String get normalPlaceHealerInstruction =>
      "अपने राजा कार्ड को हमला किया गया है और उसे तुरंत चिकित्सा की आवश्यकता है! एक कार्ड को स्थानांतरित करने के लिए वही कार्ड चुनें";
  @override
  String get normalConnectHealerInstruction =>
      "आपके राजा पर संदेह हो रहा है और उसे तुरंत सुरक्षित करने की आवश्यकता है ताकि रंग न बदले! कनेक्ट करने के लिए, मूल कार्ड से लक्ष्य किया हुआ कार्ड को स्थानांतरित करें!";
  @override
  String get normalPlaceAttackerInstruction =>
      "आप प्रातिष्ठान कर सकते हैं। खेल के माध्यम से एक हमलावर कार्ड प्राप्त करें!";
  @override
  String get normalConnectAttackerInstruction =>
      "प्रातिष्ठान करने के लिए, मूल कार्ड से लक्ष्य किया हुआ कार्ड को स्थानांतरित करें!";
  @override
  String get normalConquerAttackerInstruction =>
      "आपके लक्ष्य कार्ड का रंग बदलने के लिए एक संयोजन होना चाहिए और इसके पॉइंट्स 0 होने चाहिए!";
  @override
  String get normalPlaceDefenderInstruction =>
      "आपके निवासियों को प्रातिष्ठानिक कर सकते हैं। खेल के माध्यम से एक संरक्षक कार्ड प्राप्त करें!";
  @override
  String get normalConnectDefenderInstruction =>
      "आपके निवासियों कार्ड को स्थानांतरित करें ताकि वह आपके राजा को हानि नहीं पहुँचा सके!";
  @override
  String get normalConnectKingInstruction =>
      "आपके राजा की हमला किया जा रहा है। उस पर नजर रखो!";
  @override
  String get specialPlaceOrdinaryCitizenInstruction =>
      "आप प्रातिष्ठान कर सकते हैं। खेल के माध्यम से एक सामान्य नागरिक कार्ड प्राप्त करें!";
  @override
  String get specialPlaceCompressionInstruction =>
      "प्रातिष्ठान करने के लिए, मूल कार्ड से लक्ष्य किया हुआ कार्ड को स्थानांतरित करें!";
  @override
  String get specialConnectCompressionInstruction =>
      "आपके लक्ष्य कार्ड के साथ कनेक्ट करने के लिए, मूल कार्ड से लक्ष्य किया हुआ कार्ड को स्थानांतरित करें!";
  @override
  String get specialPlaceRefrigerationInstruction =>
      "आपके लक्ष्य कार्ड के साथ कनेक्ट करने के लिए, खेल के माध्यम से एक रिफ्रिजरेशन कार्ड प्राप्त करें!";
  @override
  String get specialConnectRefrigerationInstruction =>
      "आपके लक्ष्य कार्ड को कनेक्ट करने के लिए, मूल कार्ड से लक्ष्य किया हुआ कार्ड को स्थानांतरित करें!";
  @override
  String get specialConnectOrdinaryCitizen1Instruction =>
      "आपके लक्ष्य कार्ड के साथ कनेक्ट करने के लिए, मूल कार्ड से लक्ष्य किया हुआ कार्ड को स्थानांतरित करें!";
  @override
  String get specialPlaceExpansionInstruction =>
      "आप प्रातिष्ठान कर सकते हैं। खेल के माध्यम से एक विस्तारण कार्ड प्राप्त करें!";
  @override
  String get specialConnectExpansionInstruction =>
      "प्रातिष्ठान करने के लिए, मूल कार्ड से लक्ष्य किया हुआ कार्ड को स्थानांतरित करें!";
  @override
  String get specialConnectOrdinaryCitizen2Instruction =>
      "आपके लक्ष्य कार्ड के साथ कनेक्ट करने के लिए, मूल कार्ड से लक्ष्य किया हुआ कार्ड को स्थानांतरित करें!";
  @override
  String get specialConquerOrdinaryCitizenInstruction =>
      "आपके लक्ष्य कार्ड का रंग बदलने के लिए एक संयोजन होना चाहिए और इसके पॉइंट 0 होने चाहिए!";
  @override
  String get specialConnectKingInstruction =>
      "आपके राजा का हमला किया जा रहा है। उस पर नजर रखो!";

  /* TUTORIALS DESCRIPTIONS */

  @override
  String get basicsPlaceTileDescription =>
      "कार्ड स्थानांतरित करने के लिए लक्ष्य की ओर स्लाइड करें और स्थानांतरित करने के लिए स्लाइड करें!";
  @override
  String get basicsConnectCenterTileDescription =>
      "हरे कार्ड के साथ कनेक्ट करने के लिए लक्ष्य की ओर स्लाइड करें!";
  @override
  String get basicsConquerCenterTileDescription =>
      "हरे कार्ड का रंग बदलने के लिए एक संयोजन होना चाहिए और इसके पॉइंट 0 होने चाहिए!";
  @override
  String get basicsCutPathDescription =>
      "दो कार्डों के बीच के कनेक्शन को काटने के लिए, स्वाइप करके एक सेगमेंट ट्रेस करें!";
  @override
  String get basicsConnectKingDescription =>
      "अपने राजा कार्ड को कनेक्ट करने के लिए लक्ष्य की ओर स्लाइड करें और स्थानांतरित करें!";
  @override
  String get kingConquestDescription =>
      "राजा कार्ड का रंग बदलने के लिए एक संयोजन होना चाहिए और इसके पॉइंट 0 होने चाहिए!";
  @override
  String get normalPlaceOrdinaryCitizenDescription =>
      "कार्ड स्थानांतरित करने के लिए लक्ष्य की ओर स्लाइड करें और स्थानांतरित करें!";
  @override
  String get normalConnectOrdinaryCitizenDescription =>
      "प्रातिष्ठान कार्ड पर कनेक्ट करने के लिए, मूल कार्ड से लक्ष्य किया हुआ कार्ड को स्थानांतरित करें!";
  @override
  String get normalPlaceHealerDescription =>
      "अपने राजा को हमला किया गया है और उसे तुरंत चिकित्सा की आवश्यकता है! कार्ड स्थानांतरित करने के लिए लक्ष्य की ओर स्लाइड करें!";
  @override
  String get normalConnectHealerDescription =>
      "आपके राजा पर संदेह हो रहा है और उसे तुरंत सुरक्षित करने की आवश्यकता है ताकि रंग न बदले! कनेक्ट करने के लिए, मूल कार्ड से लक्ष्य किया हुआ कार्ड को स्थानांतरित करें!";
  @override
  String get normalPlaceAttackerDescription =>
      "आप प्रातिष्ठान कर सकते हैं। खेल के माध्यम से एक हमलावर कार्ड प्राप्त करें!";
  @override
  String get normalConnectAttackerDescription =>
      "प्रातिष्ठान करने के लिए, मूल कार्ड से लक्ष्य किया हुआ कार्ड को स्थानांतरित करें!";
  @override
  String get normalConquerAttackerDescription =>
      "आपके लक्ष्य कार्ड का रंग बदलने के लिए एक संयोजन होना चाहिए और इसके पॉइंट्स 0 होने चाहिए!";
  @override
  String get normalPlaceDefenderDescription =>
      "आपके निवासियों को प्रातिष्ठानिक कर सकते हैं। खेल के माध्यम से एक संरक्षक कार्ड प्राप्त करें!";
  @override
  String get normalConnectDefenderDescription =>
      "आपके निवासियों कार्ड को स्थानांतरित करें ताकि वह आपके राजा को हानि नहीं पहुँचा सके!";
  @override
  String get normalConnectKingDescription =>
      "आपके राजा का हमला किया जा रहा है। उस पर नजर रखो!";
  @override
  String get specialPlaceOrdinaryCitizenDescription =>
      "आप प्रातिष्ठान कर सकते हैं। खेल के माध्यम से एक सामान्य नागरिक कार्ड प्राप्त करें!";
  @override
  String get specialPlaceCompressionDescription =>
      "प्रातिष्ठान करने के लिए, मूल कार्ड से लक्ष्य किया हुआ कार्ड को स्थानांतरित करें!";
  @override
  String get specialConnectCompressionDescription =>
      "आपके लक्ष्य कार्ड के साथ कनेक्ट करने के लिए, मूल कार्ड से लक्ष्य किया हुआ कार्ड को स्थानांतरित करें!";
  @override
  String get specialPlaceRefrigerationDescription =>
      "आपके लक्ष्य कार्ड के साथ कनेक्ट करने के लिए, खेल के माध्यम से एक रेफ्रिजरेशन कार्ड प्राप्त करें!";
  @override
  String get specialConnectRefrigerationDescription =>
      "आपके लक्ष्य कार्ड को कनेक्ट करने के लिए, मूल कार्ड से लक्ष्य किया हुआ कार्ड को स्थानांतरित करें!";
  @override
  String get specialConnectOrdinaryCitizen1Description =>
      "आपके लक्ष्य कार्ड के साथ कनेक्ट करने के लिए, मूल कार्ड से लक्ष्य किया हुआ कार्ड को स्थानांतरित करें!";
  @override
  String get specialPlaceExpansionDescription =>
      "आप प्रातिष्ठान कर सकते हैं। खेल के माध्यम से एक विस्तारण कार्ड प्राप्त करें!";
  @override
  String get specialConnectExpansionDescription =>
      "प्रातिष्ठान करने के लिए, मूल कार्ड से लक्ष्य किया हुआ कार्ड को स्थानांतरित करें!";
  @override
  String get specialConnectOrdinaryCitizen2Description =>
      "आपके लक्ष्य कार्ड के साथ कनेक्ट करने के लिए, मूल कार्ड से लक्ष्य किया हुआ कार्ड को स्थानांतरित करें!";
  @override
  String get specialConquerOrdinaryCitizenDescription =>
      "आपके लक्ष्य कार्ड का रंग बदलने के लिए एक संयोजन होना चाहिए और इसके पॉइंट्स 0 होने चाहिए!";
  @override
  String get specialConnectKingDescription =>
      "आपके राजा का हमला किया जा रहा है। उस पर नजर रखो!";

  /* SKILLS */

  @override
  String get attackSkillNull => "शून्य";
  @override
  String get attackSkillVeryBad => "बहुत खराब";
  @override
  String get attackSkillBad => "खराब";
  @override
  String get attackSkillNormal => "सामान्य";
  @override
  String get attackSkillGood => "अच्छा";
  @override
  String get attackSkillVeryGood => "बेहतर";

  @override
  String get supportSkillNull => "शून्य";
  @override
  String get supportSkillVeryBad => "बहुत खराब";
  @override
  String get supportSkillBad => "खराब";
  @override
  String get supportSkillNormal => "सामान्य";
  @override
  String get supportSkillGood => "अच्छा";
  @override
  String get supportSkillVeryGood => "बेहतर";

  @override
  String get resistanceSkillNull => "शून्य";
  @override
  String get resistanceSkillVeryBad => "बहुत खराब";
  @override
  String get resistanceSkillBad => "खराब";
  @override
  String get resistanceSkillNormal => "सामान्य";
  @override
  String get resistanceSkillGood => "अच्छा";
  @override
  String get resistanceSkillVeryGood => "बेहतर";

  @override
  String get lifeSkillNull => "शून्य";
  @override
  String get lifeSkillHalf => "आधा";
  @override
  String get lifeSkillNormal => "सामान्य";

  @override
  String get speedSkillNull => "शून्य";
  @override
  String get speedSkillHalf => "आधा";
  @override
  String get speedSkillNormal => "सामान्य";

  @override
  String remoteComplexCloseDescription(int cowries) =>
      "इस भाग को बंद करने के लिए आपको बिल्कुल $cowries कौरीज़ खर्च होगा! क्या आप वाकई खेल बंद करना चाहते हैं?";
  @override
  String adventureComplexCloseDescription(int cowries) =>
      "इस भाग को बंद करने के लिए आपको बिल्कुल $cowries कौरीज़ खर्च होगा! क्या आप वाकई खेल बंद करना चाहते हैं?";
  @override
  String get adventureSimpleCloseDescription =>
      "वर्तमान खेल को बंद करने से आपकी प्रगति हो जाएगी! क्या आप वाकई वर्तमान खेल को बंद करना चाहते हैं?";
  @override
  String get remoteSimpleCloseDescription =>
      "इस भाग को बंद करने से इसकी वर्तमान प्रगति हो जाएगी! क्या आप वाकई इस भाग को बंद करना चाहते हैं?";
  @override
  String get closeClose => "बंद करें";
  @override
  String get closeTitle => "बंद करें";

  @override
  String get watchAdButtonRefreshAd => "विज्ञापन रीफ़्रेश करें";
  @override
  String get cardOptionButtonPopupSelectDeck => "इस डेक का चयन करें";

  @override
  String get lessonChangeTitle => "पाठ परिवर्तन";
  @override
  String get lessonChangeDescription =>
      "कृपया इस पाठ की शिक्षा को सीखने के पूर्व ही दूसरे पाठ पर जाने का प्रयास करें! क्या आप वाकई पाठ बदलना चाहते हैं?";
  @override
  String get lessonChangeAction => "बदलें";

  @override
  String get restoreDefaultLanguage => "डिफ़ॉल्ट भाषा पुनः स्थापित करें";

  //

  @override
  String get loadingDescription =>
      "हम खेल के डेटा को लोड कर रहे हैं। कृपया एक क्षण प्रतीक्षा करें!";
  @override
  String get homeUpdateSimpleDescription =>
      "खेल का एक नया संस्करण उपलब्ध है। नवीनतम सुविधाओं का आनंद लेने के लिए इसे तेजी से स्थापित करें!";
  @override
  String get gametutorialCongratulationsPopupDescription =>
      "अब आप खेल ब्रह्मांड में प्रवेश कर सकते हैं और उसकी सभी जटिलताओं का अन्वेषण कर सकते हैं!";
  @override
  String gameScoresIndicatorNormalGameDescription(int level) =>
      "मैं खेल के स्तर $level की कृत्रिम बुद्धिमत्ता हूं! मैं आपको एक शानदार खेल प्रदान करने के लिए अपनी सर्वोत्तम कोशिश करूंगा!";
  @override
  String get gameScoresIndicatorTutorialGameDescription =>
      "मैं खेल ट्यूटोरियल की कृत्रिम बुद्धिमत्ता हूं। बस निर्देशों का पालन करें और जीतें!";

  @override
  String get homeCowriesStoreTransactionErrorTitle => "लेन-देन रद्द हो गई!";
  @override
  String get homeCowriesStoreTransactionErrorDescription =>
      "हम आपकी खरीद को प्रमाणित नहीं कर सके। कृपया अपना भुगतान तरीका और इंटरनेट कनेक्शन जांचें!";

  @override
  String get drawTitle => "बराबरी!";
  @override
  String get adventureDrawGameFinishedDescription =>
      "आप बराबरी पर समाप्त हो गए! चाहे आपने इस खेल मोड के सभी स्तर पूरे कर लिए हों!";
  @override
  String get adventureDrawPossibleToPlayNextLevelDescription =>
      "आप बराबरी पर समाप्त हो गए! चाहे आपने यह स्तर पूरा कर लिया हो और आगे के स्तर पर जा सकते हैं!";
  @override
  String get adventureDrawPossibleToPlayAgainDescription =>
      "आप बराबरी पर समाप्त हो गए! आप फिर से एआई के खिलाफ एक नया खेल खेलकर जीत सकते हैं!";
  @override
  String get remoteDrawDescription =>
      "आपने न तो जीता है और न हारा है! दूसरे खिलाड़ी के साथ एक और खेल शुरू करके फैसला क्यों नहीं करते हैं?";
  @override
  String get newPlayer => "नया खिलाड़ी";

  @override
  String get premiumButtonRemoveAds => "विज्ञापन हटाएं";

  @override
  String get localNetworkWaitingForHost => "होस्ट की प्रतीक्षा…";

  @override
  String get localNetworkHostLeftDescription =>
      "होस्ट ने खेल छोड़ दिया: यह टेबल समाप्त हो गई। आप मेनू से नया खेल शुरू कर सकते हैं।";

  @override
  String get replayVoteChooseOption => "बदले के लिए मोड चुनें";

  @override
  String replayVoteCountdown(int seconds) =>
      "${seconds}s में तैयार खिलाड़ियों के साथ शुरू";

  @override
  String get replayVoteStartingSoon =>
      "खेल उन खिलाड़ियों के साथ शुरू होगा जिन्होंने स्वीकार किया";

  @override
  String get replayVoteWaitingForPlayers => "अन्य खिलाड़ियों की प्रतीक्षा";

  /* ROLL CALL */

  @override
  String get rollCallWaitingTitle => "खिलाड़ियों की प्रतीक्षा";

  @override
  String get rollCallReady => "तैयार";

  @override
  String get rollCallConnecting => "कनेक्ट हो रहा है…";

  @override
  String get rollCallYou => "आप";

  @override
  String rollCallVoteOpensIn(int s) =>
      "अनुपस्थित खिलाड़ियों को हटाने का वोट $s सेकंड में";

  @override
  String rollCallStartsIn(int s) => "खेल $s सेकंड में शुरू होगा";

  @override
  String rollCallEjectVotes(int votes, int needed) =>
      "अनुपस्थित खिलाड़ियों को हटाएँ: $votes/$needed";

  @override
  String get rollCallEject => "हटाएँ";

  @override
  String get rollCallWait => "प्रतीक्षा करें";

  @override
  String get rollCallPlayerUnavailableTitle => "खिलाड़ी उपलब्ध नहीं";

  @override
  String rollCallPlayerUnavailableDescription(int s) =>
      "आपका प्रतिद्वंद्वी $s सेकंड में कनेक्ट नहीं हुआ। खेल बिना किसी दंड के रद्द कर दिया गया है।";

  @override
  String get rollCallPlayersUnavailableTitle => "खिलाड़ी उपलब्ध नहीं";

  @override
  String get rollCallPlayersUnavailableDescription =>
      "कोई अन्य खिलाड़ी समय पर कनेक्ट नहीं हुआ। खेल बिना किसी दंड के रद्द कर दिया गया है।";

  @override
  String get rollCallCancelledTitle => "खेल रद्द";

  @override
  String get rollCallExcludedTitle => "खेल आपके बिना शुरू हुआ";

  @override
  String rollCallExcludedDuel(int s) =>
      "आपके प्रतिद्वंद्वी ने $s सेकंड तक आपका इंतज़ार किया, इसलिए खेल रद्द कर दिया गया। आप पर कोई दंड नहीं लगेगा।";

  @override
  String get rollCallExcludedVote =>
      "आप अभी कनेक्ट नहीं हुए थे, इसलिए अन्य खिलाड़ियों ने आपके बिना शुरू करने का वोट दिया। आप पर कोई दंड नहीं लगेगा।";

  @override
  String rollCallExcludedCap(int s) =>
      "$s सेकंड बाद भी आप कनेक्ट नहीं हुए, इसलिए खेल आपके बिना शुरू हो गया। आप पर कोई दंड नहीं लगेगा।";

  @override
  String get rollCallExcludedGrace =>
      "आप समय पर कनेक्ट नहीं हुए, इसलिए खेल आपके बिना शुरू हो गया। आप पर कोई दंड नहीं लगेगा।";

  @override
  String get rollCallClose => "बंद करें";

  @override
  String get rollCallPlayerLeftDescription =>
      "आपका प्रतिद्वंद्वी खेल शुरू होने से पहले चला गया। खेल बिना किसी दंड के रद्द कर दिया गया है।";

  @override
  String get rollCallPlayersLeftDescription =>
      "अन्य खिलाड़ी खेल शुरू होने से पहले चले गए। खेल बिना किसी दंड के रद्द कर दिया गया है।";

  @override
  String get rollCallWaitingOpponentTitle => "आपके प्रतिद्वंद्वी की प्रतीक्षा";

  @override
  String rollCallCancelsIn(int s) => "$s सेकंड में रद्द";

  @override
  String get rollCallAway => "तैयार · ऐप से बाहर";

  @override
  String get rollCallLeave => "छोड़ें";
}
