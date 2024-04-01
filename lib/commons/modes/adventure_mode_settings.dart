import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/generics/game_exit_button.dart';
import 'package:gamico/commons/generics/game_replay_button.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';
import 'package:gamico/commons/modes/game_mode_settings.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:gamico/features/game/cubits/adventure/adventure_game_cubit.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/languages/languages.dart';

class AdventureModeSettings implements GameModeSettings {
  @override
  void manageReplay(BuildContext context) {
    final adventureGameCubit = context.read<GamicoAdventureGameCubit>();

    NavigationService.pop(context);

    adventureGameCubit.setReplayActive(true);
  }

  @override
  GamicoUserModel localPlayerProfile(BuildContext context) {
    return UserService.getUser() ?? const GamicoUserModel();
  }

  @override
  GamicoUserModel otherPlayerProfile(BuildContext context) {
    final l = GamicoLanguages.of(context);
    final level = context
        .select((GamicoAdventureGameCubit gameCubit) => gameCubit.state.level);

    return GamicoUserModel(name: l.names[level]);
  }

  @override
  String? localPlayerDescription(BuildContext context) {
    return null;
  }

  @override
  String? otherPlayerDescription(BuildContext context) {
    final l = GamicoLanguages.of(context);
    final level = context
        .select((GamicoAdventureGameCubit gameCubit) => gameCubit.state.level);

    return l.gameScoresIndicatorNormalGameDescription(level);
  }

  @override
  String? gamePopupDescription(BuildContext context) {
    final l = GamicoLanguages.of(context);
    final adventureUtility = context.select(
        (GamicoAdventureGameCubit userCubit) =>
            userCubit.state.adventureUtility);
    final userLevel = context.select((GamicoUserCubit userCubit) =>
        adventureUtility.getUserLevel(userCubit.state.user));
    final level = context
        .select((GamicoAdventureGameCubit userCubit) => userCubit.state.level);
    final victory =
        context.select((GamicoGameCubit userCubit) => userCubit.state.victory);

    final possibleToPlayNextLevel = isPossibleToPlayNextLevel(context);
    final possibleToPlayAgain = isPossibleToPlayAgain(context);

    if (victory == null) {
      if (userLevel > level) {
        if (level == adventureUtility.maxLevel) {
          return l.adventureDrawGameFinishedDescription;
        }

        if (!possibleToPlayNextLevel) {
          return l.adventureDrawImpossibleToPlayNextLevelDescription;
        }

        return l.adventureDrawPossibleToPlayNextLevelDescription;
      } else {
        return l.adventureDrawPossibleToPlayAgainDescription;
      }
    } else if (victory) {
      if (level == adventureUtility.maxLevel) {
        return l.adventureVictoryGameFinishedDescription;
      }

      if (!possibleToPlayNextLevel) {
        return l.adventureVictoryImpossibleToPlayNextLevelDescription;
      }

      return l.adventureVictoryPossibleToPlayNextLevelDescription;
    } else {
      if (userLevel > level) {
        if (level == adventureUtility.maxLevel) {
          return l.adventureGameAlreadyFinishedDescription;
        }

        if (!possibleToPlayNextLevel) {
          return l.adventureDefeatImpossibleToPlayNextLevelDescription;
        }

        return l.adventureDefeatPossibleToPlayNextLevelDescription;
      } else {
        if (!possibleToPlayAgain) {
          return l.adventureDefeatImpossibleToPlayAgainDescription;
        }

        return l.adventureDefeatPossibleToPlayAgainDescription;
      }
    }
  }

  @override
  String? gamePopupTitle(BuildContext context) {
    return null;
  }

  @override
  bool isOpponentAvailable(BuildContext context) {
    return true;
  }

  @override
  bool isPossibleToPlayAgain(BuildContext context) {
    final level = context
        .select((GamicoAdventureGameCubit userCubit) => userCubit.state.level);
    final adventureUtility = context.select(
        (GamicoAdventureGameCubit userCubit) =>
            userCubit.state.adventureUtility);
    final coins = context.select(
        (GamicoUserCubit userCubit) => userCubit.state.user?.coins ?? 0);
    final userLevel = context.select((GamicoUserCubit userCubit) =>
        adventureUtility.getUserLevel(userCubit.state.user));

    return coins >= Gamico.instance.gameSettings.playMinimumCowries ||
        userLevel > level;
  }

  @override
  bool isPossibleToPlayNextLevel(BuildContext context) {
    final adventureUtility = context.select(
        (GamicoAdventureGameCubit userCubit) =>
            userCubit.state.adventureUtility);

    final coins = context.select(
        (GamicoUserCubit userCubit) => userCubit.state.user?.coins ?? 0);
    final userLevel = context.select((GamicoUserCubit userCubit) =>
        adventureUtility.getUserLevel(userCubit.state.user));

    final level = context
        .select((GamicoAdventureGameCubit userCubit) => userCubit.state.level);

    return (userLevel == level + 1
            ? coins >= Gamico.instance.gameSettings.playMinimumCowries
            : userLevel > level) &&
        level != adventureUtility.maxLevel;
  }

