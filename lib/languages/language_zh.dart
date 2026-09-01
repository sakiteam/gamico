import 'package:gamico/languages/languages.dart';

abstract class GamicoLanguageZh extends GamicoLanguages {
  @override
  String get globalMax => "最大";
  @override
  String get globalRefresh => "刷新";
  @override
  String get globalClose => "关闭";
  @override
  String get globalOK => "确定";

  /* FRIEND */

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
  String get friendPageInvitationSent => "邀请已发送！";

  @override
  String get friendPageFailedToSendInvitation => "发送邀请失败";

  @override
  String get friendPageUnknown => "未知";
  @override
  String get notificationInvitationBody => "您收到了一条游戏邀请！";
  @override
  String notificationInvitationFrom(String name) => "$name 邀请您一起玩！";

  /* ADVENTURE */

  @override
  String get adventureHelpTitle => "帮助";
  @override
  String get adventureHelpDescription => "您可以通过单击来选择一个级别。但是如果您还不太会玩，请跟随教程！";
  @override
  String get adventureClose => "关闭";
  @override
  String get adventureFollow => "跟随";

  @override
  String adventureChapterChapter(int chapter) => "章节 $chapter";

  /* COLLECTION */

  @override
  String collectionCardPopupFamily(String family) => "家庭：$family";
  @override
  String get collectionCardPopupUpgrade => "升级";
  @override
  String get collectionCardPopupRemove => "移除";
  @override
  String get collectionCardPopupUse => "使用";
  @override
  String get collectionCardPopupAcquire => "获取";

  @override
  String get collectionCardSkillsAttack => "攻击";
  @override
  String get collectionCardSkillsSupport => "支持";
  @override
  String get collectionCardSkillsResistance => "抵抗";
  @override
  String get collectionCardSkillsTheoreticalLife => "理论生命";
  @override
  String get collectionCardSkillsTheoreticalSpeed => "理论速度";
  @override
  String get collectionCardSkillsPower => "力量";
  @override
  String get collectionCardSkillsConcreteLife => "实际生命";
  @override
  String get collectionCardSkillsConcreteSpeed => "实际速度";
  @override
  String get collectionCardSkillsConnections => "连接";

  @override
  String collectionCardSquareLevel(int level) => "等级 $level";

  @override
  String get collectionCardBlocked => "被阻止";
  @override
  String collectionCardLevel(int level) => "等级 $level";

  @override
  String get collectionContentDeck => "卡组";
  @override
  String get collectionContentUnlockedCards => "已解锁的卡片";
  @override
  String get collectionContentRemainingCards => "剩余卡片";

  /* HOME */

  @override
  String get homeLanguagesTitle => "语言";

  /* HOME */

  @override
  String get homeMultiplayerButtonShowcase => "这个按钮允许您与其他玩家在线游戏。";
  @override
  String get homeSingleplayerButtonShowcase => "这个按钮允许您与游戏的人工智能进行游戏。";
  @override
  String get homeNotificationsTitle => "通知";
  @override
  String get homeNotificationsDescription => "为了提高您的游戏体验，您需要允许通知！您想允许通知吗？";
  @override
  String get homeNotificationsAllow => "允许";
  @override
  String get homeNotificationsReminderTitle => "开启通知";
  @override
  String get homeNotificationsReminderDescription =>
      "通知有助于提升您的游戏体验。您想现在开启吗？";
  @override
  String get homeUpdateTitle => "有更新可用！";
  @override
  String get homeUpdateForceDescription => "新版本中修复了多个错误和问题。快速安装以享受这些修复！";
  @override
  String get homeUpdateInstall => "安装";

  @override
  String get homeAbout => "关于";
  @override
  String homeAboutPopupShareText(String link) =>
      "我发现了一个非常有趣的策略游戏！在$link上免费下载它！";
  @override
  String get homeAboutPopupImplementation => "实施";
  @override
  String get homeAboutPopupMusic => "音乐";
  @override
  String get homeAboutPopupVersion => "版本";
  @override
  String get homeAboutPopupRateGame => "评分\n游戏";
  @override
  String get homeAboutPopupVisitWebstie => "访问\nSaki Hub";
  @override
  String get homeAboutPopupDiscoverApps => "查看我的\n应用程序";

  @override
  String get homeCardPresentationShowcase => "使用此菜单购买新卡并改进您已拥有的卡。";
  @override
  String get homeCardPresentationShow => "查看所有卡";

  @override
  String get homeGratificationPopupConnectionErrorTitle => "连接错误！";
  @override
  String get homeGratificationPopupConnectionErrorDescription =>
      "请检查您的互联网连接。此部分将在您连接后自动刷新！";
  @override
  String get homeGratificationPopupLoadingTitle => "加载奖励！";
  @override
  String get homeGratificationPopupLoadingDescription => "奖励将在几秒钟内可用。请稍候！";
  @override
  String get homeGratificationPopupIncorrectTimestampTitle => "时间戳错误！";

  @override
  String get homeMultiplayerButtonConnectionErrorTitle => "连接问题！";
  @override
  String get homeMultiplayerButtonConnectionErrorDescription =>
      "看起来您没有连接到互联网。请检查您的互联网连接质量，然后重试！";
  @override
  String get homeMultiplayerButtonText => "多人";

  @override
  String get homeProfilePopupBestTacticians => "最佳策略家";
  @override
  String get homeProfilePopupDescription => "玩家根据在线获胜次数和最大卡利的数量进行排名！";
  @override
  String get homeProfilePopupBestCollectors => "最佳收藏家";
  @override
  String get homeProfilePopupCheckAchievements => "查看我的成就";

  @override
  String get homeSingleplayerButtonText => "单人";

