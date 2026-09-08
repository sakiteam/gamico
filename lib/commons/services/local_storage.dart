import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Typed access to SharedPreferences, plus the account pointer.
///
/// [uid] is not an ordinary key: writing it carries an invariant (see its
/// setter). It lives here rather than in a service of its own, so this is the
/// single place that knows how the account pointer is stored — do not add a
/// second way to write the `uid` key.
class LocalStorageService {
  // Preferences
  static late SharedPreferences preferences;

  // Init preferences
  static Future<void> initialize() async {
    preferences = await SharedPreferences.getInstance();
  }

  // Preference getting
  static bool? getBool(String key) => preferences.getBool(key);
  static double? getDouble(String key) => preferences.getDouble(key);
  static int? getInt(String key) => preferences.getInt(key);
  static String? getString(String key) => preferences.getString(key);
  static List<String>? getStringList(String key) =>
      preferences.getStringList(key);
  static Map? getMap(String key) {
    String? encodedString = preferences.getString(key);

    if (encodedString == null) {
      return null;
    }

    return jsonDecode(encodedString) as Map?;
  }

  // Preference setting
  static Future<bool> setBool(String key, bool value) =>
      preferences.setBool(key, value);
  static Future<bool> setDouble(String key, double value) =>
      preferences.setDouble(key, value);
  static Future<bool> setInt(String key, int value) =>
      preferences.setInt(key, value);
  static Future<bool> setString(String key, String value) =>
      preferences.setString(key, value);
  static Future<bool> setStringList(String key, List<String> value) =>
      preferences.setStringList(key, value);
  static Future<bool> setMap(String key, Map? value) {
    return preferences.setString(key, jsonEncode(value));
  }

  // Uid
  //
  // `uid` is the RTDB push key of the account node — the ONLY pointer this
  // device has to the player's progression. Erasing it does not sign the player
  // out of anything server-side; it makes their account unreachable, and the
  // next sign-in that fails to find it by `social_id` will happily create a
  // fresh one and orphan the real node. That is an unrecoverable loss, so the
  // last non-empty value is mirrored to a second key that no error path
  // touches. [lastUid] is the recovery pointer, nothing else reads it.
  //
  // Never write the "uid" key directly: that mirror is the whole safety net.
  static set uid(String value) {
    setString("uid", value);
    if (value.isNotEmpty) setString("last_uid", value);
  }

  static String get uid => getString("uid") ?? "";

  /// The last account this device was attached to, kept across sign-outs and
  /// failed sign-ins. See the note on [uid].
  static String get lastUid => getString("last_uid") ?? "";

  /// Derived, never stored: the app is "signed in" exactly when it holds a
  /// pointer to an account.
  static bool get authenticated => uid.isNotEmpty;

  // Games counter
  static int get games => preferences.getInt("games") ?? 0;
  static set games(int value) => preferences.setInt("games", value);

  // Chat auto close
  static bool get chatAutoCloseOnSend =>
      preferences.getBool("chat_auto_close_on_send") ?? true;
  static set chatAutoCloseOnSend(bool value) =>
      preferences.setBool("chat_auto_close_on_send", value);

  // Init alias for initialize
  static Future<void> init() => initialize();
}
