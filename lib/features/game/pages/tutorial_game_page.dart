import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/enums/game_type.dart';
import 'package:gamico/commons/generics/game_initial_tutorial_popup.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/features/game/cubits/tutorial/tutorial_game_cubit.dart';

class TutorialGamePage extends StatelessWidget {
  final Widget child;

  final void Function()? onBackButtonPressed;

  const TutorialGamePage({
    super.key,
    required this.child,
    required this.onBackButtonPressed,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<GamicoTutorialGameCubit, GamicoTutorialGameState>(
          listener: (context, state) {
            context.read<GamicoTutorialGameCubit>().setTutorialDialog(false);

            NavigationService.showPopup(
              draggable: false,
              dismissible: false,
              context: context,
              builder: (_) {
                return BlocProvider.value(
                  value: context.read<GamicoGameCubit>(),
                  child: BlocProvider.value(
                    value: context.read<GamicoTutorialGameCubit>(),
                    child: const GamicoGameInitialTutorialPopup(),
                  ),
                );
              },
            );
          },
          listenWhen: (previous, current) {
            return current.tutorialDialog;
          },
        ),
        BlocListener<GamicoTutorialGameCubit, GamicoTutorialGameState>(
          listener: (context, state) async {
            context.read<GamicoGameCubit>().setActive(false);

            await NavigationService.replacePageWithAnimation(
              context,
              Gamico.instance.pagesSettings.homePage(context),
            );
          },
          listenWhen: (previous, current) {
            return !previous.homePageActive && current.homePageActive;
          },
        ),
        BlocListener<GamicoTutorialGameCubit, GamicoTutorialGameState>(
          listener: (context, state) async {
            final gameCubit = context.read<GamicoGameCubit>();

            gameCubit.setActive(false);
            gameCubit.setAnimGame(true);

            await NavigationService.replacePageWithAnimation(
              context,
              Gamico.instance.pagesSettings.gamePage(
                context,
                GameUtility(
                  onBackButtonPressed: onBackButtonPressed,
                  tutorialLessonIndex: state.tutorialNextLessonIndex,
                  gameType: GameType.tutorial,
                ),
              ),
            );
          },
          listenWhen: (previous, current) {
            return previous.tutorialNextLessonIndex !=
                current.tutorialNextLessonIndex;
          },
        ),
      ],
      child: child,
    );
  }
}
