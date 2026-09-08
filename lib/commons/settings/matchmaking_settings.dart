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

  /// Namespace of the server-driven pool this search queues in
  /// (`pools/<poolKey>_<seats>`), for [MatchmakingMigration].
  ///
  /// Game modes are deliberately NOT part of it: they travel inside each queue
  /// entry, and the server groups compatible players. That is what lets a
  /// player who picked one mode and a player with no preference sit at the
  /// same table — under the legacy scheme the latter had to queue in every
  /// mode's room at once to achieve the same thing.
  ///
  /// Defaults to [mode], which is right for every single-mode game (there the
  /// mode string is a namespace, not a choice). Games whose [mode]/[modes]
  /// encode a real player choice must set it explicitly.
  final String? poolKey;

  /// Seat count as it appears in a pool key: `00` for an infinite pool.
  String get poolSeats =>
      (isInfinite || (maxPlayers ?? 2) == 0) ? "00" : "${maxPlayers ?? 2}";

  /// Full `pools/` key: namespace plus seat count.
  String get resolvedPoolKey {
    final base = (poolKey ?? mode ?? "default")
        .replaceAll(RegExp(r'[.#$/\[\]\s]'), '_');
    return "${base}_$poolSeats";
  }

  /// Mode identifiers this player accepts, as sent in the queue entry.
  List<String> get queueModes {
    final list = modes;
    if (list != null && list.isNotEmpty) return List<String>.from(list);
    return [mode ?? "default"];
  }

  const MatchmakingSettings({
    required this.minLevel,
    required this.maxLevel,
    required this.getMatchmakingLevel,
    required this.increment,
    this.mode,
    this.modes,
    this.maxPlayers,
    this.isInfinite = false,
    this.poolKey,
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
      poolKey: poolKey,
    );
  }
}
