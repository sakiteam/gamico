part of 'tutorial_game_cubit.dart';

@immutable
class GamicoTutorialGameState {
  final bool tutorialDialog;
  final bool homePageActive;

  final int tutorialLessonIndex;
  final int tutorialStepIndex;
  final int? tutorialNextLessonIndex;
  final bool tutorialStepTransition;

  TutorialLessonUtility? get tutorialLesson =>
      Gamico.instance.tutorialSettings!.lessons[tutorialLessonIndex];

  TutorialStepUtility? get tutorialStep =>
      tutorialLesson?.steps[tutorialStepIndex];

  const GamicoTutorialGameState({
    this.tutorialStepTransition = false,
    this.tutorialLessonIndex = 0,
    this.tutorialStepIndex = 0,
    this.tutorialNextLessonIndex,
    this.homePageActive = false,
    this.tutorialDialog = false,
  });

  GamicoTutorialGameState copyWith({
    bool? tutorialStepTransition,
    int? Function()? tutorialNextLessonIndex,
    int? tutorialLessonIndex,
    int? tutorialStepIndex,
    bool? homePageActive,
    bool? tutorialDialog,
  }) {
    return GamicoTutorialGameState(
      tutorialStepTransition:
          tutorialStepTransition ?? this.tutorialStepTransition,
      tutorialNextLessonIndex: tutorialNextLessonIndex != null
          ? tutorialNextLessonIndex()
          : this.tutorialNextLessonIndex,
      tutorialLessonIndex: tutorialLessonIndex ?? this.tutorialLessonIndex,
      tutorialStepIndex: tutorialStepIndex ?? this.tutorialStepIndex,
      homePageActive: homePageActive ?? this.homePageActive,
      tutorialDialog: tutorialDialog ?? this.tutorialDialog,
    );
  }
}
