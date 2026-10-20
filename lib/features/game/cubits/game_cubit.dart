import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/admob/admob_cubit.dart';
import 'package:gamico/commons/enums/game_type.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/cubits/music/music_cubit.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/animation.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/features/game/cubits/adventure/adventure_game_cubit.dart';
import 'package:gamico/features/game/cubits/local_network/local_network_game_cubit.dart';
import 'package:gamico/features/game/cubits/pass_and_play/pass_and_play_game_cubit.dart';
import 'package:gamico/features/game/cubits/remote/remote_game_cubit.dart';
import 'package:gamico/features/game/cubits/tutorial/tutorial_game_cubit.dart';
import 'package:gamico/features/game/modes/game_mode_settings.dart';
import 'package:gamico/commons/cubits/character/character_cubit.dart';
import 'package:gamico/commons/utilities/message/abstract/message_utility.dart';
import 'package:gamico/commons/utilities/message/concrete/congratulations_message_utility.dart';
import 'package:gamico/features/game/utilities/gamico_game_cubit_settings.dart';
import 'package:gamico/features/game/widgets/game_popup.dart';
import 'package:gamico/languages/languages.dart';

part 'game_state.dart';

class GamicoGameCubit extends Cubit<GamicoGameState> {
  /* CONSTRUCTOR */

  GamicoGameCubit({
    required GameType gameType,
    required this.userCubit,
    required this.musicCubit,
    required this.characterCubit,
    this.admobCubit,
  }) : super(GamicoGameState(mode: gameType));

  /* PROPERTIES */

  // Usual cubits
  final GamicoUserCubit userCubit;
  final GamicoMusicCubit musicCubit;
  final CharacterCubit characterCubit;
  final AdmobCubit? admobCubit;

  // Game settings
  GamicoGameCubitSettings? settings;

  // Controllers
  Future<void> Function()? onInit;

  /// Called when a second [init] swaps the settings in, with the ones it
  /// replaced (see `GamicoRemoteGameCubit`, which hands the new settings what
  /// placeholder ones could not take).
  void Function(GamicoGameCubitSettings? previous)? onSettingsReplaced;
  void Function()? onGiveUp;
  void Function()? onExitGame;

  /// Run as soon as the player asks to leave, before anything decides whether
  /// that is an abandonment. A game whose result is already settled on the
  /// table but not yet announced to the framework (the end of a run, while its
  /// reveal still plays) ends the game here: [GamicoGameState.over] is then
  /// true when the exit is judged, so leaving is neither penalised nor asked to
  /// be confirmed, and the framework settles the result as it always does.
  void Function()? onBeforeExit;

  /// Asked right after [onBeforeExit], before anything else is decided or
  /// done: false keeps the player on the page, with nothing of the exit
  /// started. A game that wants a say before the exit begins (a warning about
  /// the voice call that would be hung up, closing an open chat first) must
  /// ask here: once [managePop] has run the game is already deactivated and the
  /// player's exit declared, whatever the page then decides.
  Future<bool> Function()? confirmExit;
  void Function()? onGameEnd;

  /// Fired the moment the match actually starts, whatever led to it (the
  /// readiness roll-call, a bot table, an explanation popup the player just
  /// dismissed). Remote games hang the abandonment penalty on it: arming that
  /// penalty at any *earlier* point punishes players for leaving a table that
  /// was never dealt, and arming it at one specific call site would miss any
  /// other way of starting.
  void Function()? onGameStart;
  Function? onClosed;

  /// The game's own end-of-match popup, taken from its [GameUtility]. When it
  /// is null — or returns null — the framework's generic [GamicoGamePopup]
  /// closes the match instead. Either way the framework owns *when* it opens.
  Widget? Function(BuildContext context)? endGamePopupBuilder;

  /// Optional gate awaited right before the end-of-game popup is shown (after
  /// the standard result delay). A game can use it to let an end-game
  /// cinematic play out first — the popup only appears once this completes.
  /// Null (the default) keeps the standard timing for every other game.
  Future<void> Function()? awaitBeforeGamePopup;

  /// Set by a game that runs its own interstitial rules for this match (e.g.
  /// Crazy Eights): the framework then never adds its end-of-game ad, so the
  /// two sets of rules can't each show one on the same ending.
  bool ownsInterstitials = false;

  /* INHERITED */

  @override
  void emit(GamicoGameState state) {
    if (isClosed) return;

    super.emit(state);
  }

  /* USUAL */

  void setAnimInit(bool animInit) {
    emit(state.copyWith(animInit: animInit));
  }

  void setAnimGame(bool animGame) {
    emit(state.copyWith(animGame: animGame));
  }

  void setAnimHome(bool animHome) {
    emit(state.copyWith(animHome: animHome));
  }

  void setAnimated(bool animated) {
    emit(state.copyWith(animated: animated));
  }

