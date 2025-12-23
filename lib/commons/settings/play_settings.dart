import 'package:meta/meta.dart';

@immutable
class PlaySettings {
  final String activePlayersLeaderboardId;
  final String inactivePlayersLeaderboardId;
  final bool enableFakeOpponent;

  const PlaySettings({
    required this.activePlayersLeaderboardId,
    required this.inactivePlayersLeaderboardId,
    this.enableFakeOpponent = true,
  });
}