  @override
  String get homeSpecialOfferPopupOfferDisabledDescription =>
      "特别优惠每3天激活一次，仅在24小时内有效。不要错过下一个！";
  @override
  String get homeSpecialOfferPopupOfferLoadedDescription =>
      "特别优惠每3天激活一次，仅在24小时内有效。那么，您还在等什么呢？";
  @override
  String get homeSpecialOfferPopupOfferLoadingDescription =>
      "与特别优惠相关的数据将很快可用。请稍等片刻！";
  @override
  String get homeSpecialOfferPopupErrorDescription =>
      "我们无法验证您的购买。请检查您的付款方式和互联网连接！";
  @override
  String homeSpecialOfferPopupOffsetLoadedTitle(String? packTitle) =>
      "$packTitle！";
  @override
  String get homeSpecialOfferPopupOfferLoadingTitle => "加载优惠！";
  @override
  String get homeSpecialOfferPopupErrorTitle => "交易取消！";
  @override
  String get homeSpecialOfferPopupClose => "关闭";
  @override
  String get homeSpecialOfferPopupTimestampTitle => "时间戳不正确！";
  @override
  String get homeSpecialOfferPopupLoadingDescription =>
      "与特别优惠相关的数据将很快可用。请稍等片刻！";
  @override
  String get homeSpecialOfferPopupLoadingTitle => "加载优惠！";
  @override
  String get homeSpecialOfferPopupProblemClose => "关闭";
  @override
  String get homeSpecialOfferPopupProblemTitle => "连接问题！";

  @override
  String get premiumPopupTitle => "高级模式";
  @override
  String get premiumPopupDescription => "解锁完整版以移除所有广告！";
  @override
  String get premiumPlayer => "高级玩家";
  @override
  String get nonPremiumPlayer => "非高级玩家";

  @override
  String get homeHelpBasicsA => "蓝色王国面对橙色王国。";
  @override
  String get homeHelpBasicsB => "可以通过改变敌方领主的颜色来获胜。";
  @override
  String get homeHelpBasicsC => "可以在规定的时间内拥有最多的生命点数来获胜。";

  @override
  String get homeHelpConnections1A => "您可以点击并拖动以连接两张卡片。";
  @override
  String get homeHelpConnections1B => "您可以点击并点击以连接两张卡片。";
  @override
  String get homeHelpConnections1C => "您可以通过滑动手指来切断连接。";

  @override
  String get homeHelpConnections2A => "有时候，连接可能会妨碍游戏的能力。";
  @override
  String get homeHelpConnections2B => "不能跳过一张卡片连接到另一张卡片。";
  @override
  String get homeHelpConnections2C => "最大化的卡片会返回它收到的所有球。";

  @override
  String get homeHelpCards1A => "红色卡片适合攻击。";
  @override
  String get homeHelpCards1B => "灰色卡片适合抵抗。";
  @override
  String get homeHelpCards1C => "绿色卡片适合支持。";

  @override
  String get homeHelpCards2A => "棕色卡片具有平衡的能力。";
  @override
  String get homeHelpCards2B => "黄色卡片对其他卡片具有特殊效果。";
  @override
  String get homeHelpCards2C => "白色卡片是必须不惜一切代价保护的卡片。";

  @override
  String get homeHelpRestrictionsA => "每个连接都必须有用。在这里，它是无用的，因此不可能。";
  @override
  String get homeHelpRestrictionsB => "毁灭卡不能攻击领主。";
  @override
  String get homeHelpRestrictionsC => "不能克隆或移动领主。";

  /* LOADING */

  @override
  String get loadingTitle => "请稍等!";

  /* REMOTE */

  @override
  String get remoteConnexionProblemTitle => "连接问题!";
  @override
  String get remoteConnexionProblemDescription =>
      "对不起！您的互联网连接已断开。您已被宣布为游戏的失败者！";
  @override
  String get remoteInvitationTitle => "来玩吧!";
  @override
  String get remoteInvitationDescription => "您的在线游戏已经开始了!";
  @override
  String get remoteMultiplayer => "多人游戏";

  @override
  String get remoteFailurePosterTitle => "发生了错误!";
  @override
  String get remoteFailurePosterDescription => "在搜索过程中发生了错误。请检查您的互联网连接并重试!";

  @override
  String get remoteImpossibleGamePosterTitle => "贝壳不足!";
  @override
  String remoteImpossibleGamePosterDescription(int cowries) =>
      "您需要至少有 $cowries 个贝壳才能在线玩游戏!";

  @override
  String get remoteNewGamePosterTitle => "新游戏?";
  @override
  String get remoteNewGamePosterDescription => "您仍然可以与世界各地的玩家玩游戏，提高您的水平!";

  @override
  String get remoteSearchPosterTitle => "寻找玩家";
  @override
  String get remoteSearchPosterDescription => "我们正在全球范围内寻找玩家与您玩游戏!";

  @override
  String get homeTranslationPopupDescription => "本节允许您选择游戏的主要语言。单击一种语言以自动激活！";

  /* 卡片标题 */

