import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/game_stepper.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/generics/card.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/generics/outlined_text.dart';
import 'package:gamico/commons/utilities/tutorial/tutorial_lesson_utility.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/features/game/cubits/tutorial/tutorial_game_cubit.dart';
import 'package:gamico/languages/languages.dart';

class GamicoGameStepperStep extends StatelessWidget {
  final TutorialLessonUtility lesson;

  const GamicoGameStepperStep({
    super.key,
    required this.lesson,
  });

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    const double margin = 3;
    const double marginDouble = 2 * margin;

    final currentLesson = context.select(
        (GamicoTutorialGameCubit gameCubit) => gameCubit.state.tutorialLesson);
    final over =
        context.select((GamicoGameCubit gameCubit) => gameCubit.state.over);

    final currentIndex = currentLesson?.index ?? 0;

    final bool active = currentIndex == lesson.index;
    final bool passed = currentIndex > lesson.index;

    final Color color;

    if (active) {
      color = Colors.blue;
    } else if (passed) {
      color = Colors.white;
    } else {
      color = Colors.white.withAlpha(100);
    }

    return GestureDetector(
      onTap: active
          ? null
          : () async {
              await NavigationService.showPopup(
                context: context,
                builder: (_) {
                  return BlocProvider.value(
                    value: context.read<GamicoGameCubit>(),
                    child: GamicoPopup(
                      child: GamicoDialogPoster(
                        icon: Icons.cached,
                        title: l.lessonChangeTitle,
                        description: l.lessonChangeDescription,
                        acceptationText: l.lessonChangeAction,
                        acceptationIcon: Icons.cached,
                        onAccepted: () {
                          context
                              .read<GamicoTutorialGameCubit>()
                              .setNextLessonIndex(lesson.index);
                        },
                      ),
                    ),
                  );
                },
              );
            },
      child: GamicoCard(
        color: color,
        borderColor: Colors.black,
        borderWidth: 0.25,
        width: GamicoGameStepper.height - marginDouble,
        height: GamicoGameStepper.height - marginDouble,
        margin: const EdgeInsets.all(margin),
        borderRadius: BorderRadius.circular(GamicoGameStepper.height / 2),
        child: Center(
          child: over && active
              ? (const Icon(
                  Icons.check,
                  color: Colors.white,
                  size: 16,
                ))
              : (passed
                  ? const Icon(
                      Icons.check,
                      color: Colors.black,
                      size: 16,
                    )
                  : GamicoOutlinedText(
                      "${lesson.index + 1}",
                      // strokeWidth: 0.25,
                      strokeColor: active ? null : Colors.transparent,
                      style: TextStyle(
                        fontSize: 14 * 450 / 400,
                        color: active ? Colors.white : null,
                      ),
                    )),
        ),
      ),
    );
  }
}
