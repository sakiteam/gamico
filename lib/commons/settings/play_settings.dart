import 'package:meta/meta.dart';

@immutable
class PlaySettings {
  final String activePlayersLeaderboardId;
  final String inactivePlayersLeaderboardId;
  final bool enableFakeOpponent;
  final bool singlePlayerWhenFake;
  final bool displayCongratulations;
  final bool exitUserWhenDisconnected;

  const PlaySettings({
    required this.activePlayersLeaderboardId,
    required this.inactivePlayersLeaderboardId,
    this.enableFakeOpponent = true,
    this.singlePlayerWhenFake = false,
    this.displayCongratulations = true,
    this.exitUserWhenDisconnected = true,
  });
}
