import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/features/game/cubits/remote/remote_game_cubit.dart';
import 'package:gamico/features/game/utilities/roll_call.dart';
import 'package:gamico/features/game/widgets/game_roll_call_panel.dart';
import 'package:gamico/features/game/widgets/game_roll_call_popup.dart';
import 'package:gamico/features/remote/cubits/remote_cubit.dart';

class GamicoRemoteGamePage extends StatelessWidget {
  final Widget child;
  final void Function()? onBackButtonPressed;

  /// Carried into the rematch so a game that declared its own result screen at
  /// launch still has it after "Rejouer". Only what the utility declared — a
  /// builder a game installed on its page belongs to that page and is
  /// reinstalled by the next one.
  final Widget? Function(BuildContext context)? endGamePopupBuilder;

  /// See [RemoteGameUtility.spectatorPageBuilder].
  final Widget Function(BuildContext context, String gameId)?
  spectatorPageBuilder;

  const GamicoRemoteGamePage({
    super.key,
    required this.child,
    required this.onBackButtonPressed,
    this.endGamePopupBuilder,
    this.spectatorPageBuilder,
  });

  /// Takes the player out of a table the roll-call settled without a game:
  /// cancelled, or dealt without them.
  ///
  /// Straight through the framework's exit and a plain route pop — never
  /// `maybePop`. A game with its own `PopScope` (Ludo) answers a back request
  /// on an unfinished table with "abandon? you will forfeit", which is the
  /// wrong question for a match that never started; nothing was dealt, so the
  /// framework's exit is already penalty-free.
  ///
  /// Between friends, a player left out of a table that is being played (not
  /// a cancelled duel) lands on the game's spectator view when it has one.
  Future<void> _leaveAfterRollCall(
    BuildContext context,
    GamicoRollCallOutcome outcome,
  ) async {
    final gameCubit = context.read<GamicoGameCubit>();
    final remoteGameCubit = context.read<GamicoRemoteGameCubit>();
    final gameId = remoteGameCubit.gameId;
    final builder = spectatorPageBuilder;
    final watch =
        builder != null &&
        remoteGameCubit.state.friend &&
        outcome.excluded &&
        outcome.exclusionReason != GamicoRollCallReason.duelTimeout &&
        gameId.isNotEmpty;

    NavigationService.closePopups();
    // A route animating is refused an exit (see `handleWillPop`); this one
    // must not be.
    gameCubit.setAnimated(false);
    final left = await gameCubit.managePop(
      context,
      // Kept even on the way to the spectator view: it takes the lobby or the
      // matchmaking page underneath down with the table, and a lobby left
      // alive under the spectator would react to the room again.
      onBackButtonPressed: onBackButtonPressed,
    );
    if (left && context.mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }

    if (watch) {
      await Future.delayed(const Duration(milliseconds: 350));
      final root = NavigationService.globalNavigatorKey.currentContext;
      if (root != null && root.mounted) {
        unawaited(
          NavigationService.pushPageWithAnimation(root, builder(root, gameId)),
        );
      }
      GamicoRollCallPopup.showLater(
        outcome,
        delay: const Duration(milliseconds: 900),
      );
      return;
    }
    GamicoRollCallPopup.showLater(outcome);
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // A pre-deal wait the game left to gamico (see
        // `GamicoGameCubitSettings.onRollCallCancelled` and
        // `onExcludedFromRollCall`): the table is left — penalty-free, since
        // nothing was dealt — and the player is told why.
        BlocListener<GamicoRemoteGameCubit, GamicoRemoteGameState>(
          listener: (context, state) {
            final outcome = state.rollCallOutcome;
            if (outcome == null) return;
            _leaveAfterRollCall(context, outcome);
          },
          listenWhen: (previous, current) {
            return previous.rollCallOutcome == null &&
                current.rollCallOutcome != null;
          },
        ),
        BlocListener<GamicoRemoteGameCubit, GamicoRemoteGameState>(
          listener: (context, state) {
            NavigationService.maybePop(context);
          },
          listenWhen: (previous, current) {
            return !previous.newRemoteGameActive && current.newRemoteGameActive;
          },
        ),
        BlocListener<GamicoRemoteGameCubit, GamicoRemoteGameState>(
          listener: (context, gameState) async {
            if (!context.mounted) return;

            GameService.plays++;

            final gameCubit = context.read<GamicoGameCubit>();
            // Only matchmaking puts a RemoteCubit above the game page
            // (GamicoRemotePage owns it). A game reached any other way — a
            // friend invitation, a shared room link — has none, and reading
            // it unconditionally threw "Could not find the correct
            // Provider<RemoteCubit>" the moment those players hit Rejouer.
            // It is only carried down to the replacement page here, so when
            // there is none there is simply nothing to carry.
            RemoteCubit? remoteCubit;
            try {
              remoteCubit = context.read<RemoteCubit>();
            } catch (_) {
              remoteCubit = null;
            }

            NavigationService.closePopups();

            if (!context.mounted) return;

            gameCubit.setActive(false);
            gameCubit.setAnimGame(true);

            final replacementPage = Gamico.instance.pagesSettings.gamePage(
              context,
              RemoteGameUtility(
                onBackButtonPressed: onBackButtonPressed,
                gameId: gameState.newGameId,
                creatorOfCurrentGame: gameState.newGameCreator,
                fakeOpponent: false,
                level: gameState.nextLevel ?? gameState.level,
                remoteUtility: gameState.remoteUtility,
                adventureUtility: gameState.adventureUtility,
                // A replayed friend game is still a friend game: dropping the
                // flag here sent those players down the matchmaking paths of
                // the game screens they land on.
                friend: gameState.friend,
                // The rematch closes the same way this match did, on the
                // option the table just voted for.
                replayOptions: context
                    .read<GamicoRemoteGameCubit>()
                    .replayOptions,
                currentReplayOption:
                    gameState.replayOption ??
                    context.read<GamicoRemoteGameCubit>().currentReplayOption,
                replayVote: context
                    .read<GamicoRemoteGameCubit>()
                    .replayVoteEnabled,
                endGamePopupBuilder: endGamePopupBuilder,
                legacyRollCall: context
                    .read<GamicoRemoteGameCubit>()
                    .legacyRollCall,
                spectatorPageBuilder: spectatorPageBuilder,
              ),
            );

            await NavigationService.replacePageWithAnimation(
              context,
              remoteCubit == null
                  ? replacementPage
                  : BlocProvider.value(
                      value: remoteCubit,
                      child: replacementPage,
                    ),
            );
          },
          listenWhen: (oldState, newState) {
            return !oldState.replay && newState.replay;
          },
        ),
      ],
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          child,
          // Tables of three or more: who is there, who is not, and the vote
          // on the absent — over the game's own pre-deal loader.
          GamicoRollCallPanel(
            // Through the game's own back flow, so a game with its own exit
            // (voice chat, lobby) runs it; before the deal it is free.
            onLeave: () => NavigationService.maybePop(context),
          ),
        ],
      ),
    );
  }
}
