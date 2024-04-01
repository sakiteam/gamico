import 'package:bloc/bloc.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:meta/meta.dart';

part 'pass_and_play_game_state.dart';

class GamicoPassAndPlayGameCubit extends Cubit<GamicoPassAndPlayGameState> {
  final GamicoGameCubit gameCubit;

  GamicoPassAndPlayGameCubit({
    required this.gameCubit,
  }) : super(const GamicoPassAndPlayGameState());

  void init() {
    gameCubit.onInit = () async {
      gameCubit.settings?.initGame();
      gameCubit.startGame();
    };
  }

  void setReplayActive(bool replayActive) {
    emit(state.copyWith(
      replayActive: replayActive,
    ));
  }
}
