import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/features/game/cubits/local_network/local_network_game_cubit.dart';
import 'package:gamico/features/game/modes/game_mode_settings.dart';
import 'package:gamico/features/game/widgets/game_exit_button.dart';
import 'package:gamico/features/game/widgets/game_host_waiting_indicator.dart';
import 'package:gamico/features/game/widgets/game_replay_button.dart';
import 'package:gamico/languages/languages.dart';

/// End of a WiFi-local match, framework side.
///
/// The table itself belongs to the game (it owns the sockets and the board),
/// but everything that closes a match is the same wherever it is played:
/// the result goes into the game's progression namespace under its own mode
/// key, the interstitial follows the app-wide cadence, and only the host may
/// deal again — a guest waits for them instead of being handed a dead button.
class LocalNetworkModeSettings implements GameModeSettings {
  GamicoLocalNetworkGameCubit? _cubitOf(BuildContext context) {
    try {
      return context.read<GamicoLocalNetworkGameCubit>();
    } catch (_) {
      return null;
    }
  }

  @override
  void manageReplay(BuildContext context) {
    final localNetworkCubit = _cubitOf(context);
    if (localNetworkCubit == null) return;

    NavigationService.pop(context);

    localNetworkCubit.requestNewGame();
  }

  @override
  GamicoUserModel localPlayerProfile(BuildContext context) {
    // Straight from the cubit: it is the account, and `GamicoAccountGate` has
    // already waited for it. Reading a persisted copy here is what used to hand
    // the game a profile from the last session.
    return context.read<GamicoUserCubit>().state.user ??
        const GamicoUserModel();
  }

  @override
  GamicoUserModel otherPlayerProfile(BuildContext context) {
    return const GamicoUserModel();
  }

  @override
  String? localPlayerDescription(BuildContext context) => null;

  @override
  String? otherPlayerDescription(BuildContext context) => null;

  @override
  String? gamePopupTitle(BuildContext context) => null;

  @override
  String? gamePopupDescription(BuildContext context) {
    final l = GamicoLanguages.of(context);

    final hostGone = context.select(
      (GamicoLocalNetworkGameCubit cubit) => cubit.state.hostGone,
    );

    if (hostGone) return l.localNetworkHostLeftDescription;

    final victory = context.select(
      (GamicoGameCubit gameCubit) => gameCubit.state.victory,
    );

    if (victory == null) return l.remoteDrawDescription;

    return victory ? l.remoteVictoryDescription : l.remoteDefeatDescription;
  }

  /// A LAN table only stops being playable when the host is gone: everybody
  /// else is right there in the room.
  @override
  bool isOpponentAvailable(BuildContext context) {
    return !context.select(
      (GamicoLocalNetworkGameCubit cubit) => cubit.state.hostGone,
    );
  }

  /// LAN play costs nothing, so the wallet never blocks a rematch — only host
  /// authority does.
  @override
  bool isPossibleToPlayAgain(BuildContext context) {
    final canStartNewGame = context.select(
      (GamicoLocalNetworkGameCubit cubit) =>
          cubit.state.isHost && cubit.utility.onNewGame != null,
    );

    return canStartNewGame;
  }

  @override
  bool isPossibleToPlayNextLevel(BuildContext context) => false;

  @override
  bool hasTripleAdAfterVictory(BuildContext context) => true;

  @override
  Key? gamePopupContentKey(BuildContext context) => null;

  @override
  bool displayStarsAfterVictory(BuildContext context) => false;

  @override
  String gamePageClosingPopupDescription(BuildContext context) {
    return GamicoLanguages.of(context).remoteSimpleCloseDescription;
  }

  /// Books the match in the game's own progression namespace (and the wallet,
  /// on a table that pays). Called by [GamicoGameCubit.handleGameOver], so a
  /// LAN result is recorded exactly like every other mode's.
  @override
  void gamePageManageCoinsAndStars(BuildContext context) {
    final localNetworkCubit = _cubitOf(context);
    if (localNetworkCubit == null) return;

    final victory = context.read<GamicoGameCubit>().state.victory;
    if (victory == null) return;

    localNetworkCubit.recordResult(victory: victory);
  }

  @override
  void gamePageManageGamePopup(BuildContext context) {
    if (!context.mounted) return;
    try {
      context.read<GamicoGameCubit>().setDisplayGamePopup(true);
    } catch (e) {
      debugPrint('gamePageManageGamePopup error: $e');
    }
  }

  /// The app-wide cadence, same as pass-and-play: a LAN evening is a string of
  /// short matches and an ad after every single one would be unbearable.
  @override
  bool shouldShowAds(BuildContext context) {
    final localNetworkCubit = _cubitOf(context);
    if (localNetworkCubit != null && localNetworkCubit.state.adShown) {
      return false;
    }

    return GameService.plays >= 3;
  }

  @override
  void onExitingGame(BuildContext context) {}

  /// The host walking out ends the table for everyone: there is nothing left
  /// to confirm before leaving.
  @override
  bool shouldForceExit(BuildContext context) {
    return _cubitOf(context)?.state.hostGone ?? false;
  }

  @override
  Widget? levelsBuilder(BuildContext context) => null;

  @override
  List<Widget> gamePopupButtons(
    BuildContext context,
    GamicoGameExitButton exitButton,
    GamicoGameReplayButton replayButton,
  ) {
    final isHost = context.select(
      (GamicoLocalNetworkGameCubit cubit) => cubit.state.isHost,
    );
    final hostGone = context.select(
      (GamicoLocalNetworkGameCubit cubit) => cubit.state.hostGone,
    );

    // Only the host deals: a guest is told to wait rather than being offered a
    // replay button that cannot do anything. Both keep the way out.
    if (!isHost && !hostGone) {
      return [exitButton, const GamicoGameHostWaitingIndicator()];
    }

    if (hostGone) return [exitButton];

    return [exitButton, replayButton];
  }
}
