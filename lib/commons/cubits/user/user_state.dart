part of 'user_cubit.dart';

/// Outcome of a player-initiated rename (see [GamicoUserCubit.updateUserName]).
enum GamicoNameUpdateResult {
  success,

  /// Empty, too short/long, or contains forbidden characters.
  invalid,

  /// Another account already uses this name.
  taken,

  /// No signed-in account to rename.
  unauthenticated,

  /// The write (or the uniqueness check) could not be completed.
  failure,
}

@immutable
class GamicoUserState {
  final GamicoUserModel? user;
  final int cowriesUpdate;
  final int cowriesUpdateDifference;

  /// A user has been delivered by the RTDB listener — from the disk cache or
  /// from the server, indistinguishably. Enough to paint the UI; NOT enough to
  /// base a write on. See [serverSynced].
  final bool loaded;

  /// The account has been round-tripped with the RTDB backend during this
  /// session, so [user] is the real one and not a possibly-behind disk cache.
  ///
  /// Disk persistence is enabled (`GamicoBootstrap.initialize`), so on a cold
  /// start RTDB answers the listener from disk before the socket is even up.
  /// That payload is indistinguishable from a server one — unlike Firestore,
  /// RTDB tags no snapshot as coming from cache — which is why this flag is
  /// tracked separately, off `.info/connected`.
  final bool serverSynced;

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
    this.serverSynced = false,
    this.challengeCompletedSignal = 0,
    this.challengeCompletedGameKey,
  });

  GamicoUserState copyWith({
    GamicoUserModel? Function()? user,
    int? cowriesUpdate,
    int? cowriesUpdateDifference,
    bool? loaded,
    bool? serverSynced,
    int? challengeCompletedSignal,
    String? challengeCompletedGameKey,
  }) {
    return GamicoUserState(
      user: user != null ? user() : this.user,
      cowriesUpdate: cowriesUpdate ?? this.cowriesUpdate,
      cowriesUpdateDifference:
          cowriesUpdateDifference ?? this.cowriesUpdateDifference,
      loaded: loaded ?? this.loaded,
      serverSynced: serverSynced ?? this.serverSynced,
      challengeCompletedSignal:
          challengeCompletedSignal ?? this.challengeCompletedSignal,
      challengeCompletedGameKey:
          challengeCompletedGameKey ?? this.challengeCompletedGameKey,
    );
  }
}

extension GamicoUserStateX on GamicoUserState {
  /// Casts the user to a specialized subtype (e.g. LudikoUser) or returns null.
  T? userAs<T extends GamicoUserModel>() {
    final u = user;
    return u is T ? u : null;
  }
}

extension GamicoUserContextX on BuildContext {
  /// Reads the current GamicoUser (or subclass) without subscribing to updates.
  T? user<T extends GamicoUserModel>() =>
      read<GamicoUserCubit>().state.userAs<T>();

  /// Watches the current GamicoUser (or subclass), triggering rebuilds on changes.
  T? watchUser<T extends GamicoUserModel>() =>
      watch<GamicoUserCubit>().state.userAs<T>();
}
