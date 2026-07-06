part of 'user_cubit.dart';

@immutable
class GamicoUserState {
  // dynamic?
  final dynamic user;
  final int cowriesUpdate;
  final int cowriesUpdateDifference;
  final bool loaded;

  const GamicoUserState({
    this.user,
    this.cowriesUpdate = 0,
    this.cowriesUpdateDifference = 0,
    this.loaded = false,
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
    // bool? loadingAchievements,
    // bool? loadingCollectorsLeaderboards,
  }) {
    return GamicoUserState(
      user: user != null ? user() : this.user,
      cowriesUpdate: cowriesUpdate ?? this.cowriesUpdate,
      cowriesUpdateDifference:
          cowriesUpdateDifference ?? this.cowriesUpdateDifference,
      loaded: loaded ?? this.loaded,
    );
  }
}
