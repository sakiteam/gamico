import 'package:flutter/material.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/features/game/widgets/game_exit_button.dart';
import 'package:gamico/features/game/widgets/game_next_lesson_button.dart';
import 'package:gamico/features/game/widgets/game_replay_button.dart';
import 'package:gamico/languages/languages.dart';

class GamicoGamePassedTutorialPopup extends StatelessWidget {
  const GamicoGamePassedTutorialPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return GamicoPopup(
      child: GamicoPoster(
        icon: Icons.emoji_events,
        title: l.gametutorialCongratulationsPopupTitle,
        description: l.gameTutorialCongratulationsPopupUnclearDescription,
        expandContent: true,
        content: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            GamicoGameExitButton(),
            GamicoGameReplayButton(color: Colors.blue),
            GamicoGameNextLessonButton(color: Colors.blue),
          ],
        ),
      ),
    );
  }
}
