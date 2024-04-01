part of 'adventure_game_cubit.dart';

@immutable
class GamicoAdventureGameState {
  final int level;
  final bool explanationDialog;
  final bool nextLevelActive;
  final bool replayActive;
  final int userInitialLevel;
  final AdventureUtility adventureUtility;

  bool get initialLevel => level <= adventureUtility.initialLevelsLimit;

  const GamicoAdventureGameState({
    this.explanationDialog = false,
    this.nextLevelActive = false,
    this.replayActive = false,
    required this.level,
    required this.userInitialLevel,
    required this.adventureUtility,
  });

  GamicoAdventureGameState copyWith({
    bool? explanationDialog,
    bool? nextLevelActive,
    bool? replayActive,
    int? level,
    int? userInitialLevel,
    AdventureUtility? adventureUtility,
  }) {
    return GamicoAdventureGameState(
      adventureUtility: adventureUtility ?? this.adventureUtility,
      explanationDialog: explanationDialog ?? this.explanationDialog,
      nextLevelActive: nextLevelActive ?? this.nextLevelActive,
      replayActive: replayActive ?? this.replayActive,
      level: level ?? this.level,
      userInitialLevel: userInitialLevel ?? this.userInitialLevel,
    );
  }
}
