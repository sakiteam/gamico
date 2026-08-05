import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamico/commons/enums/game_type.dart';
import 'package:gamico/commons/cubits/music/music_cubit.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/generics/pop_scope.dart';
import 'package:gamico/commons/global/gamico.dart';
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
class GamicoGamePage extends StatefulWidget {
  final Widget child;
  final GameUtility gameUtility;

  /// Page on which the concrete game is played.
  const GamicoGamePage({
    super.key,
    required this.child,
    required this.gameUtility,
  });

  @override
  State<GamicoGamePage> createState() => _GamicoGamePageState();
}

class _GamicoGamePageState extends State<GamicoGamePage> {
  Function? onClosed;

  @override
  Widget build(BuildContext context) {
    final finalGameUtility = widget.gameUtility;
    final gameType = finalGameUtility.type;

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
        if (finalGameUtility is AdventureGameUtility)
          BlocProvider(
            lazy: false,
            create: (context) => GamicoAdventureGameCubit(
              level: finalGameUtility.level,
              gameCubit: context.read<GamicoGameCubit>(),
              adventureUtility: finalGameUtility.adventureUtility,
            )..init(),
          ),
        if (finalGameUtility is TutorialGameUtility)
          BlocProvider(
            lazy: false,
            create: (context) => GamicoTutorialGameCubit(
              gameCubit: context.read<GamicoGameCubit>(),
              tutorialLessonIndex: finalGameUtility.tutorialLessonIndex,
            )..init(),
          ),
        if (finalGameUtility is RemoteGameUtility)
          BlocProvider(
            lazy: false,
            create: (context) => GamicoRemoteGameCubit(
              level: finalGameUtility.level,
              remoteUtility: finalGameUtility.remoteUtility,
              adventureUtility: finalGameUtility.adventureUtility,
              fakeOpponent: finalGameUtility.fakeOpponent,
              gameId: finalGameUtility.gameId,
              creator: finalGameUtility.creatorOfCurrentGame,
              gameCubit: context.read<GamicoGameCubit>(),
              gamesRepository: context.read<GamicoGamesRepository>(),
              friend: finalGameUtility.friend,
            )..init(),
          ),
        if (finalGameUtility is PassAndPlayGameUtility)
          BlocProvider(
            lazy: false,
            create: (context) => GamicoPassAndPlayGameCubit(
              gameCubit: context.read<GamicoGameCubit>(),
            )..init(),
          ),
      ],
      child: Builder(
        builder: (context) {
          // Read once, during build: the listeners below can fire while this
          // element is already deactivated (the page being popped), and a
          // `context.read` at that point throws "Looking up a deactivated
          // widget's ancestor is unsafe".
          final pageGameCubit = context.read<GamicoGameCubit>();
          final pageAdmobCubit = context.read<AdmobCubit>();
          final pageUserCubit = context.read<GamicoUserCubit>();
          final pageMusicCubit = context.read<GamicoMusicCubit>();
          final pageCharacterCubit = context.read<CharacterCubit>();
          final pageAdventureCubit = gameType == GameType.adventure
              ? context.read<GamicoAdventureGameCubit>()
              : null;
          final pageRemoteCubit = gameType == GameType.remote
              ? context.read<GamicoRemoteGameCubit>()
              : null;
          final pagePassAndPlayCubit = gameType == GameType.passAndPlay
              ? context.read<GamicoPassAndPlayGameCubit>()
              : null;
          final pageTutorialCubit = gameType == GameType.tutorial
              ? context.read<GamicoTutorialGameCubit>()
              : null;

          final finalChild = MultiBlocListener(
            listeners: [
              BlocListener<GamicoGameCubit, GamicoGameState>(
                listener: (context, state) {
                  if (state.displayGamePopup) {
                    pageGameCubit.setDisplayGamePopup(false);

                    NavigationService.showPopup(
                      context: context,
                      builder: (_) {
                        final finalPopup = BlocProvider.value(
                          value: pageGameCubit,
                          child: const GamicoGamePopup(),
                        );

                        return switch (gameType) {
                          GameType.adventure => BlocProvider.value(
                            value: pageAdventureCubit!,
                            child: finalPopup,
                          ),
                          GameType.remote => BlocProvider.value(
                            value: pageRemoteCubit!,
                            child: finalPopup,
                          ),
                          GameType.passAndPlay => BlocProvider.value(
                            value: pagePassAndPlayCubit!,
                            child: finalPopup,
                          ),
                          GameType.tutorial => BlocProvider.value(
                            value: pageTutorialCubit!,
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

                  final admobCubit = pageAdmobCubit;
                  final gameCubit = pageGameCubit;
                  final userCubit = pageUserCubit;

                  final victory = state.victory;
                  final gameMode = state.gameMode;

                  // Display message and character feeling
                  if (victory == null) {
                    pageCharacterCubit.setFeeling(
                      FeelingType.normal,
                    );
                  } else if (victory) {
                    pageCharacterCubit.setFeeling(
                      FeelingType.happy,
                    );

                    if (state.overReason != "PASS") {
                      gameCubit.displayMessage(CongratulationsMessageUtility());
                    }
                  } else {
                    pageCharacterCubit.setFeeling(FeelingType.sad);
                  }

                  // Manage coins and stars
                  if (GameService.tutorialPassed && victory != null) {
                    gameMode.gamePageManageCoinsAndStars(context);
                  }

                  // Music management 1
                  final musicCubit = pageMusicCubit;

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

                  if (!context.mounted) return;

                  // Let an end-game cinematic (e.g. a chapter unlock) play out
                  // before the result popup slides in over it.
                  await gameCubit.awaitBeforeGamePopup?.call();

                  if (!context.mounted) return;

                  NavigationService.closePopups();
                  gameMode.gamePageManageGamePopup(context);

                  if (GameService.tutorialPassed &&
                      gameMode.shouldShowAds(context) &&
                      userCubit.state.user?.premium != true) {
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
            child: GamicoPopScope(
              onWillPop: () => _onWillPop(context),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // Concrete game
                  widget.child,

                  // Widget that displays confettis to the user
                  const GamicoGameConfetti(),

                  // Content visible when displaying congratulation message
                  if (Gamico.instance.playSettings?.displayCongratulations ==
                      true)
                    const GamicoGameCongratulationsText(),
                ],
              ),
            ),
          );

          if (finalGameUtility is AdventureGameUtility) {
            return AdventureGamePage(
              level: finalGameUtility.level,
              onBackButtonPressed: finalGameUtility.onBackButtonPressed,
              child: finalChild,
            );
          } else if (finalGameUtility is TutorialGameUtility) {
            return TutorialGamePage(
              onBackButtonPressed: finalGameUtility.onBackButtonPressed,
              child: finalChild,
            );
          } else if (finalGameUtility is RemoteGameUtility) {
            return GamicoRemoteGamePage(
              onBackButtonPressed: finalGameUtility.onBackButtonPressed,
              child: finalChild,
            );
          } else if (finalGameUtility is PassAndPlayGameUtility) {
            return PassAndPlayGamePage(
              onBackButtonPressed: finalGameUtility.onBackButtonPressed,
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

    if (gameState.over ||
        gameState.gameMode.shouldForceExit(context) ||
        (gameCubit.settings?.exitIsPenaltyFree?.call() ?? false)) {
      return _managePop(context);
    }

    bool back = false;

    await NavigationService.showPopup(
      context: context,
      builder: (innerContext) {
        return GamicoPopup(
          child: GamicoDialogPoster(
            icon: Icons.warning,
            title: l.closeTitle,
            acceptationText: l.closeClose,
            acceptationIcon: Icons.arrow_back,
            description: gameState.gameMode.gamePageClosingPopupDescription(
              innerContext,
            ),
            automaticClose: false,
            onAccepted: () async {
              back = true;
              NavigationService.pop(innerContext);
            },
            onRejected: () {
              back = false;
              NavigationService.pop(innerContext);
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

    gameCubit.state.gameMode.onExitingGame(context);

    // "Nouvelle partie" (newRemoteGameActive) keeps the matchmaking page
    // below alive: onExitingGame just reset it to search again, and this pop
    // must land the player back on its waiting screen. onBackButtonPressed —
    // which pops the matchmaking page too, sending the player home — is for
    // genuine exits only.
    var newRemoteSearch = false;
    try {
      newRemoteSearch = context
          .read<GamicoRemoteGameCubit>()
          .state
          .newRemoteGameActive;
    } catch (_) {}

    onClosed = () {
      if (!newRemoteSearch) {
        widget.gameUtility.onBackButtonPressed?.call();
      }
      musicCubit.playMainMusic();
    };

    await Future.delayed(AnimationService.animationDuration);

    return true;
  }

  @override
  void deactivate() {
    onClosed?.call();
    super.deactivate();
  }
}
