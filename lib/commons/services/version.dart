import 'package:flutter/foundation.dart';

/// Decides whether the "update the app" popup must be shown, and whether the
/// player may dismiss it. Everything is driven by four values that the host app
/// copies from its remote config at startup (see the fields below): there is no
/// store lookup, so a new release never nags players until it is explicitly
/// announced.
///
/// Every value has a safe default, so the whole thing stays inert — no popup —
/// until the remote config is filled in (or when it cannot be fetched at all).
class VersionService {
  static String versionString = "";

  /// Most recent version available on iOS (and macOS). Builds older than this
  /// are the ones the popup may target. Empty = not announced yet.
  static String latestVersionIos = "";

  /// Most recent version available on Android. Empty = not announced yet.
  static String latestVersionAndroid = "";

  /// Master switch: the popup is never shown while this is `false`.
  static bool showUpdatePopup = false;

  /// Whether the player can close the popup. `false` marks an urgent update:
  /// the popup then blocks the app until the store is opened.
  static bool updateDismissible = true;

  /// The latest version announced for the platform this build runs on, without
  /// surrounding spaces or a build suffix (`1.4.2+37` -> `1.4.2`). Empty when
  /// none was announced or the platform has no store.
  static String get latestVersion {
    final raw = switch (defaultTargetPlatform) {
      TargetPlatform.iOS || TargetPlatform.macOS => latestVersionIos,
      TargetPlatform.android => latestVersionAndroid,
      _ => "",
    };
    return raw.split("+").first.trim();
  }

  /// Whether this build is older than the announced latest version. `false`
  /// whenever either version is unknown.
  static bool updateAvailable() {
    final latest = latestVersion;
    return latest.isNotEmpty &&
        versionString.isNotEmpty &&
        compareVersions(versionString, latest) < 0;
  }

  /// Whether the update popup must be shown at all.
  static bool shouldShowUpdatePopup() => showUpdatePopup && updateAvailable();

  /// Whether the popup must be shown as non-dismissible (urgent update).
  static bool forceUpdate() => shouldShowUpdatePopup() && !updateDismissible;

  static String formatVersion(String version) {
    List parts = version.split(".");

    if (parts.length < 3) {
      return formatVersion("$version.0");
    }

    if (parts.length < 2) {
      return formatVersion("$version.0.0");
    }

    return version;
  }

  /// Returns negative if [a] < [b], 0 if equal, positive if [a] > [b].
  static int compareVersions(String a, String b) {
    final partsA = formatVersion(
      a,
    ).split(".").map((e) => int.tryParse(e) ?? 0).toList();
    final partsB = formatVersion(
      b,
    ).split(".").map((e) => int.tryParse(e) ?? 0).toList();

    for (var i = 0; i < 3; i++) {
      if (partsA[i] != partsB[i]) {
        return partsA[i] - partsB[i];
      }
    }

    return 0;
  }
}
