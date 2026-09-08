import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';

class AdventureUtility<T extends GamicoUserModel> extends Equatable {
  final String? name;
  final int chapters;
  final int maxLevel;
  final int gameEndReward;
  final int levelsPerChapter;
  final int initialLevelsLimit;
  final Widget explanationPopup;

  final bool Function(T? user) isUserBroke;
  final int Function(T? user) getUserLevel;
  final List<int> Function(T? user) getUserStars;

  /// Optional mode-aware writers, symmetric to [getUserLevel]/[getUserStars].
  ///
  /// When null (the default), gamico falls back to writing the user's top-level
  /// `level`/`stars` via `GamicoUserCubit.incrementLevel`/`updateStars` — so all
  /// existing single-game apps are unchanged. An embedding app (e.g. a second
  /// game living inside another) can supply these to persist adventure progress
  /// in its own namespace (e.g. `progression.<game>`) instead of clobbering the
  /// host game's level/stars.
  final void Function(GamicoUserCubit userCubit, int level)? setUserLevel;
  final void Function(GamicoUserCubit userCubit, List<int> stars)? setUserStars;

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
    this.name,
    this.setUserLevel,
    this.setUserStars,
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
