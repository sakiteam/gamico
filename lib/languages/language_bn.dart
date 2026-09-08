import 'package:gamico/languages/languages.dart';

abstract class GamicoLanguageBn extends GamicoLanguages {
  @override
  String get globalMax => "সর্বাধিক";
  @override
  String get globalRefresh => "রিফ্রেশ";
  @override
  String get globalClose => "বন্ধ করুন";
  @override
  String get globalOK => "ঠিক আছে";

  /* FRIEND */

  @override
  String get friendPageTitle => "বন্ধু খুঁজুন";

  @override
  String get friendPageSearchHint => "নাম দিয়ে খুঁজুন...";

  @override
  String get friendPagePendingInvitations => "অপেক্ষমান আমন্ত্রণ";

  @override
  String get friendPageGameInvitation => "খেলার আমন্ত্রণ";

  @override
  String friendPageInvitationFrom(String name) => "থেকে: $name";

  @override
  String get friendPageInvitationSent => "আমন্ত্রণ পাঠানো হয়েছে!";

  @override
  String get friendPageFailedToSendInvitation => "আমন্ত্রণ পাঠাতে ব্যর্থ";

  @override
  String get friendPageUnknown => "অজানা";
  @override
  String get notificationInvitationBody => "আপনি একটি গেম আমন্ত্রণ পেয়েছেন!";
  @override
  String notificationInvitationFrom(String name) =>
      "$name আপনাকে খেলতে আমন্ত্রণ জানিয়েছেন!";

  /* ADVENTURE */

  @override
  String get adventureHelpTitle => "সাহায্য";
  @override
  String get adventureHelpDescription =>
      "আপনি একটি স্তর নির্বাচন করতে তাকে চাপুন। কিন্তু আপনি যদি এখনো খুব ভালো খেলতে জানেন না, তাহলে টিউটরিয়াল অনুসরণ করুন!";
  @override
  String get adventureClose => "বন্ধ করুন";
  @override
  String get adventureFollow => "অনুসরণ করুন";

  @override
  String adventureChapterChapter(int chapter) => "অধ্যায় $chapter";

  /* COLLECTION */

  @override
  String collectionCardPopupFamily(String family) => "পরিবার: $family";
  @override
  String get collectionCardPopupUpgrade => "আপগ্রেড";
  @override
  String get collectionCardPopupRemove => "সরান";
  @override
  String get collectionCardPopupUse => "ব্যবহার করা";
  @override
  String get collectionCardPopupAcquire => "অর্জন করা";

  @override
  String get collectionCardSkillsAttack => "আক্রমণ";
  @override
  String get collectionCardSkillsSupport => "সমর্থন";
  @override
  String get collectionCardSkillsResistance => "প্রতিরোধ";
  @override
  String get collectionCardSkillsTheoreticalLife => "তত্ত্বগত জীবন";
  @override
  String get collectionCardSkillsTheoreticalSpeed => "তত্ত্বগত গতি";
  @override
  String get collectionCardSkillsPower => "শক্তি";
  @override
  String get collectionCardSkillsConcreteLife => "বাস্তব জীবন";
  @override
  String get collectionCardSkillsConcreteSpeed => "বাস্তব গতি";
  @override
  String get collectionCardSkillsConnections => "সংযোগ";

  @override
  String collectionCardSquareLevel(int level) => "স্তর $level";

  @override
  String get collectionCardBlocked => "বাধাগ্রস্ত";
  @override
  String collectionCardLevel(int level) => "স্তর $level";

  @override
  String get collectionContentDeck => "ডেক";
  @override
  String get collectionContentUnlockedCards => "আনলক কার্ডস";
  @override
  String get collectionContentRemainingCards => "বাকি কার্ড";

  /* HOME */

  @override
  String get homeLanguagesTitle => "ভাষা";

  /* HOME */

  @override
  String get homeMultiplayerButtonShowcase =>
      "এই বোতামটি অনলাইনে অন্যান্য খেলোয়ারের সাথে খেলার সুযোগ দেয়।";
  @override
  String get homeSingleplayerButtonShowcase =>
      "এই বোতামটি খেলার সুযোগ দেয় খেলার কৃত্রিম বুদ্ধিমত্তা সহ।";
  @override
  String get homeNotificationsTitle => "বিজ্ঞপ্তি";
  @override
  String get homeNotificationsDescription =>
      "খেলার অভিজ্ঞতার জন্য আপনাকে বিজ্ঞপ্তি অনুমোদন দেওয়া দরকার! আপনি কি বিজ্ঞপ্তি অনুমোদন দিতে চান?";
  @override
  String get homeNotificationsAllow => "অনুমোদন দিন";
  @override
  String get homeNotificationsReminderTitle => "বিজ্ঞপ্তি চালু করুন";
  @override
  String get homeNotificationsReminderDescription =>
      "আরও ভালো গেমিং অভিজ্ঞতার জন্য বিজ্ঞপ্তি গুরুত্বপূর্ণ। আপনি কি এখন এগুলি চালু করতে চান?";
  @override
  String get homeUpdateTitle => "নতুন আপডেট উপলব্ধ!";
  @override
  String get homeUpdateForceDescription =>
      "নতুন সংস্করণে অনেকগুলি ত্রুটি এবং সমস্যা সমাধান করা হয়েছে। এটি দ্রুত ইনস্টল করুন এবং এই সংস্করণের সুধ নাও নাও ফিচার অফার করা হয়েছে!";
  @override
  String get homeUpdateInstall => "ইনস্টল করুন";

  @override
  String get homeAbout => "সম্পর্কিত";
  @override
  String homeAboutPopupShareText(String link) =>
      "আমি একটি মনোনিবেশ খেলা খুঁজে পেয়েছি! এটি নিঃশুল্ক ডাউনলোড করুন $link !";
  @override
  String get homeAboutPopupImplementation => "বৈদ্যুতিনতা";
  @override
  String get homeAboutPopupMusic => "সংগীত";
  @override
  String get homeAboutPopupVersion => "সংস্করণ";
  @override
  String get homeAboutPopupRateGame => "খেলা নির্ধারণ করুন";
  @override
  String get homeAboutPopupVisitWebstie => "সাকি হাব দেখুন";
  @override
  String get homeAboutPopupDiscoverApps => "আমার অ্যাপস দেখুন";

  @override
  String get homeCardPresentationShowcase =>
      "নতুন কার্ড কেনার এবং যেগুলি আপনার আছে সেগুলি উন্নত করতে এই মেনু ব্যবহার করুন।";
  @override
  String get homeCardPresentationShow => "সমস্ত কার্ড দেখুন";

  @override
  String get homeGratificationPopupConnectionErrorTitle => "সংযোগ সমস্যা!";
  @override
  String get homeGratificationPopupConnectionErrorDescription =>
      "আপনার ইন্টারনেট সংযোগ পরীক্ষা করুন। আপনি যখন সংযুক্ত হন, তখন এই বিভাগটি স্বয়ংক্রিয়ভাবে আপডেট হবে!";
  @override
  String get homeGratificationPopupLoadingTitle => "পুরষ্কার লোড হচ্ছে!";
  @override
  String get homeGratificationPopupLoadingDescription =>
      "পুরষ্কারগুলি শীঘ্রই উপলব্ধ হবে। দয়া করে অপেক্ষা করুন!";
  @override
  String get homeGratificationPopupIncorrectTimestampTitle => "ভুল সময়চিহ্ন!";

  @override
  String get homeMultiplayerButtonConnectionErrorTitle => "সংযোগ সমস্যা!";
  @override
  String get homeMultiplayerButtonConnectionErrorDescription =>
      "আপনি ইন্টারনেটে সংযুক্ত হয়নি মনে হচ্ছে। দয়া করে আপনার ইন্টারনেট সংযোগের গুণগতি চেক করুন এবং পুনরায় চেষ্টা করুন!";
  @override
  String get homeMultiplayerButtonText => "মাল্টি";

  @override
  String get homeProfilePopupBestTacticians => "সেরা যোদ্ধাদের";
  @override
  String get homeProfilePopupDescription =>
      "খেলোয়াড়রা দুটি মৌলিক মানের উপর বিশ্রেণীবদ্ধ হন: অনলাইন জিতগুলির সংখ্যা এবং সর্বাধিক কৌড়ি!";
  @override
  String get homeProfilePopupBestCollectors => "সর্বোত্তম সংগ্রহকারীগণ";
  @override
  String get homeProfilePopupCheckAchievements => "আমার সাফল্যগুলি দেখুন";

  @override
  String get homeSingleplayerButtonText => "সিঙ্গেল";

