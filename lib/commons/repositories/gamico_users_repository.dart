import 'package:firebase_database/firebase_database.dart';
import 'package:gamico/commons/providers/gamico_users_provider.dart';

class GamicoUsersRepository {
  final GamicoUsersProvider usersProvider;

  final dynamic Function(Map<String, dynamic>) fromJson;
  final Map<String, dynamic> Function(dynamic) toJson;

  const GamicoUsersRepository({
    required this.usersProvider,
    required this.fromJson,
    required this.toJson,
  });

  Future<String> createUser(dynamic user) async {
    return await usersProvider.createUser(toJson(user));
  }

  Future<dynamic> readUser(String id) async {
    return fromJson(await usersProvider.readUser(id));
  }

  Future<void> updateUser(String id, dynamic user) async {
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

  // Skins

  Future<void> updateUserSkins(String id, Map<String, dynamic> skins) async {
    await usersProvider.updateUser(id, {"skins": skins});
  }

  Future<void> updateUserPremium(String id, bool premium) async {
    await usersProvider.updateUser(id, {"premium": premium});
  }
}
