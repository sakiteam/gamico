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
import 'package:gamico/commons/services/locale.dart';
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

  /// Whether the native OS permission dialog has ever been presented. It stays
  /// `false` while the player only declined our in-app prompt (the system
  /// dialog was never shown) and flips to `true` the first time we actually
  /// call [requestPermissionToSendNotifications]. Used by the home reminder to
  /// decide whether re-asking can still show the native dialog (not yet
  /// requested) or must instead send the player to the app's notification
  /// settings (already requested and denied).
  static bool get notificationsRequested =>
      LocalStorageService.getBool("notifications_requested") ?? false;
  static set notificationsRequested(bool value) =>
      LocalStorageService.setBool("notifications_requested", value);

  /// Whether the one-off reminder popup (shown to players who left the flow
  /// without enabling notifications) has already been presented. Once `true`,
  /// the reminder is never shown again, so a player who declines it is not
  /// nagged on every launch.
  static bool get notificationsReminderShown =>
      LocalStorageService.getBool("notifications_reminder_shown") ?? false;
  static set notificationsReminderShown(bool value) =>
      LocalStorageService.setBool("notifications_reminder_shown", value);

  static bool get defaultTopicSubscribed =>
      LocalStorageService.getBool("default_topic_subscribed") ?? false;
  static set defaultTopicSubscribed(bool value) =>
      LocalStorageService.setBool("default_topic_subscribed", value);

  /// Debug-only switch: when `true`, the home page shows the notification
  /// reminder popup on every launch regardless of the stored permission state,
  /// so its appearance can be inspected. Guarded by [kDebugMode] on the call
  /// site, so it has no effect in release builds. Set it from `main()`.
  static bool debugForceReminderPopup = false;

  static Future<bool> allowed() =>
      AwesomeNotifications().isNotificationAllowed();

  /// Clears the app-icon badge counter (notably on iOS, where the OS never
  /// decrements the badge on its own — reading or dismissing notifications
  /// from the tray does not touch the icon count, only the app can reset it).
  /// Call this whenever the app comes to the foreground so the badge doesn't
  /// keep accumulating from scheduled reminders and pushed invitations.
  static Future<void> clearBadge() async {
    try {
      await AwesomeNotifications().resetGlobalBadge();
    } catch (e) {
      debugPrint("Error clearing badge: $e");
    }
  }

  /// App-level override for invitation notification actions. When set, it is
  /// tried first and, if it returns true, the default (legacy 2-player)
  /// handling below is skipped. Lets each app route the accept action to its
  /// own game flow instead of the generic game page.
  static Future<bool> Function(ReceivedAction action)? invitationActionHandler;

  static bool _initialized = false;
  static bool _subscribingToDefaultTopic = false;

  static void init() async {
    if (!(await allowed())) return;
    if (_initialized) return;
    _initialized = true;

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

  static Future<void> subscribeToDefaultTopic({
    int maxRetries = 5,
    Duration initialDelay = const Duration(seconds: 5),
  }) async {
    if (defaultTopicSubscribed) return;
    if (_subscribingToDefaultTopic) return;
    _subscribingToDefaultTopic = true;

    try {
      int attempt = 0;
      while (attempt < maxRetries && !defaultTopicSubscribed) {
        attempt++;
        try {
          if (Platform.isIOS) {
            String? apnsToken =
                await FirebaseMessaging.instance.getAPNSToken();

            if (apnsToken == null) {
              await Future.delayed(initialDelay * attempt);
              continue;
            }
          }

          await FirebaseMessaging.instance.subscribeToTopic("default");
          defaultTopicSubscribed = true;
          debugPrint(
            "Successfully subscribed to default topic on attempt $attempt",
          );
          break;
        } catch (e) {
          debugPrint(
            "Attempt $attempt failed to subscribe to default topic: $e",
          );
          if (attempt < maxRetries) {
            await Future.delayed(initialDelay * attempt);
          }
        }
      }
    } finally {
      _subscribingToDefaultTopic = false;
    }
  }

  static void scheduleNotification() async {
    try {
      if (!(await allowed())) return;

      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: "default",
          title: GamicoLanguages.instance.notificationMissTitle,
          body: GamicoLanguages.instance.notificationMissBody,
          notificationLayout: NotificationLayout.BigText,
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
          notificationLayout: NotificationLayout.BigText,
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

    if (await invitationActionHandler?.call(receivedAction) ?? false) return;

    final invitationId = receivedAction.payload!['invitation_id']!;

    // The invitation has now been acted on from its notification: drop it from
    // the tray so the ACCEPT/REJECT buttons can't be pressed again.
    await cancelGameInvitationNotification(invitationId);

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

  /// Localized labels, with English fallbacks for contexts where the
  /// languages singleton is not initialized (e.g. the background isolate).
  static String get _acceptLabel {
    try {
      return GamicoLanguages.instance.globalAccept;
    } catch (_) {
      return "Accept";
    }
  }

  static String get _rejectLabel {
    try {
      return GamicoLanguages.instance.globalReject;
    } catch (_) {
      return "Reject";
    }
  }

  static String get invitationTitle {
    try {
      return GamicoLanguages.instance.friendPageGameInvitation;
    } catch (_) {
      return "New Game Invitation";
    }
  }

  static String get invitationBody {
    try {
      return GamicoLanguages.instance.notificationInvitationBody;
    } catch (_) {
      return "You have been invited to play!";
    }
  }

  static String invitationBodyFrom(String senderName) {
    try {
      return GamicoLanguages.instance.notificationInvitationFrom(senderName);
    } catch (_) {
      return "$senderName invites you to play!";
    }
  }

  static Future<void> showGameInvitationNotification({
    required String title,
    required String body,
    required String invitationId,
  }) async {
    if (!(await allowed())) return;

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          // hashCode can be negative, which awesome_notifications rejects.
          id: invitationId.hashCode & 0x7fffffff,
          channelKey: 'invitations',
          title: title,
          body: body,
          payload: {'invitation_id': invitationId},
          notificationLayout: NotificationLayout.BigText,
          wakeUpScreen: true,
          displayOnForeground: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: "ACCEPT",
            label: _acceptLabel,
            color: Colors.green,
          ),
          NotificationActionButton(
            key: "REJECT",
            label: _rejectLabel,
            color: Colors.red,
          ),
        ],
      );
    } catch (e) {
      debugPrint("Error creating invitation notification: $e");
    }
  }

  /// Dismisses a previously shown invitation notification (same id derivation
  /// as [showGameInvitationNotification]). Triggered by the host-side
  /// `invitation_cancelled` data push when an invitation is withdrawn.
  static Future<void> cancelGameInvitationNotification(
    String invitationId,
  ) async {
    await AwesomeNotifications().cancel(invitationId.hashCode & 0x7fffffff);
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
        await ref.update({
          'token': token,
          // Lets the backend localize pushed notifications (e.g. game
          // invitations) in the receiver's language.
          if (LocaleService.language.isNotEmpty)
            'language': LocaleService.language,
        });
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
    final senderName = message.data['sender_name'] as String?;
    await NotificationService.showGameInvitationNotification(
      title: message.notification?.title ?? NotificationService.invitationTitle,
      body:
          message.notification?.body ??
          (senderName != null
              ? NotificationService.invitationBodyFrom(senderName)
              : NotificationService.invitationBody),
      invitationId: message.data['invitation_id'],
    );
  } else if (message.data['type'] == 'invitation_cancelled') {
    await NotificationService.cancelGameInvitationNotification(
      message.data['invitation_id'],
    );
  }
}

