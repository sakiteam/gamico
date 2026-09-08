import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/features/game/cubits/remote/remote_game_cubit.dart';
import 'package:gamico/features/game/widgets/game_exit_button.dart';
import 'package:gamico/features/game/widgets/game_replay_vote_button.dart';
import 'package:gamico/languages/languages.dart';

/// What a player can do once an online match is over: leave, ask the same
/// players for a rematch, or go looking for new opponents.
///
/// The framework's own end-of-game popup shows this row, and so can a game
/// that draws its own result screen — a score table across rounds, say. Either
/// way the rematch is the same vote, run by [GamicoRemoteGameCubit], so a
/// game never has to reimplement it.
class GamicoRemoteEndGameActions extends StatelessWidget {
  /// Leaving the match. Defaults to the framework's own exit flow; a game that
  /// has its own teardown (closing a voice call, say) passes it here.
  final VoidCallback? onBack;

  const GamicoRemoteEndGameActions({super.key, this.onBack});

  /// The three buttons on their own, for a layout that already has a row to
  /// put them in — the framework's own popup builds its content that way.
  static List<Widget> buttons(BuildContext context, {VoidCallback? onBack}) {
    final l = GamicoLanguages.of(context);
    final remoteGameCubit = context.watch<GamicoRemoteGameCubit>();

    return [
      if (onBack == null)
        const GamicoGameExitButton()
      else
        GamicoIconTextButton(
          iconData: Icons.arrow_back,
          text: l.globalExit,
          onPressed: onBack,
        ),
      GamicoReplayVoteButton(
        options: remoteGameCubit.replayOptions,
        currentOption: remoteGameCubit.currentReplayOption,
      ),
      // A friend match already has its players: looking for new opponents
      // would throw away the very people who were invited.
      if (!remoteGameCubit.state.friend)
        GamicoIconTextButton(
          iconData: Icons.sports_esports,
          text: l.gamePopupNewGame,
          onPressed: () {
            NavigationService.pop(context);
            remoteGameCubit.setNewRemoteGameActive(true);
          },
        ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: buttons(context, onBack: onBack),
    );
  }
}

/// Convenience for a game drawing its own end-of-match dialog: the actions row
/// with the framework cubits it needs already provided, so it can be dropped
/// into a popup mounted under the navigator.
class GamicoRemoteEndGameActionsProvider extends StatelessWidget {
  final GamicoGameCubit gameCubit;
  final GamicoRemoteGameCubit remoteGameCubit;
  final VoidCallback? onBack;

  const GamicoRemoteEndGameActionsProvider({
    super.key,
    required this.gameCubit,
    required this.remoteGameCubit,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: gameCubit),
        BlocProvider.value(value: remoteGameCubit),
      ],
      child: GamicoRemoteEndGameActions(onBack: onBack),
    );
  }
}