  @override
  List<Widget> gamePopupButtons(
    BuildContext context,
    GamicoGameExitButton exitButton,
    GamicoGameReplayButton replayButton,
  ) {
    final l = GamicoLanguages.of(context);

    final adventureUtility = context.select(
        (GamicoAdventureGameCubit userCubit) =>
            userCubit.state.adventureUtility);

    final userLevel = context.select((GamicoUserCubit userCubit) =>
        adventureUtility.getUserLevel(userCubit.state.user));
    final level = context
        .select((GamicoAdventureGameCubit userCubit) => userCubit.state.level);
    final victory =
        context.select((GamicoGameCubit userCubit) => userCubit.state.victory);

    final nextLevelButton = GamicoIconTextButton(
      color: Colors.orange,
      onPressed: !isPossibleToPlayNextLevel(context)
          ? null
          : () async {
              NavigationService.pop(context);
              context.read<GamicoAdventureGameCubit>().setNextLevelActive(true);
            },
      text: l.gamePopupNextLevel,
      iconData: Icons.keyboard_double_arrow_right,
    );

    final nextLevelVisible = (victory == true || userLevel > level) &&
        level != adventureUtility.maxLevel;

    return [
      exitButton,
      if (nextLevelVisible) nextLevelButton,
      replayButton,
    ];
  }

  @override
  bool hasTripleAdAfterVictory(BuildContext context) {
    final level = context
        .select((GamicoAdventureGameCubit userCubit) => userCubit.state.level);
    final adventureUtility = context.select(
        (GamicoAdventureGameCubit userCubit) =>
            userCubit.state.adventureUtility);
    final userInitialLevel = context.select(
        (GamicoAdventureGameCubit userCubit) =>
            userCubit.state.userInitialLevel);
    final userLevel = context.select((GamicoUserCubit userCubit) =>
        adventureUtility.getUserLevel(userCubit.state.user));

    return userLevel == level + 1 && userInitialLevel == level;
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

    final adventureGameCubit = context.read<GamicoAdventureGameCubit>();
    final userCubit = context.read<GamicoUserCubit>();

    final adventureUtility = adventureGameCubit.state.adventureUtility;

    if (adventureGameCubit.state.level ==
        adventureUtility.getUserLevel(userCubit.state.user)) {
      return l.adventureComplexCloseDescription(
          Gamico.instance.gameSettings.playMinimumCowries);
    } else {
      return l.adventureSimpleCloseDescription;
    }
  }

  @override
  void gamePageManageCoinsAndStars(BuildContext context) {
    final gameCubit = context.read<GamicoGameCubit>();
    final userCubit = context.read<GamicoUserCubit>();
    final adventureGameCubit = context.read<GamicoAdventureGameCubit>();

    final gameState = gameCubit.state;
    final aventureGameState = adventureGameCubit.state;

    final victory = gameState.victory;
    final level = aventureGameState.level;
    final currentLevelStars = gameState.stars;
    final userStars = (userCubit.state.user?.stars as List<int>?) ?? [];
    final levelPreviousStars = userStars.elementAtOrNull(level) ?? 0;
    final adventureUtility = aventureGameState.adventureUtility;

    if (victory == true) {
      if (currentLevelStars > levelPreviousStars) {
        final newStars = <int>[];

        for (int i = 0; i <= adventureUtility.maxLevel; i++) {
          newStars.add(userStars.elementAtOrNull(i) ?? 0);
        }

        newStars[level] = currentLevelStars;

        userCubit.updateStars(newStars);

        final int currentUserLevel =
            adventureUtility.getUserLevel(userCubit.state.user);
        final multiplicationFactor = currentLevelStars - levelPreviousStars;

        if (multiplicationFactor > 0) {
          final int cowriesReward;

          if (currentUserLevel == adventureUtility.maxLevel) {
            cowriesReward = adventureUtility.gameEndReward;
          } else {
            cowriesReward = Gamico.instance.gameSettings.playMinimumCowries;
          }

          userCubit
              .incrementCowries((cowriesReward * multiplicationFactor).toInt());
        }

        // Increment level if current level is last
        if (level == adventureUtility.getUserLevel(userCubit.state.user)) {
          userCubit.incrementLevel();
        }
      }
    } else {
      // Decrement cowries if current level is last
      if (level == adventureUtility.getUserLevel(userCubit.state.user)) {
        userCubit.decrementCowries(
          Gamico.instance.gameSettings.playMinimumCowries,
        );
      }
    }
  }

  @override
  bool shouldShowAds(BuildContext context) {
    final gameCubit = context.read<GamicoGameCubit>();
    final adventureGameCubit = context.read<GamicoAdventureGameCubit>();

    final gameState = gameCubit.state;
    final adventureGameState = adventureGameCubit.state;

    return GameService.plays >= 5 ||
        (gameState.victory == true &&
            adventureGameState.level ==
                adventureGameState.adventureUtility.maxLevel);
  }

  @override
  void onExitingGame(BuildContext context) {}

  @override
  bool shouldForceExit(BuildContext context) {
    return false;
  }

  @override
  void gamePageManageGamePopup(BuildContext context) {
    context.read<GamicoGameCubit>().setDisplayGamePopup(true);
  }
}