  @override
  String get lordLazyKingName => "懒惰国王";
  @override
  String get lordLazyQueenName => "脆弱女王";
  @override
  String get lordLazyPrinceName => "孤独王子";
  @override
  String get lordLazyPrincessName => "内向公主";
  @override
  String get lordCourageousKingName => "实际国王";
  @override
  String get lordCourageousQueenName => "无畏女王";
  @override
  String get lordCourageousPrinceName => "坚韧王子";
  @override
  String get lordCourageousPrincessName => "忠诚公主";
  @override
  String get normalOrdinaryCitizenName => "普通市民";
  @override
  String get normalAttackerDefenderName => "军事卫士";
  @override
  String get normalAttackerHealerName => "军事医生";
  @override
  String get normalDefenderHealerName => "卫士医生";
  @override
  String get attacker2AName => "流感";
  @override
  String get attacker2BName => "太阳";
  @override
  String get attacker2CName => "火花";
  @override
  String get attacker4AName => "旋风";
  @override
  String get attacker4BName => "小虫";
  @override
  String get attacker4CName => "飓风";
  @override
  String get defender2AName => "石头";
  @override
  String get defender2BName => "鹅卵石";
  @override
  String get defender2CName => "壁垒";
  @override
  String get defender4AName => "光束";
  @override
  String get defender4BName => "阳台";
  @override
  String get defender4CName => "窗户";
  @override
  String get healer2AName => "草";
  @override
  String get healer2BName => "花";
  @override
  String get healer2CName => "叶";
  @override
  String get healer4AName => "灌木";
  @override
  String get healer4BName => "创可贴";
  @override
  String get healer4CName => "树";
  @override
  String get specialExpansionName => "扩张";
  @override
  String get specialCompressionName => "压缩";
  @override
  String get specialDecelerationName => "减速";
  @override
  String get specialAccelerationName => "加速";
  @override
  String get specialAttackIncreaseName => "勇气";
  @override
  String get specialAttackDecreaseName => "胆怯";
  @override
  String get specialResistanceIncreaseName => "增强";
  @override
  String get specialResistanceDecreaseName => "削弱";
  @override
  String get specialSupportIncreaseName => "利他主义";
  @override
  String get specialSupportDecreaseName => "个人主义";
  @override
  String get specialCloningName => "克隆";
  @override
  String get specialCancellationName => "取消";
  @override
  String get specialRefrigerationName => "制冷";
  @override
  String get specialAspiratorName => "深渊";
  @override
  String get specialSubstractionName => "减法";
  @override
  String get specialDivisionName => "除法";
  @override
  String get specialDeflagrationName => "燃烧";
  @override
  String get specialParalysisName => "麻痹";
  @override
  String get specialInvulnerabilityName => "无敌";
  @override
  String get specialVortexName => "涡流";

  /* 卡片描述 */

  @override
  String get lordLazyKingDescription =>
      "这是唯一不能攻击也不能防御的领主。然而，他是一个平衡的国王，没有明显的弱点！";
  @override
  String get lordLazyQueenDescription =>
      "这位女士非常擅长进攻和支持她的臣民，尽管年事已高。然而，她的抵抗力有待提高！";
  @override
  String get lordLazyPrinceDescription => "这位年轻人非常擅长进攻和抵抗攻击。然而，他不懂如何支持他的臣民！";
  @override
  String get lordLazyPrincessDescription =>
      "这位年轻女性非常擅长抵抗攻击和支持她的臣民。然而，她的攻击能力有限！";
  @override
  String get lordCourageousKingDescription =>
      "这是一个平衡的国王，没有明显的弱点。然而，他的生命值只有正常的一半！";
  @override
  String get lordCourageousQueenDescription => "这位女士非常擅长进攻，尽管年事已高。但她在其他方面并不出色！";
  @override
  String get lordCourageousPrinceDescription => "这位年轻人非常擅长抵抗攻击。但他在其他方面并不出色！";
  @override
  String get lordCourageousPrincessDescription =>
      "这位年轻女性非常擅长支持她的臣民。但她在其他方面并不出色！";
  @override
  String get normalOrdinaryCitizenDescription =>
      "这张卡片是游戏中最平衡的。它没有明显的优势或劣势，但仍然是一个可靠的盟友！";
  @override
  String get normalAttackerDefenderDescription =>
      "正如其名称所示，这是一位擅长攻击敌人并抵御他们攻击的年轻人！";
  @override
  String get normalAttackerHealerDescription => "正如其名称所示，这是一位擅长攻击敌人并支援盟友的年轻人！";
  @override
  String get normalDefenderHealerDescription =>
      "正如其名称所示，这是一位擅长支援盟友并抵御敌人攻击的年轻人！";
  @override
  String get attacker2ADescription => "这张卡片对敌人造成的伤害是普通卡片的两倍，但在支援盟友方面表现不佳！";
  @override
  String get attacker2BDescription => "这张卡片对敌人造成的伤害是普通卡片的两倍，但对敌人的攻击抵抗力较低！";
  @override
  String get attacker2CDescription => "这张卡片对敌人造成的伤害是普通卡片的两倍，但速度只有普通卡片的一半！";
  @override
  String get attacker4ADescription => "这张卡片对敌人造成的伤害是普通卡片的四倍，但在支援盟友方面表现不佳！";
  @override
  String get attacker4BDescription => "这张卡片对敌人造成的伤害是普通卡片的四倍，但对敌人的攻击抵抗力非常低！";
  @override
  String get attacker4CDescription => "这张卡片对敌人造成的伤害是普通卡片的四倍，但在其他方面并不出色！";
  @override
  String get defender2ADescription => "这张卡片的抵抗力是普通卡片的两倍，但在攻击敌人方面表现不佳！";
  @override
  String get defender2BDescription => "这张卡片的抵抗力是普通卡片的两倍，但在支援盟友方面表现不佳！";
  @override
  String get defender2CDescription => "这张卡片的抵抗力是普通卡片的两倍，但速度只有普通卡片的一半！";
  @override
  String get defender4ADescription => "这张卡片的抵抗力是普通卡片的四倍，但在攻击敌人方面表现不佳！";
  @override
  String get defender4BDescription => "这张卡片的抵抗力是普通卡片的四倍，但在支援盟友方面表现不佳！";
  @override
  String get defender4CDescription => "这张卡片的抵抗力是普通卡片的四倍，但在其他方面并不出色！";
  @override
  String get healer2ADescription => "这张卡片治疗盟友的速度是普通卡片的两倍，但在攻击敌人方面表现不佳！";
  @override
  String get healer2BDescription => "这张卡片治疗盟友的速度是普通卡片的两倍，但对敌人的攻击抵抗力较低！";
  @override
  String get healer2CDescription => "这张卡片治疗盟友的速度是普通卡片的两倍，但速度只有普通卡片的一半！";
  @override
  String get healer4ADescription => "这张卡片治疗盟友的速度是普通卡片的四倍，但在攻击敌人方面表现不佳！";
  @override
  String get healer4BDescription => "这张卡片治疗盟友的速度是普通卡片的四倍，但对敌人的攻击抵抗力非常低！";
  @override
  String get healer4CDescription => "这张卡片治疗盟友的速度是普通卡片的四倍，但在其他方面并不出色！";
  @override
  String get specialExpansionDescription => "这张卡片将目标卡片的攻击可能性增加一次，无论目标是盟友还是敌人！";
  @override
  String get specialCompressionDescription =>
      "这张卡片将目标卡片的攻击可能性减少一次，无论目标是盟友还是敌人！";
  @override
  String get specialDecelerationDescription =>
      "这张卡片将目标减速，将其速度减小一半。无论目标是盟友还是敌人！";
  @override
  String get specialAccelerationDescription =>
      "这张卡片将目标加速，将其速度提高一倍。无论目标是盟友还是敌人！";
  @override
  String get specialAttackIncreaseDescription => "这张卡片将目标的攻击力提高一倍。无论目标是盟友还是敌人！";
  @override
  String get specialAttackDecreaseDescription => "这张卡片将目标的攻击力减小一倍。无论目标是盟友还是敌人！";
  @override
  String get specialResistanceIncreaseDescription =>
      "这张卡片将目标的抵抗力提高一倍。无论目标是盟友还是敌人！";
  @override
  String get specialResistanceDecreaseDescription =>
      "这张卡片将目标的抵抗力减小一倍。无论目标是盟友还是敌人！";
  @override
  String get specialSupportIncreaseDescription =>
      "这张卡片将目标的支援能力提高一倍。无论目标是盟友还是敌人！";
  @override
  String get specialSupportDecreaseDescription =>
      "这张卡片将目标的支援能力减小一倍。无论目标是盟友还是敌人！";
  @override
  String get specialCloningDescription => "这是一张有限寿命的卡片，允许复制目标卡片在游戏场地上的所有属性和能力！";
  @override
  String get specialCancellationDescription =>
      "这张卡片取消目标的特殊效果，无论目标是盟友还是敌人。然而，它无法以任何方式取消！";
  @override
  String get specialRefrigerationDescription => "这张卡片阻止目标被其拥有者修改，无论目标是盟友还是敌人！";
  @override
  String get specialAspiratorDescription =>
      "这是一张有限寿命的卡片，允许在一定时间后摧毁其周围一格范围内的所有卡片，时间与其当前级别成比例！";
  @override
  String get specialSubstractionDescription =>
      "这是一张有限寿命的卡片，允许在一定时间后摧毁其所在行和列的所有卡片，时间与其当前级别成比例！";
  @override
  String get specialDivisionDescription =>
      "这是一张有限寿命的卡片，允许在一定时间后摧毁其对角线上的所有卡片，时间与其当前级别成比例！";
  @override
  String get specialDeflagrationDescription =>
      "这是一张有限寿命的卡片，允许在一定时间后摧毁其所在行、列和对角线上的所有卡片，时间与其当前级别成比例！";
  @override
  String get specialParalysisDescription =>
      "这是一张有限寿命的卡片，使目标无法攻击或防御，无论目标是盟友还是敌人！";
  @override
  String get specialInvulnerabilityDescription =>
      "这是一张有限寿命的卡片，使目标在一段时间内免疫伤害，时间与其当前级别成比例！";
  @override
  String get specialVortexDescription => "这是一张有限寿命的卡片，允许与目标卡片交换位置，从而移动目标卡片！";

