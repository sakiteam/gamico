import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/features/game/widgets/game_congratulations_tutorial_popup.dart';
import 'package:gamico/features/game/widgets/game_exit_button.dart';
import 'package:gamico/features/game/widgets/game_passed_tutorial_popup.dart';
import 'package:gamico/features/game/widgets/game_progress_tutorial_popup.dart';
import 'package:gamico/features/game/widgets/game_replay_button.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';
import 'package:gamico/features/game/modes/game_mode_settings.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/features/game/cubits/tutorial/tutorial_game_cubit.dart';
import 'package:gamico/languages/languages.dart';

class TutorialModeSettings implements GameModeSettings {
  @override
  void manageReplay(BuildContext context) {
    final gameTutorialCubit = context.read<GamicoTutorialGameCubit>();

    NavigationService.pop(context);

    gameTutorialCubit.setNextLessonIndex(
      gameTutorialCubit.state.tutorialLesson!.index,
    );
  }

  @override
  String? localPlayerDescription(BuildContext context) {
    return null;
  }

  @override
  GamicoUserModel localPlayerProfile(BuildContext context) {
    return UserService.getUser() ?? const GamicoUserModel();
  }

  @override
  String? otherPlayerDescription(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return l.gameScoresIndicatorTutorialGameDescription;
  }

  @override
  GamicoUserModel otherPlayerProfile(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return GamicoUserModel(
      name: l.names[0],
    );
  }

  @override
  String? gamePopupDescription(BuildContext context) {
    return null;
  }

  @override
  String? gamePopupTitle(BuildContext context) {
    return null;
  }

  @override
  bool isPossibleToPlayAgain(BuildContext context) {
    return true;
  }

  @override
  bool isPossibleToPlayNextLevel(BuildContext context) {
    return false;
  }

  @override
  List<Widget> gamePopupButtons(
    BuildContext context,
    GamicoGameExitButton exitButton,
    GamicoGameReplayButton replayButton,
  ) {
    return [];
  }

  @override
  bool hasTripleAdAfterVictory(BuildContext context) {
    return false;
  }

  @override
  Key? gamePopupContentKey(BuildContext context) {
    return null;
  }

  @override
  bool displayStarsAfterVictory(BuildContext context) {
    return true;
  }

  @override
  String gamePageClosingPopupDescription(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return l.remoteSimpleCloseDescription;
  }

  @override
  void gamePageManageCoinsAndStars(BuildContext context) {}

  @override
  bool shouldShowAds(BuildContext context) {
    return false;
  }

  @override
  void onExitingGame(BuildContext context) {}

  @override
  bool shouldForceExit(BuildContext context) {
    return false;
  }

  @override
  void gamePageManageGamePopup(BuildContext context) {
    final gameCubit = context.read<GamicoGameCubit>();
    final gameTutorialCubit = context.read<GamicoTutorialGameCubit>();

    if (GameService.tutorialPassed) {
      NavigationService.showPopup(
        context: context,
        builder: (_) {
          return BlocProvider.value(
            value: gameCubit,
            child: BlocProvider.value(
              value: gameTutorialCubit,
              child: const GamicoGamePassedTutorialPopup(),
            ),
          );
        },
      );
    } else {
      NavigationService.showPopup(
        context: context,
        dismissible: false,
        draggable: false,
        builder: (_) {
          return BlocProvider.value(
            value: gameCubit,
            child: BlocProvider.value(
              value: gameTutorialCubit,
              child: () {
                if ((gameTutorialCubit.state.tutorialLessonIndex ==
                        Gamico.instance.tutorialSettings!.lessons.length - 1) ||
                    gameCubit.state.overReason == "PASS") {
                  return const GameCongratulationsTutorialPopup();
                }

                return const GamicoGameProgressTutorialPopup();
              }(),
            ),
          );
        },
      );
    }
  }

  @override
  Widget? levelsBuilder(BuildContext context) => null;

  @override
  bool isOpponentAvailable(BuildContext context) => true;
}
