import 'package:gamico/commons/cubits/admob/admob_cubit.dart';
import 'package:gamico/commons/generics/game_popup_stars.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/generics/ad_button.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/game_exit_button.dart';
import 'package:gamico/commons/generics/game_replay_button.dart';
import 'package:gamico/languages/languages.dart';

class GamicoGamePopup extends StatelessWidget {
  const GamicoGamePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    final gameMode =
        context.select((GamicoGameCubit gameCubit) => gameCubit.state.gameMode);
    final victory =
        context.select((GamicoGameCubit gameCubit) => gameCubit.state.victory);
    final tripleAdWatched = context
        .select((GamicoGameCubit gameCubit) => gameCubit.state.tripleAdWatched);

    final tripleAd = gameMode.hasTripleAdAfterVictory(context) &&
        victory == true &&
        !tripleAdWatched;

    return GamicoPopup(
      additionalChild: GamicoAdButton(
        color: tripleAd ? Colors.orange : null,
        onPressed: () async {
          final AdmobCubit admobCubit = context.read<AdmobCubit>();

          await admobCubit.ensureRewardedAdLoaded();

          admobCubit.showRewardedAd(() {
            context.read<GamicoUserCubit>().incrementCowries(tripleAd ? 3 : 1);
            context.read<GamicoGameCubit>().enabledTripleAd();
          });
        },
        text: tripleAd
            ? l.gamePopupWatchAd(
                Gamico.instance.gameSettings.playMinimumCowries)
            : null,
      ),
      child: GamicoPoster(
        icon: victory == null
            ? Icons.balance
            : victory
                ? Icons.emoji_events
                : Icons.sentiment_dissatisfied,
        iconWidget:
            victory == true && gameMode.displayStarsAfterVictory(context)
                ? const GamePopupStars()
                : null,
        title: gameMode.gamePopupTitle(context) ?? getDefaultTitle(context),
        description: gameMode.gamePopupDescription(context) ?? "",
        content: Row(
          key: gameMode.gamePopupContentKey(context),
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: gameMode.gamePopupButtons(
            context,
            const GamicoGameExitButton(),
            GamicoGameReplayButton(
              enabled: gameMode.isPossibleToPlayAgain(context) &&
                  gameMode.isOpponentAvailable(context),
            ),
          ),
        ),
        expandContent: true,
      ),
    );
  }

  String getDefaultTitle(BuildContext context) {
    final l = GamicoLanguages.of(context);

    final victory =
        context.select((GamicoGameCubit gameCubit) => gameCubit.state.victory);
    final overReason = context
        .select((GamicoGameCubit gameCubit) => gameCubit.state.overReason);

    if (victory == null) {
      return l.drawTitle;
    } else if (victory) {
      if (overReason == "EXIT") {
        return l.victoryByAbandonment;
      }

      return l.normalVictoryTitle;
    } else {
      if (overReason == "EXIT") {
        return l.defeatByAbandonment;
      }

      return l.normalDefeatTitle;
    }
  }
}
