import 'package:bloc/bloc.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:meta/meta.dart';

part 'pass_and_play_game_state.dart';

class GamicoPassAndPlayGameCubit extends Cubit<GamicoPassAndPlayGameState> {
  static int globalTeam1Wins = 0;
  static int globalTeam2Wins = 0;

  final GamicoGameCubit gameCubit;

  GamicoPassAndPlayGameCubit({required this.gameCubit})
    : super(
        GamicoPassAndPlayGameState(
          team1Wins: globalTeam1Wins,
          team2Wins: globalTeam2Wins,
        ),
      );

  @override
  void emit(GamicoPassAndPlayGameState state) {
    if (isClosed) return;
    super.emit(state);
  }

  void init() {
    gameCubit.onInit = () async {
      gameCubit.settings?.initGame();
      gameCubit.startGame();
    };
  }

  void setReplayActive(bool replayActive) {
    emit(state.copyWith(replayActive: replayActive));
  }

  void incrementTeam1Wins() {
    globalTeam1Wins++;
    emit(state.copyWith(team1Wins: globalTeam1Wins));
  }

  void incrementTeam2Wins() {
    globalTeam2Wins++;
    emit(state.copyWith(team2Wins: globalTeam2Wins));
  }
}
