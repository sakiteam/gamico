import 'package:firebase_database/firebase_database.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';
import 'package:gamico/commons/providers/gamico_users_provider.dart';

class GamicoUsersRepository {
  final GamicoUsersProvider usersProvider;

  final GamicoUserModel Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(GamicoUserModel) toJson;

  const GamicoUsersRepository({
    required this.usersProvider,
    required this.fromJson,
    required this.toJson,
  });

  Future<String> createUser(GamicoUserModel user) async {
    return await usersProvider.createUser(toJson(user));
  }

  Future<GamicoUserModel> readUser(String id) async {
    return fromJson(await usersProvider.readUser(id));
  }

  Future<void> updateUser(String id, GamicoUserModel user) async {
    await usersProvider.updateUser(id, toJson(user));
  }

  Future<void> deleteUser(String id) async {
    await usersProvider.deleteUser(id);
  }

  // Info

  Future<void> updateUserToken(String id, String token) async {
    await usersProvider.updateUser(id, {"token": token});
  }

  Future<void> updateUserPhoto(String id, String photo) async {
    await usersProvider.updateUser(id, {"photo": photo});
  }

  /// Updates the player-facing name. `formatted_name` is the normalized
  /// (lowercased, diacritic-free) mirror used both by the friend search and by
  /// the uniqueness check, so the two must always be written together.
  Future<void> updateUserName(
    String id,
    String name,
    String formattedName,
  ) async {
    await usersProvider.updateUser(id, {
      "name": name,
      "formatted_name": formattedName,
    });
  }

  /// Updates the Game Center / Play Games display name. Never touches [name]:
  /// the player owns that one once it has been seeded.
  Future<void> updateUserSocialName(String id, String socialName) async {
    await usersProvider.updateUser(id, {"social_name": socialName});
  }

  // Level

  Future<void> updateUserLevel(String id, int level) async {
    await usersProvider.updateUser(id, {"level": level});
  }

  Future<void> incrementUserLevel(String id) async {
    await usersProvider.updateUser(id, {"level": ServerValue.increment(1)});
  }

  /// Raises the account level to [level], never lowers it.
  ///
  /// A level is an absolute value computed from what the device believes the
  /// player has reached, so a stale local copy could publish a level BELOW the
  /// real one — the regression players reported. The transaction compares
  /// against the value on the server and aborts when it is already ahead, so
  /// no device can ever walk a level backwards.
  Future<bool> raiseUserLevel(String id, int level) async {
    return usersProvider.transactData("users/$id/level", (current) {
      final server = (current as num?)?.toInt() ?? 0;
      return level > server ? level : null;
    });
  }

  // Stars

  Future<void> updateUserStars(String id, List<int> stars) async {
    await usersProvider.updateUser(id, {"stars": stars});
  }

  // Trophies

  Future<void> incrementUserTrophies(String id) async {
    await usersProvider.updateUser(id, {
      "victories": ServerValue.increment(1),
      "trophies": ServerValue.increment(1),
    });
  }

  Future<void> decrementUserTrophies(String id, int crowns) async {
    await usersProvider.updateUser(id, {
      "defeats": ServerValue.increment(1),
      "trophies": ServerValue.increment(-crowns),
    });
  }

  // Coins

  Future<void> incrementUserCoins(String id, int coins) async {
    await usersProvider.updateUser(id, {"coins": ServerValue.increment(coins)});
  }

  Future<void> decrementUserCoins(String id, int coins) async {
    await usersProvider.updateUser(id, {
      "coins": ServerValue.increment(-coins),
    });
  }

  Future<void> updateUserGratification(String id, int last, int next) async {
    await usersProvider.updateUser(id, {
      "last_gratification": last,
      "next_gratification": next,
      "gratified_at": DateTime.now().toString(),
    });
  }

  Future<void> updateUserProgression(
    String id,
    Map<String, dynamic> progression,
  ) async {
    await usersProvider.updateUser(id, {"progression": progression});
  }

