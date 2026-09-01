import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/features/game/widgets/game_stepper_step.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/layout.dart';
import 'package:gamico/commons/generics/card.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';

class GamicoGameStepper extends StatelessWidget {
  static const double height = 30 * 450 / 400;

  const GamicoGameStepper({super.key});

  @override
  Widget build(BuildContext context) {
    final animInit =
        context.select((GamicoGameCubit gameCubit) => gameCubit.state.animInit);

    return Center(
      child: GamicoCard(
        width: 2.5 * LayoutService.referenceWidth / 20 * 3,
        height: height,
        color: Colors.black.withAlpha(50),
        borderColor: Colors.transparent,
        borderWidth: 0,
        borderRadius: BorderRadius.circular(GamicoGameStepper.height / 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: Gamico.instance.tutorialSettings!.lessons.map((lesson) {
            return GamicoGameStepperStep(lesson: lesson);
          }).toList(),
        ),
      ),
    ).animate(target: animInit ? 1 : 0).slideY(begin: -1 / 4, end: 0).fadeIn();
  }
}