  @override
  String get homeSpecialOfferPopupOfferDisabledDescription =>
      "বিশেষ অফারগুলি 3 দিন পর সক্রিয় হয় এবং কেবল 24 ঘণ্টা পর্যন্ত বৈধ। পরবর্তীটি না হারান!";
  @override
  String get homeSpecialOfferPopupOfferLoadedDescription =>
      "বিশেষ অফারগুলি 3 দিন পর সক্রিয় হয় এবং কেবল 24 ঘণ্টা পর্যন্ত বৈধ। তাহলে কী অপেক্ষা করছেন?";
  @override
  String get homeSpecialOfferPopupOfferLoadingDescription =>
      "বিশেষ অফারের তথ্য শীঘ্রই উপলব্ধ হবে। অনুগ্রহ করে একটু অপেক্ষা করুন!";
  @override
  String get homeSpecialOfferPopupErrorDescription =>
      "আমরা আপনার ক্রয় যাচাই করতে পারি নি। দয়া করে আপনার পেমেন্ট মাধ্যম এবং ইন্টারনেট সংযোগ পরীক্ষা করুন!";
  @override
  String homeSpecialOfferPopupOffsetLoadedTitle(String? packTitle) =>
      "$packTitle !";
  @override
  String get homeSpecialOfferPopupOfferLoadingTitle => "অফার লোড হচ্ছে!";
  @override
  String get homeSpecialOfferPopupErrorTitle => "লেনদেন বাতিল!";
  @override
  String get homeSpecialOfferPopupClose => "বন্ধ";
  @override
  String get homeSpecialOfferPopupTimestampTitle => "সময়সূচি ভুল!";
  @override
  String get homeSpecialOfferPopupLoadingDescription =>
      "বিশেষ অফারের তথ্য শীঘ্রই উপলব্ধ হবে। অনুগ্রহ করে একটু অপেক্ষা করুন!";
  @override
  String get homeSpecialOfferPopupLoadingTitle => "অফার লোড হচ্ছে!";
  @override
  String get homeSpecialOfferPopupProblemClose => "বন্ধ";
  @override
  String get homeSpecialOfferPopupProblemTitle => "সংযোগে সমস্যা!";

  @override
  String get premiumPopupTitle => "প্রিমিয়াম মোড";
  @override
  String get premiumPopupDescription =>
      "সব বিজ্ঞাপন সরাতে সম্পূর্ণ সংস্করণ আনলক করুন!";
  @override
  String get premiumPlayer => "প্রিমিয়াম প্লেয়ার";
  @override
  String get nonPremiumPlayer => "নন-প্রিমিয়াম প্লেয়ার";

  @override
  String get homeHelpBasicsA => "নীল সাম্রাজ্য আর কমলা সাম্রাজ্যের সম্মুখীন।";
  @override
  String get homeHelpBasicsB =>
      "বিপক্ষী শাসকের রঙ পরিবর্তন করে জিতা যেতে পারে।";
  @override
  String get homeHelpBasicsC =>
      "নির্ধারিত সময়ের মধ্যে সর্বাধিক জীবনের সঙ্খ্যা থাকায় জিতা যেতে পারে।";

  @override
  String get homeHelpConnections1A =>
      "আপনি দুটি কার্ড সংযোগ করতে ট্যাপ এবং স্লাইড করতে পারেন।";
  @override
  String get homeHelpConnections1B =>
      "আপনি দুটি কার্ড সংযোগ করতে ট্যাপ এবং ট্যাপ করতে পারেন।";
  @override
  String get homeHelpConnections1C =>
      "আপনি একটি সংযোগ একটি আঙ্গুলের চলক চালিয়ে বিচ্ছিন্ন করতে পারেন।";

  @override
  String get homeHelpConnections2A =>
      "কাছাকাছি একটি সংযোগ খেলার সম্ভাবনা প্রতিরোধ করতে পারে।";
  @override
  String get homeHelpConnections2B =>
      "একটি কার্ড অন্য কার্ডে সংযোগ করতে হয় না যেতে।";
  @override
  String get homeHelpConnections2C =>
      "একটি সর্বাধিক কার্ড যেটি পেতে, সব বল যেগুলি এটি পেতে পেয়েছে সব ফেরৎ দেয়।";

  @override
  String get homeHelpCards1A => "লাল কার্ড আক্রমণ করার জন্য ভালো।";
  @override
  String get homeHelpCards1B => "ধূসর কার্ড প্রতিরোধ করার জন্য ভালো।";
  @override
  String get homeHelpCards1C =>
      "সবার সাথে সামর্থ্য সাধন করার জন্য সবচেয়ে ভালো হলো সবচেয়ে বেশি নেমে যাওয়া কার্ডগুলি।";

  @override
  String get homeHelpCards2A => "ব্যালেন্সড সুবিধা দেওয়া একটি ব্রাউন কার্ড।";
  @override
  String get homeHelpCards2B =>
      "হয়রানি দিয়ে ব্যক্তিগত কার্ড সম্পর্কে বিশেষ দ্বারা ব্যক্ত কার্ড সম্পর্কে বিশেষ দ্বারা সম্পর্ক করুন।";
  @override
  String get homeHelpCards2C => "সম্পূর্ণ রক্ষণা করা আবশ্যক সফেদ কার্ডগুলি।";

  @override
  String get homeHelpRestrictionsA =>
      "যেকোন সংযোগ প্রাথমিক হতে হবে। এখানে সে অপ্রায়ক্ত এবং তাই অসম্ভব।";
  @override
  String get homeHelpRestrictionsB =>
      "একটি ধ্বংস কার্ড একটি শাসকের উপর আক্রমণ করতে পারবে না।";
  @override
  String get homeHelpRestrictionsC =>
      "একটি শাসক ক্লোন করা বা স্থানান্তরিত করা সম্ভব নয়।";

  /* LOADING */

  @override
  String get loadingTitle => "অনুগ্রহ করে অপেক্ষা করুন!";

  /* REMOTE */

  @override
  String get remoteConnexionProblemTitle => "সংযোগে সমস্যা!";
  @override
  String get remoteConnexionProblemDescription =>
      "দুঃখিত! আপনার ইন্টারনেট সংযোগ বিচ্ছিন্ন হয়েছে। আপনি খেলার লড়াইয়ের অবাধিত হন!";
  @override
  String get remoteInvitationTitle => "আসুন খেলা খেলি!";
  @override
  String get remoteInvitationDescription => "আপনার অনলাইন খেলা শুরু হয়েছে!";
  @override
  String get remoteMultiplayer => "বহুখেলা";

  @override
  String get remoteFailurePosterTitle => "একটি সমস্যা সামনে আসছে!";
  @override
  String get remoteFailurePosterDescription =>
      "খোঁজে পাওয়ার সময় একটি সমস্যা সামনে আসছে। আপনার ইন্টারনেট সংযোগ পরীক্ষা করুন এবং পুনরায় চেষ্টা করুন!";

  @override
  String get remoteImpossibleGamePosterTitle => "কবজি পুরানো!";
  @override
  String remoteImpossibleGamePosterDescription(int cowries) =>
      "অনলাইনে খেলা খেলতে আপনার অন্তত $cowries কবজি থাকতে হবে!";

  @override
  String get remoteNewGamePosterTitle => "নতুন খেলা?";
  @override
  String get remoteNewGamePosterDescription =>
      "আপনি আপনার প্রায় স্তর বাড়ানোর জন্য দুনিয়া জুড়ে খেলতে পারেন!";

  @override
  String get remoteSearchPosterTitle => "খেলোয়াড় খোঁজা হচ্ছে";
  @override
  String get remoteSearchPosterDescription =>
      "আমরা দুনিয়ার প্রায় সার্চ করছি যাতে আপনি একটি খেলা খেতে পারেন!";

  @override
  String get homeTranslationPopupDescription =>
      "এই অধ্যায়টি খেলার মূখ্য ভাষা নির্বাচন করতে দেয়। স্বয়ংক্রিয়ভাবে সক্রিয় করতে একটি ভাষাতে ক্লিক করুন!";

  /* কার্ডের শিরোনাম */

  @override
  String get lordLazyKingName => "রাজা অলস";
  @override
  String get lordLazyQueenName => "রানী অল্পবল্লুক";
  @override
  String get lordLazyPrinceName => "প্রিন্স একাকী";
  @override
  String get lordLazyPrincessName => "প্রিন্সেস অন্তর্বন্ধী";
  @override
  String get lordCourageousKingName => "রাজা প্রাগতিশীল";
  @override
  String get lordCourageousQueenName => "রানী দাঁড়িয়ে";
  @override
  String get lordCourageousPrinceName => "প্রিন্স দৃঢ়";
  @override
  String get lordCourageousPrincessName => "প্রিন্সেস অনুরণ্য";
  @override
  String get normalOrdinaryCitizenName => "সাধারণ নাগরিক";
  @override
  String get normalAttackerDefenderName => "সাধারণ আক্রমণকারী রক্ষক";
  @override
  String get normalAttackerHealerName => "সাধারণ আক্রমণকারী চিকিত্সক";
  @override
  String get normalDefenderHealerName => "রক্ষক চিকিত্সক";
  @override
  String get attacker2AName => "জ্বর";
  @override
  String get attacker2BName => "সূর্য";
  @override
  String get attacker2CName => "উদ্ধীপনা";
  @override
  String get attacker4AName => "চক্রান্বিত";
  @override
  String get attacker4BName => "ম্যাঞ";
  @override
  String get attacker4CName => "ঘূর্ণন";
  @override
  String get defender2AName => "পাথর";
  @override
  String get defender2BName => "শিলা";
  @override
  String get defender2CName => "সুরক্ষাকক্ষ";
  @override
  String get defender4AName => "রশ্মি";
  @override
  String get defender4BName => "বালকনি";
  @override
  String get defender4CName => "জানালা";
  @override
  String get healer2AName => "ঘাস";
  @override
  String get healer2BName => "ফুল";
  @override
  String get healer2CName => "পাতা";
  @override
  String get healer4AName => "গাছ";
  @override
  String get healer4BName => "স্প্যারাড্রাপ";
  @override
  String get healer4CName => "বৃক্ষ";
  @override
  String get specialExpansionName => "প্রসারণ";
  @override
  String get specialCompressionName => "সঙ্কোচন";
  @override
  String get specialDecelerationName => "প্রশমন";
  @override
  String get specialAccelerationName => "ত্বরণ";
  @override
  String get specialAttackIncreaseName => "মর্যাদা";
  @override
  String get specialAttackDecreaseName => "ভয়ানকতা";
  @override
  String get specialResistanceIncreaseName => "সহনশীলতা";
  @override
  String get specialResistanceDecreaseName => "দ্বার";
  @override
  String get specialSupportIncreaseName => "সহানুভূতি";
  @override
  String get specialSupportDecreaseName => "ব্যক্তিগততা";
  @override
  String get specialCloningName => "ক্লোনিং";
  @override
  String get specialCancellationName => "বাতিল";
  @override
  String get specialRefrigerationName => "শীতলণ";
  @override
  String get specialAspiratorName => "অভিস";
  @override
  String get specialSubstractionName => "বিয়োগ";
  @override
  String get specialDivisionName => "বিভাজন";
  @override
  String get specialDeflagrationName => "স্ফোটন";
  @override
  String get specialParalysisName => "প্যারালাইসিস";
  @override
  String get specialInvulnerabilityName => "অক্ষয়তা";
  @override
  String get specialVortexName => "ঘূর্ণন";

