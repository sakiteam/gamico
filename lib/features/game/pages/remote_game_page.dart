import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/features/game/cubits/remote/remote_game_cubit.dart';
import 'package:gamico/features/remote/cubits/remote_cubit.dart';

class GamicoRemoteGamePage extends StatelessWidget {
  final Widget child;
  final void Function()? onBackButtonPressed;

  const GamicoRemoteGamePage({
    super.key,
    required this.child,
    required this.onBackButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
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
      child: child,
    );
  }
}
