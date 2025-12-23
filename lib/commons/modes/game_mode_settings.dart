import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/enums/game_type.dart';
import 'package:gamico/commons/generics/game_exit_button.dart';
import 'package:gamico/commons/generics/game_replay_button.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';
import 'package:gamico/commons/modes/adventure_mode_settings.dart';
import 'package:gamico/commons/modes/pass_and_play_mode_settings.dart';
import 'package:gamico/commons/modes/remote_mode_settings.dart';
import 'package:gamico/commons/modes/tutorial_mode_settings.dart';

import 'package:gamico/commons/services/game.dart';
import 'package:gamico/features/adventure/utilities/adventure_utility.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';

bool shouldShowAdsInAdventureGame(
  bool? victory,
  int? currentLevel,
  int maxLevel,
) {
  // final gameCubit = context.read<GamicoGameCubit>();
  // final adventureGameCubit = context.read<GamicoAdventureGameCubit>();

  // final gameState = gameCubit.state;
  // final adventureGameState = adventureGameCubit.state;

  return GameService.plays >= 5 &&
      !(victory == true && currentLevel == maxLevel);
}

void gamePageManageCoinsAndStarsInAdventureGame(
  BuildContext context,
  int level,
  AdventureUtility adventureUtility,
) {
  final gameCubit = context.read<GamicoGameCubit>();
  final userCubit = context.read<GamicoUserCubit>();
  // final adventureGameCubit = context.read<GamicoAdventureGameCubit>();

  final gameState = gameCubit.state;
  // final aventureGameState = adventureGameCubit.state;

  final victory = gameState.victory;
  // final level = aventureGameState.level;
  final currentLevelStars = gameState.stars;
  final userStars = (userCubit.state.user?.stars as List<int>?) ?? [];
  final levelPreviousStars = userStars.elementAtOrNull(level) ?? 0;
  // final adventureUtility = aventureGameState.adventureUtility;

  final isCurrentLevelLast =
      level == adventureUtility.getUserLevel(userCubit.state.user);

  if (victory == true) {
    if (currentLevelStars > levelPreviousStars) {
      final newStars = <int>[];

      for (int i = 0; i <= adventureUtility.maxLevel; i++) {
        newStars.add(userStars.elementAtOrNull(i) ?? 0);
      }

      newStars[level] = currentLevelStars;

      userCubit.updateStars(newStars);

      final int currentUserLevel = adventureUtility.getUserLevel(
        userCubit.state.user,
      );
      final multiplicationFactor = currentLevelStars - levelPreviousStars;

      if (multiplicationFactor > 0) {
        final int cowriesReward;

        if (currentUserLevel == adventureUtility.maxLevel) {
          cowriesReward = adventureUtility.gameEndReward;
        } else {
          cowriesReward = Gamico.instance.gameSettings.playMinimumCoins;
        }

        userCubit.incrementCowries(
          (cowriesReward * multiplicationFactor).toInt(),
        );
      }
    }

    if (isCurrentLevelLast) {
      userCubit.incrementLevel();
    }
  } else {
    if (isCurrentLevelLast) {
      userCubit.decrementCowries(Gamico.instance.gameSettings.playMinimumCoins);
    }
  }
}

abstract class GameModeSettings {
  void manageReplay(BuildContext context);

  GamicoUserModel localPlayerProfile(BuildContext context);
  GamicoUserModel otherPlayerProfile(BuildContext context);
  String? localPlayerDescription(BuildContext context);
  String? otherPlayerDescription(BuildContext context);

  String? gamePopupTitle(BuildContext context);
  String? gamePopupDescription(BuildContext context);
  bool isOpponentAvailable(BuildContext context);
  bool isPossibleToPlayAgain(BuildContext context);
  bool isPossibleToPlayNextLevel(BuildContext context);
  bool hasTripleAdAfterVictory(BuildContext context);
  Key? gamePopupContentKey(BuildContext context);
  bool displayStarsAfterVictory(BuildContext context);

  String gamePageClosingPopupDescription(BuildContext context);
  void gamePageManageCoinsAndStars(BuildContext context);
  void gamePageManageGamePopup(BuildContext context);

  bool shouldShowAds(BuildContext context);
  void onExitingGame(BuildContext context);
  bool shouldForceExit(BuildContext context);

  Widget? levelsBuilder(BuildContext context);

  List<Widget> gamePopupButtons(
    BuildContext context,
    GamicoGameExitButton exitButton,
    GamicoGameReplayButton replayButton,
  );

  factory GameModeSettings(GameType type) {
    return switch (type) {
      GameType.adventure => AdventureModeSettings(),
      GameType.remote => RemoteModeSettings(),
      GameType.passAndPlay => PassAndPlayModeSettings(),
      GameType.tutorial => TutorialModeSettings(),
    };
  }
}
