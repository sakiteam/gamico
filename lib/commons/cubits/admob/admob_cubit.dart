import 'dart:io';
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/music.dart';
import 'package:gamico/commons/services/global.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

part 'admob_state.dart';

class AdmobCubit extends Cubit<AdmobState> {
  /// Retries use an exponential backoff: a load failure is usually a lack of
  /// connectivity or an empty fill, and hammering the SDK every 30s for the
  /// whole session builds a request (and its web views) each time for nothing.
  static const Duration _initialRetryDelay = Duration(seconds: 30);
  static const Duration _maxRetryDelay = Duration(minutes: 5);

  /// How long we wait for the user to load before deciding whether to request
  /// an interstitial. Bounded so a signed-out/guest session — where the user
  /// never loads — still gets its ads, just a few seconds later.
  static const Duration _premiumResolutionTimeout = Duration(seconds: 5);

  AdmobCubit({GamicoUserCubit? userCubit}) : this._(userCubit);

  AdmobCubit._(this._userCubit) : super(const AdmobState()) {
    // Rewarded ads are opt-in (the user taps a button to earn something), so
    // they are preloaded for everyone, premium included.
    loadRewardedAd();
    _watchPremium();
    loadInterstitialAd();
  }

  final GamicoUserCubit? _userCubit;
  StreamSubscription<GamicoUserState>? _userSubscription;
  bool _lastKnownPremium = false;

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

  Timer? _rewardedRetryTimer;
  Timer? _interstitialRetryTimer;
  Duration _rewardedRetryDelay = _initialRetryDelay;
  Duration _interstitialRetryDelay = _initialRetryDelay;

  bool get _isPremium => _userCubit?.state.user?.premium == true;

  static Duration _nextDelay(Duration current) {
    final next = current * 2;
    return next > _maxRetryDelay ? _maxRetryDelay : next;
  }

  /// Resolves whether the current user is premium, waiting (briefly) for the
  /// user to load when it hasn't yet — at cold start the cubit is built before
  /// the user comes back, so reading [_isPremium] straight away would say
  /// "not premium" for everyone.
  Future<bool> _resolvePremium() async {
    final userCubit = _userCubit;
    if (userCubit == null) return false;
    if (userCubit.state.loaded) return _isPremium;

    try {
      await userCubit.stream
          .firstWhere((state) => state.loaded)
          .timeout(_premiumResolutionTimeout);
    } catch (_) {
      // Timed out or the cubit closed: fall through on what we know.
    }

    return _isPremium;
  }

  /// Drops (or picks back up) the interstitial when the premium flag flips
  /// mid-session — a purchase, or a subscription that lapses.
  void _watchPremium() {
    final userCubit = _userCubit;
    if (userCubit == null) return;

    _lastKnownPremium = _isPremium;
    _userSubscription = userCubit.stream.listen((_) {
      final premium = _isPremium;
      if (premium == _lastKnownPremium) return;
      _lastKnownPremium = premium;

      if (premium) {
        _interstitialRetryTimer?.cancel();
        _interstitialAd?.dispose();
        _interstitialAd = null;
        if (!isClosed) {
          emit(
            state.copyWith(
              interstitialAdStatus: AdmobInterstitialAdStatus.failure,
            ),
          );
        }
      } else if (_interstitialAd == null) {
        loadInterstitialAd();
      }
    });
  }

  String get androidRewardedAdUnitId =>
      Gamico.instance.admobSettings?.androidRewardedAdUnitId ?? "";
  String get iosRewardedAdUnitId =>
      Gamico.instance.admobSettings?.iosRewardedAdUnitId ?? "";
  String get androidInterstitialAdUnitId =>
      Gamico.instance.admobSettings?.androidInterstitialAdUnitId ?? "";
  String get iosInterstitialAdUnitId =>
      Gamico.instance.admobSettings?.iosInterstitialAdUnitId ?? "";