  void setDisplayGamePopup(bool displayGamePopup) {
    emit(state.copyWith(displayGamePopup: displayGamePopup));
  }

  void setBackActive(bool backActive) {
    emit(state.copyWith(backActive: backActive));
  }

  void setActive(bool active) {
    emit(state.copyWith(active: active));
  }

  /* BEFORE GAME */

  Future<void> init(GamicoGameCubitSettings settings) async {
    // A remote game can legitimately call this twice: once with a throwaway
    // settings object to kick off matchmaking/opponent loading as early as
    // possible, then again with the real callbacks once the concrete game
    // cubit exists. The second call must still swap in the real settings
    // (that's what wires up move/exit handling), but must not replay the
    // one-time init work — restarting game music and re-running `onInit`
    // (re-fetching the game, resubscribing opponent listeners, resending
    // readiness) a second time.
    final previous = this.settings;
    final alreadyInitialized = previous != null;
    this.settings = settings;
    if (alreadyInitialized) {
      onSettingsReplaced?.call(previous);
      return;
    }

    setAnimInit(true);

    musicCubit.playGameMusic();

    await onInit?.call();
  }

  void startGame() {
    final wasReady = state.ready;

    // Declare game as ready
    emit(state.copyWith(ready: true));

    if (!wasReady) onGameStart?.call();

    settings?.startGame();
  }

  /* DURING GAME */

  Future<void> displayMessage(MessageUtility? message) async {
    emit(state.copyWith(message: () => message));

    if (message != null) {
      musicCubit.playVoiceBruitage(message.voice);
    }
  }

  /// Sets a narrative message to display in the end-of-game poster description.
  /// Pass null to clear it (fall back to the default mode description).
  void setEndMessage(String? message) {
    emit(state.copyWith(endMessage: () => message));
  }

  /// Sets a narrative message to display in the end-of-game poster description.
  /// Pass null to clear it (fall back to the default mode description).
  void setDescriptionMessage(String? message) {
    emit(state.copyWith(descriptionMessage: () => message));
  }

  void setStars(int stars) {
    emit(state.copyWith(stars: stars));
  }

  void giveUp() {
    onGiveUp?.call();

    settings?.onUserGiveUp();

    // endGame("R", "ABANDONMENT");
    // userCubit.unlockModestAchievement();
  }

  /* AFTER GAME */

  void enabledTripleAd() {
    emit(state.copyWith(tripleAdWatched: true));
  }

  /// The end-of-game "watch an ad" reward: one coin, or
  /// [GameSettings.playMinimumCoins] on the first claim after a genuine
  /// victory — the amount the button's own label advertises.
  ///
  /// Lives here so every result screen pays it the same way: the framework's
  /// own popup, a WiFi-local table, or a game drawing its own score table.
  Future<void> claimAdReward({AdmobCubit? admob, bool? tripleAd}) async {
    final cubit = admob ?? admobCubit;
    if (cubit == null) return;

    final bool triple =
        tripleAd ?? (state.victory == true && !state.tripleAdWatched);

    await cubit.ensureRewardedAdLoaded();

    cubit.showRewardedAd(() {
      userCubit.incrementCoins(
        triple ? Gamico.instance.gameSettings.playMinimumCoins : 1,
      );
      enabledTripleAd();
    });
  }

  void endGame(bool? victory, bool secondVictory, String overReason) {
    emit(
      state.copyWith(
        victory: () => victory,
        secondVictory: secondVictory,
        overReason: overReason,
      ),
    );

    onGameEnd?.call();
  }

  /// Clears a previous [endGame] result. Games that let players start a fresh
  /// match in place (e.g. Crazy Eights' online "Rejouer", which restarts the
  /// engine without recreating this cubit) must call this once play resumes,
  /// otherwise `state.over` stays stuck true and anything gated on it — the
  /// end-of-game confetti loop included — keeps behaving as if the match were
  /// still over.
  void resetGameOver() {
    emit(state.copyWith(victory: () => null, overReason: ""));
  }

