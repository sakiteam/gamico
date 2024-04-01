class MatchmakingSettings {
  final int minLevel;
  final int maxLevel;

  final int increment;

  final int Function(dynamic user) getMatchmakingLevel;

  const MatchmakingSettings({
    required this.minLevel,
    required this.maxLevel,
    required this.getMatchmakingLevel,
    required this.increment,
  });
}