  /* কার্ড বর্ণনা */

  @override
  String get lordLazyKingDescription =>
      "এটি একটি লর্ড যে যুদ্ধ করতে না পারে না প্রতিরক্ষা করতে। তবে, এটি একটি বিশেষ দুর্বলতা সম্পর্কে কোন ধারণা নেই!";
  @override
  String get lordLazyQueenDescription =>
      "এটি একটি বয়স প্রাপ্ত মহিলা যে তার শ্রেষ্ঠ আক্রমণ এবং তার বয়সের সাথে তার অনুগতিতা প্রদান করতে খুব দক্ষ। তবে, তার সহনশীলতা স্বীকার্য নয়!";
  @override
  String get lordLazyPrinceDescription =>
      "এটি একটি যুদ্ধ করতে এবং আক্রমণে অভিজ্ঞ মুখোমুখি যুবক। তবে, এটি তার অনুগতিতা প্রদান করতে জানে না!";
  @override
  String get lordLazyPrincessDescription =>
      "এটি একটি যুদ্ধ করতে এবং তার অনুগতিতা প্রদান করতে জানে খুব দক্ষ যুবতী। তবে, এটি আক্রমণে শক্ত নয়!";
  @override
  String get lordCourageousKingDescription =>
      "এটি একটি বিশেষ দুর্বলতা সম্পর্কে কোন ধারণা নেই একটি স্বাধীন রাজা। তবে, এটির প্রাণের প্রাণ 2 গুণ কম!";
  @override
  String get lordCourageousQueenDescription =>
      "এটি একটি বয়স প্রাপ্ত মহিলা যে তার শ্রেষ্ঠ আক্রমণ করতে খুব দক্ষ। তবে, অন্য ক্ষেত্রে এটি সুপারিশ করে না!";
  @override
  String get lordCourageousPrinceDescription =>
      "এটি একটি যুদ্ধ করতে খুব দক্ষ যুবক। তবে, এই প্রিন্স অন্য ক্ষেত্রে সুপারিশ করে না!";
  @override
  String get lordCourageousPrincessDescription =>
      "এটি একটি যুদ্ধ করতে বেশ দক্ষ যুবতী। তবে, এই প্রিন্সেস অন্য ক্ষেত্রে সুপারিশ করে না!";
  @override
  String get normalOrdinaryCitizenDescription =>
      "এই কার্ড খেলার সবচেয়ে বিনিয়মিত। এটির কোনও বিশেষ সুবিধ নেই, তবে এটি একটি বিশ্বাসযোগ্য সাথী!";
  @override
  String get normalAttackerDefenderDescription =>
      "এটির নামে সুঝায়, এটি তার শত্রুদের আক্রমণ করতে খুব দক্ষ, সময়ে তাদের আক্রমণ প্রতিরোধ করতে!";
  @override
  String get normalAttackerHealerDescription =>
      "এটির নামে সুঝায়, এটি তার শত্রুদের আক্রমণ করতে খুব দক্ষ, তাদের সাথে তাদের সাথে সাহায্য করতে!";
  @override
  String get normalDefenderHealerDescription =>
      "এটির নামে সুঝায়, এটি তার সহযোগীদের সাথে সাহায্য করতে খুব দক্ষ, সময়ে তাদের আক্রমণ প্রতিরোধ করতে!";
  @override
  String get attacker2ADescription =>
      "এই কার্ড তার শত্রুদের একই কার্ডের তুলনায় 2 গুণ বেশি ক্ষতি পুনর্নির্মাণ করে, তবে তার সহযোগীদের সাথে সাহায্য করতে বেশ না দক্ষ!";
  @override
  String get attacker2BDescription =>
      "এই কার্ড তার শত্রুদের একই কার্ডের তুলনায় 2 গুণ বেশি ক্ষতি পুনর্নির্মাণ করে, তবে এটি তার শত্রুদের আক্রমণে অস্থিত!";
  @override
  String get attacker2CDescription =>
      "এই কার্ড তার শত্রুদের একই কার্ডের তুলনায় 2 গুণ বেশি ক্ষতি পুনর্নির্মাণ করে, তবে এটি একই কার্ডের তুলনায় 2 গুণ আগে প্রত্যাহার করে!";
  @override
  String get attacker4ADescription =>
      "এই কার্ড তার শত্রুদের একই কার্ডের তুলনায় 4 গুণ বেশি ক্ষতি পুনর্নির্মাণ করে, তবে তার সহযোগীদের সাথে সাহায্য করতে খুব না দক্ষ!";
  @override
  String get attacker4BDescription =>
      "এই কার্ড তার শত্রুদের একই কার্ডের তুলনায় 4 গুণ বেশি ক্ষতি পুনর্নির্মাণ করে, তবে তার সহযোগীদের সাথে সাহায্য করতে খুব অল্প!";
  @override
  String get attacker4CDescription =>
      "এই কার্ড তার শত্রুদের একই কার্ডের তুলনায় 4 গুণ বেশি ক্ষতি পুনর্নির্মাণ করে, তবে এটি অন্য ক্ষেত্রে সুপারিশ করে না!";
  @override
  String get defender2ADescription =>
      "এই কার্ডের সহনশীলতা 2 গুণ বেশি একই কার্ডের তুলনায়, তবে এটি তার শত্রুদের আক্রমণ করতে বেশ না দক্ষ!";
  @override
  String get defender2BDescription =>
      "এই কার্ডের সহনশীলতা 2 গুণ বেশি একই কার্ডের তুলনায়, তবে এটি তার সহযোগীদের সাথে সাহায্য করতে বেশ না দক্ষ!";
  @override
  String get defender2CDescription =>
      "এই কার্ডের সহনশীলতা 2 গুণ বেশি একই কার্ডের তুলনায়, তবে এটি একই কার্ডের তুলনায় 2 গুণ আগে প্রত্যাহার করে!";
  @override
  String get defender4ADescription =>
      "এই কার্ডের সহনশীলতা 4 গুণ বেশি একই কার্ডের তুলনায়, তবে এটি তার শত্রুদের আক্রমণ করতে বেশ না দক্ষ!";
  @override
  String get defender4BDescription =>
      "এই কার্ডের সহনশীলতা 4 গুণ বেশি একই কার্ডের তুলনায়, তবে এটি তার সহযোগীদের সাথে সাহায্য করতে বেশ অল্প!";
  @override
  String get defender4CDescription =>
      "এই কার্ডের সহনশীলতা 4 গুণ বেশি একই কার্ডের তুলনায়, তবে এটি অন্য ক্ষেত্রে সুপারিশ করে না!";
  @override
  String get healer2ADescription =>
      "এই কার্ড তার সহযোগীদের 2 গুণ দ্রুত সেবা দেয়, তবে এটি তার শত্রুদের আক্রমণ করতে বেশ না দক্ষ!";
  @override
  String get healer2BDescription =>
      "এই কার্ড তার সহযোগীদের 2 গুণ দ্রুত সেবা দেয়, তবে এটি তার শত্রুদের আক্রমণে অস্থিত!";
  @override
  String get healer2CDescription =>
      "এই কার্ড তার সহযোগীদের 2 গুণ দ্রুত সেবা দেয়, তবে এই কার্ড একই কার্ডের তুলনায় 2 গুণ আগে প্রত্যাহার করে!";
  @override
  String get healer4ADescription =>
      "এই কার্ড তার সহযোগীদের 4 গুণ দ্রুত সেবা দেয়, তবে এটি তার শত্রুদের আক্রমণ করতে বেশ না দক্ষ!";
  @override
  String get healer4BDescription =>
      "এই কার্ড তার সহযোগীদের 4 গুণ দ্রুত সেবা দেয়, তবে এটি তার সহযোগীদের সাথে সাহায্য করতে খুব অল্প!";
  @override
  String get healer4CDescription =>
      "এই কার্ড তার সহযোগীদের 4 গুণ দ্রুত সেবা দেয়, তবে এটি অন্য ক্ষেত্রে সুপারিশ করে না!";
  @override
  String get specialExpansionDescription =>
      "এই কার্ড লক্ষ্য কার্ডের আক্রমণ সংখ্যা 1 বেড়ে দেয়; লক্ষ্য একটি সহযোগী বা নয়!";
  @override
  String get specialCompressionDescription =>
      "এই কার্ড লক্ষ্য কার্ডের আক্রমণ সংখ্যা 1 কমিয়ে দেয়; লক্ষ্য একটি সহযোগী বা নয়!";
  @override
  String get specialDecelerationDescription =>
      "এই কার্ড তার লক্ষ্যগুলি দ্বিগুণ দ্রুত ধীর করে দেয়, তাদের গতি দ্বিগুণ করে দেয়। লক্ষ্য একটি সহযোগী বা নয় তা দেখা দেয়!";
  @override
  String get specialAccelerationDescription =>
      "এই কার্ড তার লক্ষ্যগুলি দ্বিগুণ দ্রুত দ্রুত করে দেয়, তাদের গতি দ্বিগুণ করে দেয়। লক্ষ্য একটি সহযোগী বা নয় তা দেখা দেয়!";
  @override
  String get specialAttackIncreaseDescription =>
      "এই কার্ড তার লক্ষ্যগুলির আক্রমণ দ্বিগুণ করে দেয়, তাদের আক্রমণ দ্বিগুণ হয়। লক্ষ্য একটি সহযোগী বা নয় তা দেখা দেয়!";
  @override
  String get specialAttackDecreaseDescription =>
      "এই কার্ড তার লক্ষ্যগুলির আক্রমণ দ্বিগুণ করে দেয়, তাদের আক্রমণ দ্বিগুণ হয়। লক্ষ্য একটি সহযোগী বা নয় তা দেখা দেয়!";
  @override
  String get specialResistanceIncreaseDescription =>
      "এই কার্ড তার লক্ষ্যগুলির সহনশীলতা দ্বিগুণ করে দেয়, তাদের সহনশীলতা দ্বিগুণ হয়। লক্ষ্য একটি সহযোগী বা নয় তা দেখা দেয়!";
  @override
  String get specialResistanceDecreaseDescription =>
      "এই কার্ড তার লক্ষ্যগুলির সহনশীলতা দ্বিগুণ করে দেয়, তাদের সহনশীলতা দ্বিগুণ হয়। লক্ষ্য একটি সহযোগী বা নয় তা দেখা দেয়!";
  @override
  String get specialSupportIncreaseDescription =>
      "এই কার্ড তার লক্ষ্যগুলির সহায়তা দ্বিগুণ করে দেয়, তাদের সহায়তা দ্বিগুণ হয়। লক্ষ্য একটি সহযোগী বা নয় তা দেখা দেয়!";
  @override
  String get specialSupportDecreaseDescription =>
      "এই কার্ড তার লক্ষ্যগুলির সহায়তা দ্বিগুণ করে দেয়, তাদের সহায়তা দ্বিগুণ হয়। লক্ষ্য একটি সহযোগী বা নয় তা দেখা দেয়!";
  @override
  String get specialCloningDescription =>
      "এই কার্ড সীমাবদ্ধ জীবনে তার লক্ষ্য কার্ডের সমস্ত বৈশিষ্ট্য এবং সুযোগ একটি কার্ড উপর ক্লোন করতে দেয়!";
  @override
  String get specialCancellationDescription =>
      "এই কার্ড তার লক্ষ্যগুলির বিশেষ কার্যকরী প্রভাব বাতিল করে, লক্ষ্য একটি সহযোগী বা নয়। তবে, এটি তার সাথে বাতিল হতে পারে না!";
  @override
  String get specialRefrigerationDescription =>
      "এই কার্ড তার লক্ষ্যগুলির মালিকের দ্বারা পরিবর্তন হতে দেয় না, লক্ষ্য একটি সহযোগী বা নয়!";
  @override
  String get specialAspiratorDescription =>
      "এই কার্ড একটি প্রমাণিত সময়ে তার দ্বরা একটি কার্ডের একটি ক্ষেত্রে বসে থাকা সমস্ত কার্ড মুছে ফেলে!";
  @override
  String get specialSubstractionDescription =>
      "এই কার্ড একটি প্রমাণিত সময়ে তার দ্বারা একটি কার্ডের সাথে একটি লাইন এবং একটি কলামে অবস্থিত সমস্ত কার্ড মুছে ফেলে!";
  @override
  String get specialDivisionDescription =>
      "এই কার্ড একটি প্রমাণিত সময়ে তার দ্বারা একটি কার্ডের একটি প্রান্তিক অবস্থিত সমস্ত কার্ড মুছে ফেলে!";
  @override
  String get specialDeflagrationDescription =>
      "এই কার্ড একটি প্রমাণিত সময়ে তার দ্বারা একটি কার্ডের সাথে একটি লাইন, একটি কলাম এবং একটি প্রান্তিকে অবস্থিত সমস্ত কার্ড মুছে ফেলে!";
  @override
  String get specialParalysisDescription =>
      "এই কার্ড সীমাবদ্ধ জীবনে তার লক্ষ্য কার্ডগুলির আক্রমণ বা প্রতিরোধ করতে অক্ষম, লক্ষ্য একটি সহযোগী বা নয়!";
  @override
  String get specialInvulnerabilityDescription =>
      "এই কার্ড সীমাবদ্ধ জীবনে তার লক্ষ্য কার্ডগুলির জন্য অক্ষমতা প্রদান করে একটি সময় প্রতিবর্তন করে!";
  @override
  String get specialVortexDescription =>
      "এই কার্ড সীমাবদ্ধ জীবনে তার লক্ষ্য কার্ডটি সহ আপনার খেলার ঠিকানা সহ একটি কার্ড স্থানান্তর করতে দেয়!";

