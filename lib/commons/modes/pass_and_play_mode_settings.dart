import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/game_exit_button.dart';
import 'package:gamico/commons/generics/game_replay_button.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';
import 'package:gamico/commons/modes/game_mode_settings.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/features/game/cubits/pass_and_play/pass_and_play_game_cubit.dart';
import 'package:gamico/languages/languages.dart';

class PassAndPlayModeSettings implements GameModeSettings {
  @override
  void manageReplay(BuildContext context) {
    final passAndPlayGameCubit = context.read<GamicoPassAndPlayGameCubit>();

    NavigationService.pop(context);

    passAndPlayGameCubit.setReplayActive(true);
  }

  @override
  String? localPlayerDescription(BuildContext context) {
    return null;
  }

  @override
  GamicoUserModel localPlayerProfile(BuildContext context) {
    return const GamicoUserModel();
  }

  @override
  String? otherPlayerDescription(BuildContext context) {
    return null;
  }

  @override
  GamicoUserModel otherPlayerProfile(BuildContext context) {
    return const GamicoUserModel();
  }

  @override
  String? gamePopupDescription(BuildContext context) {
    final l = GamicoLanguages.of(context);
    final victory = context.select(
      (GamicoGameCubit userCubit) => userCubit.state.victory,
    );
    final secondVictory = context.select(
      (GamicoGameCubit userCubit) => userCubit.state.secondVictory,
    );

    if (victory == null) {
      return l.passAndPlayDrawDescription;
    } else {
      if (secondVictory) {
        return l.passAndPlayTeam2VictoryDescription;
      } else {
        return l.passAndPlayTeam1VictoryDescription;
      }
    }
  }

  @override
  String? gamePopupTitle(BuildContext context) {
    final l = GamicoLanguages.of(context);

    final victory = context.select(
      (GamicoGameCubit gameCubit) => gameCubit.state.victory,
    );
    final secondVictory = context.select(
      (GamicoGameCubit gameCubit) => gameCubit.state.secondVictory,
    );

    if (victory == null) {
      return l.passAndPlayDrawTitle;
    } else {
      if (secondVictory) {
        return l.passAndPlayTeam2VictoryTitle;
      } else {
        return l.passAndPlayTeam1VictoryTitle;
      }
    }
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
    return [exitButton, replayButton];
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
    return false;
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
    return GameService.plays >= 3;
  }

  @override
  void onExitingGame(BuildContext context) {}

  @override
  bool shouldForceExit(BuildContext context) {
    return false;
  }

  @override
  void gamePageManageGamePopup(BuildContext context) {
    if (!context.mounted) return;
    try {
      context.read<GamicoGameCubit>().setDisplayGamePopup(true);
    } catch (e) {
      debugPrint('gamePageManageGamePopup error: $e');
    }
  }

  @override
  Widget? levelsBuilder(BuildContext context) => null;

  @override
  bool isOpponentAvailable(BuildContext context) => true;
}
