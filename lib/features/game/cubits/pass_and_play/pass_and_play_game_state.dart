part of 'pass_and_play_game_cubit.dart';

@immutable
class GamicoPassAndPlayGameState {
  final bool replayActive;
  final int team1Wins;
  final int team2Wins;

  const GamicoPassAndPlayGameState({
    this.replayActive = false,
    this.team1Wins = 0,
    this.team2Wins = 0,
  });

  GamicoPassAndPlayGameState copyWith({
    bool? replayActive,
    int? team1Wins,
    int? team2Wins,
  }) {
    return GamicoPassAndPlayGameState(
      replayActive: replayActive ?? this.replayActive,
      team1Wins: team1Wins ?? this.team1Wins,
      team2Wins: team2Wins ?? this.team2Wins,
    );
  }
}
