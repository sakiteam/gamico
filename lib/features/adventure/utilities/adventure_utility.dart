import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';

class AdventureUtility<T extends GamicoUserModel> extends Equatable {
  final int chapters;
  final int maxLevel;
  final int gameEndReward;
  final int levelsPerChapter;
  final int initialLevelsLimit;
  final Widget explanationPopup;

  final bool Function(T user) isUserBroke;
  final int Function(T user) getUserLevel;
  final List<int> Function(T user) getUserStars;

  final int startChapter;
  final int endChapter;
  final bool reversed;

  const AdventureUtility({
    required this.maxLevel,
    required this.levelsPerChapter,
    required this.getUserLevel,
    required this.getUserStars,
    required this.chapters,
    required this.isUserBroke,
    this.startChapter = 0,
    this.endChapter = 20,
    this.reversed = false,
    this.gameEndReward = 50,
    this.initialLevelsLimit = 0,
    this.explanationPopup = const SizedBox(),
  });

  @override
  List<Object?> get props => [
    chapters,
    maxLevel,
    gameEndReward,
    levelsPerChapter,
    initialLevelsLimit,
    // explanationPopup,
    startChapter,
    endChapter,
    reversed,
  ];
}
