import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/features/game/cubits/tutorial/tutorial_game_cubit.dart';
import 'package:gamico/languages/languages.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:gamico/commons/cubits/music/music_cubit.dart';

class GameCongratulationsTutorialPopup extends StatelessWidget {
  const GameCongratulationsTutorialPopup({super.key});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return GamicoPopup(
      dismissible: false,
      child: GamicoDialogPoster(
        icon: Icons.emoji_events,
        title: l.gametutorialCongratulationsPopupTitle,
        simple: true,
        acceptationIcon: Icons.sports_esports,
        acceptationText: l.gametutorialCongratulationsPopupPlay,
        description: l.gametutorialCongratulationsPopupDescription,
        automaticClose: false,
        onRejected: () {
          NavigationService.pop(context);
        },
        onAccepted: () async {
          final tutorialGameCubit = context.read<GamicoTutorialGameCubit>();
          final musicCubit = context.read<GamicoMusicCubit>();

          musicCubit.playMainMusic();
          NavigationService.pop(context);
          tutorialGameCubit.declareTutorialAsPassed();
        },
      ),
    );
  }
}
