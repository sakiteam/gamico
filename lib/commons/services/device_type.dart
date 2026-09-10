import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

/// Detects whether the app is running on Android TV, whose fixed-landscape
/// panel can't honor a portrait orientation lock — locking portrait there
/// just letterboxes the UI with black bars instead of rotating anything.
class DeviceTypeService {
  static bool isAndroidTv = false;

  static Future<void> init() async {
    if (!Platform.isAndroid) return;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    isAndroidTv = androidInfo.systemFeatures.contains('android.software.leanback') ||
        androidInfo.systemFeatures.contains('android.hardware.type.television');
  }
}
