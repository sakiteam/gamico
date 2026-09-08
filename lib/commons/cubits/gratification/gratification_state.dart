part of 'gratification_cubit.dart';

@immutable
class GratificationState {
  final bool loading;
  final Duration worldDateTimeDifference;
  final bool gratificationEnabled;
  final Duration durationDifference;
  final bool offerEnabled;
  final Duration offerRemainingDuration;

  const GratificationState({
    this.loading = false,
    this.worldDateTimeDifference = Duration.zero,
    this.gratificationEnabled = false,
    this.durationDifference = Duration.zero,
    this.offerEnabled = false,
    this.offerRemainingDuration = Duration.zero,
  });

  /// Whether the device clock is significantly out of sync with the world time (>= 5 minutes).
  bool get isClockDesynchronized => worldDateTimeDifference.inMinutes >= 5;

  /// Computes the reward coins based on user state and elapsed duration.
  int calculateRewardCoins(int? nextGratification) {
    int next = nextGratification ?? GratificationCubit.hour1Gratification;
    if (durationDifference.inHours > 1) {
      next = GratificationCubit.hour1Gratification;
    }
    return next;
  }

  GratificationState copyWith({
    bool? loading,
    Duration? worldDateTimeDifference,
    bool? gratificationEnabled,
    Duration? durationDifference,
    bool? offerEnabled,
    Duration? offerRemainingDuration,
  }) {
    return GratificationState(
      loading: loading ?? this.loading,
      worldDateTimeDifference:
          worldDateTimeDifference ?? this.worldDateTimeDifference,
      gratificationEnabled: gratificationEnabled ?? this.gratificationEnabled,
      durationDifference: durationDifference ?? this.durationDifference,
      offerEnabled: offerEnabled ?? this.offerEnabled,
      offerRemainingDuration:
          offerRemainingDuration ?? this.offerRemainingDuration,
    );
  }
}
