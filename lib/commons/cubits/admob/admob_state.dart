part of 'admob_cubit.dart';

enum AdmobRewardedAdStatus {
  initial,
  loading,
  success,
  failure,
}

enum AdmobInterstitialAdStatus {
  initial,
  loading,
  success,
  failure,
}

@immutable
class AdmobState {
  final AdmobRewardedAdStatus rewardedAdStatus;
  final AdmobInterstitialAdStatus interstitialAdStatus;

  const AdmobState({
    this.rewardedAdStatus = AdmobRewardedAdStatus.initial,
    this.interstitialAdStatus = AdmobInterstitialAdStatus.initial,
  });

  AdmobState copyWith({
    AdmobRewardedAdStatus? rewardedAdStatus,
    AdmobInterstitialAdStatus? interstitialAdStatus,
  }) {
    return AdmobState(
      rewardedAdStatus: rewardedAdStatus ?? this.rewardedAdStatus,
      interstitialAdStatus: interstitialAdStatus ?? this.interstitialAdStatus,
    );
  }
}