  /* GAME */

  @override
  String get gameAbandonmentButtonDescription =>
      "আপনার প্রতিদ্বন্দ্বী স্বয়ংক্রিয়ভাবে বিজয়ী ঘোষিত হবে! আপনি কি সত্যিই এই খেলাটি পরিত্যাগ করতে চান?";
  @override
  String get gameAbandonmentButtonAbandon => "পরিত্যাগ করুন";
  @override
  String get gameAbandonmentButtonTitle => "পরিত্যাগ";

  @override
  String get gameBottomButtonDisplayResult => "ফলাফল দেখান";

  @override
  String get gameCardsSummaryPlay => "খেলা";
  @override
  String get gameCardsSummaryRemember => "ভালো মনে রাখুন!";

  @override
  String get gameInitialTutorialPopupPlay => "খেলা";

  @override
  String get gamePassButtonPopupPass => "পাস";
  @override
  String get gamePassButtonPopupDescription =>
      "চালানো যাওয়ার আগে নিশ্চিত হোন যে, আপনি খেলার নিয়মগুলি ভালোভাবে জানেন। আপনি কি সত্যিই টিউটোরিয়ালটি বাদ দিতে চান?";
  @override
  String get gamePassButtonPopupTitle => "টিউটোরিয়াল পাস করুন";

