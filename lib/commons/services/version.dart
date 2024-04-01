import 'package:flutter/material.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:new_version_plus/new_version_plus.dart';

class VersionService {
  static late String versionString;

  static String get storeVersion =>
      LocalStorageService.getString("store_version") ?? "";
  static set storeVersion(String value) {
    LocalStorageService.setString("store_version", value);
  }

  static final NewVersionPlus version = NewVersionPlus();
  static late VersionStatus? status;

  static Future<void> init() async {
    try {
      status = await VersionService.version.getVersionStatus();
    } catch (e) {
      debugPrint(e.toString());
      status = null;
    }
  }

  static bool forceUpdate(String storeVersion) {
    return formatVersion(storeVersion).split(".").last == "9";
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

  static bool localVersionDeprecated() {
    if (storeVersion.isNotEmpty) {
      final localParts = formatVersion(versionString)
          .split(".")
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
      final storeParts = formatVersion(storeVersion)
          .split(".")
          .map((e) => int.tryParse(e) ?? 0)
          .toList();

      if (storeParts[0] > localParts[0]) {
        return true;
      }

      if (storeParts[0] == localParts[0]) {
        if (storeParts[1] > localParts[1]) {
          return true;
        }

        if (storeParts[1] == localParts[1]) {
          if (storeParts[2] > localParts[2]) {
            return true;
          }
        }
      }
    }

    return false;
  }
}
