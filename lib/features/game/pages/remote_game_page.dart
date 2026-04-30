import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/commons/cubits/internet/internet_cubit.dart';
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
        BlocListener<InternetCubit, InternetState>(
          listener: (context, state) async {
            final gameCubit = context.read<GamicoGameCubit>();

            if (!gameCubit.state.over) {
              context.read<GamicoRemoteGameCubit>().setRemoteGameInternetError(
                true,
              );
              NavigationService.maybePop(context);
            }
          },
          listenWhen: (previous, current) {
            return previous.connected && !current.connected;
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
            GameService.plays++;

            final gameCubit = context.read<GamicoGameCubit>();

            NavigationService.closePopups();

            gameCubit.setActive(false);
            gameCubit.setAnimGame(true);

            await NavigationService.replace(
              context,
              BlocProvider.value(
                value: context.read<RemoteCubit>(),
                child: Gamico.instance.pagesSettings.gamePage(
                  context,
                  RemoteGameUtility(
                    onBackButtonPressed: onBackButtonPressed,
                    gameId: gameState.newGameId,
                    creatorOfCurrentGame: gameState.newGameCreator,
                    fakeOpponent: false,
                    level: gameState.nextLevel ?? gameState.level,
                    remoteUtility: gameState.remoteUtility,
                    adventureUtility: gameState.adventureUtility,
                  ),
                ),
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
