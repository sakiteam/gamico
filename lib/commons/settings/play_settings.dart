import 'package:flutter/widgets.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/features/game/utilities/roll_call_panel_builder.dart';

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

  /// Optional veto over the generic "Félicitations" message
  /// ([CongratulationsMessageUtility] — text and its voice line both) shown
  /// by [GamicoGameCubit.handleGameOver] on a genuine victory. Consulted the
  /// moment it would display; returning true holds the whole message back.
  ///
  /// For a game whose own commentary already crowns the winner with its own
  /// text and sound for a specific win — Crazy Eights' "C'est faciiile !"
  /// combo-finish line, say — where the generic message would otherwise show
  /// and play right on top of it. Leave null to keep the default behaviour.
  final bool Function()? suppressCongratulationsMessage;

  /// Overrides `GamicoRollCallPanel`'s default look (a white card over a
  /// dimmed backdrop) app-wide, for a host that wants the pre-deal wait/vote
  /// screen to match its own game's theme — dark, say, instead of gamico's
  /// generic light one. Leave null to keep the default look.
  final GamicoRollCallPanelBuilder? rollCallPanelBuilder;

  /// Lets the game being played dress the generic end-of-game popup
  /// ([GamicoGamePopup]): its own icon in place of the plain trophy or sad
  /// face, and a layer laid over the popup — confetti, what the game paid.
  /// Consulted as the popup builds, with the game's result ([victory] null
  /// for a draw). Returning null — or leaving the hook null — keeps the
  /// default look. Adventure stars, when shown, keep the icon's place.
  final GamicoGamePopupDecor? Function(BuildContext context, bool? victory)?
  gamePopupDecor;

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
    this.suppressCongratulationsMessage,
    this.rollCallPanelBuilder,
    this.gamePopupDecor,
  });
}

/// See [PlaySettings.gamePopupDecor].
@immutable
class GamicoGamePopupDecor {
  /// Replaces the popup's icon. Null keeps the default one.
  final Widget? icon;

  /// Laid over the whole popup content, never taking a tap. Null adds
  /// nothing.
  final Widget? overlay;

  const GamicoGamePopupDecor({this.icon, this.overlay});
}
