import 'package:gamico/commons/cubits/admob/admob_cubit.dart';
import 'package:gamico/features/game/widgets/game_popup_stars.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/generics/ad_button.dart';
import 'package:gamico/features/game/modes/remote_mode_settings.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/features/game/widgets/game_exit_button.dart';
import 'package:gamico/features/game/widgets/game_replay_button.dart';
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

    final showStars =
        victory == true && gameMode.displayStarsAfterVictory(context);
    final decor = Gamico.instance.playSettings?.gamePopupDecor?.call(
      context,
      victory,
    );

    return GamicoPopup(
      additionalChild: Gamico.instance.admobSettings?.displayAdButton == false
          ? null
          : GamicoAdButton(
              color: tripleAd ? ColorService.accentColor : null,
              onPressed: () => context.read<GamicoGameCubit>().claimAdReward(
                admob: context.read<AdmobCubit>(),
                tripleAd: tripleAd,
              ),
              text: tripleAd
                  ? l.gamePopupWatchAd(
                      Gamico.instance.gameSettings.playMinimumCoins,
                    )
                  : null,
            ),
      child: _decorated(
        decor?.overlay,
        GamicoPoster(
          icon: victory == null
              ? Icons.balance
              : victory
              ? Icons.emoji_events
              : Icons.sentiment_dissatisfied,
          iconWidget: showStars ? const GamePopupStars() : decor?.icon,
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
                            Gamico
                                    .instance
                                    .playSettings
                                    ?.singlePlayerWhenFake ==
                                true),
                    color: gameMode.isPossibleToPlayNextLevel(context)
                        ? null
                        : ColorService.accentColor,
                  ),
                ),
              ),
          expandContent: true,
        ),
      ),
    );
  }

  /// [poster] under the game's own [overlay] (see
  /// [PlaySettings.gamePopupDecor]), or alone.
  Widget _decorated(Widget? overlay, Widget poster) {
    if (overlay == null) return poster;
    return Stack(
      fit: StackFit.expand,
      clipBehavior: Clip.none,
      children: [
        poster,
        Positioned.fill(child: IgnorePointer(child: overlay)),
      ],
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
