import 'package:bloc/bloc.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/services/global.dart';
import 'package:gamico/commons/utilities/tutorial/tutorial_lesson_utility.dart';
import 'package:gamico/commons/utilities/tutorial/tutorial_step_utility.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:meta/meta.dart';

part 'tutorial_game_state.dart';

class GamicoTutorialGameCubit extends Cubit<GamicoTutorialGameState> {
  final GamicoGameCubit gameCubit;

  GamicoTutorialGameCubit({
    required this.gameCubit,
    required int tutorialLessonIndex,
  }) : super(GamicoTutorialGameState(tutorialLessonIndex: tutorialLessonIndex));

  void startTutorial() async {
    final settingsGameCubit = gameCubit.settings?.gameCubit;

    if (settingsGameCubit == null) return;

    gameCubit.startGame();

    final tutorialLesson = state.tutorialLesson!;

    // final firstStep = tutorialLesson.firstStep;
    // final lastStep = tutorialLesson.lastStep;

    // TutorialStepUtility activeStep = firstStep;
    setTutorialStepIndex(0);

    final length = tutorialLesson.steps.length;

    for (int i = 0; i < length; i++) {
      final step = tutorialLesson.steps[i];

      await GamicoGlobalService.waitWhile(
        () => step.condition(settingsGameCubit),
      );

      //
      emit(state.copyWith(tutorialStepTransition: true));
      await gameCubit.displayMessage(step.message);
      await step.execute(settingsGameCubit);
      emit(state.copyWith(tutorialStepTransition: false));
      //

      if (i != length - 1) {
        await setTutorialStepIndex(state.tutorialStepIndex + 1);
      }
    }

    // while (activeStep != lastStep) {
    //   await GlobalService.waitWhile(() => activeStep.condition(gameCubit));
    //   //
    //   emit(state.copyWith(tutorialStepTransition: true));
    //   await displayMessage(activeStep.message);
    //   await activeStep.execute(gameCubit);
    //   emit(state.copyWith(tutorialStepTransition: false));
    //   //
    //   await setTutorialStepIndex(state.tutorialStepIndex! + 1);
    //   activeStep = state.tutorialStep!;
    // }
  }

  void setTutorialDialog(bool tutorialDialog) {
    emit(state.copyWith(
      tutorialDialog: tutorialDialog,
    ));
  }

  void declareTutorialAsPassed() {
    GameService.tutorialPassed = true;

    emit(state.copyWith(
      homePageActive: true,
    ));
  }

  void declareWinnerByPass() {
    gameCubit.settings?.onUserWonByPass();
    // endGame("B", "PASS");
  }

  Future<void> setTutorialStepIndex(int index) async {
    emit(state.copyWith(
      tutorialStepIndex: index,
    ));
  }

  void goToNextLesson() {
    emit(state.copyWith(
      tutorialNextLessonIndex: () => state.tutorialLessonIndex + 1,
    ));
  }

  void setNextLessonIndex(int index) {
    emit(state.copyWith(
      tutorialNextLessonIndex: () => index,
    ));
  }

  void init() {
    gameCubit.onInit = () async {
      gameCubit.settings!.initGame();

      setTutorialDialog(true);
    };
  }
}
