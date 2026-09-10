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
  /// (`pools/<poolKey>_<seats>`).
  ///
  /// Game modes are deliberately NOT part of it: they travel inside each queue
  /// entry, and the server groups compatible players. That is what lets a
  /// player who picked one mode and a player with no preference sit at the
  /// same table.
  ///
  /// Defaults to [mode], which is right for every single-mode game (there the
  /// mode string is a namespace, not a choice). Games whose [mode]/[modes]
  /// encode a real player choice must set it explicitly.
  final String? poolKey;

  /// Seats this search plays with. `0` marks an infinite pool, whose
  /// [maxPlayers] is a cap rather than a target.
  int get seats => (maxPlayers ?? 2);

  /// Seat count as it appears in a lobby pool key: `00` for an infinite pool.
  String get poolSeats => (isInfinite || seats == 0) ? "00" : "$seats";

  /// Full `pools/` key — a plain namespace, opaque to the server.
  ///
  /// Two players meet if and only if they build the same string, so it has to
  /// carry everything that must match. Two shapes, by what identifies the
  /// table:
  ///
  ///  * a lobby pool is identified by its size — `crazy_eights_00`,
  ///    `ludo_quick_hex_2v2_4`;
  ///  * an **adventure** pool by the level being played, since both players
  ///    work the same puzzle and a table gathers per level — `classic_007`.
  ///
  /// Lower-cased so the key is canonical whatever case the game writes its
  /// mode in (`CLASSIC` → `classic`); every existing caller is already
  /// lower-case, so nothing moves for them.
  String poolKeyFor(int? level) {
    final base = (poolKey ?? mode ?? "default")
        .toLowerCase()
        .replaceAll(RegExp(r'[.#$/\[\]\s]'), '_');
    if (level != null) return "${base}_${level.toString().padLeft(3, '0')}";
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
