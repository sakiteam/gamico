import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gamico/languages/languages.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static bool get notificationsSet =>
      LocalStorageService.getBool("notifications_set") ?? false;
  static set notificationsSet(bool value) =>
      LocalStorageService.setBool("notifications_set", value);

  static bool get notificationsAccepted =>
      LocalStorageService.getBool("notifications_accepted") ?? false;
  static set notificationsAccepted(bool value) =>
      LocalStorageService.setBool("notifications_accepted", value);

  static Future<bool> allowed() =>
      AwesomeNotifications().isNotificationAllowed();

  static void scheduleNotificationsIfAllowed() async {
    if (!(await allowed())) return;

    FirebaseMessaging.instance.subscribeToTopic("default");

    NotificationService.scheduleNotification();
    NotificationService.scheduleReminder();
  }

  static void scheduleNotification() async {
    try {
      if (!(await allowed())) return;

      AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: "default",
          title: GamicoLanguages.instance.notificationMissTitle,
          body: GamicoLanguages.instance.notificationMissBody,
          wakeUpScreen: true,
        ),
        schedule: NotificationInterval(
          interval: 3.days.inSeconds,
          allowWhileIdle: true,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static void scheduleReminder() async {
    try {
      if (!(await allowed())) return;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 3,
          channelKey: "default",
          title: GamicoLanguages.instance.notificationGiftTitle,
          body: GamicoLanguages.instance.notificationGiftBody,
          wakeUpScreen: true,
          displayOnForeground: true,
        ),
        schedule: NotificationInterval(
          interval: 6.hours.inSeconds,
          allowWhileIdle: true,
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
