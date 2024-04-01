import 'package:gamico/commons/utilities/tutorial/tutorial_step_utility.dart';

abstract class TutorialLessonUtility {
  int get index;
  String get winningMessage;
  String get title;
  String get description;

  List<TutorialStepUtility> get steps;

  TutorialStepUtility get firstStep {
    return steps.first;
  }

  TutorialStepUtility get lastStep {
    return steps.last;
  }
}
