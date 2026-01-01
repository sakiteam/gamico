import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/features/adventure/cubits/adventure_cubit.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/features/game/cubits/adventure/adventure_game_cubit.dart';

class AdventureGamePage extends StatelessWidget {
  final Widget child;

  final int level;
  final void Function()? onBackButtonPressed;

  const AdventureGamePage({
    super.key,
    required this.child,
    required this.level,
    required this.onBackButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GamicoAdventureGameCubit, GamicoAdventureGameState>(
          listener: (context, state) {
            context.read<GamicoAdventureGameCubit>().setExplanationDialog(
              false,
            );

            NavigationService.showPopup(
              draggable: false,
              dismissible: false,
              context: context,
              builder: (_) {
                return BlocProvider.value(
                  value: context.read<GamicoGameCubit>(),
                  child: BlocProvider.value(
                    value: context.read<GamicoAdventureGameCubit>(),
                    child: state.adventureUtility.explanationPopup,
                  ),
                );
              },
            );
          },
          listenWhen: (previous, current) {
            return current.explanationDialog;
          },
        ),
        BlocListener<GamicoAdventureGameCubit, GamicoAdventureGameState>(
          listener: (context, state) async {
            final gameCubit = context.read<GamicoGameCubit>();

            gameCubit.setActive(false);

            gameCubit.setAnimGame(true);

            final adventureGameCubit = context.read<GamicoAdventureGameCubit>();

            await NavigationService.replacePageWithAnimation(
              context,
              Gamico.instance.pagesSettings.gamePage(
                context,
                AdventureGameUtility(
                  level: level,
                  onBackButtonPressed: onBackButtonPressed,
                  adventureUtility: adventureGameCubit.adventureUtility,
                  remoteUtility: null,
                ),
              ),
            );
          },
          listenWhen: (previous, current) {
            return !previous.replayActive && current.replayActive;
          },
        ),
        BlocListener<GamicoAdventureGameCubit, GamicoAdventureGameState>(
          listener: (context, state) async {
            final gameCubit = context.read<GamicoGameCubit>();

            gameCubit.setActive(false);

            gameCubit.setAnimGame(true);

            final adventureGameCubit = context.read<GamicoAdventureGameCubit>();

            await NavigationService.replacePageWithAnimation(
              context,
              Gamico.instance.pagesSettings.gamePage(
                context,
                AdventureGameUtility(
                  level: level + 1,
                  onBackButtonPressed: onBackButtonPressed,
                  adventureUtility: adventureGameCubit.adventureUtility,
                  remoteUtility: null,
                ),
              ),
            );
          },
          listenWhen: (previous, current) {
            return !previous.nextLevelActive && current.nextLevelActive;
          },
        ),
      ],
      child: child,
    );
  }
}