  @override
  String get adventureVictoryPossibleToPlayNextLevelDescription =>
      "আপনার জয়ের জন্য অভিনন্দন! আপনি এই স্তরটি সফলভাবে পার করেছেন। আপনি পরবর্তী স্তরে যেতে পারেন!";
  @override
  String get adventureVictoryImpossibleToPlayNextLevelDescription =>
      "পরবর্তী স্তরে খেলার জন্য আপনার যত্ন প্রয়োজন! 1 টি কাউরি পেতে একটি বিজ্ঞাপন দেখুন!";
  @override
  String get adventureVictoryGameFinishedDescription =>
      "আপনি 'সোলিটেয়ার' মোড সম্পন্ন করেছেন!\nবিশ্বের প্রায় সমস্ত খেলোয়াড় অনলাইন খেলায় আপনির জন্য অপেক্ষা করছে!";
  @override
  String get adventureDefeatPossibleToPlayAgainDescription =>
      "আপনার পরাজয়ের জন্য দু: খিত! হারিয়ে নিতে সাবধান হবেন না: আপনি পুনরায় খেলার মাধ্যমে আপনি স্বন্ত্যেষ্ট হতে পারেন!";
  @override
  String get adventureDefeatImpossibleToPlayAgainDescription =>
      "আপনার পুনরায় খেলার জন্য যত্ন প্রয়োজন! 1 টি কাউরি পেতে একটি বিজ্ঞাপন দেখুন!";
  @override
  String get adventureDefeatPossibleToPlayNextLevelDescription =>
      "আপনার পরাজয়ের জন্য দু: খিত! চাইতেও, আপনি ইতিমধ্যে এই স্তরটি পার করেছেন এবং পরবর্তী স্তরে যেতে পারেন!";
  @override
  String get adventureDefeatImpossibleToPlayNextLevelDescription =>
      "পরবর্তী স্তরে খেলার জন্য আপনার যত্ন প্রয়োজন! 1 টি কাউরি পেতে একটি বিজ্ঞাপন দেখুন!";
  @override
  String get adventureGameAlreadyFinishedDescription =>
      "আপনার পরাজয়ের জন্য দু: খিত! সম্পর্কে না, আপনি ইতিমধ্যে এই গেম মোডের সমস্ত স্তর সম্পন্ন করেছেন!";
  @override
  String get remoteDefeatDescription =>
      "আপনার পরাজয়ের জন্য দু: খিত! নিরাশ হওয়া বাড়ি: আপনি আরও খেলার মাধ্যমে নিজেকে উন্নত করতে পারেন!";
  @override
  String get remoteVictoryDescription =>
      "আপনার জয়ের জন্য অভিনন্দন! আপনি অনলাইনে আরও খেলার সাথে আপনার স্তর আরও উন্নত করতে পারেন!";
  @override
  String get remotePossibleToPlayAgainDescription =>
      "আপনার পুনরায় খেলার জন্য যত্ন প্রয়োজন! 1 টি কাউরি পেতে একটি বিজ্ঞাপন দেখুন!";
  @override
  String get remoteOpponentUnavailableDescription =>
      "অন্য খেলোয়াড় খেলার জন্য আর প্রাপ্ত নেই। তবে, আপনার জন্য এখানে আরও অনেক বিকল্প রয়েছে!";
  @override
  String get externalNeedinessDescription =>
      "অন্য খেলোয়াড় খেলার জন্য যত্ন প্রয়োজন! তবে, আপনি তাকিয়ে পারেন অথবা একটি নতুন খেলা শুরু করতে পারেন!";
  @override
  String get internalNeedinessTitle => "কাউরি অপর্যাপ্ত!";
  @override
  String get replayImpossibleDescription =>
      "অন্য খেলোয়াড় সংযোগ করেননি। তবে, আপনি অন্য খেলোয়াড়ের সাথে একটি নতুন খেলা শুরু করতে পারেন!";
  @override
  String get invitationWithdrawalDescription =>
      "অন্য খেলোয়াড় তার পুনরায় খেলার আমন্ত্রণ প্রত্যাহার করেছে। তবে, আপনি এখানে একটি নতুন খেলা শুরু করতে পারেন!";
  @override
  String get invitationRejectionDescription =>
      "দুঃখিত, আপনার আমন্ত্রণ দু: খিত হয়েছে। তবে, আপনি এখানে একটি নতুন খেলা শুরু করতে পারেন!";
  @override
  String get invitationAcceptationDescription =>
      "আপনি দুটি প্রস্তুত খেলার জন্য! একটু ধৈর্য ধরুন! খেলা কিছু ক্ষণে পুনরায় চালিত হবে!";
  @override
  String get externalInvitationReplayImpossibleDescription =>
      "আপনার আমন্ত্রণ গ্রহণ করার জন্য আপনি কাউরি অপর্যাপ্ত! 1 টি কাউরি পেতে একটি বিজ্ঞাপন দেখুন!";
  @override
  String get externalInvitationReplayPossibleDescription =>
      "অন্য খেলোয়াড় আবার আপনার সাথে একটি নতুন খেলা খেতে চান! আপনি কি তার আমন্ত্রণ গ্রহণ করতে বা প্রত্যাখ্যান করতে চান?";
  @override
  String get internalInvitationDescription =>
      "অন্য খেলোয়াড় আপনার খেলার আমন্ত্রণ প্রাপ্ত করেছেন। তিনি এটি গ্রহণ বা প্রত্যাখ্যান করতে পারেন!";

  @override
  String get gamePopupNewGame => "নতুন\nখেলা";
  @override
  String get gamePopupNextLevel => "পরবর্তী\nস্তর";
  @override
  String get gamePopupReplay => "পুনরায়\nখেলা";
  @override
  String get globalExit => "বেরিয়ে যান";
  @override
  String get globalAccept => "গ্রহণ করুন";
  @override
  String get globalReject => "প্রত্যাখ্যান করুন";
  @override
  String get globalCancel => "বাতিল করুন";
  @override
  String get normalDefeatTitle => "আপনি হারিয়েছেন!";
  @override
  String get defeatByAbandonment => "বাতিলে হার!";
  @override
  String get normalVictoryTitle => "আপনি জিতেছেন!";
  @override
  String get victoryByAbandonment => "বাতিলে জয়!";
  @override
  String get externalNeedinessTitle => "উফ!";
  @override
  String get internalNeedinessDescription =>
      "অন্য খেলোয়াড় আপনার সাথে আবার একটি খেলা খেতে চান, কিন্তু আপনার খেলার জন্য কাউরি নেই!";
  @override
  String get replayImpossibleTitle => "পুনরায় খেলা অসম্ভব!";
  @override
  String get invitationWithdrawalTitle => "আমন্ত্রণ প্রাপ্ত নেই!";
  @override
  String get invitationRejectionTitle => "আমন্ত্রণ প্রত্যাখ্যান!";
  @override
  String get invitationAcceptationTitle => "খেলা লোড হচ্ছে!";
  @override
  String get externalInvitationTitle => "আপনি কি আবার খেলতে চান?";
  @override
  String get internalInvitationTitle => "একটু ধৈর্য ধরুন!";
  @override
  String get gameProfilePosterClose => "বন্ধ করুন";
  @override
  String get gameProfilePosterDeck => "ডেক";
  @override
  String get gameProfilePosterCards => "কার্ড";
  @override
  String get gameProfilePosterCrowns => "কোরোন";

  @override
  List<String> get names => [
    "আলেক্জ",
    "সোনিয়া",
    "বাসিল",
    "ইয়োয়ান",
    "ইসাক",
    "রোবার্টো",
    "টাঙ্গুয়ি",
    "জেসি",
    "অ্যালিস",
    "ক্রিস্টিয়ান",
    "ফ্যাবিয়েন",
    "মিমি",
    "মোরিস",
    "লুসি",
    "জোসিয়ান",
    "ভিয়ানি",
    "অ্যানিসেট",
    "এডেলাইন",
    "বেনেডিক্ট",
    "রোসা",
    "দেবোরাহ",
    "অ্যাঞ্জ",
    "ক্লেমেন্স",
    "অড",
    "মিরেল",
    "সেসিল",
    "লরেন্স",
    "মারিস",
    "নাদেজ",
    "সিল্ভি",
    "ক্লারিস",
    "ক্লোড",
    "ক্লটিল্ড",
    "আন্দ্রে",
    "ক্রিস্টিন",
    "লিওপোল্ড",
    "জেনেভিয়েভ",
    "এস্থার",
    "ফ্লোর",
    "অ্যাঞ্জেল",
    "জেনিফার",
    "হিউগস",
    "হিউগেট",
    "অলিভিয়ার",
    "জুডিথ",
    "মার্টিন",
    "রেচেল",
    "আন্তুয়ান",
    "আলফ্রেড",
    "মার্থ",
    "বব",
  ];

  @override
  String gameTileNameLevel(int level) => "স্তর $level";
  @override
  String get gameTopBarTutorialText => "টিউটোরিয়াল";

  @override
  String get gametutorialCongratulationsPopupPlay => "খেলা";
  @override
  String get gametutorialCongratulationsPopupTitle => "অভিনন্দন !";
  @override
  String get gameTutorialCongratulationsPopupUnclearDescription =>
      "আপনি এই পাঠটি সফলভাবে সম্পন্ন করেছেন! তবে এখনো অন্ধকারের অঞ্চল থাকলে আপনি পুনরায় শুরু করতে পারেন!";

  @override
  String get gameTutorialPopupTitle => "সাহায্য";

  @override
  String get gameTutorialProgressPopupNextLesson => "পরবর্তী পাঠ্য";
  @override
  String get gameTutorialProgressPopupTitle => "অভিনন্দন !";

  /* USER CUBIT */

  @override
  String get referralNotificationTitle => "+50 করি !";

  @override
  String referralNotificationBody(String name) =>
      "অভিনন্দন ! আপনি $name-র নিবন্ধনের সাথে 50 করি পেয়েছেন !";

  /* NOTIFICATION */

  @override
  String get notificationMissBody =>
      "আমরা আপনার দেখা সব কিছু করেছি না বলেই দিয়েছে এখানে একটি সমাপন্ন দিন! মজা করার জন্য আসুন আপনার মাথা চুরি করুন !";
  @override
  String get notificationMissTitle => "আমরা আপনার কাছে নেই !";
  @override
  String get notificationGiftBody =>
      "প্রতি ঘণ্টা, আপনি বিনামূল্যে করি পেয়ে ! আসুন আপনার উপহার নিয়ে আসুন !";
  @override
  String get notificationGiftTitle => "আপনি আপনার উপহার না হারান !";

  /* GLOBAL */

  @override
  String get kingConquestInstruction =>
      "রাজা রং পরিবর্তন হওয়ার জন্য অপেক্ষা করুন খেলা জিততে।";
  @override
  String get invalidDeckTitle => "অবৈধ ডেক !";
  @override
  String get invalidDeckDescription =>
      "আপনার বর্তমান ডেক অবৈধ। নতুন খেলা খেলার আগে এটি ঠিক করুন বা অন্য একটি নির্বাচন করুন !";

