import 'package:bloc/bloc.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/features/adventure/utilities/adventure_utility.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:meta/meta.dart';

part 'adventure_game_state.dart';

class GamicoAdventureGameCubit extends Cubit<GamicoAdventureGameState> {
  final GamicoGameCubit gameCubit;
  final AdventureUtility adventureUtility;

  GamicoAdventureGameCubit({
    required int level,
    required this.gameCubit,
    required this.adventureUtility,
  }) : super(GamicoAdventureGameState(
          adventureUtility: adventureUtility,
          level: level,
          userInitialLevel:
              adventureUtility.getUserLevel(gameCubit.userCubit.state.user),
        ));

  void init() {
    gameCubit.onInit = () async {
      // Initial configs
      GameService.gameSkipped =
          adventureUtility.getUserLevel(gameCubit.userCubit.state.user) ==
              state.level;

      gameCubit.settings!.initGame();

      if (state.initialLevel) {
        setExplanationDialog(true);
      } else {
        gameCubit.startGame();
      }
    };

    gameCubit.onExitGame = () {
      if (!gameCubit.state.over) {
        if (state.level ==
            adventureUtility.getUserLevel(gameCubit.userCubit.state.user)) {
          gameCubit.userCubit.decrementCowries(
              Gamico.instance.gameSettings.playMinimumCowries);
        }
      }
    };
  }

  void setExplanationDialog(bool explanationDialog) {
    emit(state.copyWith(
      explanationDialog: explanationDialog,
    ));
  }

  void setNextLevelActive(bool nextLevelActive) {
    emit(state.copyWith(
      nextLevelActive: nextLevelActive,
    ));
  }

  void setReplayActive(bool replayActive) {
    emit(state.copyWith(
      replayActive: replayActive,
    ));
  }
}