  String get testRewardedAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/5224354917";
    }

    if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/1712485313";
    }

    return "";
  }

  String get testInterstitialAdUnitId {
    if (Platform.isAndroid) {
      return "ca-app-pub-3940256099942544/1033173712";
    }

    if (Platform.isIOS) {
      return "ca-app-pub-3940256099942544/4411468910";
    }

    return "";
  }

  String get adRewardedUnitId {
    if (Platform.isAndroid) {
      return androidRewardedAdUnitId;
    }

    if (Platform.isIOS) {
      return iosRewardedAdUnitId;
    }

    return "";
  }

  String get adInterstitialUnitId {
    if (Platform.isAndroid) {
      return androidInterstitialAdUnitId;
    }

    if (Platform.isIOS) {
      return iosInterstitialAdUnitId;
    }

    return "";
  }

  Future<void> loadRewardedAd() async {
    try {
      await Gamico.mobileAdsInitFuture;
    } catch (_) {}

    if (isClosed) return;
    emit(state.copyWith(rewardedAdStatus: AdmobRewardedAdStatus.loading));

    await RewardedAd.load(
      adUnitId: kDebugMode ? testRewardedAdUnitId : adRewardedUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          if (isClosed) {
            ad.dispose();
            return;
          }
          _rewardedAd?.dispose();
          _rewardedAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              MusicService.pausedByAd = false;
              Future.microtask(() {
                _rewardedAd = null;
                ad.dispose();
                loadRewardedAd();
              });
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              MusicService.pausedByAd = false;
              Future.microtask(() {
                _rewardedAd = null;
                ad.dispose();
                loadRewardedAd();
              });
            },
          );

          _rewardedRetryDelay = _initialRetryDelay;
          emit(state.copyWith(rewardedAdStatus: AdmobRewardedAdStatus.success));
        },
        onAdFailedToLoad: (error) {
          debugPrint("⚠️ Gamico Rewarded ad failed to load: $error");
          if (isClosed) return;

          emit(state.copyWith(rewardedAdStatus: AdmobRewardedAdStatus.failure));

          _rewardedRetryTimer?.cancel();
          _rewardedRetryTimer = Timer(_rewardedRetryDelay, () {
            if (!isClosed &&
                state.rewardedAdStatus == AdmobRewardedAdStatus.failure) {
              loadRewardedAd();
            }
          });
          _rewardedRetryDelay = _nextDelay(_rewardedRetryDelay);
        },
      ),
    );
  }

  Future<void> loadInterstitialAd() async {
    try {
      await Gamico.mobileAdsInitFuture;
    } catch (_) {}

    if (isClosed) return;

    // Premium users never see interstitials, so never build the request: at
    // cold start it lands in the same window as the audio player and the ad
    // web views spinning up, for an ad that would only be thrown away.
    if (await _resolvePremium()) {
      if (isClosed) return;
      // Reported as a failure so `showInterstitialAd` bails out immediately
      // instead of waiting on an ad that will never come.
      emit(
        state.copyWith(interstitialAdStatus: AdmobInterstitialAdStatus.failure),
      );
      return;
    }
    if (isClosed) return;

    emit(
      state.copyWith(interstitialAdStatus: AdmobInterstitialAdStatus.loading),
    );

    await InterstitialAd.load(
      adUnitId: kDebugMode ? testInterstitialAdUnitId : adInterstitialUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (isClosed) {
            ad.dispose();
            return;
          }
          _interstitialAd?.dispose();
          _interstitialAd = ad;

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              MusicService.pausedByAd = false;
              Future.microtask(() {
                _interstitialAd = null;
                ad.dispose();
                loadInterstitialAd();
              });
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              MusicService.pausedByAd = false;
              Future.microtask(() {
                _interstitialAd = null;
                ad.dispose();
                loadInterstitialAd();
              });
            },
          );

          _interstitialRetryDelay = _initialRetryDelay;
          emit(
            state.copyWith(
              interstitialAdStatus: AdmobInterstitialAdStatus.success,
            ),
          );
        },
        onAdFailedToLoad: (error) {
          debugPrint("⚠️ Gamico Interstitial ad failed to load: $error");
          if (isClosed) return;

          emit(
            state.copyWith(
              interstitialAdStatus: AdmobInterstitialAdStatus.failure,
            ),
          );

          _interstitialRetryTimer?.cancel();
          _interstitialRetryTimer = Timer(_interstitialRetryDelay, () {
            if (!isClosed &&
                state.interstitialAdStatus ==
                    AdmobInterstitialAdStatus.failure) {
              loadInterstitialAd();
            }
          });
          _interstitialRetryDelay = _nextDelay(_interstitialRetryDelay);
        },
      ),
    );
  }

  Future<void> ensureRewardedAdLoaded() async {
    await GamicoGlobalService.waitWhile(
      () => state.rewardedAdStatus != AdmobRewardedAdStatus.success,
    );
  }

  Future<void> ensureInterstitialAdLoaded() async {
    await GamicoGlobalService.waitWhile(
      () => state.interstitialAdStatus != AdmobInterstitialAdStatus.success,
    );
  }

  Future<void> showRewardedAd(Function onShown) async {
    if (_rewardedAd == null) {
      debugPrint('⚠️ Rewarded ad not ready, skipping show');
      return;
    }

    MusicService.pausedByAd = true;

    try {
      await _rewardedAd?.show(
        onUserEarnedReward: (_, _) {
          onShown();
        },
      );
    } catch (e) {
      MusicService.pausedByAd = false;
      debugPrint('Failed to show rewarded ad: $e');
      _rewardedAd?.dispose();
      _rewardedAd = null;
      loadRewardedAd();
    }
  }

  Future<void> showInterstitialAd() async {
    if (_interstitialAd == null) {
      // The ad may simply still be loading (right after a previous one was
      // shown, or on the very first game of a session) — give it a short
      // grace period instead of silently dropping the ad. Bounded so a load
      // failure can never hang the caller, and so `MusicService.pausedByAd`
      // (set below) never gets stuck true: `_interstitialAd?.show()` on a
      // null ad doesn't throw, so without this guard the catch block below
      // would never run to reset it.
      await GamicoGlobalService.waitWhile(
        () =>
            _interstitialAd == null &&
            state.interstitialAdStatus != AdmobInterstitialAdStatus.failure,
      ).timeout(const Duration(seconds: 5), onTimeout: () {});
    }

    if (_interstitialAd == null) {
      debugPrint('⚠️ Interstitial ad not ready, skipping show');
      return;
    }

    MusicService.pausedByAd = true;

    try {
      await _interstitialAd?.show();
    } catch (e) {
      MusicService.pausedByAd = false;
      debugPrint('Failed to show interstitial ad: $e');
      _interstitialAd?.dispose();
      _interstitialAd = null;
      loadInterstitialAd();
    }
  }

  @override
  Future<void> close() {
    _userSubscription?.cancel();
    _rewardedRetryTimer?.cancel();
    _interstitialRetryTimer?.cancel();
    _rewardedAd?.dispose();
    _interstitialAd?.dispose();
    return super.close();
  }
}
