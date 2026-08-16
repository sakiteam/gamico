import 'dart:io';
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/music.dart';
import 'package:gamico/commons/services/global.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

part 'admob_state.dart';

class AdmobCubit extends Cubit<AdmobState> {
  static const Duration _retryDelay = Duration(seconds: 30);

  AdmobCubit() : super(const AdmobState()) {
    loadRewardedAd();
    loadInterstitialAd();
  }

  RewardedAd? _rewardedAd;
  InterstitialAd? _interstitialAd;

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

          emit(state.copyWith(rewardedAdStatus: AdmobRewardedAdStatus.success));
        },
        onAdFailedToLoad: (error) {
          debugPrint("⚠️ Gamico Rewarded ad failed to load: $error");
          if (isClosed) return;

          emit(state.copyWith(rewardedAdStatus: AdmobRewardedAdStatus.failure));

          Timer(_retryDelay, () {
            if (!isClosed &&
                state.rewardedAdStatus == AdmobRewardedAdStatus.failure) {
              loadRewardedAd();
            }
          });
        },
      ),
    );
  }

  Future<void> loadInterstitialAd() async {
    try {
      await Gamico.mobileAdsInitFuture;
    } catch (_) {}

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

          Timer(_retryDelay, () {
            if (!isClosed &&
                state.interstitialAdStatus ==
                    AdmobInterstitialAdStatus.failure) {
              loadInterstitialAd();
            }
          });
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
    MusicService.pausedByAd = true;

    try {
      await _rewardedAd?.show(
        onUserEarnedReward: (_, _) {
          onShown();
        },
      );
    } catch (e) {
      debugPrint('Failed to show rewarded ad: $e');
      _rewardedAd = null;
      loadRewardedAd();
    }
  }

  Future<void> showInterstitialAd() async {
    MusicService.pausedByAd = true;

    try {
      await _interstitialAd?.show();
    } catch (e) {
      debugPrint('Failed to show interstitial ad: $e');
      _interstitialAd = null;
      loadInterstitialAd();
    }
  }
}
