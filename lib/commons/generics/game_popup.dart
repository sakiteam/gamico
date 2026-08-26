import 'package:gamico/commons/cubits/admob/admob_cubit.dart';
import 'package:gamico/commons/generics/game_popup_stars.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/generics/ad_button.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/modes/remote_mode_settings.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/game_exit_button.dart';
import 'package:gamico/commons/generics/game_replay_button.dart';
import 'package:gamico/features/game/cubits/remote/remote_game_cubit.dart';
import 'package:gamico/languages/languages.dart';

class GamicoGamePopup extends StatelessWidget {
  const GamicoGamePopup({super.key});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    final gameMode = context.select(
      (GamicoGameCubit gameCubit) => gameCubit.state.gameMode,
    );
    final victory = context.select(
      (GamicoGameCubit gameCubit) => gameCubit.state.victory,
    );
    final tripleAdWatched = context.select(
      (GamicoGameCubit gameCubit) => gameCubit.state.tripleAdWatched,
    );

    final String gameEndStatus;

    if (gameMode is RemoteModeSettings) {
      gameEndStatus = context.select(
        (GamicoRemoteGameCubit remoteGameCubit) =>
            remoteGameCubit.state.gameEndStatus,
      );
    } else {
      gameEndStatus = "";
    }

    final tripleAd =
        gameMode.hasTripleAdAfterVictory(context) &&
        victory == true &&
        !tripleAdWatched;

    final levelsBuilder = gameEndStatus.isEmpty
        ? gameMode.levelsBuilder(context)
        : null;

    return GamicoPopup(
      additionalChild: Gamico.instance.admobSettings?.displayAdButton == false
          ? null
          : GamicoAdButton(
              color: tripleAd ? ColorService.accentColor : null,
              onPressed: () async {
                final AdmobCubit admobCubit = context.read<AdmobCubit>();

                await admobCubit.ensureRewardedAdLoaded();

                admobCubit.showRewardedAd(() {
                  context.read<GamicoUserCubit>().incrementCowries(
                    tripleAd
                        ? Gamico.instance.gameSettings.playMinimumCoins
                        : 1,
                  );
                  context.read<GamicoGameCubit>().enabledTripleAd();
                });
              },
              text: tripleAd
                  ? l.gamePopupWatchAd(
                      Gamico.instance.gameSettings.playMinimumCoins,
                    )
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
        contentPadding: EdgeInsets.zero,
        content:
            levelsBuilder ??
            Row(
              key: gameMode.gamePopupContentKey(context),
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: gameMode.gamePopupButtons(
                context,
                const GamicoGameExitButton(),
                GamicoGameReplayButton(
                  enabled:
                      gameMode.isPossibleToPlayAgain(context) &&
                      (gameMode.isOpponentAvailable(context) ||
                          Gamico.instance.playSettings?.singlePlayerWhenFake ==
                              true),
                  color: gameMode.isPossibleToPlayNextLevel(context)
                      ? null
                      : ColorService.accentColor,
                ),
              ),
            ),
        expandContent: true,
      ),
    );
  }

  String getDefaultTitle(BuildContext context) {
    final l = GamicoLanguages.of(context);

    final victory = context.select(
      (GamicoGameCubit gameCubit) => gameCubit.state.victory,
    );
    final overReason = context.select(
      (GamicoGameCubit gameCubit) => gameCubit.state.overReason,
    );

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
