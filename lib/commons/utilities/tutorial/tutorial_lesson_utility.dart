import 'package:gamico/commons/utilities/tutorial/tutorial_step_utility.dart';

abstract class TutorialLessonUtility {
  int get index;
  String get title;
  String get description;
  String get winningMessage;

  List<TutorialStepUtility> get steps;
}
