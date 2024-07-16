import 'package:flutter/material.dart';
import 'package:gamico/commons/utilities/tutorial/tutorial_lesson_utility.dart';

@immutable
class TutorialSettings {
  final List<TutorialLessonUtility> lessons;

  const TutorialSettings({
    required this.lessons,
  });
}
