import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/local_storage.dart';

class UserService {
  // final dynamic Function(Map<String, dynamic>) fromJson;
  // final Map<String, dynamic> Function(dynamic) toJson;

  // UserService({
  //   required this.fromJson,
  //   required this.toJson,
  // });

  // dynamic?
  static dynamic getUser() {
    final userMap = LocalStorageService.getMap("user");

    if (userMap == null) return null;

    // [GAMICO-FIX] name/level-loss investigation.
    // A previous build could persist a partial RTDB latency-compensation
    // snapshot (e.g. {token, updated_at}) as the "user". Such a poisoned copy
    // has no identity, and returning it would (a) seed state.user with garbage
    // and (b) satisfy `waitWhile(state.user == null)` in the auth flow — letting
    // premature writes fire again. Reject it (and purge it) so the app behaves
    // as if no user were cached and waits for the real server node.
    final looksEmpty = userMap["social_id"] == null &&
        userMap["firebase_id"] == null &&
        userMap["name"] == null;
    if (looksEmpty) {
      LocalStorageService.setMap("user", null);
      return null;
    }

    return Gamico.instance.userFromJson(Map<String, dynamic>.from(userMap));
  }

  // dynamic?
  static Future<void> setUser(dynamic user) async {
    await LocalStorageService.setMap(
      "user",
      user == null ? null : Gamico.instance.userToJson(user),
    );
  }

  // Uid
  static set uid(String value) => LocalStorageService.setString("uid", value);
  static String get uid => LocalStorageService.getString("uid") ?? "";

  // Authenticated
  static bool get authenticated => uid.isNotEmpty;

  // Display name
  static String get displayName => getUser()?.name ?? "";
}
