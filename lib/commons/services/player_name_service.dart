import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:remove_diacritic/remove_diacritic.dart';
import 'package:gamico/commons/services/global.dart';
import 'package:gamico/commons/services/local_storage.dart';

/// Player-name rules: format, validation and uniqueness.
///
/// Two distinct names live on a user:
///  * `social_name` mirrors the Game Center / Play Games display name. It is
///    refreshed on every sign-in and the player cannot change it from here.
///  * `name` is what the game shows everywhere. It is seeded from the social
///    name the first time the account is seen, then belongs to the player:
///    the platform must never overwrite it again.
///
/// `formatted_name` is the normalized mirror of `name` (lowercased, no
/// diacritics). It backs the friend search AND the uniqueness check, so both
/// are always written together.
class GamicoPlayerNameService {
  static const int nameMinLength = 5;
  static const int nameMaxLength = 15;

  /// RTDB never fails a write while offline, it just keeps it pending. Cap the
  /// wait so a rename can be reported as failed instead of hanging.
  static const Duration writeTimeout = Duration(seconds: 10);

  /// Letters (any alphabet), digits, spaces and a few separators.
  static final RegExp _nameAllowedCharacters = RegExp(
    r"^[\p{L}\p{N} ._'-]+$",
    unicode: true,
  );

  /// Trims and collapses whitespace. What actually gets stored in `name`.
  static String sanitizeName(String name) =>
      name.trim().replaceAll(RegExp(r"\s+"), " ");

  /// Drops unpaired UTF-16 surrogates.
  ///
  /// Some accounts' `name` was seeded before [findAvailableName] truncated by
  /// grapheme cluster instead of code unit, so a handful of stored names
  /// still contain a lone surrogate. Flutter's TextPainter throws on that
  /// (`string is not well-formed UTF-16`) the moment the value is laid out in
  /// an editable field, so strip it defensively wherever a stored name feeds
  /// a TextField, not just at write time.
  static String stripLoneSurrogates(String name) {
    final buffer = StringBuffer();

    for (var i = 0; i < name.length; i++) {
      final unit = name.codeUnitAt(i);

      if (unit >= 0xD800 && unit <= 0xDBFF) {
        final hasLowSurrogate =
            i + 1 < name.length &&
            name.codeUnitAt(i + 1) >= 0xDC00 &&
            name.codeUnitAt(i + 1) <= 0xDFFF;

        if (!hasLowSurrogate) continue;

        buffer.write(name[i]);
        buffer.write(name[i + 1]);
        i++;
      } else if (unit >= 0xDC00 && unit <= 0xDFFF) {
        continue;
      } else {
        buffer.write(name[i]);
      }
    }

    return buffer.toString();
  }

  /// Normalized form stored in `formatted_name`.
  static String formatName(String name) =>
      removeDiacritics(sanitizeName(name).toLowerCase());

  static bool isNameValid(String name) {
    final sanitized = sanitizeName(name);

    return sanitized.length >= nameMinLength &&
        sanitized.length <= nameMaxLength &&
        _nameAllowedCharacters.hasMatch(sanitized);
  }

  /// Whether [formattedName] already belongs to ANOTHER account.
  ///
  /// Returns null when the check itself failed (offline, permission, …) so the
  /// caller can refuse the rename instead of silently creating a duplicate.
  static Future<bool?> isNameTaken(String formattedName) async {
    if (formattedName.isEmpty) return null;

    try {
      final snapshot = await FirebaseDatabase.instance
          .ref()
          .child("profiles")
          .orderByChild("formatted_name")
          .equalTo(formattedName)
          // One extra entry so our own account never hides a real conflict.
          .limitToFirst(2)
          .get()
          .timeout(writeTimeout);

      if (!snapshot.exists) return false;

      final data = Map<String, dynamic>.from(
        jsonDecode(jsonEncode(snapshot.value)),
      );

      return data.keys.any((id) => id != LocalStorageService.uid);
    } catch (e) {
      debugPrint("⚠️ isNameTaken('$formattedName') failed: $e");
      return null;
    }
  }

  /// Derives a free name from [base] by suffixing a number when needed. Used
  /// for the initial seeding only — a player-initiated rename must fail loudly
  /// rather than silently rename someone to "Alex2".
  static Future<String> findAvailableName(String base) async {
    var root = sanitizeName(base);

    if (!isNameValid(root)) {
      root = sanitizeName(GamicoGlobalService.getRandomPlayerName());
    }

    for (var attempt = 0; attempt < 8; attempt++) {
      final suffix = attempt == 0
          ? ""
          : "${GamicoGlobalService.random.nextInt(900) + 100}";

      // Keep room for the suffix rather than overflowing the max length.
      // Truncate by grapheme cluster, not UTF-16 code unit: root can contain
      // astral-plane letters (e.g. some non-Latin scripts), and cutting mid
      // surrogate pair leaves a lone surrogate that later crashes any
      // TextField laid out with this name (invalid UTF-16 in TextPainter).
      final trimmed = root.length + suffix.length > nameMaxLength
          ? root.characters.take(nameMaxLength - suffix.length).toString()
          : root;

      final candidate = "$trimmed$suffix";

      if (await isNameTaken(formatName(candidate)) == false) return candidate;
    }

    return root;
  }
}
