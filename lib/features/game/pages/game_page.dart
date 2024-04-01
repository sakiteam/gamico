import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamico/commons/enums/game_type.dart';
import 'package:gamico/commons/cubits/music/music_cubit.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/services/animation.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:gamico/commons/generics/game_confetti.dart';
import 'package:gamico/commons/generics/game_congratulations_text.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/features/game/cubits/adventure/adventure_game_cubit.dart';
import 'package:gamico/features/game/cubits/pass_and_play/pass_and_play_game_cubit.dart';
import 'package:gamico/commons/utilities/message/concrete/congratulations_message_utility.dart';
import 'package:gamico/features/game/cubits/remote/remote_game_cubit.dart';
import 'package:gamico/features/game/cubits/tutorial/tutorial_game_cubit.dart';
import 'package:gamico/features/game/pages/adventure_game_page.dart';
import 'package:gamico/features/game/pages/pass_and_play_game_page.dart';
import 'package:gamico/features/game/pages/remote_game_page.dart';
import 'package:gamico/features/game/pages/tutorial_game_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/cubits/admob/admob_cubit.dart';
import 'package:gamico/commons/repositories/gamico_games_repository.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/commons/generics/game_popup.dart';
import 'package:gamico/commons/cubits/character/character_cubit.dart';
import 'package:gamico/languages/languages.dart';

/// Page on which the concrete game is played.
class GamicoGamePage extends StatelessWidget {
  final Widget child;
  final GameUtility gameUtility;

  /// Page on which the concrete game is played.
  const GamicoGamePage({
    super.key,
    required this.child,
    required this.gameUtility,
  });