  /// Handles game-over consequences: plays count, emotion, rewards, audio, delay,
  /// popups and interstitial ads.
  Future<void> handleGameOver(BuildContext context) async {
    if (!state.tutorial) {
      GameService.plays++;
    }

    GameService.gameSkipped = false;

    final victory = state.victory;
    final gameMode = state.gameMode;

    // Display message and character feeling
    if (victory == null) {
      characterCubit.setFeeling(FeelingType.normal);
    } else if (victory) {
      characterCubit.setFeeling(FeelingType.happy);

      if (state.overReason != "PASS" &&
          Gamico.instance.playSettings?.suppressCongratulationsMessage
                  ?.call() !=
              true) {
        displayMessage(CongratulationsMessageUtility());
      }
    } else {
      characterCubit.setFeeling(FeelingType.sad);
    }

    // Manage coins and stars
    if (GameService.tutorialPassed && victory != null) {
      gameMode.gamePageManageCoinsAndStars(context);
    }

    // Music management 1
    try {
      Future<void> Function()? playingBruitageFunction;

      if (state.active) {
        await musicCubit.pauseMusic();
      }

      if (state.active) {
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

      if (state.active) {
        playingBruitageFunction?.call();
      }
    } catch (e) {
      debugPrint(e.toString());
    }

    await Future.delayed(2.seconds);

    if (!context.mounted) return;

    // Let an end-game cinematic (e.g. a chapter unlock) play out
    // before the result popup slides in over it.
    await awaitBeforeGamePopup?.call();

    if (!context.mounted) return;

    NavigationService.closePopups();
    if (!context.mounted) return;

    if (Gamico.instance.playSettings?.suppressEndOfGamePopup?.call() != true) {
      gameMode.gamePageManageGamePopup(context);
    }

    if (context.mounted &&
        GameService.tutorialPassed &&
        gameMode.shouldShowAds(context) &&
        !ownsInterstitials &&
        Gamico.instance.playSettings?.suppressEndOfGameAd?.call() != true &&
        userCubit.state.user?.premium != true) {
      try {
        if (admobCubit?.state.rewardedAdStatus ==
            AdmobRewardedAdStatus.success) {
          admobCubit?.showInterstitialAd();
          GameService.plays = 0;
        }
      } catch (e) {
        debugPrint(e.toString());
      }
    }

    // Music management 2
    if (state.active) musicCubit.playMainPlayer();
  }

  /// Displays the game popup with the appropriate sub-cubit provider.
  void showGamePopup(BuildContext context) {
    setDisplayGamePopup(false);

    final pageAdventureCubit = state.mode == GameType.adventure
        ? context.read<GamicoAdventureGameCubit>()
        : null;
    final pageRemoteCubit = state.mode == GameType.remote
        ? context.read<GamicoRemoteGameCubit>()
        : null;
    final pagePassAndPlayCubit = state.mode == GameType.passAndPlay
        ? context.read<GamicoPassAndPlayGameCubit>()
        : null;
    final pageTutorialCubit = state.mode == GameType.tutorial
        ? context.read<GamicoTutorialGameCubit>()
        : null;
    final pageLocalNetworkCubit = state.mode == GameType.localNetwork
        ? context.read<GamicoLocalNetworkGameCubit>()
        : null;

    // A game may bring its own end-of-match popup — a score table across
    // rounds, say, which only it can draw. It is built here, from the page's
    // own context, because the popup itself is mounted under the navigator and
    // no longer sees the game's providers. When there is none, the generic
    // popup closes the match like everywhere else.
    final gamePopup = endGamePopupBuilder?.call(context);

    NavigationService.showPopup(
      context: context,
      builder: (_) {
        final finalPopup = BlocProvider.value(
          value: this,
          child: gamePopup ?? const GamicoGamePopup(),
        );

        return switch (state.mode) {
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
          GameType.localNetwork => BlocProvider.value(
            value: pageLocalNetworkCubit!,
            child: finalPopup,
          ),
        };
      },
    );
  }

  /// Determines whether pop is allowed or displays confirmation popup.
  Future<bool> handleWillPop(
    BuildContext context, {
    VoidCallback? onBackButtonPressed,
  }) async {
    if (!state.enabled) {
      return false;
    }

    onBeforeExit?.call();
    if (confirmExit != null && !await confirmExit!()) return false;

    // A remote table that was never dealt is not a match to abandon: the
    // player is looking at the pre-deal loader (where a matched opponent who
    // never showed up leaves them), so leaving is free — and warning them
    // about a penalty that no longer applies would only keep them there.
    final neverStartedRemote = state.mode == GameType.remote && !state.ready;

    if (state.over ||
        neverStartedRemote ||
        state.gameMode.shouldForceExit(context) ||
        (settings?.exitIsPenaltyFree?.call() ?? false)) {
      return managePop(context, onBackButtonPressed: onBackButtonPressed);
    }

    final l = GamicoLanguages.of(context);
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
            description: state.gameMode.gamePageClosingPopupDescription(
              context,
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
      return managePop(context, onBackButtonPressed: onBackButtonPressed);
    }

    return false;
  }

  /// Determine whether one can go back or not
  Future<bool> managePop(
    BuildContext context, {
    VoidCallback? onBackButtonPressed,
  }) async {
    onBeforeExit?.call();

    setActive(false);

    NavigationService.closePopups();

    onExitGame?.call();
    setAnimInit(false);

    state.gameMode.onExitingGame(context);

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
        onBackButtonPressed?.call();
      }
      musicCubit.playMainMusic();
    };

    await Future.delayed(AnimationService.animationDuration);

    return true;
  }

  /* CLOSE */

  @override
  Future<void> close() {
    onClosed?.call();
    onClosed = null;

    // Reset character feeling to the default
    characterCubit.setFeeling(FeelingType.normal);

    // Call inherited method
    return super.close();
  }
}