  @override
  String get authenticationPopupAuthenticationErrorDescription =>
      "আমরা আপনার খেলার অ্যাকাউন্টে সংযোগ করতে পারিনি। দয়া করে আপনার ইন্টারনেট সংযোগ যাচাই করুন এবং আবার চেষ্টা করুন!";
  @override
  String get authenticationPopupAuthenticationErrorTitle => "সংযোগ ত্রুটি !";

  @override
  String get globalRetry => "পুনরায় চেষ্টা করুন";

  @override
  String get authenticationPopupRequiredAuthentication =>
      "প্রমাণীকরণ প্রয়োজন !";

  @override
  String get authenticationPopupLoadingAuthentication => "সংযোগ চলছে !";

  @override
  String authenticationPopupDescription(String account) =>
      "আমরা আপনাকে আপনার $account অ্যাকাউন্টে সংযোগ করতে চলেছি যাতে আপনি খেলায় অগ্রগতি সংরক্ষণ করতে পারেন!";

  @override
  String get globalAppleGameCenter => "আপেল গেম সেন্টার";

  @override
  String get globalGooglePlay => "গুগল প্লে গেমস";

  @override
  String cardOptionButtonPopupDeckN(int index) => "ডেক $index";

  @override
  String get cardOptionButtonDescription =>
      "আপনি সর্বোচ্চ 3 টি ডেক পেতে পারেন। আপনার ডেক দেখুন এবং এখান থেকে আপনার খেলার ডেক নির্বাচন করুন।";

  @override
  String get globalValidate => "বৈধ";

  @override
  String get blockedAccountContactSakiHub => "সাকি হাব-কে যোগাযোগ করুন";

  @override
  String get blockedAccountDescription =>
      "একটি গৈর-বৈধ বা সন্দেহজনক কার্যকলাপের পরে একটি অ্যাকাউন্ট লক হয়েছে। এই লকটি একটি ভুল হলে, আমাদের সাথে যোগাযোগ করুন!";
  @override
  String get blockedAccountTitle => "আপনার অ্যাকাউন্ট বন্ধ হয়েছে !";

  @override
  String get progressOptionButtonNotAuthenticationDescription =>
      "করি আপনার স্বাধীনতা বাড়াতে এবং খেলা খেলার জন্য আপনি প্রথমে সংযোগিত হতে হবে !";

  @override
  String get progressOptionButtonNotAuthenticatedTitle => "আপনি করি নেই !";

  @override
  String get progressOptionButtonShowcase =>
      "খেলার মুদ্রা, খেলার কার্ড কেনার জন্য গুরুত্বপূর্ণ। আপনার করি এখানে পরিচালনা করুন।";

  @override
  String get globalAd => "বিজ্ঞাপন";

  @override
  String get globalConnect => "সংযোগ";

  /* FAMILIES */

  @override
  String get attackerFamilyName => "আক্রমণকারী";
  @override
  String get attackerFamilyShortDescription => "লাল কার্ড: আক্রমণে দক্ষ";
  @override
  String get attackerFamilyLongDescription =>
      "এই কার্ডগুলি তাদের শত্রুদের সবচেয়ে বেশি ক্ষতি করে। তবে, অন্য এলাকায় তারা এখনও ভালো নয় !";

  @override
  String get defenderFamilyName => "রক্ষণাত্মক";
  @override
  String get defenderFamilyShortDescription => "ধূসর কার্ড: প্রতিরোধে দক্ষ";
  @override
  String get defenderFamilyLongDescription =>
      "এই কার্ডগুলির সর্বোচ্চ প্রতিরোধ আছে। তবে, অন্য এলাকায় তারা এখনও ভালো নয় !";

  @override
  String get healerFamilyName => "চিকিত্সক";
  @override
  String get healerFamilyShortDescription =>
      "সবুজ কার্ড: চিকিত্সা দেওয়ার দক্ষ";
  @override
  String get healerFamilyLongDescription =>
      "এই কার্ডগুলি তাদের বন্ধুদের সেরা চিকিত্সক। তবে, অন্য এলাকায় তারা এখনও ভালো নয় !";

  @override
  String get lordFamilyName => "রাজা";
  @override
  String get lordFamilyShortDescription =>
      "রাজা: সব কিছু সম্পর্কে সাবধানো দরকার";
  @override
  String get lordFamilyLongDescription =>
      "এই কার্ডগুলি খেলায় অবশ্যই সুরক্ষিত থাকতে হবে: আপনি যদি আপনার রাজা রং পরিবর্তন হয়, তাহলে স্বায়ত্তভরে হারিয়ে যাবেন !";

  @override
  String get normalFamilyName => "নরমাল";
  @override
  String get normalFamilyShortDescription => "বাদামী কার্ড: সাধারণ সুবিধা";
  @override
  String get normalFamilyLongDescription =>
      "নরমাল খেলোয়াড়রা খেলায় সবচেয়ে সামান্য হারায়। তারা খেলা উপরে একটি বিশেষ সুবিধা সাধারণভাবে আপনার দিকে !";

  @override
  String get specialFamilyName => "বিশেষ";
  @override
  String get specialFamilyShortDescription =>
      "হলুদ কার্ড: অন্য কার্ডে বিশেষ প্রভাব";
  @override
  String get specialFamilyLongDescription =>
      "এই কার্ডগুলি অন্য কার্ডে প্রভাব ফেলে। তাদের প্রভাব প্রধানত তাদের স্বভাবে নির্ভর করে !";

  /* LESSONS */

  @override
  String get basicsLessonTitle => "পাঠ 1/3: খেলার মৌলিক";
  @override
  String get globalLesson => "পাঠ";
  @override
  String get basicsLessonSuffix => "খেলার মৌলিক";
  @override
  String get basicsLessonWinningMessage =>
      "আপনার বিজয়ের জন্য অভিনন্দন! খেলার কার্ডের ভূমিকা সম্পর্কে জানতে দ্রুত পরবর্তী পাঠে যান!";

  @override
  String get normalLessonTitle => "পাঠ 2/3: কার্ডের ভূমিকা";
  @override
  String get normalLessonSuffix => "কার্ডের ভূমিকা";
  @override
  String get specialLessonSuffix => "বিশেষ কার্ড";
  @override
  String get normalLessonDescription =>
      "লাল কার্ড আক্রমণে দক্ষ, সবুজ সমর্থন, ধূসর প্রতিরোধ এবং মারুন সমান! ";
  @override
  String get normalLessonWinningMessage =>
      "আপনার বিজয়ের জন্য অভিনন্দন! কাঁদে পাতা না দেওয়ার জন্য দ্রুত পরবর্তী পাঠে যান!";

  @override
  String get specialLessonTitle => "পাঠ 3/3: বিশেষ কার্ড";
  @override
  String get specialLessonDescription =>
      "হলুদ কার্ডের অন্যদের উপর বিশেষ প্রভাব থাকে। একটি বিশেষ কার্ডের প্রভাব মূলভূতভাবে তার প্রাকৃতিক বৈশিষ্ট্যের উপর নির্ভর করে!";

  /* MESSAGES */

  @override
  String get awesomeMessage => "আদর্শ";
  @override
  String get congratulationsMessage => "অভিনন্দন";
  @override
  String get excellentMessage => "অত্যদুর্দর্শ";
  @override
  String get goodMessage => "ভাল";
  @override
  String get greatMessage => "সুস্থ্য";
  @override
  String get magnificentMessage => "অদ্ভুত";
  @override
  String get masterfulMessage => "প্রভুত্ব";

  /* TUTORIALS INSTRUCTIONS */

