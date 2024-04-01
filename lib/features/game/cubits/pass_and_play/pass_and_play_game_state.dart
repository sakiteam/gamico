part of 'pass_and_play_game_cubit.dart';

@immutable
class GamicoPassAndPlayGameState {
  final bool replayActive;

  const GamicoPassAndPlayGameState({
    this.replayActive = false,
  });

  GamicoPassAndPlayGameState copyWith({
    bool? replayActive,
  }) {
    return GamicoPassAndPlayGameState(
      replayActive: replayActive ?? this.replayActive,
    );
  }
}
