class AdventureUtility {
  final int maxLevel;
  final int levelsPerChapter;
  final int Function(dynamic user) getUserLevel;
  final List<int> Function(dynamic user) getUserStars;
  final bool Function(dynamic user) isUserBroke;
  // user?.broke == true
  final int chapters;
  final int gameEndReward;
  final int initialLevelsLimit;

  const AdventureUtility({
    required this.maxLevel,
    required this.levelsPerChapter,
    required this.getUserLevel,
    required this.getUserStars,
    required this.chapters,
    required this.isUserBroke,
    this.gameEndReward = 50,
    this.initialLevelsLimit = 5,
  });
}
