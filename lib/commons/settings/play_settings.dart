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

  /// Optional veto over the generic end-of-game interstitial shown by
  /// [GamePage]. Consulted at the moment the ad would play; returning true
  /// holds it back.
  ///
  /// For host apps that run a sequence of games as one unit and own the ad
  /// rhythm themselves — a best-of-3 tournament tie, say, where the generic
  /// per-game ad would interrupt the run between legs and the host shows a
  /// single ad of its own once the tie is decided. Leave null to keep the
  /// default behaviour.
  final bool Function()? suppressEndOfGameAd;

  /// Optional veto over the generic end-of-game popup ([GamicoGamePopup])
  /// shown by [GamePage]. Consulted the moment that popup would open;
  /// returning true holds it back.
  ///
  /// For host apps whose own game already shows its own end-of-game dialog
  /// and runs a sequence of games as one unit — same case as
  /// [suppressEndOfGameAd] — where the generic popup would otherwise flash
  /// on screen for a moment before being dismissed. Leave null to keep the
  /// default behaviour.
  final bool Function()? suppressEndOfGamePopup;

  const PlaySettings({
    required this.activePlayersLeaderboardId,
    required this.inactivePlayersLeaderboardId,
    this.enableFakeOpponent = true,
    this.singlePlayerWhenFake = false,
    this.displayCongratulations = true,
    this.exitUserWhenDisconnected = true,
    this.onModedRemoteResult,
    this.suppressEndOfGameAd,
    this.suppressEndOfGamePopup,
  });
}
