import 'dart:math' as math;

import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';
import 'package:gamico/commons/services/pending_progression.dart';
import 'package:gamico/commons/services/local_storage.dart';

/// Namespaced progression stats (`user.progression[<gameKey>]`).
///
/// An app hosting several games keeps each one's victories/defeats/trophies in
/// its own namespace, with a sub-map per playing mode ("online", "local",
/// "adventure", …) so a WiFi-local table can never inflate the online ladder.
/// Every game used to carry its own copy of these reads and writes; they live
/// here so a new mode — the WiFi-local one especially — is recorded the same
/// way whichever game is playing it.
class GamicoProgressionService {
  const GamicoProgressionService._();

  /// The whole namespace of [gameKey], or an empty map when the player has
  /// never played it.
  static Map<String, dynamic> of(GamicoUserModel? user, String gameKey) {
    final namespace = user?.progression?[gameKey];
    return namespace is Map
        ? Map<String, dynamic>.from(namespace)
        : <String, dynamic>{};
  }

  /// The `victories`/`defeats` sub-map of one playing [modeKey], or null when
  /// that mode has never been played.
  static Map<String, dynamic>? modeStatsOf(
    GamicoUserModel? user,
    String gameKey,
    String modeKey,
  ) {
    final raw = of(user, gameKey)[modeKey];
    return raw is Map ? Map<String, dynamic>.from(raw) : null;
  }

  static int modeVictories(
    GamicoUserModel? user,
    String gameKey,
    String modeKey,
  ) => (modeStatsOf(user, gameKey, modeKey)?["victories"] as int?) ?? 0;

  static int modeDefeats(
    GamicoUserModel? user,
    String gameKey,
    String modeKey,
  ) => (modeStatsOf(user, gameKey, modeKey)?["defeats"] as int?) ?? 0;

  /// Books one finished match: the namespace totals plus the [modeKey]
  /// sub-map. [trophiesDelta] only applies to the ladder-bearing modes — a
  /// WiFi-local or pass-and-play result leaves it at 0 so a private table
  /// cannot farm trophies.
  ///
  /// Every counter is written as a RELATIVE change (`ServerValue.increment`,
  /// or a transaction for trophies since they must not fall below zero), never
  /// as the absolute value this device computed. A win is "+1 on whatever the
  /// server holds", so two devices — or one device still holding last
  /// session's copy — can no longer overwrite each other's totals. The local
  /// mirror below keeps the UI instant; the server value echoes back through
  /// the `progression` listener a moment later.
  ///
  /// The "online" mode is seeded from the totals the first time it is written,
  /// so players who were counted before the per-mode split keep their history.
  static void recordResult(
    GamicoUserCubit userCubit, {
    required String gameKey,
    required String modeKey,
    required bool victory,
    int trophiesDelta = 0,
  }) {
    final user = userCubit.state.user;
    if (user == null) return;
    if (!userCubit.canPersistUser) return;

    final ns = of(user, gameKey);

    final topV = ((ns["victories"] as int?) ?? 0) + (victory ? 1 : 0);
    final topD = ((ns["defeats"] as int?) ?? 0) + (victory ? 0 : 1);
    final currentTrophies = (ns["trophies"] as int?) ?? 0;
    final topTrophies = math.max(0, currentTrophies + trophiesDelta);

    final modeMap = Map<String, dynamic>.from(
      (ns[modeKey] as Map?) ?? const <String, dynamic>{},
    );

    // Relative deltas, keyed by path under `progression/<gameKey>`.
    //
    // Trophies ride along with the rest rather than going through a
    // transaction of their own: they are match bookkeeping, not the adventure
    // progress the transactions exist to protect, and an increment is both
    // cheaper and — unlike a transaction — kept by the SDK's normal write
    // queue. Their only extra rule is the floor, enforced here by simply not
    // sending a decrement that would cross it (the account is loaded from the
    // server at this point, so `ns` is the real value), and again at read time
    // in each game's `trophies` getter in case two devices race to zero.
    final effectiveTrophiesDelta = trophiesDelta < 0 && currentTrophies <= 0
        ? 0
        : trophiesDelta;

    final deltas = <String, num>{
      "victories": victory ? 1 : 0,
      "defeats": victory ? 0 : 1,
      "$modeKey/victories": victory ? 1 : 0,
      "$modeKey/defeats": victory ? 0 : 1,
      "trophies": effectiveTrophiesDelta,
    };

    if (modeKey == "online" && !modeMap.containsKey("victories")) {
      // First online result since the per-mode split: the sub-map inherits the
      // namespace totals. That one is an absolute seed by nature — it copies a
      // value rather than changing it — and it only ever runs once, on an
      // account already loaded from the server.
      modeMap["victories"] = topV;
      modeMap["defeats"] = topD;
      deltas.remove("$modeKey/victories");
      deltas.remove("$modeKey/defeats");
      userCubit.updateUserProgressionEntry(gameKey, modeKey, modeMap);
    } else {
      final prevV = (modeMap["victories"] as int?) ?? 0;
      final prevD = (modeMap["defeats"] as int?) ?? 0;
      modeMap["victories"] = prevV + (victory ? 1 : 0);
      modeMap["defeats"] = prevD + (victory ? 0 : 1);
    }

    userCubit.incrementProgression(gameKey, deltas);

    // Local mirror so the end-of-game screen shows the new totals at once.
    ns["victories"] = topV;
    ns["defeats"] = topD;
    ns["trophies"] = topTrophies;
    ns[modeKey] = modeMap;
    userCubit.mirrorProgression(gameKey, ns);
  }