  /* 游戏 */

  @override
  String get gameAbandonmentButtonDescription => "您的对手将被自动宣布为胜利者！您真的要放弃这场比赛吗？";
  @override
  String get gameAbandonmentButtonAbandon => "放弃";
  @override
  String get gameAbandonmentButtonTitle => "放弃";

  @override
  String get gameBottomButtonDisplayResult => "显示结果";

  @override
  String get gameCardsSummaryPlay => "玩";
  @override
  String get gameCardsSummaryRemember => "记住！";

  @override
  String get gameInitialTutorialPopupPlay => "玩";

  @override
  String get gamePassButtonPopupPass => "跳过";
  @override
  String get gamePassButtonPopupDescription => "在继续之前，请确保您熟悉游戏规则。您真的要跳过教程吗？";
  @override
  String get gamePassButtonPopupTitle => "跳过教程";

  @override
  String get adventureVictoryPossibleToPlayNextLevelDescription =>
      "恭喜您获胜！您已成功完成了这个级别。您可以前进到下一个级别！";
  @override
  String get adventureVictoryImpossibleToPlayNextLevelDescription =>
      "您没有足够的宝贝来玩下一个级别！观看广告以获得1个宝贝！";
  @override
  String get adventureVictoryGameFinishedDescription =>
      "您已完成“单人”模式！\n全球玩家在在线游戏世界等待着您！";
  @override
  String get adventureDefeatPossibleToPlayAgainDescription =>
      "为您的失败感到抱歉！不要灰心：您可以通过再次玩游戏来改善自己！";
  @override
  String get adventureDefeatImpossibleToPlayAgainDescription =>
      "遗憾的是，您没有足够的宝贝来重新玩游戏！观看广告以获得1个宝贝！";
  @override
  String get adventureDefeatPossibleToPlayNextLevelDescription =>
      "为您的失败感到抱歉！无论如何，您已经通过了这个级别，可以前进到下一个级别！";
  @override
  String get adventureDefeatImpossibleToPlayNextLevelDescription =>
      "您没有足够的宝贝来玩下一个级别！观看广告以获得1个宝贝！";
  @override
  String get adventureGameAlreadyFinishedDescription =>
      "为您的失败感到抱歉！无论如何，您已经完成了该游戏模式的所有级别！";
  @override
  String get remoteDefeatDescription =>
      "为您的失败感到抱歉！不要灰心：通过参加更多的比赛，您仍然可以提高自己的水平！";
  @override
  String get remoteVictoryDescription => "恭喜您获胜！通过参加更多的在线比赛，您还可以提高自己的水平！";
  @override
  String get remotePossibleToPlayAgainDescription =>
      "遗憾的是，您没有足够的宝贝来重新玩游戏！观看广告以获得1个宝贝！";
  @override
  String get remoteOpponentUnavailableDescription =>
      "另一名玩家不再可用于比赛。但是，您仍然有许多其他选择！";
  @override
  String get externalNeedinessDescription => "另一名玩家没有足够的宝贝来玩游戏。但是您可以等待或开始新的比赛！";
  @override
  String get internalNeedinessTitle => "宝贝不足！";
  @override
  String get replayImpossibleDescription => "另一名玩家已经下线了。但是，您仍然可以与其他玩家开始新的比赛！";
  @override
  String get invitationWithdrawalDescription =>
      "另一名玩家已撤回了再次比赛的邀请。但是，您仍然可以开始新的比赛！";
  @override
  String get invitationRejectionDescription => "很遗憾，您的邀请被拒绝了。但是，您仍然可以开始新的比赛！";
  @override
  String get invitationAcceptationDescription => "您们两位都准备好再次比赛。稍等片刻！游戏将在片刻后继续！";
  @override
  String get externalInvitationReplayImpossibleDescription =>
      "您没有足够的宝贝来接受邀请！观看广告以获得1个宝贝！";
  @override
  String get externalInvitationReplayPossibleDescription =>
      "另一名玩家希望与您再次开始新的比赛！您要接受还是拒绝他的邀请？";
  @override
  String get internalInvitationDescription =>
      "另一名玩家收到了有关您再次比赛邀请的通知。他可以接受或拒绝这个邀请！";

