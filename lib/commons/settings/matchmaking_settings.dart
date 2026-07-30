import 'package:gamico/commons/models/gamico_user_model.dart';

class MatchmakingSettings<T extends GamicoUserModel> {
  final int minLevel;
  final int maxLevel;

  final int increment;

  final int Function(T? user) getMatchmakingLevel;

  final String? mode;

  /// Candidate pool modes for a "no preference" search: the player waits in
  /// every listed pool at once and plays in whichever fills first. When set
  /// (non-empty), it takes precedence over [mode], which the matchmaking
  /// resolves to the winning pool at launch time.
  final List<String>? modes;

  final int? maxPlayers;
  final bool isInfinite;

  const MatchmakingSettings({
    required this.minLevel,
    required this.maxLevel,
    required this.getMatchmakingLevel,
    required this.increment,
    this.mode,
    this.modes,
    this.maxPlayers,
    this.isInfinite = false,
  });

  /// Copy of these settings pinned to a single resolved [mode] — what the
  /// launched game consumes once a "no preference" search has picked its pool.
  MatchmakingSettings<T> withMode(String? mode) {
    return MatchmakingSettings<T>(
      minLevel: minLevel,
      maxLevel: maxLevel,
      getMatchmakingLevel: getMatchmakingLevel,
      increment: increment,
      mode: mode,
      maxPlayers: maxPlayers,
      isInfinite: isInfinite,
    );
  }
}
