import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:gamico/commons/services/local_storage.dart';

/// The durable queue of monotonic progression gains that have not been
/// confirmed by the server yet.
///
/// Adventure levels and stars are earned offline all the time, and an RTDB
/// transaction is NOT persisted across an app restart — even with disk
/// persistence enabled. So a chapter cleared in airplane mode, followed by the
/// app being killed before it ever reconnects, would vanish: the value lived
/// only in `state.user`, which is replaced wholesale by the server node on the
/// next launch.
///
/// This is where it waits in the meantime. Only monotonic values go in — a
/// level and a star list, both of which can only ever go up — which is what
/// makes replaying the queue safe: re-sending a gain the server already has is
/// a no-op (the transaction aborts), and re-sending one it lost repairs it.
/// Nothing here is ever used as the BASE of a read-modify-write, so it cannot
/// become the stale-copy problem it exists to survive.
///
/// Entries are scoped to the account that earned them: switching accounts must
/// not hand one player's chapters to another.
class GamicoPendingProgressionService {
  const GamicoPendingProgressionService._();

  static const String _key = "pending_progression";

  static Map<String, dynamic> _read(String uid) {
    final raw = LocalStorageService.getMap(_key);
    if (raw == null) return <String, dynamic>{};

    final map = Map<String, dynamic>.from(raw);

    // Belongs to another account (or a pre-scoping build): drop it whole.
    if (map["uid"] != uid) return <String, dynamic>{};

    final games = map["games"];
    return games is Map
        ? Map<String, dynamic>.from(games)
        : <String, dynamic>{};
  }

  static Future<void> _write(String uid, Map<String, dynamic> games) async {
    if (games.isEmpty) {
      await LocalStorageService.setMap(_key, null);
      return;
    }

    await LocalStorageService.setMap(_key, {"uid": uid, "games": games});
  }

  static Map<String, dynamic> _namespace(
    Map<String, dynamic> games,
    String gameKey,
  ) {
    final raw = games[gameKey];
    return raw is Map ? Map<String, dynamic>.from(raw) : <String, dynamic>{};
  }

  static List<int> _stars(Object? raw) => raw is List
      ? raw.map((e) => e is num ? e.toInt() : 0).toList()
      : const <int>[];

  /// Element-wise max of two star lists, the same merge the server transaction
  /// performs.
  static List<int> mergeStarLists(List<int> a, List<int> b) => <int>[
    for (var i = 0; i < math.max(a.length, b.length); i++)
      math.max(i < a.length ? a[i] : 0, i < b.length ? b[i] : 0),
  ];

  /// Queues a level gain. Kept only while it is higher than what is already
  /// queued.
  static void recordLevel(String uid, String gameKey, int level) {
    if (uid.isEmpty) return;

    final games = _read(uid);
    final ns = _namespace(games, gameKey);

    if (level <= ((ns["level"] as num?)?.toInt() ?? 0)) return;

    ns["level"] = level;
    games[gameKey] = ns;
    _write(uid, games);
  }

  /// Queues a star list, merged onto whatever is already queued.
  static void recordStars(String uid, String gameKey, List<int> stars) {
    if (uid.isEmpty) return;

    final games = _read(uid);
    final ns = _namespace(games, gameKey);
    final merged = mergeStarLists(stars, _stars(ns["stars"]));

    ns["stars"] = merged;
    games[gameKey] = ns;
    _write(uid, games);
  }

  /// Drops a level once the server has acknowledged it (or has proved to hold
  /// a higher one). [level] is the value that was confirmed.
  static void confirmLevel(String uid, String gameKey, int level) {
    if (uid.isEmpty) return;

    final games = _read(uid);
    final ns = _namespace(games, gameKey);

    // A higher gain queued in the meantime must survive this confirmation.
    if (((ns["level"] as num?)?.toInt() ?? 0) > level) return;

    ns.remove("level");
    if (ns.isEmpty) {
      games.remove(gameKey);
    } else {
      games[gameKey] = ns;
    }
    _write(uid, games);
  }

  /// Drops the queued stars once the server has acknowledged [stars].
  static void confirmStars(String uid, String gameKey, List<int> stars) {
    if (uid.isEmpty) return;

    final games = _read(uid);
    final ns = _namespace(games, gameKey);
    final queued = _stars(ns["stars"]);

    // Anything queued beyond what was confirmed stays queued.
    final remaining = mergeStarLists(queued, stars);
    if (!listEquals(remaining, stars)) return;

    ns.remove("stars");
    if (ns.isEmpty) {
      games.remove(gameKey);
    } else {
      games[gameKey] = ns;
    }
    _write(uid, games);
  }

  /// Everything still waiting, as `{gameKey: {level, stars}}`.
  static Map<String, ({int? level, List<int>? stars})> pending(String uid) {
    if (uid.isEmpty) return const {};

    final games = _read(uid);

    return {
      for (final entry in games.entries)
        if (entry.value is Map)
          entry.key: (
            level: ((entry.value as Map)["level"] as num?)?.toInt(),
            stars: (entry.value as Map)["stars"] == null
                ? null
                : _stars((entry.value as Map)["stars"]),
          ),
    };
  }
}