  @override
  String get gamePopupNewGame => "新的\n游戏";
  @override
  String get gamePopupNextLevel => "下一个\n级别";
  @override
  String get gamePopupReplay => "重播";
  @override
  String get globalExit => "退出";
  @override
  String get globalAccept => "接受";
  @override
  String get globalReject => "拒绝";
  @override
  String get globalCancel => "取消";
  @override
  String get normalDefeatTitle => "您失败了！";
  @override
  String get defeatByAbandonment => "因放弃而败！";
  @override
  String get normalVictoryTitle => "您胜利了！";
  @override
  String get victoryByAbandonment => "因放弃而胜！";
  @override
  String get externalNeedinessTitle => "哎呀！";
  @override
  String get internalNeedinessDescription => "另一名玩家希望与您再次比赛，但您没有足够的宝贝来玩！";
  @override
  String get replayImpossibleTitle => "无法重播！";
  @override
  String get invitationWithdrawalTitle => "邀请已撤回！";
  @override
  String get invitationRejectionTitle => "邀请被拒绝！";
  @override
  String get invitationAcceptationTitle => "游戏加载中！";
  @override
  String get externalInvitationTitle => "您要再次比赛吗？";
  @override
  String get internalInvitationTitle => "稍等片刻！";
  @override
  String get gameProfilePosterClose => "关闭";
  @override
  String get gameProfilePosterDeck => "卡组";
  @override
  String get gameProfilePosterCards => "卡牌";
  @override
  String get gameProfilePosterCrowns => "皇冠";

  @override
  List<String> get names => [
    "亚历克斯",
    "索尼娅",
    "巴西尔",
    "约翰",
    "艾萨克",
    "罗伯特",
    "坦吉",
    "杰西",
    "爱丽丝",
    "克里斯蒂安",
    "法比安",
    "米米",
    "莫里斯",
    "露西",
    "若西安",
    "维安尼",
    "阿尼塞特",
    "阿德琳",
    "本尼迪克特",
    "罗莎",
    "德博拉",
    "安吉",
    "克莱曼斯",
    "奥德",
    "米莱尔",
    "塞西尔",
    "劳伦斯",
    "马里奥",
    "纳代吉",
    "西尔维",
    "克拉丽丝",
    "克洛德",
    "克罗蒂尔德",
    "安德烈",
    "克里斯汀",
    "利奥波德",
    "吉纳维芙",
    "埃斯特尔",
    "弗洛尔",
    "安吉莉卡",
    "珍妮弗",
    "休伊",
    "休格特",
    "奥利弗",
    "朱迪思",
    "马丁",
    "拉海尔",
    "安托万",
    "阿尔弗雷德",
    "玛莎",
    "鲍勃",
  ];

  @override
  String gameTileNameLevel(int level) => "级别 $level";
  @override
  String get gameTopBarTutorialText => "教程";

  @override
  String get gametutorialCongratulationsPopupPlay => "开始游戏";
  @override
  String get gametutorialCongratulationsPopupTitle => "恭喜！";
  @override
  String get gameTutorialCongratulationsPopupUnclearDescription =>
      "您已成功完成本课程！但如果仍然有黑暗区域，您随时可以重新开始！";

  @override
  String get gameTutorialPopupTitle => "帮助";

  @override
  String get gameTutorialProgressPopupNextLesson => "下一课";
  @override
  String get gameTutorialProgressPopupTitle => "恭喜！";

  /* USER CUBIT */

  @override
  String get referralNotificationTitle => "+50 Cowries！";

  @override
  String referralNotificationBody(String name) =>
      "恭喜！由于 $name 的注册，您获得了 50 Cowries！";

  /* NOTIFICATION */

  @override
  String get notificationMissBody => "我们已经好几天没有见到您了。来玩游戏锻炼您的大脑吧！";
  @override
  String get notificationMissTitle => "我们想念您！";
  @override
  String get notificationGiftBody => "每小时您都可以免费获得 Cowries！来领取您的礼物吧！";
  @override
  String get notificationGiftTitle => "不要错过您的礼物！";

  /* GLOBAL */

