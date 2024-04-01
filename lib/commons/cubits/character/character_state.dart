part of 'character_cubit.dart';

@immutable
class CharacterState {
  final GamicoCharacterPosition? position;
  final flame_components.SpriteAnimation? animation;

  const CharacterState({
    this.position,
    this.animation,
  });

  CharacterState copyWith({
    required GamicoCharacterPosition? position,
    flame_components.SpriteAnimation? animation,
  }) {
    return CharacterState(
      position: position,
      animation: animation ?? this.animation,
    );
  }

  // @override
  // List<Object?> get props => [position, animation];
}
