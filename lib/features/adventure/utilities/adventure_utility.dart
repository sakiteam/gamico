import 'package:flutter/material.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';

class AdventureUtility<T extends GamicoUserModel> {
  final int chapters;
  final int maxLevel;
  final int gameEndReward;
  final int levelsPerChapter;
  final int initialLevelsLimit;
  final Widget explanationPopup;

  final bool Function(T user) isUserBroke;
  final int Function(T user) getUserLevel;
  final List<int> Function(T user) getUserStars;

  const AdventureUtility({
    required this.maxLevel,
    required this.levelsPerChapter,
    required this.getUserLevel,
    required this.getUserStars,
    required this.chapters,
    required this.isUserBroke,
    this.gameEndReward = 50,
    this.initialLevelsLimit = 5,
    this.explanationPopup = const SizedBox(),
  });
}