  @override
  Widget build(BuildContext context) {
    final gameType = gameUtility.gameType;

    return MultiBlocProvider(
      providers: [
        BlocProvider(
          lazy: false,
          create: (context) => GamicoGameCubit(
            gameType: gameType,
            userCubit: context.read<GamicoUserCubit>(),
            musicCubit: context.read<GamicoMusicCubit>(),
            characterCubit: context.read<CharacterCubit>(),
          ),
        ),
        if (gameType == GameType.adventure)
          BlocProvider(
            lazy: false,
            create: (context) => GamicoAdventureGameCubit(
              level: gameUtility.level!,
              gameCubit: context.read<GamicoGameCubit>(),
              adventureUtility: gameUtility.adventureUtility!,
            )..init(),
          ),
        if (gameType == GameType.tutorial)
          BlocProvider(
            lazy: false,
            create: (context) => GamicoTutorialGameCubit(
              gameCubit: context.read<GamicoGameCubit>(),
              tutorialLessonIndex: gameUtility.tutorialLessonIndex ?? 0,
            )..init(),
          ),
        if (gameType == GameType.remote)
          BlocProvider(
            lazy: false,
            create: (context) => GamicoRemoteGameCubit(
              fakeOpponent: gameUtility.fakeOpponent ?? false,
              gamesRepository: context.read<GamicoGamesRepository>(),
              gameId: gameUtility.gameId ?? "",
              creator: gameUtility.creatorOfCurrentGame ?? true,
              gameCubit: context.read<GamicoGameCubit>(),
            )..init(),
          ),
        if (gameType == GameType.passAndPlay)
          BlocProvider(
            lazy: false,
            create: (context) => GamicoPassAndPlayGameCubit(
              gameCubit: context.read<GamicoGameCubit>(),
            )..init(),
          ),
      ],
      child: Builder(
        builder: (context) {
          final finalChild = MultiBlocListener(
            listeners: [
              BlocListener<GamicoGameCubit, GamicoGameState>(
                listener: (context, state) {
                  context.read<GamicoGameCubit>().setDisplayGamePopup(false);

                  if (state.displayGamePopup) {
                    NavigationService.showPopup(
                      context: context,
                      builder: (_) {
                        final finalPopup = BlocProvider.value(
                          value: context.read<GamicoGameCubit>(),
                          child: const GamicoGamePopup(),
                        );

                        return switch (gameType) {
                          GameType.adventure => BlocProvider.value(
                              value: context.read<GamicoAdventureGameCubit>(),
                              child: finalPopup,
                            ),
                          GameType.remote => BlocProvider.value(
                              value: context.read<GamicoRemoteGameCubit>(),
                              child: finalPopup,
                            ),
                          GameType.passAndPlay => BlocProvider.value(
                              value: context.read<GamicoPassAndPlayGameCubit>(),
                              child: finalPopup,
                            ),
                          GameType.tutorial => BlocProvider.value(
                              value: context.read<GamicoTutorialGameCubit>(),
                              child: finalPopup,
                            ),
                        };
                      },
                    );
                  }
                },
                listenWhen: (previous, current) {
                  return !previous.displayGamePopup && current.displayGamePopup;
                },
              ),
              BlocListener<GamicoGameCubit, GamicoGameState>(
                listener: (context, state) {
                  NavigationService.maybePop(context);
                },
                listenWhen: (previous, current) {
                  return !previous.backActive && current.backActive;
                },
              ),
              BlocListener<GamicoGameCubit, GamicoGameState>(
                listener: (context, state) async {
                  if (!state.tutorial) {
                    GameService.plays++;
                  }

                  GameService.gameSkipped = false;

                  final admobCubit = context.read<AdmobCubit>();
                  final gameCubit = context.read<GamicoGameCubit>();

                  final victory = state.victory;
                  final gameMode = state.gameMode;

                  // Display message and character feeling
                  if (victory == null) {
                    context
                        .read<CharacterCubit>()
                        .setFeeling(FeelingType.normal);
                  } else if (victory) {
                    context
                        .read<CharacterCubit>()
                        .setFeeling(FeelingType.happy);

                    if (state.overReason != "PASS") {
                      gameCubit.displayMessage(CongratulationsMessageUtility());
                    }
                  } else {
                    context.read<CharacterCubit>().setFeeling(FeelingType.sad);
                  }

                  // Manage coins and stars
                  if (GameService.tutorialPassed && victory != null) {
                    gameMode.gamePageManageCoinsAndStars(context);
                  }

                  // Music management 1
                  final musicCubit = context.read<GamicoMusicCubit>();

                  try {
                    Future<void> Function()? playingBruitageFunction;

                    if (gameCubit.state.active) {
                      await musicCubit.pauseMusic();
                    }

                    if (gameCubit.state.active) {
                      if (victory == null) {
                        await musicCubit.setDrawMusicAsset();
                        playingBruitageFunction = musicCubit.playDrawBruitage;
                      } else if (victory) {
                        await musicCubit.setVictoryMusicAsset();
                        playingBruitageFunction = musicCubit.playWinBruitage;
                      } else {
                        await musicCubit.setDefeatMusicAsset();
                        playingBruitageFunction = musicCubit.playLoseBruitage;
                      }
                    }

                    if (gameCubit.state.active) {
                      playingBruitageFunction?.call();
                    }
                  } catch (e) {
                    debugPrint(e.toString());
                  }

                  await Future.delayed(2.seconds);

                  NavigationService.closePopups();
                  gameMode.gamePageManageGamePopup(context);

                  if (GameService.tutorialPassed &&
                      gameMode.shouldShowAds(context)) {
                    try {
                      if (admobCubit.state.rewardedAdStatus ==
                          AdmobRewardedAdStatus.success) {
                        admobCubit.showInterstitialAd();
                        GameService.plays = 0;
                      }
                    } catch (e) {
                      debugPrint(e.toString());
                    }
                  }

                  // Music management 2
                  if (gameCubit.state.active) musicCubit.playMainPlayer();
                },
                listenWhen: (oldState, newState) {
                  return !oldState.over && newState.over;
                },
              ),
            ],
            child: WillPopScope(
              onWillPop: () => _onWillPop(context),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Concrete game
                  child,

                  /// Widget that displays confettis to the user
                  const GamicoGameConfetti(),

                  // Content visible when displaying congratulation message
                  const GamicoGameCongratulationsText(),
                ],
              ),
            ),
          );

          if (gameType == GameType.adventure) {
            return AdventureGamePage(
              level: gameUtility.level!,
              onBackButtonPressed: gameUtility.onBackButtonPressed,
              child: finalChild,
            );
          } else if (gameType == GameType.tutorial) {
            return TutorialGamePage(
              onBackButtonPressed: gameUtility.onBackButtonPressed,
              child: finalChild,
            );
          } else if (gameType == GameType.remote) {
            return GamicoRemoteGamePage(
              onBackButtonPressed: gameUtility.onBackButtonPressed,
              child: finalChild,
            );
          } else if (gameType == GameType.remote) {
            return PassAndPlayGamePage(
              onBackButtonPressed: gameUtility.onBackButtonPressed,
              child: finalChild,
            );
          }

          return finalChild;
        },
      ),
    );
  }

  Future<bool> _onWillPop(BuildContext context) async {
    final l = GamicoLanguages.of(context);

    final gameCubit = context.read<GamicoGameCubit>();
    final gameState = gameCubit.state;

    if (!gameCubit.state.enabled) {
      return false;
    }

    if (gameState.over || gameState.gameMode.shouldForceExit(context)) {
      return _managePop(context);
    }

    bool back = false;

    await NavigationService.showPopup(
      context: context,
      builder: (_) {
        return GamicoPopup(
          child: GamicoDialogPoster(
            icon: Icons.warning,
            title: l.closeTitle,
            acceptationText: l.closeClose,
            acceptationIcon: Icons.arrow_back,
            description:
                gameState.gameMode.gamePageClosingPopupDescription(context),
            automaticClose: false,
            onAccepted: () async {
              back = true;
              NavigationService.pop(_);
            },
            onRejected: () {
              back = false;
              NavigationService.pop(_);
            },
          ),
        );
      },
    );

    if (back) {
      return _managePop(context);
    }

    return false;
  }

  /// Determine whether one can go back or not
  Future<bool> _managePop(BuildContext context) async {
    final gameCubit = context.read<GamicoGameCubit>();
    final musicCubit = context.read<GamicoMusicCubit>();

    gameCubit.setActive(false);

    NavigationService.closePopups();

    gameCubit.onExitGame?.call();
    gameCubit.setAnimInit(false);

    await Future.delayed(AnimationService.animationDuration);

    gameUtility.onBackButtonPressed?.call();

    gameCubit.state.gameMode.onExitingGame(context);

    musicCubit.playMainMusic();

    return true;
  }
}
