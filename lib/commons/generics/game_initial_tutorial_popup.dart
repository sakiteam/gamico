import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/features/game/cubits/tutorial/tutorial_game_cubit.dart';
import 'package:gamico/languages/languages.dart';

class GamicoGameInitialTutorialPopup extends StatelessWidget {
  static Widget? iconWidget;

  const GamicoGameInitialTutorialPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    final currentLesson = context.select(
      (GamicoTutorialGameCubit gameCubit) => gameCubit.state.tutorialLesson,
    );

    return GamicoPopup(
      dismissible: false,
      child: GamicoDialogPoster(
        simple: true,
        // icon: Icons.school,
        icon: Icons.help,
        iconWidget: iconWidget,
        title: currentLesson?.title,
        acceptationText: l.gameInitialTutorialPopupPlay,
        acceptationIcon: Icons.sports_esports,
        description: currentLesson?.description,
        automaticClose: false,
        onAccepted: () async {
          context.read<GamicoTutorialGameCubit>().startTutorial();
          NavigationService.pop(context);
        },
      ),
    );
  }
}
