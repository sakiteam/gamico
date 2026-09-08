import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:flutter/foundation.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/time_zone.dart';
import 'package:gamico/commons/services/version.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Handles the asynchronous initialization of core services and system plugins
/// required during app bootstrap.
class GamicoAppInitializer {
  const GamicoAppInitializer._();

  /// Initializes versioning, time zone, notifications channels, and package info.
  static Future<void> initialize() async {
    await VersionService.init();
    TimeZoneService.initTimeZone();

    try {
      await AwesomeNotifications().initialize(
        "resource://drawable/ic_stat_${Gamico.instance.title.toLowerCase()}",
        [
          NotificationChannel(
            channelKey: "default",
            channelName: "Généralités",
            channelDescription: "Ces notifications servent à informer le joueur des nouveautés et de toutes les informations d'ordre général !",
            playSound: true,
            enableVibration: true,
            channelShowBadge: true,
            onlyAlertOnce: false,
            importance: NotificationImportance.Max,
          ),
          NotificationChannel(
            channelKey: 'invitations',
            channelName: 'Invitations',
            channelDescription: 'Ces notifications servent à informer le joueur des invitations reçues !',
            playSound: true,
            enableVibration: true,
            channelShowBadge: true,
            onlyAlertOnce: false,
            importance: NotificationImportance.Max,
          ),
          // Channel for active game turn updates.
          // Importance Max ensures it appears in the active/prominent section of the
          // Android shade (NOT tucked away in "Silencieux").
          // onlyAlertOnce: true ensures silent progress updates without repeated sounds.
          NotificationChannel(
            channelKey: 'game',
            channelName: 'Parties',
            channelDescription: "Ces notifications servent à donner des informations au joueur au cours d'une partie !",
            enableVibration: false,
            playSound: false,
            onlyAlertOnce: true,
            channelShowBadge: true,
            importance: NotificationImportance.Max,
          ),
        ],
        debug: kDebugMode,
      );
    } catch (e) {
      debugPrint("Error initializing AwesomeNotifications: $e");
    }

    // Package info
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    VersionService.versionString = packageInfo.version;
  }
}
