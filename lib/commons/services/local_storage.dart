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
  static Future<bool> setMap(String key, Map? value) =>
      preferences.setString(key, jsonEncode(value));

  // Authenticated
  static bool get authenticated => uid.isNotEmpty;

  // Uid
  static String get uid => getString("uid") ?? "";
  static set uid(String value) => setString("uid", value);

  // Games
  static int get games => preferences.getInt("games") ?? 0;
  static set games(int value) => preferences.setInt("games", value);

  // Chat auto close on send
  static bool get chatAutoCloseOnSend =>
      preferences.getBool("chat_auto_close_on_send") ?? true;
  static set chatAutoCloseOnSend(bool value) =>
      preferences.setBool("chat_auto_close_on_send", value);
}