  /// Raises the per-game level, never lowers it. The adventure pages call this
  /// once a chapter is cleared; going through a transaction means a device
  /// running on a stale copy cannot publish a level below the one reached.
  ///
  /// The gain is queued in [GamicoPendingProgressionService] first and only
  /// dequeued once the server settles it, so a chapter cleared offline survives
  /// the app being killed before it ever reconnects.
  static void raiseLevel(GamicoUserCubit userCubit, String gameKey, int level) {
    final user = userCubit.state.user;
    if (user == null) return;

    // Mirror first so the map unlocks immediately.
    final ns = of(user, gameKey);
    if (level > ((ns["level"] as int?) ?? 0)) {
      ns["level"] = level;
      userCubit.mirrorProgression(gameKey, ns);
    }

    final uid = LocalStorageService.uid;
    GamicoPendingProgressionService.recordLevel(uid, gameKey, level);

    userCubit.raiseProgressionField(gameKey, "level", level).then((settled) {
      if (settled) {
        GamicoPendingProgressionService.confirmLevel(uid, gameKey, level);
      }
    });
  }

  /// Merges the adventure star list element-wise, keeping the better score of
  /// each chapter rather than replacing the list wholesale. Queued and
  /// dequeued like [raiseLevel].
  static void mergeStars(
    GamicoUserCubit userCubit,
    String gameKey,
    List<int> stars,
  ) {
    final user = userCubit.state.user;
    if (user == null) return;

    final ns = of(user, gameKey);
    final previous = (ns["stars"] as List?) ?? const [];
    final merged = GamicoPendingProgressionService.mergeStarLists(
      stars,
      previous.map((e) => e is num ? e.toInt() : 0).toList(),
    );

    ns["stars"] = merged;
    userCubit.mirrorProgression(gameKey, ns);

    final uid = LocalStorageService.uid;
    GamicoPendingProgressionService.recordStars(uid, gameKey, merged);

    userCubit.mergeProgressionStars(gameKey, merged).then((settled) {
      if (settled) {
        GamicoPendingProgressionService.confirmStars(uid, gameKey, merged);
      }
    });
  }

  /// Re-sends every monotonic gain that never reached the server — a chapter
  /// cleared offline, then lost when the app restarted before reconnecting.
  ///
  /// Safe to call on every launch: each entry goes through the same
  /// max-transaction as a fresh gain, so one the server already holds aborts
  /// and one it lost is restored. Call it only once the account is loaded —
  /// the writes are refused otherwise.
  static void replayPending(GamicoUserCubit userCubit) {
    if (!userCubit.canPersistUser) return;

    final uid = LocalStorageService.uid;
    final pending = GamicoPendingProgressionService.pending(uid);

    for (final entry in pending.entries) {
      final level = entry.value.level;
      final stars = entry.value.stars;

      if (level != null) raiseLevel(userCubit, entry.key, level);
      if (stars != null && stars.isNotEmpty) {
        mergeStars(userCubit, entry.key, stars);
      }
    }
  }

  /// Writes a single [field] of [gameKey]'s namespace, merging onto whatever
  /// the user already has.
  ///
  /// Goes straight at `progression/{gameKey}/{field}` rather than rebuilding
  /// and re-uploading the whole map, so it can neither carry another game's
  /// stale stats along nor be refused for a namespace it never touched.
  static void write(
    GamicoUserCubit userCubit,
    String gameKey,
    String field,
    Object value,
  ) {
    final user = userCubit.state.user;
    if (user == null) return;

    final ns = of(user, gameKey);
    ns[field] = value;
    userCubit.mirrorProgression(gameKey, ns);

    userCubit.updateUserProgressionEntry(gameKey, field, value);
  }
}
