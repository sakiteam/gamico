import 'package:flutter/material.dart';
import 'package:gamico/commons/utilities/tutorial/tutorial_lesson_utility.dart';

@immutable
class TutorialSettings {
  final List<TutorialLessonUtility> lessons;
  final String description;

  const TutorialSettings({
    required this.lessons,
    required this.description,
  });
}

const globalTutorialSettings = TutorialSettings(
  lessons: [],
  description: "",
);
