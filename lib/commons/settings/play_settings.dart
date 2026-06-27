import 'package:meta/meta.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';

@immutable
class PlaySettings {
  final String activePlayersLeaderboardId;
  final String inactivePlayersLeaderboardId;
  final bool enableFakeOpponent;
  final bool singlePlayerWhenFake;
  final bool displayCongratulations;
  final bool exitUserWhenDisconnected;

  /// Optional hook invoked when a *moded* remote game records a result — i.e.
  /// when the matchmaking `mode` is non-null (e.g. a secondary game embedded
  /// into the host app). Fires for the three result paths: normal end, exiting
  /// mid-game, and (client-side fallback) disconnection. When provided, the
  /// host fully owns result handling (coins + stats) for that mode, so the
  /// default top-level victory/defeat writes are skipped. Leave null to keep
  /// the default behaviour.
  final void Function(
    GamicoUserCubit userCubit,
    String mode,
    bool victory,
    int stars,
  )?
  onModedRemoteResult;

  const PlaySettings({
    required this.activePlayersLeaderboardId,
    required this.inactivePlayersLeaderboardId,
    this.enableFakeOpponent = true,
    this.singlePlayerWhenFake = false,
    this.displayCongratulations = true,
    this.exitUserWhenDisconnected = true,
    this.onModedRemoteResult,
  });
}
