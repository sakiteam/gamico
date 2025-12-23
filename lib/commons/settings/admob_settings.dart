import 'package:meta/meta.dart';

@immutable
class AdmobSettings {
  final String androidRewardedAdUnitId;
  final String iosRewardedAdUnitId;
  final String androidInterstitialAdUnitId;
  final String iosInterstitialAdUnitId;

  final bool displayAdButton;

  const AdmobSettings({
    this.displayAdButton = true,
    required this.androidInterstitialAdUnitId,
    required this.androidRewardedAdUnitId,
    required this.iosInterstitialAdUnitId,
    required this.iosRewardedAdUnitId,
  });
}
