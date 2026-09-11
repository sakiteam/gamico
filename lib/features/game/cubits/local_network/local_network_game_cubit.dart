import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:gamico/commons/cubits/admob/admob_cubit.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:gamico/commons/services/progression.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';

part 'local_network_game_state.dart';

/// Owns the end of a WiFi-local match.
///
/// A LAN table has no backend to book anything for it, which is why every game
/// used to record its own result, count its own ads and pay its own rewarded
/// coins from inside its game page. All of that lives here now: the game keeps
/// the board and the transport, the framework keeps the bookkeeping — the same
/// division the other [GameType]s already have.
class GamicoLocalNetworkGameCubit extends Cubit<GamicoLocalNetworkGameState> {
  final GamicoGameCubit gameCubit;
  final GamicoUserCubit userCubit;
  final AdmobCubit? admobCubit;
  final LocalNetworkGameUtility utility;

  /// How many finished hands a table plays before its next interstitial. Only
  /// used by [countHandAndMaybeShowAd] — the end of the *match* goes through
  /// the framework's own cadence ([GameService.plays]).
  static const int handsPerAd = 3;

  GamicoLocalNetworkGameCubit({
    required this.gameCubit,
    required this.userCubit,
    required this.utility,
    this.admobCubit,
  }) : super(GamicoLocalNetworkGameState(isHost: utility.isHost));

  @override
  void emit(GamicoLocalNetworkGameState state) {
    if (isClosed) return;
    super.emit(state);
  }

  void init() {
    gameCubit.onInit = () async {
      gameCubit.settings?.initGame();
      gameCubit.startGame();
    };
  }

  /* TABLE */

  /// Host authority moved (a client promoted after the host left, typically).
  void setHost(bool isHost) {
    if (state.isHost == isHost) return;
    emit(state.copyWith(isHost: isHost));
  }

  /// (Clients) the host went away mid-match.
  void setHostGone(bool hostGone) {
    if (state.hostGone == hostGone) return;
    emit(state.copyWith(hostGone: hostGone));
  }

  /// Whether this device can deal a fresh match to the same table.
  bool get canStartNewGame => state.isHost && utility.onNewGame != null;

  /// Asks for a fresh match on the same table. Picked up by
  /// [LocalNetworkGamePage], which calls the host app back and clears every
  /// per-match flag so the next end of game is booked on its own merits.
  void requestNewGame() {
    if (!canStartNewGame) return;
    emit(state.copyWith(newGameActive: true));
  }

  /// Clears the per-match flags once a new match is under way.
  void resetForNewGame() {
    emit(
      state.copyWith(
        newGameActive: false,
        adShown: false,
        resultRecorded: false,
      ),
    );
    gameCubit.resetGameOver();
  }

  /* RESULT */

  /// Books a finished LAN match: the game's own progression namespace, and the
  /// shared wallet when the table [LocalNetworkGameUtility.rewardsCoins].
  ///
  /// Idempotent for one match — the same result reaching us twice (the host
  /// re-broadcasting its final state, say) is booked once.
  void recordResult({required bool victory}) {
    if (state.resultRecorded) return;
    emit(state.copyWith(resultRecorded: true));

    GamicoProgressionService.recordResult(
      userCubit,
      gameKey: utility.progressionKey,
      modeKey: utility.modeKey,
      victory: victory,
    );

    if (!utility.rewardsCoins) return;

    if (victory) {
      userCubit.incrementCoins(Gamico.instance.gameSettings.playMinimumCoins);
    } else {
      userCubit.decrementCoins(Gamico.instance.gameSettings.playMinimumCoins);
    }
  }

  /// Books one finished hand of a table that plays several of them under a
  /// single match — a card game's rounds. Unlike [recordResult] it is not
  /// idempotent: each hand is its own result.
  void recordHandResult({required bool victory}) {
    GamicoProgressionService.recordResult(
      userCubit,
      gameKey: utility.progressionKey,
      modeKey: utility.modeKey,
      victory: victory,
    );
  }

  /* ADS */

  bool get _isPremium => userCubit.state.user?.premium == true;

  /// One interstitial per match, whatever brings it to an end (this player
  /// busting out, or the winner being crowned). Returns whether an ad was
  /// actually scheduled.
  ///
  /// For the games that decide their own end of match; a table that lets the
  /// framework run the end of game gets its ad from
  /// [LocalNetworkModeSettings.shouldShowAds] instead.
  bool showEndOfGameAd({Duration delay = const Duration(seconds: 3)}) {
    if (_isPremium || state.adShown || admobCubit == null) return false;
    if (Gamico.instance.playSettings?.suppressEndOfGameAd?.call() == true) {
      return false;
    }

    emit(state.copyWith(adShown: true));

    Future.delayed(delay, () {
      admobCubit?.showInterstitialAd();
    });

    return true;
  }

  /// Counts one finished hand and shows an interstitial every [handsPerAd] of
  /// them, on the counter shared with the rest of the app.
  void countHandAndMaybeShowAd({Duration delay = const Duration(seconds: 3)}) {
    if (_isPremium || admobCubit == null) return;
    if (Gamico.instance.playSettings?.suppressEndOfGameAd?.call() == true) {
      return;
    }

    LocalStorageService.games++;
    if (LocalStorageService.games < handsPerAd) return;

    LocalStorageService.games = 0;
    Future.delayed(delay, () {
      admobCubit?.showInterstitialAd();
    });
  }

  /// The end-of-game popup's "watch an ad" reward, identical to the generic
  /// one: one coin, or [GameSettings.playMinimumCoins] on the first claim
  /// after a genuine victory — the amount its own label advertises.
  Future<void> claimAdReward({bool tripleAd = false}) =>
      gameCubit.claimAdReward(admob: admobCubit, tripleAd: tripleAd);
}