  @override
  String get basicsPlaceTileInstruction =>
      "আপনার মুখোমুখি যৌথ যোগ্য একটি কার্ড প্রাপ্ত করার জন্য খেলার মাধ্যমে একটি কার্ড প্রাপ্ত করুন।";
  @override
  String get basicsConnectCenterTileInstruction =>
      "গ্রে কার্ডে সংযোগ করতে, একটি কার্ড স্থানান্তর করুন এবং গ্রে কার্ডে স্থানান্তর করুন!";
  @override
  String get basicsConquerCenterTileInstruction =>
      "গ্রে কার্ডের রঙ পরিবর্তন হতে হলে আপনার একটি সংযোগ থাকতে হবে এবং এর পয়েন্টগুলি 0 হতে হবে!";
  @override
  String get basicsCutPathInstruction =>
      "দুটি কার্ডের মধ্যে সংযোগ মুছে ফেলতে, যেভাবে নির্দেশিত করা আছে তা করুন!";
  @override
  String get basicsConnectKingInstruction =>
      "দ্বিধা করা দরকার নেই। রাজা কার্ডে সংযোগ করুন!";
  @override
  String get normalPlaceOrdinaryCitizenInstruction =>
      "আপনার দ্বিধা করতে হতে পারে। খেলার মাধ্যমে একটি কার্ড প্রাপ্ত করুন!";
  @override
  String get normalConnectOrdinaryCitizenInstruction =>
      "প্রতিস্থান কার্ডে সংযোগ করতে, মূল কার্ড থেকে লক্ষ্য করা কার্ডে একটি কার্ড স্থানান্তর করুন!";
  @override
  String get normalPlaceHealerInstruction =>
      "আপনার রাজা আক্রমিত এবং তাকে চিকিৎসা দেওয়া প্রয়োজন। মূল কার্ড থেকে একটি চিকিৎসক স্থানান্তর করুন!";
  @override
  String get normalConnectHealerInstruction =>
      "আপনার রাজা দ্বিধা করা আছে এবং তাকে তাড়াতাড়ি নিরাপদ করুন যাতে তা রং পরিবর্তন না করে!";
  @override
  String get normalPlaceAttackerInstruction =>
      "আপনি প্রতিস্থাপন করতে হতে পারে। খেলার মাধ্যমে একটি আক্রমণকারী কার্ড প্রাপ্ত করুন!";
  @override
  String get normalConnectAttackerInstruction =>
      "প্রতিস্থাপন করতে, মূল কার্ড থেকে লক্ষ্য করা কার্ডে একটি কার্ড স্থানান্তর করুন!";
  @override
  String get normalConquerAttackerInstruction =>
      "আপনার লক্ষ্যের কার্ডের রঙ পরিবর্তন হতে হলে আপনার একটি সংযোগ থাকতে হবে এবং এর পয়েন্টগুলি 0 হতে হবে!";
  @override
  String get normalPlaceDefenderInstruction =>
      "আপনার নগরবাসী প্রতিস্থাপন করতে হতে পারে। খেলার মাধ্যমে একটি রক্ষক কার্ড প্রাপ্ত করুন!";
  @override
  String get normalConnectDefenderInstruction =>
      "আপনার নগরবাসী কার্ড স্থানান্তর করুন যাতে তা আপনার রাজাকে হয়রানি না দেয়!";
  @override
  String get normalConnectKingInstruction =>
      "আপনার রাজা আক্রমণ করা হচ্ছে। তাতে চোখ রাখুন!";
  @override
  String get specialPlaceOrdinaryCitizenInstruction =>
      "আপনি প্রতিস্থাপন করতে হতে পারে। খেলার মাধ্যমে একটি সাধারণ নাগরিক কার্ড প্রাপ্ত করুন!";
  @override
  String get specialPlaceCompressionInstruction =>
      "প্রতিস্থাপন করতে, মূল কার্ড থেকে লক্ষ্য করা কার্ডে একটি কার্ড স্থানান্তর করুন!";
  @override
  String get specialConnectCompressionInstruction =>
      "আপনার লক্ষ্যের কার্ডের সাথে সংযোগ করতে, মূল কার্ড থেকে লক্ষ্য করা কার্ডে একটি কার্ড স্থানান্তর করুন!";
  @override
  String get specialPlaceRefrigerationInstruction =>
      "আপনার লক্ষ্যের কার্ডের সাথে সংযোগ করতে পারে। খেলার মাধ্যমে একটি রেফ্রিজারেশন কার্ড প্রাপ্ত করুন!";
  @override
  String get specialConnectRefrigerationInstruction =>
      "আপনার লক্ষ্যের কার্ড সাথে সংযোগ করতে, মূল কার্ড থেকে লক্ষ্য করা কার্ডে একটি কার্ড স্থানান্তর করুন!";
  @override
  String get specialConnectOrdinaryCitizen1Instruction =>
      "আপনার লক্ষ্যের কার্ড সাথে সংযোগ করতে, মূল কার্ড থেকে লক্ষ্য করা কার্ডে একটি কার্ড স্থানান্তর করুন!";
  @override
  String get specialPlaceExpansionInstruction =>
      "আপনি প্রতিস্থাপন করতে পারে। খেলার মাধ্যমে একটি বিস্তারণ কার্ড প্রাপ্ত করুন!";
  @override
  String get specialConnectExpansionInstruction =>
      "প্রতিস্থাপন করতে, মূল কার্ড থেকে লক্ষ্য করা কার্ডে একটি কার্ড স্থানান্তর করুন!";
  @override
  String get specialConnectOrdinaryCitizen2Instruction =>
      "আপনার লক্ষ্যের কার্ডের সাথে সংযোগ করতে, মূল কার্ড থেকে লক্ষ্য করা কার্ডে একটি কার্ড স্থানান্তর করুন!";
  @override
  String get specialConquerOrdinaryCitizenInstruction =>
      "আপনার লক্ষ্যের কার্ডের রঙ পরিবর্তন হতে হলে আপনার একটি সংযোগ থাকতে হবে এবং এর পয়েন্টগুলি 0 হতে হবে!";
  @override
  String get specialConnectKingInstruction =>
      "আপনার রাজা আক্রমণ করা হচ্ছে। চোখ রাখুন এবং তাকে ধ্বংস করতে শেষ করুন!";

  /* TUTORIALS DESCRIPTIONS */

  @override
  String get basicsPlaceTileDescription =>
      "একটি কার্ড স্থানান্তর করতে, প্লেস করার জন্য লক্ষ্য করা কার্ড থেকে প্লেস করার জন্য স্লাইড করুন!";
  @override
  String get basicsConnectCenterTileDescription =>
      "গ্রে কার্ডে সংযোগ করতে, প্লেস করার জন্য লক্ষ্য করা কার্ড থেকে স্লাইড করুন!";
  @override
  String get basicsConquerCenterTileDescription =>
      "গ্রে কার্ডের রঙ পরিবর্তন হতে হলে একটি সংযোগ থাকতে হবে এবং এর পয়েন্টগুলি 0 হতে হবে!";
  @override
  String get basicsCutPathDescription =>
      "দুটি কার্ডের মধ্যে সংযোগ কাটতে, স্যুইপিং করে একটি সেগমেন্ট ট্রেস করার জন্য স্যুইপ করুন!";
  @override
  String get basicsConnectKingDescription =>
      "আপনার রাজা কার্ডে সংযোগ করতে, প্লেস করার জন্য লক্ষ্য করা কার্ড থেকে প্লেস করার জন্য স্লাইড করুন!";
  @override
  String get kingConquestDescription =>
      "কিং কার্ডের রঙ পরিবর্তন হতে হলে একটি সংযোগ থাকতে হবে এবং এর পয়েন্টগুলি 0 হতে হবে!";
  @override
  String get normalPlaceOrdinaryCitizenDescription =>
      "একটি কার্ড স্থানান্তর করতে, প্লেস করার জন্য লক্ষ্য করা কার্ড থেকে প্লেস করার জন্য স্লাইড করুন!";
  @override
  String get normalConnectOrdinaryCitizenDescription =>
      "প্রতিস্থান কার্ডে সংযোগ করতে, মূল কার্ড থেকে লক্ষ্য করা কার্ডে একটি কার্ড স্থানান্তর করুন!";
  @override
  String get normalPlaceHealerDescription =>
      "আপনার রাজা কার্ড আক্রমিত এবং তাকে তাড়াতাড়ি চিকিৎসা দেয়া প্রয়োজন! প্লেস করার জন্য লক্ষ্য করা কার্ড থেকে প্লেস করার জন্য স্লাইড করুন!";
  @override
  String get normalConnectHealerDescription =>
      "আপনার রাজা দ্বিধা করা আছে এবং তাকে তাড়াতাড়ি নিরাপদ করতে হবে যাতে তা রং পরিবর্তন না করে! প্রতিস্থান কার্ডে সংযোগ করতে, মূল কার্ড থেকে লক্ষ্য করা কার্ডে একটি কার্ড স্থানান্তর করুন!";
  @override
  String get normalPlaceAttackerDescription =>
      "আপনি প্রতিস্থাপন করতে পারে। খেলার মাধ্যমে একটি আক্রমণকারী কার্ড প্রাপ্ত করুন!";
  @override
  String get normalConnectAttackerDescription =>
      "প্রতিস্থাপন করতে, মূল কার্ড থেকে লক্ষ্য করা কার্ডে একটি কার্ড স্থানান্তর করুন!";
  @override
  String get normalConquerAttackerDescription =>
      "আপনার লক্ষ্যের কার্ডের রঙ পরিবর্তন হতে হলে একটি সংযোগ থাকতে হবে এবং এর পয়েন্টগুলি 0 হতে হবে!";
  @override
  String get normalPlaceDefenderDescription =>
      "আপনার নগরবাসী প্রতিস্থাপন করতে পারে। খেলার মাধ্যমে একটি রক্ষক কার্ড প্রাপ্ত করুন!";
  @override
  String get normalConnectDefenderDescription =>
      "আপনার নগরবাসী কার্ড স্থানান্তর করুন যাতে তা আপনার রাজাকে হয়রানি না দেয়!";
  @override
  String get normalConnectKingDescription =>
      "আপনার রাজা আক্রমণ করা হচ্ছে। তাতে চোখ রাখুন!";
  @override
  String get specialPlaceOrdinaryCitizenDescription =>
      "আপনি প্রতিস্থাপন করতে পারে। খেলার মাধ্যমে একটি সাধারণ নাগরিক কার্ড প্রাপ্ত করুন!";
  @override
  String get specialPlaceCompressionDescription =>
      "প্রতিস্থাপন করতে, মূল কার্ড থেকে লক্ষ্য করা কার্ডে একটি কার্ড স্থানান্তর করুন!";
  @override
  String get specialConnectCompressionDescription =>
      "আপনার লক্ষ্যের কার্ডের সাথে সংযোগ করতে, মূল কার্ড থেকে লক্ষ্য করা কার্ডে একটি কার্ড স্থানান্তর করুন!";
  @override
  String get specialPlaceRefrigerationDescription =>
      "আপনার লক্ষ্যের কার্ডের সাথে সংযোগ করতে পারে। খেলার মাধ্যমে একটি রেফ্রিজারেশন কার্ড প্রাপ্ত করুন!";
  @override
  String get specialConnectRefrigerationDescription =>
      "আপনার লক্ষ্যের কার্ড সাথে সংযোগ করতে, মূল কার্ড থেকে লক্ষ্য করা কার্ডে একটি কার্ড স্থানান্তর করুন!";
  @override
  String get specialConnectOrdinaryCitizen1Description =>
      "আপনার লক্ষ্যের কার্ড সাথে সংযোগ করতে, মূল কার্ড থেকে লক্ষ্য করা কার্ডে একটি কার্ড স্থানান্তর করুন!";
  @override
  String get specialPlaceExpansionDescription =>
      "আপনি প্রতিস্থাপন করতে পারে। খেলার মাধ্যমে একটি বিস্তারণ কার্ড প্রাপ্ত করুন!";
  @override
  String get specialConnectExpansionDescription =>
      "প্রতিস্থাপন করতে, মূল কার্ড থেকে লক্ষ্য করা কার্ডে একটি কার্ড স্থানান্তর করুন!";
  @override
  String get specialConnectOrdinaryCitizen2Description =>
      "আপনার লক্ষ্যের কার্ডের সাথে সংযোগ করতে, মূল কার্ড থেকে লক্ষ্য করা কার্ডে একটি কার্ড স্থানান্তর করুন!";
  @override
  String get specialConquerOrdinaryCitizenDescription =>
      "আপনার লক্ষ্যের কার্ডের রঙ পরিবর্তন হতে হলে একটি সংযোগ থাকতে হবে এবং এর পয়েন্টগুলি 0 হতে হবে!";
  @override
  String get specialConnectKingDescription =>
      "আপনার রাজা আক্রমণ করা হচ্ছে। চোখ রাখুন এবং তাকে ধ্বংস করতে শেষ করুন!";