  /// Writes only the progression namespaces in [changed], each under its own
  /// `progression/{key}` path, and deletes the ones mapped to null.
  ///
  /// [updateUserProgression] sets the whole `progression` node, which means one
  /// game recording a single win uploads — and has echoed back to it — every
  /// other game's stats too. It is also why that path needs its "user not
  /// loaded" guard: a caller merging onto an empty map replaces the entire
  /// node, taking every other game down with it. Writing per namespace is both
  /// smaller and structurally unable to touch a game it was not given.
  Future<void> updateUserProgressionEntries(
    String id,
    Map<String, dynamic> changed,
  ) async {
    if (changed.isEmpty) return;
    await usersProvider.updateUser(id, {
      for (final entry in changed.entries)
        "progression/${entry.key}": entry.value,
    });
  }

  /// Writes a single field inside one progression namespace
  /// (`progression/{gameKey}/{field}`), leaving the rest of the namespace — and
  /// every other game — untouched.
  Future<void> updateUserProgressionField(
    String id,
    String gameKey,
    String field,
    Object? value,
  ) async {
    await usersProvider.updateUser(id, {"progression/$gameKey/$field": value});
  }

  /// Applies relative deltas to counters inside one progression namespace.
  ///
  /// [deltas] is keyed by path relative to `progression/{gameKey}` — e.g.
  /// `"victories"` or `"online/defeats"`. Each one is written as a
  /// `ServerValue.increment`, so the value on the server is the one being
  /// incremented and two devices (or a device holding a stale copy) can never
  /// overwrite each other's count.
  Future<void> incrementUserProgressionFields(
    String id,
    String gameKey,
    Map<String, num> deltas,
  ) async {
    final effective = {
      for (final entry in deltas.entries)
        if (entry.value != 0)
          "progression/$gameKey/${entry.key}": ServerValue.increment(
            entry.value,
          ),
    };

    if (effective.isEmpty) return;

    await usersProvider.updateUser(id, effective);
  }

  /// Raises one progression field to [value], never lowers it. The per-game
  /// counterpart of [raiseUserLevel].
  Future<bool> raiseUserProgressionField(
    String id,
    String gameKey,
    String field,
    int value,
  ) async {
    return usersProvider.transactData("users/$id/progression/$gameKey/$field", (
      current,
    ) {
      final server = (current as num?)?.toInt() ?? 0;
      return value > server ? value : null;
    });
  }

  /// Merges a star list element-wise, keeping the better score of each entry.
  ///
  /// Adventure stars have the same regression problem as the level: the list
  /// is written whole, so a device replaying an early chapter with a stale copy
  /// could publish fewer stars than the player actually earned.
  Future<bool> mergeUserProgressionStars(
    String id,
    String gameKey,
    List<int> stars,
  ) async {
    return usersProvider.transactData("users/$id/progression/$gameKey/stars", (
      current,
    ) {
      final server = current is List
          ? current.map((e) => e is num ? e.toInt() : 0).toList()
          : <int>[];

      final length = stars.length > server.length
          ? stars.length
          : server.length;
      final merged = <int>[];
      var changed = server.length != length;

      for (var i = 0; i < length; i++) {
        final mine = i < stars.length ? stars[i] : 0;
        final theirs = i < server.length ? server[i] : 0;
        final best = mine > theirs ? mine : theirs;
        if (best != theirs) changed = true;
        merged.add(best);
      }

      return changed ? merged : null;
    });
  }

  /// Writes only the `streak` node. Unlike [updateUserProgression] this is a
  /// narrow update: it cannot take another part of the account down with it,
  /// which matters for a write that fires on every app open.
  Future<void> updateUserStreak(String id, Map<String, dynamic> streak) async {
    await usersProvider.updateUser(id, {"streak": streak});
  }

  // Skins

  Future<void> updateUserSkins(String id, Map<String, dynamic> skins) async {
    await usersProvider.updateUser(id, {"skins": skins});
  }

  Future<void> updateUserPremium(String id, bool premium) async {
    await usersProvider.updateUser(id, {"premium": premium});
  }
}
