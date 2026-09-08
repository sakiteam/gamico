import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/enums/game_type.dart';
import 'package:gamico/features/game/widgets/game_exit_button.dart';
import 'package:gamico/features/game/widgets/game_replay_button.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';
import 'package:gamico/features/game/modes/adventure_mode_settings.dart';
import 'package:gamico/features/game/modes/local_network_mode_settings.dart';
import 'package:gamico/features/game/modes/pass_and_play_mode_settings.dart';
import 'package:gamico/features/game/modes/remote_mode_settings.dart';
import 'package:gamico/features/game/modes/tutorial_mode_settings.dart';

import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/models/adventure_utility.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';

bool shouldShowAdsInAdventureGame(
  bool? victory,
  int? currentLevel,
  int maxLevel,
  String? endMessage,
  String? descriptionMessage,
) {
  // final gameCubit = context.read<GamicoGameCubit>();
  // final adventureGameCubit = context.read<GamicoAdventureGameCubit>();

  // final gameState = gameCubit.state;
  // final adventureGameState = adventureGameCubit.state;

  return GameService.plays >= 3 &&
      !(victory == true &&
          (currentLevel == maxLevel ||
              endMessage != null ||
              descriptionMessage != null));
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
  final user = userCubit.state.user;
  final userStars = user != null
      ? adventureUtility.getUserStars(user)
      : <int>[];
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

      // Mode-aware write: namespaced if the utility provides a writer, else the
      // default top-level write (unchanged behavior for single-game apps).
      if (adventureUtility.setUserStars != null) {
        adventureUtility.setUserStars!(userCubit, newStars);
      } else {
        userCubit.updateStars(newStars);
      }

      final multiplicationFactor = currentLevelStars - levelPreviousStars;

      // Adventure reward is improvement-based for every game (8 Américain
      // included): coins are paid only when a level's star count beats its
      // previous best, proportionally to the gain. (8 Américain online/WiFi
      // modes keep their own flat per-win reward in remote_mode_settings.)
      // The gameEndReward bonus applies only when the level just played is the
      // adventure's final one — not whenever the player's progression has
      // reached it, which used to overpay every replay of earlier levels.
      if (multiplicationFactor > 0) {
        final int cowriesReward;

        if (level == adventureUtility.maxLevel) {
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
      // Mode-aware write: namespaced if the utility provides a writer, else the
      // default top-level increment (unchanged behavior for single-game apps).
      if (adventureUtility.setUserLevel != null) {
        adventureUtility.setUserLevel!(
          userCubit,
          adventureUtility.getUserLevel(userCubit.state.user) + 1,
        );
      } else {
        userCubit.incrementLevel();
      }
    }
  } else if (isCurrentLevelLast) {
    // Losing (or quitting, which registers as a defeat) costs coins only on the
    // furthest, not-yet-cleared level. Replaying an already-passed level is
    // free — matching the quit/exit rule (adventure onExitGame) and the
    // closing-popup copy. (8 Américain previously charged on every defeat
    // regardless of level, which drained coins even on already-passed replays.)
    userCubit.decrementCowries(Gamico.instance.gameSettings.playMinimumCoins);
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
      GameType.localNetwork => LocalNetworkModeSettings(),
      GameType.tutorial => TutorialModeSettings(),
    };
  }
}
