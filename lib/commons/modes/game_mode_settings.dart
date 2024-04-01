import 'package:flutter/material.dart';
import 'package:gamico/commons/enums/game_type.dart';
import 'package:gamico/commons/generics/game_exit_button.dart';
import 'package:gamico/commons/generics/game_replay_button.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';
import 'package:gamico/commons/modes/adventure_mode_settings.dart';
import 'package:gamico/commons/modes/pass_and_play_mode_settings.dart';
import 'package:gamico/commons/modes/remote_mode_settings.dart';
import 'package:gamico/commons/modes/tutorial_mode_settings.dart';

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
