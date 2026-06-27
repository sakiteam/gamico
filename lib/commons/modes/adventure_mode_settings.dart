import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/generics/game_exit_button.dart';
import 'package:gamico/commons/generics/game_replay_button.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';
import 'package:gamico/commons/modes/game_mode_settings.dart';
import 'package:gamico/commons/services/color.dart';
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
    final level = context.select(
      (GamicoAdventureGameCubit gameCubit) => gameCubit.state.level,
    );

    return GamicoUserModel(name: l.names[level % l.names.length]);
  }

  @override
  String? localPlayerDescription(BuildContext context) {
    return null;
  }

  @override
  String? otherPlayerDescription(BuildContext context) {
    final l = GamicoLanguages.of(context);
    final level = context.select(
      (GamicoAdventureGameCubit gameCubit) => gameCubit.state.level,
    );

    return l.gameScoresIndicatorNormalGameDescription(level);
  }

  @override
  String? gamePopupDescription(BuildContext context) {
    final endMessage = context.select(
      (GamicoGameCubit gameCubit) => gameCubit.state.endMessage,
    );

    final descriptionMessage = context.select(
      (GamicoGameCubit gameCubit) => gameCubit.state.descriptionMessage,
    );

    if (descriptionMessage != null) return descriptionMessage;
    if (endMessage != null) return endMessage;

    final l = GamicoLanguages.of(context);
    final adventureUtility = context.select(
      (GamicoAdventureGameCubit userCubit) => userCubit.state.adventureUtility,
    );
    final userLevel = context.select(
      (GamicoUserCubit userCubit) =>
          adventureUtility.getUserLevel(userCubit.state.user),
    );
    final level = context.select(
      (GamicoAdventureGameCubit userCubit) => userCubit.state.level,
    );
    final victory = context.select(
      (GamicoGameCubit userCubit) => userCubit.state.victory,
    );

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
  bool isPossibleToPlayAgain(BuildContext context) {
    final level = context.select(
      (GamicoAdventureGameCubit userCubit) => userCubit.state.level,
    );
    final adventureUtility = context.select(
      (GamicoAdventureGameCubit userCubit) => userCubit.state.adventureUtility,
    );
    final coins = context.select(
      (GamicoUserCubit userCubit) => userCubit.state.user?.coins ?? 0,
    );
    final userLevel = context.select(
      (GamicoUserCubit userCubit) =>
          adventureUtility.getUserLevel(userCubit.state.user),
    );

    return coins >= Gamico.instance.gameSettings.playMinimumCoins ||
        userLevel > level ||
        Gamico.instance.gameSettings.ignoreMinimumCoinsToPlay;
  }

  @override
  bool isPossibleToPlayNextLevel(BuildContext context) {
    final adventureUtility = context.select(
      (GamicoAdventureGameCubit cubit) => cubit.state.adventureUtility,
    );

    final coins = context.select(
      (GamicoUserCubit cubit) => cubit.state.user?.coins ?? 0,
    );
    final userLevel = context.select(
      (GamicoUserCubit cubit) =>
          adventureUtility.getUserLevel(cubit.state.user),
    );

    final level = context.select(
      (GamicoAdventureGameCubit cubit) => cubit.state.level,
    );

    final endMessage = context.select(
      (GamicoGameCubit gameCubit) => gameCubit.state.endMessage,
    );

    return (userLevel == level + 1
            ? (coins >= Gamico.instance.gameSettings.playMinimumCoins ||
                  Gamico.instance.gameSettings.ignoreMinimumCoinsToPlay)
            : userLevel > level) &&
        level != adventureUtility.maxLevel &&
        endMessage == null;
  }

  @override
  List<Widget> gamePopupButtons(
    BuildContext context,
    GamicoGameExitButton exitButton,
    GamicoGameReplayButton replayButton,
  ) {
    final l = GamicoLanguages.of(context);

    final adventureUtility = context.select(
      (GamicoAdventureGameCubit userCubit) => userCubit.state.adventureUtility,
    );

    final userLevel = context.select(
      (GamicoUserCubit userCubit) =>
          adventureUtility.getUserLevel(userCubit.state.user),
    );
    final level = context.select(
      (GamicoAdventureGameCubit userCubit) => userCubit.state.level,
    );
    final victory = context.select(
      (GamicoGameCubit userCubit) => userCubit.state.victory,
    );

    final endMessage = context.select(
      (GamicoGameCubit gameCubit) => gameCubit.state.endMessage,
    );

    final nextLevelButton = GamicoIconTextButton(
      color: ColorService.accentColor,
      onPressed: !isPossibleToPlayNextLevel(context)
          ? null
          : () async {
              NavigationService.pop(context);
              context.read<GamicoAdventureGameCubit>().setNextLevelActive(true);
            },
      text: l.gamePopupNextLevel,
      iconData: Icons.keyboard_double_arrow_right,
    );

    final nextLevelVisible =
        (victory == true || userLevel > level) &&
        level != adventureUtility.maxLevel &&
        endMessage == null;

    return [exitButton, if (nextLevelVisible) nextLevelButton, replayButton];
  }

  @override
  bool hasTripleAdAfterVictory(BuildContext context) {
    final level = context.select(
      (GamicoAdventureGameCubit userCubit) => userCubit.state.level,
    );
    final adventureUtility = context.select(
      (GamicoAdventureGameCubit userCubit) => userCubit.state.adventureUtility,
    );
    final userInitialLevel = context.select(
      (GamicoAdventureGameCubit userCubit) => userCubit.state.userInitialLevel,
    );
    final userLevel = context.select(
      (GamicoUserCubit userCubit) =>
          adventureUtility.getUserLevel(userCubit.state.user),
    );

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
        Gamico.instance.gameSettings.playMinimumCoins,
      );
    } else {
      return l.adventureSimpleCloseDescription;
    }
  }

  @override
  void gamePageManageCoinsAndStars(BuildContext context) {
    final aventureGameState = context.read<GamicoAdventureGameCubit>().state;

    gamePageManageCoinsAndStarsInAdventureGame(
      context,
      aventureGameState.level,
      aventureGameState.adventureUtility,
    );
  }

  @override
  bool shouldShowAds(BuildContext context) {
    final gameCubit = context.read<GamicoGameCubit>();
    final adventureGameCubit = context.read<GamicoAdventureGameCubit>();

    final gameState = gameCubit.state;
    final adventureGameState = adventureGameCubit.state;

    return shouldShowAdsInAdventureGame(
      gameState.victory,
      adventureGameState.level,
      adventureGameState.adventureUtility.maxLevel,
      gameState.endMessage,
      gameState.descriptionMessage,
    );
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

  @override
  Widget? levelsBuilder(BuildContext context) => null;

  @override
  bool isOpponentAvailable(BuildContext context) => true;
}