Future<void> handleForegroundMessage(RemoteMessage message) async {
  if (message.data['type'] == 'invitation') {
    final senderName = message.data['sender_name'] as String?;
    await NotificationService.showGameInvitationNotification(
      title: message.notification?.title ?? NotificationService.invitationTitle,
      body:
          message.notification?.body ??
          (senderName != null
              ? NotificationService.invitationBodyFrom(senderName)
              : NotificationService.invitationBody),
      invitationId: message.data['invitation_id'],
    );
  } else if (message.data['type'] == 'invitation_cancelled') {
    await NotificationService.cancelGameInvitationNotification(
      message.data['invitation_id'],
    );
  }
}

Future<void> handleMessageOpenedApp(RemoteMessage message) async {
  // Handle notification tap when app is in background but opened
  if (message.data['type'] == 'invitation') {
    // La notification a déjà été créée, pas besoin de la recréer
    // On pourrait ajouter ici une logique pour ouvrir directement l'écran approprié
  }
}

Future<void> handleInitialMessage(RemoteMessage message) async {
  // Handle notification tap when app is terminated
  if (message.data['type'] == 'invitation') {
    // La notification a déjà été créée, pas besoin de la recréer
    // On pourrait ajouter ici une logique pour ouvrir directement l'écran approprié
  }
}