  @override
  String get kingConquestInstruction => "等待国王的颜色改变，以赢得比赛。";
  @override
  String get invalidDeckTitle => "无效的卡组！";
  @override
  String get invalidDeckDescription => "您当前的卡组无效。在开始新游戏之前，请纠正它或选择其他卡组！";

  @override
  String get authenticationPopupAuthenticationErrorDescription =>
      "无法连接到您的游戏帐户。请检查您的互联网连接并重试！";
  @override
  String get authenticationPopupAuthenticationErrorTitle => "身份验证错误！";

  @override
  String get globalRetry => "重试";

  @override
  String get authenticationPopupRequiredAuthentication => "需要身份验证！";
  @override
  String get authenticationPopupLoadingAuthentication => "正在验证身份！";

  @override
  String authenticationPopupDescription(String account) =>
      "我们将连接您的 $account 帐户以保存您在游戏中的进度！";

  @override
  String get globalAppleGameCenter => "Apple 游戏中心";

  @override
  String get globalGooglePlay => "Google Play 游戏";

  @override
  String cardOptionButtonPopupDeckN(int index) => "卡组 $index";

  @override
  String get cardOptionButtonDescription => "您最多可以拥有 3 个卡组。在此处查看和选择您的游戏卡组。";

  @override
  String get globalValidate => "验证";

  @override
  String get blockedAccountContactSakiHub => "联系 Saki Hub";

  @override
  String get blockedAccountDescription => "帐户封锁是非法或可疑活动的结果。如果此封锁是错误的，请与我们联系！";
  @override
  String get blockedAccountTitle => "您的帐户已被封锁！";

  @override
  String get progressOptionButtonNotAuthenticationDescription =>
      "Cowries 增加了您的游戏自由度，但您需要保持连接以使用它们！";
  @override
  String get progressOptionButtonNotAuthenticatedTitle => "您没有 Cowries！";
  @override
  String get progressOptionButtonShowcase =>
      "Cowries，游戏货币，用于购买卡片和游戏。在这里管理您的 Cowries。";

  @override
  String get globalAd => "广告";

  @override
  String get globalConnect => "连接";

  /* FAMILIES */

  @override
  String get attackerFamilyName => "攻击家族";
  @override
  String get attackerFamilyShortDescription => "红卡：擅长进攻";
  @override
  String get attackerFamilyLongDescription => "这些卡片对敌人造成最大伤害。然而，在其他方面表现不佳！";

  @override
  String get defenderFamilyName => "防御家族";
  @override
  String get defenderFamilyShortDescription => "灰卡：擅长防守";
  @override
  String get defenderFamilyLongDescription => "这些卡片具有最高的防御值。然而，在其他方面表现不佳！";

  @override
  String get healerFamilyName => "治疗家族";
  @override
  String get healerFamilyShortDescription => "绿卡：擅长治疗";
  @override
  String get healerFamilyLongDescription => "这些卡片能更好地治疗您的盟友。然而，在其他方面表现不佳！";

  @override
  String get lordFamilyName => "领主家族";
  @override
  String get lordFamilyShortDescription => "领主：必须全力保护";
  @override
  String get lordFamilyLongDescription =>
      "这些是游戏中必须全力保护的卡片：如果您的领主的颜色发生变化，您将自动失败！";

  @override
  String get normalFamilyName => "普通家族";
  @override
  String get normalFamilyShortDescription => "棕卡：平衡的能力";
  @override
  String get normalFamilyLongDescription => "普通卡片在游戏中最平衡。它们非常多才多艺，真正在战场上提供了优势！";

  @override
  String get specialFamilyName => "特殊家族";
  @override
  String get specialFamilyShortDescription => "黄卡：对其他卡片有特殊效果";
  @override
  String get specialFamilyLongDescription => "这些卡片对其他卡片有影响。它们的效果主要取决于它们的性质！";

  /* LESSONS */

  @override
  String get basicsLessonTitle => "基础教程 1/3：游戏基础";
  @override
  String get globalLesson => "基础教程";
  @override
  String get basicsLessonSuffix => "游戏基础";
  @override
  String get basicsLessonWinningMessage => "恭喜你获胜！要了解更多关于卡片在游戏中的角色，请继续下一课！";

  @override
  String get normalLessonTitle => "基础教程 2/3：卡片角色";
  @override
  String get normalLessonSuffix => "卡片角色";
  @override
  String get specialLessonSuffix => "特殊卡片";
  @override
  String get normalLessonDescription => "红色卡片攻击，绿色卡片支援，黄色卡片防守，蓝色卡片平衡！";
  @override
  String get normalLessonWinningMessage => "恭喜你获胜！要学习如何封锁平衡瓦片，请继续下一课！";

  @override
  String get specialLessonTitle => "基础教程 3/3：特殊卡片";
  @override
  String get specialLessonDescription => "特殊卡片具有特殊属性，更多地依赖于它们的天然特性！";

  /* MESSAGES */

  @override
  String get awesomeMessage => "太棒了！";
  @override
  String get congratulationsMessage => "恭喜！";
  @override
  String get excellentMessage => "优秀！";
  @override
  String get goodMessage => "不错！";
  @override
  String get greatMessage => "很好！";
  @override
  String get magnificentMessage => "了不起！";
  @override
  String get masterfulMessage => "精湛！";

  /* TUTORIALS INSTRUCTIONS */

