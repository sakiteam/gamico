part of 'adventure_cubit.dart';

@immutable
class GamicoAdventureState {
  final bool animInit;
  final bool animGame;
  final bool animated;
  final bool nextLevelActive;

  final AdventureUtility adventureUtility;
  final RemoteUtility? remoteUtility;

  final int? nextLevelToPlay;

  bool get enabled => !animated;

  const GamicoAdventureState({
    this.animInit = false,
    this.animGame = false,
    this.animated = false,
    this.nextLevelActive = false,
    this.nextLevelToPlay,
    required this.adventureUtility,
    required this.remoteUtility,
  });

  GamicoAdventureState copyWith({
    bool? animInit,
    bool? animGame,
    bool? animated,
    bool? nextLevelActive,
    int? Function()? nextLevelToPlay,
    AdventureUtility? adventureUtility,
    RemoteUtility? Function()? remoteUtility,
  }) {
    return GamicoAdventureState(
      animInit: animInit ?? this.animInit,
      animGame: animGame ?? this.animGame,
      animated: animated ?? this.animated,
      nextLevelActive: nextLevelActive ?? this.nextLevelActive,
      adventureUtility: adventureUtility ?? this.adventureUtility,
      remoteUtility: remoteUtility != null
          ? remoteUtility()
          : this.remoteUtility,
      nextLevelToPlay: nextLevelToPlay != null
          ? nextLevelToPlay()
          : this.nextLevelToPlay,
    );
  }
}
