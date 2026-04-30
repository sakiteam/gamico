import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/settings/matchmaking_settings.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/features/adventure/utilities/remote_utility.dart';
import 'package:gamico/features/friend/cubits/invitation_cubit.dart';
import 'package:gamico/features/friend/models/invitation_model.dart';
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

  static void init() async {
    if (!(await allowed())) return;

    FirebaseMessaging.onMessage.listen(handleForegroundMessage);
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    FirebaseMessaging.onMessageOpenedApp.listen(handleMessageOpenedApp);

    // Listen for notification actions
    AwesomeNotifications().setListeners(
      onActionReceivedMethod: NotificationService.onActionReceivedMethod,
    );
  }

  static void scheduleNotificationsIfAllowed() async {
    if (!(await allowed())) return;

    // FirebaseMessaging.instance.subscribeToTopic("default");

    await subscribeToDefaultTopic();

    NotificationService.scheduleNotification();
    NotificationService.scheduleReminder();
  }

  static Future<void> subscribeToDefaultTopic() async {
    // if (!(await AwesomeNotifications().isNotificationAllowed())) return;

    if (Platform.isIOS) {
      String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();

      if (apnsToken == null) {
        await Future.delayed(const Duration(minutes: 1));
        subscribeToDefaultTopic();
        return;
      }
    }

    FirebaseMessaging.instance.subscribeToTopic("default");
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
        schedule: NotificationInterval(interval: 3.days, allowWhileIdle: true),
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
        schedule: NotificationInterval(interval: 6.hours, allowWhileIdle: true),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @pragma("vm:entry-point")
  static Future<void> onActionReceivedMethod(
    ReceivedAction receivedAction,
  ) async {
    if (receivedAction.payload == null ||
        !receivedAction.payload!.containsKey('invitation_id')) {
      return;
    }

    final invitationId = receivedAction.payload!['invitation_id']!;
    final cubit = InvitationCubit(FirebaseDatabase.instance);

    if (receivedAction.buttonKeyPressed == "ACCEPT") {
      await cubit.updateInvitationStatus(
        invitationId,
        InvitationStatus.accepted,
      );

      NavigationService.closePopups();

      NavigationService.pushPageWithAnimation(
        NavigationService.globalNavigatorKey.currentContext!,
        Gamico.instance.pagesSettings.gamePage(
          NavigationService.globalNavigatorKey.currentContext!,
          RemoteGameUtility(
            level: null,
            gameId: invitationId, // remoteState.gameId,
            fakeOpponent: false,
            friend: true,
            remoteUtility: RemoteUtility(
              adventure: false,
              developerAndroidId: "",
              developerAppleId: "",
              levelsBuilder: null,
              matchmakingSettings: MatchmakingSettings(
                minLevel: 0,
                maxLevel: 0,
                getMatchmakingLevel: (_) => 0,
                increment: 0,
              ),
            ),
            adventureUtility: null,
            creatorOfCurrentGame: false,
            onBackButtonPressed: () async {
              // if (widget.remoteUtility.adventure) {
              //   remoteCubit.setForcePop(true);
              //   NavigationService.pop(context);
              // } else {
              //   remoteCubit.setAnimGame(false);
              //   await Future.delayed(AnimationService.animationDuration);
              //   remoteCubit.setAnimated(false);
              // }
            },
          ),
        ),
      );

      // Navigate to game
      // if (mounted) {
      //   // Navigator.of(context).push(
      //   //   MaterialPageRoute(
      //   //     builder:
      //   //         (context) => GamicoRemoteGamePage(
      //   //           child: Container(), // Replace with your game widget
      //   //           onBackButtonPressed: () => Navigator.of(context).pop(),
      //   //         ),
      //   //   ),
      //   // );
      // }
    } else if (receivedAction.buttonKeyPressed == 'REJECT') {
      await cubit.updateInvitationStatus(
        invitationId,
        InvitationStatus.rejected,
      );
    }
  }

  static Future<void> showGameInvitationNotification({
    required String title,
    required String body,
    required String invitationId,
  }) async {
    if (!(await allowed())) return;

    await AwesomeNotifications().createNotification(
      content: NotificationContent(
        id: invitationId.hashCode,
        channelKey: 'invitations',
        title: title,
        body: body,
        payload: {'invitation_id': invitationId},
        notificationLayout: NotificationLayout.Default,
      ),
      actionButtons: [
        NotificationActionButton(
          key: "ACCEPT",
          label: "Accept",
          color: Colors.green,
        ),
        NotificationActionButton(
          key: "REJECT",
          label: "Reject",
          color: Colors.red,
        ),
      ],
    );
  }

  static Future<void> updateUserToken(String userId) async {
    if (!(await allowed())) return;

    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) {
        final ref = FirebaseDatabase.instance
            .ref()
            .child('users')
            .child(userId);
        await ref.update({'token': token});
      }
    } catch (e) {
      debugPrint("Error updating user token: $e");
    }
  }
}

Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Initialize Firebase if needed (in background)
  await Firebase.initializeApp();

  // Convert Firebase message to local notification
  if (message.data['type'] == 'invitation') {
    await NotificationService.showGameInvitationNotification(
      title: message.notification?.title ?? 'New Game Invitation',
      body: message.notification?.body ?? 'You have been invited to play!',
      invitationId: message.data['invitation_id'],
    );
  }
}

Future<void> handleForegroundMessage(RemoteMessage message) async {
  if (message.data['type'] == 'invitation') {
    await NotificationService.showGameInvitationNotification(
      title: message.notification?.title ?? 'New Game Invitation',
      body: message.notification?.body ?? 'You have been invited to play!',
      invitationId: message.data['invitation_id'],
    );
  }
}

Future<void> handleMessageOpenedApp(RemoteMessage message) async {
  // Handle notification tap when app is in background but opened
  if (message.data['type'] == 'invitation') {
    // La notification a déjà été créée, pas besoin de la recréer
    // On pourrait ajouter ici une logique pour ouvrir directement l'écran approprié
    // TODO : display invitation popup to accept
  }
}

Future<void> handleInitialMessage(RemoteMessage message) async {
  // Handle notification tap when app is terminated
  if (message.data['type'] == 'invitation') {
    // La notification a déjà été créée, pas besoin de la recréer
    // On pourrait ajouter ici une logique pour ouvrir directement l'écran approprié
    // TODO : display invitation popup to accept
  }
}
