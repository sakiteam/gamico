import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/features/game/cubits/tutorial/tutorial_game_cubit.dart';
import 'package:gamico/languages/languages.dart';

class GamicoGameNextLessonButton extends StatelessWidget {
  final Color color;

  const GamicoGameNextLessonButton({
    super.key,
    this.color = Colors.orange,
  });

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    final currentLesson = context.select(
        (GamicoTutorialGameCubit gameCubit) => gameCubit.state.tutorialLesson);

    return GamicoIconTextButton(
      color: color,
      onPressed: currentLesson?.index ==
              Gamico.instance.tutorialSettings!.lessons.length - 1
          ? null
          : () {
              final gameTutorialCubit = context.read<GamicoTutorialGameCubit>();

              NavigationService.pop(context);

              gameTutorialCubit.goToNextLesson();
            },
      text: l.gameTutorialProgressPopupNextLesson,
      iconData: Icons.keyboard_arrow_right,
    );
  }
}
