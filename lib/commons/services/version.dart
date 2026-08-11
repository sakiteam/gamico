import 'package:flutter/material.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:new_version_plus/model/version_status.dart';
import 'package:new_version_plus/new_version_plus.dart';
import 'package:simple_connection_checker/simple_connection_checker.dart';

class VersionService {
  static String versionString = "";

  static String get storeVersion =>
      LocalStorageService.getString("store_version") ?? "";
  static set storeVersion(String value) {
    LocalStorageService.setString("store_version", value);
  }

  static final NewVersionPlus version = NewVersionPlus();
  static VersionStatus? status;

  /// Version defined in remote_config below which the update popup must be
  /// shown as non-dismissible. Set from app startup once remote_config has
  /// been fetched (e.g. `VersionService.urgentVersion = remoteConfig.getString('urgent_version')`).
  static String urgentVersion = "";

  static Future<void> init() async {
    try {
      if (await SimpleConnectionChecker.isConnectedToInternet()) {
        status = await VersionService.version.getVersionStatus();
      }
    } catch (e) {
      debugPrint(e.toString());
      status = null;
    }
  }

  static bool forceUpdate() {
    return urgentVersion.isNotEmpty &&
        versionString.isNotEmpty &&
        compareVersions(versionString, urgentVersion) < 0;
  }

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

  static bool localVersionDeprecated() {
    if (storeVersion.isNotEmpty && versionString.isNotEmpty) {
      return compareVersions(versionString, storeVersion) < 0;
    }

    return false;
  }
}
