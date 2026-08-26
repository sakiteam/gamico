part of 'user_cubit.dart';

@immutable
class GamicoUserState {
  // dynamic?
  final dynamic user;
  final int cowriesUpdate;
  final int cowriesUpdateDifference;
  final bool loaded;

  /// Bumped by [GamicoUserCubit.notifyChallengeCompleted] whenever a game
  /// finishes a daily challenge — distinct from [cowriesUpdate] so listeners
  /// can react specifically to a challenge completion rather than any coin
  /// gain (an ad reward or a match payout in the same session must not
  /// trigger a "challenge completed" banner).
  final int challengeCompletedSignal;
  final String? challengeCompletedGameKey;

  const GamicoUserState({
    this.user,
    this.cowriesUpdate = 0,
    this.cowriesUpdateDifference = 0,
    this.loaded = false,
    this.challengeCompletedSignal = 0,
    this.challengeCompletedGameKey,
  });

  // UserState copyWith({
  //   required T? user,
  // }) {
  //   return UserState(
  //     user: user,
  //   );
  // }

  GamicoUserState copyWith({
    // dynamic?
    dynamic Function()? user,
    int? cowriesUpdate,
    int? cowriesUpdateDifference,
    bool? loaded,
    int? challengeCompletedSignal,
    String? challengeCompletedGameKey,
    // bool? loadingAchievements,
    // bool? loadingCollectorsLeaderboards,
  }) {
    return GamicoUserState(
      user: user != null ? user() : this.user,
      cowriesUpdate: cowriesUpdate ?? this.cowriesUpdate,
      cowriesUpdateDifference:
          cowriesUpdateDifference ?? this.cowriesUpdateDifference,
      loaded: loaded ?? this.loaded,
      challengeCompletedSignal:
          challengeCompletedSignal ?? this.challengeCompletedSignal,
      challengeCompletedGameKey:
          challengeCompletedGameKey ?? this.challengeCompletedGameKey,
    );
  }
}
