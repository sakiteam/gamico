import 'package:meta/meta.dart';

@immutable
class PlaySettings {
  final String activePlayersLeaderboardId;
  final String inactivePlayersLeaderboardId;

  const PlaySettings({
    required this.activePlayersLeaderboardId,
    required this.inactivePlayersLeaderboardId,
  });
}
