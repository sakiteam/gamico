part of 'adventure_cubit.dart';

@immutable
class GamicoAdventureState {
  final bool animInit;
  final bool animGame;
  final bool animated;

  final AdventureUtility adventureUtility;

  bool get enabled => !animated;

  const GamicoAdventureState({
    this.animInit = false,
    this.animGame = false,
    this.animated = false,
    required this.adventureUtility,
  });

  GamicoAdventureState copyWith({
    bool? animInit,
    bool? animGame,
    bool? animated,
    AdventureUtility? adventureUtility,
  }) {
    return GamicoAdventureState(
      animInit: animInit ?? this.animInit,
      animGame: animGame ?? this.animGame,
      animated: animated ?? this.animated,
      adventureUtility: adventureUtility ?? this.adventureUtility,
    );
  }
}