  @override
  String get basicsPlaceTileInstruction => "要获得一张卡片，请将卡片拖动到您面前的目标上！";
  @override
  String get basicsConnectCenterTileInstruction =>
      "要连接到绿色卡片，请将卡片拖动到带有绿色卡片的目标上，然后将卡片放在绿色卡片上！";
  @override
  String get basicsConquerCenterTileInstruction => "要更改绿色卡片的颜色，需要连接，并且分数必须为0！";
  @override
  String get basicsCutPathInstruction => "要切断两张卡片之间的连接，请按照所示方向划线并触摸它！";
  @override
  String get basicsConnectKingInstruction => "你的国王正在受到攻击。请不要干扰他，结束你的回合！";
  String get basicsConquerKingInstruction => "要更改国王卡片的颜色，需要连接，并且分数必须为0！";
  @override
  String get normalPlaceOrdinaryCitizenInstruction =>
      "要获得普通市民卡片，请将卡片拖动到您面前的目标上！";
  @override
  String get normalConnectOrdinaryCitizenInstruction =>
      "要连接到市民卡片，请将卡片从原始卡片拖动到所选目标上！";
  @override
  String get normalPlaceHealerInstruction =>
      "你的国王受伤了，他需要立即治疗！要使用治疗卡片，请将卡片拖到相应的目标上！";
  @override
  String get normalConnectHealerInstruction =>
      "你的国王正处于危险之中，需要立即救援以防颜色变化！为了确认救援，请将卡片从原始卡片拖动到所选目标上！";
  @override
  String get normalPlaceAttackerInstruction =>
      "你可以发起攻击。要获得攻击者卡片，请将卡片拖动到您面前的目标上！";
  @override
  String get normalConnectAttackerInstruction => "要发动攻击，请将卡片从原始卡片拖动到所选目标上！";
  @override
  String get normalConquerAttackerInstruction => "要更改目标卡片的颜色，需要连接，并且分数必须为0！";
  @override
  String get normalPlaceDefenderInstruction =>
      "你可以开始加强你的防守。要获得防守者卡片，请将卡片拖动到您面前的目标上！";
  @override
  String get normalConnectDefenderInstruction =>
      "要强化防守并保护国王，请将卡片从原始卡片拖动到所选目标上！";
  @override
  String get normalConnectKingInstruction => "你的国王正在受到攻击。请不要干扰他，结束你的回合！";
  @override
  String get specialPlaceOrdinaryCitizenInstruction =>
      "你可以开始攻击。要获得普通市民卡片，请将卡片拖动到您面前的目标上！";
  @override
  String get specialPlaceCompressionInstruction => "要开始攻击，请将卡片从原始卡片拖动到所选目标上！";
  @override
  String get specialConnectCompressionInstruction =>
      "要连接到目标卡片，请将卡片从原始卡片拖动到所选目标上！";
  @override
  String get specialPlaceRefrigerationInstruction => "要连接到目标卡片，请通过游戏获得制冷卡片！";
  @override
  String get specialConnectRefrigerationInstruction =>
      "要连接到目标卡片，请将卡片从原始卡片拖动到所选目标上！";
  @override
  String get specialConnectOrdinaryCitizen1Instruction =>
      "要连接到目标卡片，请将卡片从原始卡片拖动到所选目标上！";
  @override
  String get specialPlaceExpansionInstruction =>
      "你可以开始攻击。要获得扩张卡片，请将卡片拖动到您面前的目标上！";
  @override
  String get specialConnectExpansionInstruction => "要开始攻击，请将卡片从原始卡片拖动到所选目标上！";
  @override
  String get specialConnectOrdinaryCitizen2Instruction =>
      "要连接到目标卡片，请将卡片从原始卡片拖动到所选目标上！";
  @override
  String get specialConquerOrdinaryCitizenInstruction =>
      "要更改目标卡片的颜色，需要连接，并且分数必须为0！";
  @override
  String get specialConnectKingInstruction => "你的国王正在受到攻击。请不要干扰他，结束你的回合！";

  /* TUTORIALS DESCRIPTIONS */

  @override
  String get basicsPlaceTileDescription => "要放置卡片，请将卡片拖动到目标上并释放！";
  @override
  String get basicsConnectCenterTileDescription =>
      "要连接到中央卡片，请将卡片拖动到带有绿色卡片的目标上并释放卡片！";
  @override
  String get basicsConquerCenterTileDescription => "要征服中央卡片，需要连接并且分数必须为0！";
  @override
  String get basicsCutPathDescription => "要切断两张卡片之间的连接，请按照指示的方向划线并触摸它！";
  @override
  String get basicsConnectKingDescription => "你的国王正在受到攻击。请不要干扰他，结束你的回合！";
  @override
  String get kingConquestDescription => "要改变国王卡片的颜色，需要连接并且分数必须为0！";
  @override
  String get normalPlaceOrdinaryCitizenDescription =>
      "要获得普通市民卡片，请将卡片拖动到目标上并释放！";
  @override
  String get normalConnectOrdinaryCitizenDescription =>
      "要连接到普通市民卡片，请将卡片从原始卡片拖动到所选目标上并释放卡片！";
  @override
  String get normalPlaceHealerDescription =>
      "你的国王受伤了，他需要紧急治疗！要使用治疗卡片，请将卡片拖到相应的目标上并释放卡片！";
  @override
  String get normalConnectHealerDescription =>
      "你的国王正处于危险之中，需要紧急救援以防颜色变化！要确认救援，请将卡片从原始卡片拖动到所选目标上并释放卡片！";
  @override
  String get normalPlaceAttackerDescription =>
      "你可以开始进攻。要获得攻击者卡片，请将卡片拖动到目标上并释放卡片！";
  @override
  String get normalConnectAttackerDescription =>
      "要开始进攻，请将卡片从原始卡片拖动到所选目标上并释放卡片！";
  @override
  String get normalConquerAttackerDescription => "要改变目标卡片的颜色，需要连接并且分数必须为0！";
  @override
  String get normalPlaceDefenderDescription =>
      "你可以开始加强你的防守。要获得防守者卡片，请将卡片拖动到目标上并释放卡片！";
  @override
  String get normalConnectDefenderDescription =>
      "要强化防守并保护国王，请将卡片从原始卡片拖动到所选目标上并释放卡片！";
  @override
  String get normalConnectKingDescription => "你的国王正在受到攻击。请不要干扰他，结束你的回合！";
  @override
  String get specialPlaceOrdinaryCitizenDescription =>
      "你可以开始进攻。要获得普通市民卡片，请将卡片拖动到目标上并释放卡片！";
  @override
  String get specialPlaceCompressionDescription =>
      "要开始进攻，请将卡片从原始卡片拖动到所选目标上并释放卡片！";
  @override
  String get specialConnectCompressionDescription =>
      "要连接到目标卡片，请将卡片从原始卡片拖动到所选目标上并释放卡片！";
  @override
  String get specialPlaceRefrigerationDescription => "要连接到目标卡片，请通过游戏获得制冷卡片！";
  @override
  String get specialConnectRefrigerationDescription =>
      "要连接到目标卡片，请将卡片从原始卡片拖动到所选目标上并释放卡片！";
  @override
  String get specialConnectOrdinaryCitizen1Description =>
      "要连接到目标卡片，请将卡片从原始卡片拖动到所选目标上并释放卡片！";
  @override
  String get specialPlaceExpansionDescription =>
      "你可以开始进攻。要获得扩张卡片，请将卡片拖动到目标上并释放卡片！";
  @override
  String get specialConnectExpansionDescription =>
      "要开始进攻，请将卡片从原始卡片拖动到所选目标上并释放卡片！";
  @override
  String get specialConnectOrdinaryCitizen2Description =>
      "要连接到目标卡片，请将卡片从原始卡片拖动到所选目标上并释放卡片！";
  @override
  String get specialConquerOrdinaryCitizenDescription =>
      "要改变目标卡片的颜色，需要连接并且分数必须为0！";
  @override
  String get specialConnectKingDescription => "你的国王正在受到攻击。请不要干扰他，结束你的回合！";

