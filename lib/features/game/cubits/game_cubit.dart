import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:gamico/commons/enums/game_type.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/cubits/music/music_cubit.dart';
import 'package:gamico/commons/modes/game_mode_settings.dart';
import 'package:gamico/commons/cubits/character/character_cubit.dart';
import 'package:gamico/commons/utilities/message/abstract/message_utility.dart';
import 'package:gamico/features/game/utilities/gamico_game_cubit_settings.dart';

part 'game_state.dart';

class GamicoGameCubit extends Cubit<GamicoGameState> {
  /* CONSTRUCTOR */

  GamicoGameCubit({
    required GameType gameType,
    required this.userCubit,
    required this.musicCubit,
    required this.characterCubit,
  }) : super(GamicoGameState(mode: gameType));

  /* PROPERTIES */

  // Usual cubits
  final GamicoUserCubit userCubit;
  final GamicoMusicCubit musicCubit;
  final CharacterCubit characterCubit;

  // Game settings
  GamicoGameCubitSettings? settings;

  // Controllers
  Future<void> Function()? onInit;
  void Function()? onGiveUp;
  void Function()? onExitGame;
  void Function()? onGameEnd;

  /// Optional gate awaited right before the end-of-game popup is shown (after
  /// the standard result delay). A game can use it to let an end-game
  /// cinematic play out first — the popup only appears once this completes.
  /// Null (the default) keeps the standard timing for every other game.
  Future<void> Function()? awaitBeforeGamePopup;

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
    final alreadyInitialized = this.settings != null;
    this.settings = settings;
    if (alreadyInitialized) return;

    setAnimInit(true);

    musicCubit.playGameMusic();

    await onInit?.call();
  }

  void startGame() {
    // Declare game as ready
    emit(state.copyWith(ready: true));

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

  /* CLOSE */

  @override
  Future<void> close() {
    // Reset character feeling to the default
    characterCubit.setFeeling(FeelingType.normal);

    // Call inherited method
    return super.close();
  }
}