  /* SKILLS */

  @override
  String get attackSkillNull => "শূন্য";
  @override
  String get attackSkillVeryBad => "অত্যন্ত খারাপ";
  @override
  String get attackSkillBad => "খারাপ";
  @override
  String get attackSkillNormal => "সাধারণ";
  @override
  String get attackSkillGood => "ভাল";
  @override
  String get attackSkillVeryGood => "অত্যন্ত ভাল";

  @override
  String get supportSkillNull => "শূন্য";
  @override
  String get supportSkillVeryBad => "অত্যন্ত খারাপ";
  @override
  String get supportSkillBad => "খারাপ";
  @override
  String get supportSkillNormal => "সাধারণ";
  @override
  String get supportSkillGood => "ভাল";
  @override
  String get supportSkillVeryGood => "অত্যন্ত ভাল";

  @override
  String get resistanceSkillNull => "শূন্য";
  @override
  String get resistanceSkillVeryBad => "অত্যন্ত খারাপ";
  @override
  String get resistanceSkillBad => "খারাপ";
  @override
  String get resistanceSkillNormal => "সাধারণ";
  @override
  String get resistanceSkillGood => "ভাল";
  @override
  String get resistanceSkillVeryGood => "অত্যন্ত ভাল";

  @override
  String get lifeSkillNull => "শূন্য";
  @override
  String get lifeSkillHalf => "আধা";
  @override
  String get lifeSkillNormal => "সাধারণ";

  @override
  String get speedSkillNull => "শূন্য";
  @override
  String get speedSkillHalf => "আধা";
  @override
  String get speedSkillNormal => "সাধারণ";

  @override
  String remoteComplexCloseDescription(int cowries) =>
      "এই অংশের সমাপনী আপনি $cowries সিউরিস হারাবেন! আপনি কি সত্যিই খেলাটি বন্ধ করতে চান?";
  @override
  String adventureComplexCloseDescription(int cowries) =>
      "এই অংশের সমাপনী আপনি $cowries সিউরিস হারাবেন! আপনি কি সত্যিই খেলাটি বন্ধ করতে চান?";
  @override
  String get adventureSimpleCloseDescription =>
      "আপনার বর্তমান খেলার অগ্রগতি স্থায়ীভাবে হারিয়ে যাবে! আপনি কি সত্যিই বর্তমান খেলা বন্ধ করতে চান?";
  @override
  String get remoteSimpleCloseDescription =>
      "এই অংশের সমাপনী তার বর্তমান অগ্রগতি হারাবে! আপনি কি সত্যিই এই অংশটি বন্ধ করতে চান?";
  @override
  String get closeClose => "বন্ধ করুন";
  @override
  String get closeTitle => "বন্ধ করুন";

  @override
  String get watchAdButtonRefreshAd => "বিজ্ঞাপন রিফ্রেশ করুন";
  @override
  String get cardOptionButtonPopupSelectDeck => "এই ডেক চয়ন করুন";

  @override
  String get lessonChangeTitle => "পাঠে পরিবর্তন";
  @override
  String get lessonChangeDescription =>
      "এই পাঠের শেখার পর অন্য পাঠে যেতে আপনাকে আপনার শেখা দেওয়া প্রয়োজন! আপনি কি সত্যিই পাঠ পরিবর্তন করতে চান?";
  @override
  String get lessonChangeAction => "পরিবর্তন";

  @override
  String get restoreDefaultLanguage => "ডিফল্ট ভাষা পুনরুদ্ধার করুন";

  //

  @override
  String get loadingDescription =>
      "আমরা খেলার ডেটা লোড করছি। একটু অপেক্ষা করুন!";
  @override
  String get homeUpdateSimpleDescription =>
      "খেলার নতুন সংস্করণ উপলব্ধ। নতুন বৈশিষ্ট্য উপভোগ করতে তা দ্রুত ইনস্টল করুন!";
  @override
  String get gametutorialCongratulationsPopupDescription =>
      "এখন আপনি খেলার বিশ্বে প্রবেশ করতে এবং তার প্রত্যেকটি সূক্ষ্মতার অনুভূতিতে প্রবেশ করতে পারেন!";
  @override
  String gameScoresIndicatorNormalGameDescription(int level) =>
      "আমি খেলার লেভেল $level এর কৃত্রিম বুদ্ধিমত্তা! আমি আপনাকে একটি ভালো খেলা উপহার দেওয়ার জন্য সম্ভব পরিশ্রম করব!";
  @override
  String get gameScoresIndicatorTutorialGameDescription =>
      "আমি খেলার টিউটোরিয়াল এর কৃত্রিম বুদ্ধিমত্তা। আপনাকে জিততে নির্দেশ অনুসরণ করতে হবে তাই!";

  @override
  String get homeCowriesStoreTransactionErrorTitle => "লেনদেন বাতিল!";
  @override
  String get homeCowriesStoreTransactionErrorDescription =>
      "আমরা আপনার ক্রয়ণ সত্যাপন করতে পারি নি। দয়া করে আপনার পেমেন্ট মাধ্যম এবং ইন্টারনেট সংযোগ পরীক্ষা করুন!";

  @override
  String get drawTitle => "ড্র খেলা!";
  @override
  String get adventureDrawGameFinishedDescription =>
      "আপনি বারাবার সমান সমাপ্ত করেছেন! তবে আপনি এই গেম মোডের সমস্ত স্তর সম্পন্ন করে ফেলেছেন!";
  @override
  String get adventureDrawPossibleToPlayNextLevelDescription =>
      "আপনি সমান সমাপ্ত করেছেন! তবে আপনি এই স্তর সম্পন্ন করেছেন এবং পরবর্তী স্তরে যেতে পারেন!";
  @override
  String get adventureDrawPossibleToPlayAgainDescription =>
      "আপনি সমান সমাপ্ত করেছেন! আপনি আইআরে বন্ধুত্বপূর্ণ বন্ধুত্বে একটি নতুন খেলা করে জয় অর্জন করতে পারেন!";
  @override
  String get remoteDrawDescription =>
      "আপনি জয় বা পরাজয় অর্জন করেননি! অন্য খেলোয়াড়ের সাথে আরেকটি খেলা শুরু করে তাকে প্রতিপাত করা যাবে কেন?";
  @override
  String get newPlayer => "নতুন খেলোয়াড়";

  @override
  String get premiumButtonRemoveAds => "বিজ্ঞাপন সরান";

  @override
  String get localNetworkWaitingForHost => "হোস্টের অপেক্ষায়…";

  @override
  String get localNetworkHostLeftDescription =>
      "হোস্ট খেলা ছেড়ে দিয়েছেন: এই টেবিল শেষ। আপনি মেনু থেকে নতুন খেলা শুরু করতে পারেন।";

  @override
  String get replayVoteChooseOption => "প্রতিশোধের জন্য একটি মোড বাছুন";

  @override
  String replayVoteCountdown(int seconds) =>
      "${seconds}s পরে প্রস্তুত খেলোয়াড়দের নিয়ে শুরু";

  @override
  String get replayVoteStartingSoon =>
      "যাঁরা রাজি হয়েছেন তাঁদের নিয়ে খেলা শুরু হবে";

  @override
  String get replayVoteWaitingForPlayers => "অন্য খেলোয়াড়দের অপেক্ষায়";
}