  /* SKILLS */

  @override
  String get attackSkillNull => "无";
  @override
  String get attackSkillVeryBad => "非常差";
  @override
  String get attackSkillBad => "差";
  @override
  String get attackSkillNormal => "普通";
  @override
  String get attackSkillGood => "良好";
  @override
  String get attackSkillVeryGood => "非常好";

  @override
  String get supportSkillNull => "无";
  @override
  String get supportSkillVeryBad => "非常差";
  @override
  String get supportSkillBad => "差";
  @override
  String get supportSkillNormal => "普通";
  @override
  String get supportSkillGood => "良好";
  @override
  String get supportSkillVeryGood => "非常好";

  @override
  String get resistanceSkillNull => "无";
  @override
  String get resistanceSkillVeryBad => "非常差";
  @override
  String get resistanceSkillBad => "差";
  @override
  String get resistanceSkillNormal => "普通";
  @override
  String get resistanceSkillGood => "良好";
  @override
  String get resistanceSkillVeryGood => "非常好";

  @override
  String get lifeSkillNull => "无";
  @override
  String get lifeSkillHalf => "半";
  @override
  String get lifeSkillNormal => "普通";

  @override
  String get speedSkillNull => "无";
  @override
  String get speedSkillHalf => "半";
  @override
  String get speedSkillNormal => "普通";

  @override
  String remoteComplexCloseDescription(int cowries) =>
      "关闭此部分将花费您正好 $cowries 贝壳！您真的要关闭游戏吗？";
  @override
  String adventureComplexCloseDescription(int cowries) =>
      "关闭此部分将花费您正好 $cowries 贝壳！您真的要关闭游戏吗？";
  @override
  String get adventureSimpleCloseDescription => "关闭当前游戏将导致您失去进度！您真的要关闭当前游戏吗？";
  @override
  String get remoteSimpleCloseDescription => "关闭此部分将导致失去其当前进度！您真的要关闭此部分吗？";
  @override
  String get closeClose => "关闭";
  @override
  String get closeTitle => "关闭";

  @override
  String get watchAdButtonRefreshAd => "刷新广告";
  @override
  String get cardOptionButtonPopupSelectDeck => "选择此牌组";

  @override
  String get lessonChangeTitle => "课程更改";
  @override
  String get lessonChangeDescription => "在切换到另一课程之前，请掌握这节课的教导！您真的想要更改课程吗？";
  @override
  String get lessonChangeAction => "更改";

  @override
  String get restoreDefaultLanguage => "恢复默认语言";

  //

  @override
  String get loadingDescription => "我们正在加载游戏数据。请稍等片刻！";
  @override
  String get homeUpdateSimpleDescription => "游戏的新版本已经发布。快速安装以享受最新功能！";
  @override
  String get gametutorialCongratulationsPopupDescription =>
      "您现在可以进入游戏世界并探索其所有细微之处！";
  @override
  String gameScoresIndicatorNormalGameDescription(int level) =>
      "我是游戏 $level 级别的人工智能！我会尽力为您提供一场精彩的比赛！";
  @override
  String get gameScoresIndicatorTutorialGameDescription =>
      "我是游戏教程的人工智能。只需按照说明即可获胜！";

  @override
  String get homeCowriesStoreTransactionErrorTitle => "交易已取消！";
  @override
  String get homeCowriesStoreTransactionErrorDescription =>
      "我们无法验证您的购买。请检查您的支付方式和互联网连接！";

  @override
  String get drawTitle => "平局!";
  @override
  String get adventureDrawGameFinishedDescription =>
      "您以平局结束！无论如何，您已经完成了此游戏模式的所有级别！";
  @override
  String get adventureDrawPossibleToPlayNextLevelDescription =>
      "您以平局结束！无论如何，您已经通过了这个级别，可以进入下一个级别！";
  @override
  String get adventureDrawPossibleToPlayAgainDescription =>
      "您以平局结束！您仍然可以通过与AI再次对战来获胜！";
  @override
  String get remoteDrawDescription => "您既没有赢也没有输！为什么不与另一位玩家开始另一局游戏来分出胜负？";
  @override
  String get newPlayer => "新玩家";

  @override
  String get premiumButtonRemoveAds => "去除广告";
}
