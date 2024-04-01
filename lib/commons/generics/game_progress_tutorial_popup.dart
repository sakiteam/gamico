import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/generics/game_next_lesson_button.dart';
import 'package:gamico/features/game/cubits/tutorial/tutorial_game_cubit.dart';
import 'package:gamico/languages/languages.dart';

class GamicoGameProgressTutorialPopup extends StatelessWidget {
  const GamicoGameProgressTutorialPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    final currentLesson = context.select(
        (GamicoTutorialGameCubit gameCubit) => gameCubit.state.tutorialLesson);

    return GamicoPopup(
      dismissible: false,
      child: GamicoPoster(
        // simple: true,
        icon: Icons.emoji_events,
        title: l.gameTutorialProgressPopupTitle,
        description: currentLesson?.winningMessage,
        expandContent: true,
        content: const Center(
          child: GamicoGameNextLessonButton(),
        ),
      ),
    );
  }
}
