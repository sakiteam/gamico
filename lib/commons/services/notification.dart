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

  /// App-level handler for friend-request notification actions (a distinct
  /// domain from game invitations above, gated by the `friend_request_id`
  /// payload key instead of `invitation_id`). Unlike [invitationActionHandler]
  /// there is no generic fallback handling here — gamico has no built-in
  /// notion of a "friend request", so this must be set by the app for the
  /// notification to do anything when tapped.
  static Future<bool> Function(ReceivedAction action)?
  friendRequestActionHandler;

  /// App-level hook for the iOS side of the ambient "whose turn" indicator
  /// (a `turn_notification` / `turn_notification_end` data push — see
  /// [showTurnNotification]). The Android tray entry is handled generically
  /// below via [AwesomeNotifications], already a gamico dependency; iOS's
  /// equivalent surface is a Live Activity, which needs a game-specific
  /// plugin gamico doesn't depend on, so the game sets this at startup.
  /// Reliable while the app's main isolate is alive (foreground or briefly
  /// backgrounded); not guaranteed once the OS fully suspends the app — see
  /// [firebaseMessagingBackgroundHandler].
  static Future<void> Function(Map<String, dynamic> data)?
  turnNotificationHandler;
  static Future<void> Function(Map<String, dynamic> data)?
  turnNotificationEndHandler;

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
            String? apnsToken = await FirebaseMessaging.instance.getAPNSToken();

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
    final payload = receivedAction.payload;

    if (payload != null && payload.containsKey('friend_request_id')) {
      await friendRequestActionHandler?.call(receivedAction);
      return;
    }

    if (payload == null || !payload.containsKey('invitation_id')) {
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

  /// App-level providers for friend-request notification text. gamico has no
  /// built-in notion of a "friend request" (unlike game invitations above,
  /// which have first-class [invitationTitle]/[invitationBodyFrom] backed by
  /// [GamicoLanguages]), so the app must supply these for the Android
  /// data-only notification path to show localized text.
  static String Function()? friendRequestTitleProvider;
  static String Function(String senderName)? friendRequestBodyProvider;

  static String get friendRequestTitle {
    try {
      return friendRequestTitleProvider?.call() ?? "New Friend Request";
    } catch (_) {
      return "New Friend Request";
    }
  }

  static String friendRequestBodyFrom(String senderName) {
    try {
      return friendRequestBodyProvider?.call(senderName) ??
          "$senderName sent you a friend request";
    } catch (_) {
      return "$senderName sent you a friend request";
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

  static Future<void> showFriendRequestNotification({
    required String title,
    required String body,
    required String friendRequestId,
  }) async {
    if (!(await allowed())) return;

    try {
      await AwesomeNotifications().createNotification(
        content: NotificationContent(
          // hashCode can be negative, which awesome_notifications rejects.
          id: friendRequestId.hashCode & 0x7fffffff,
          channelKey: 'invitations',
          title: title,
          body: body,
          payload: {'friend_request_id': friendRequestId},
          notificationLayout: NotificationLayout.BigText,
          wakeUpScreen: true,
          displayOnForeground: true,
        ),
        actionButtons: [
          NotificationActionButton(
            key: "ACCEPT_FRIEND",
            label: _acceptLabel,
            color: Colors.green,
          ),
          NotificationActionButton(
            key: "REJECT_FRIEND",
            label: _rejectLabel,
            color: Colors.red,
          ),
        ],
      );
    } catch (e) {
      debugPrint("Error creating friend request notification: $e");
    }
  }

  /// Dismisses a previously shown friend-request notification (same id
  /// derivation as [showFriendRequestNotification]).
  static Future<void> cancelFriendRequestNotification(
    String friendRequestId,
  ) async {
    await AwesomeNotifications().cancel(friendRequestId.hashCode & 0x7fffffff);
  }

  /// Generic ambient "whose turn" indicator for any turn-based gamico game,
  /// driven entirely by the payload the backend already localized and
  /// formatted (gamico has no notion of the game itself, just renders what
  /// it's given). Android only here — see [turnNotificationHandler] for iOS.
  static Future<void> showTurnNotification(Map<String, dynamic> data) async {
    if (!Platform.isAndroid) {
      await turnNotificationHandler?.call(data);
      return;
    }

    final idStr = data['notification_id'] as String?;
    final title = data['title'] as String?;
    final body = data['body'] as String?;
    if (idStr == null || title == null || body == null) return;
    final id = int.tryParse(idStr) ?? (idStr.hashCode & 0x7fffffff);

    try {
      if (await allowed()) {
        await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: id,
            channelKey: 'default',
            title: title,
            body: body,
            notificationLayout: NotificationLayout.Default,
            wakeUpScreen: false,
            locked: false,
            autoDismissible: true,
            displayOnForeground: false,
          ),
        );
      }
    } catch (e) {
      debugPrint("Error showing turn notification: $e");
    }

    await turnNotificationHandler?.call(data);
  }

  /// Dismisses a previously shown [showTurnNotification] entry (same id
  /// derivation) once the game is over or a fresher push moves past it.
  static Future<void> cancelTurnNotificationById(
    Map<String, dynamic> data,
  ) async {
    final idStr = data['notification_id'] as String?;
    if (idStr != null && Platform.isAndroid) {
      final id = int.tryParse(idStr) ?? (idStr.hashCode & 0x7fffffff);
      try {
        await AwesomeNotifications().cancel(id);
      } catch (e) {
        debugPrint("Error cancelling turn notification: $e");
      }
    }
    await turnNotificationEndHandler?.call(data);
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

  // On iOS, if the message has a notification payload (APNs alert), the OS
  // already displays it natively in the system tray.
  // Creating a local notification via AwesomeNotifications in background isolates
  // races with applicationDidBecomeActive lifecycle events in native Swift code,
  // causing _dictionaryUpCast / ScheduleManager crashes.
  if (Platform.isIOS && message.notification != null) return;

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
  } else if (message.data['type'] == 'friend_request') {
    final senderName = message.data['sender_name'] as String?;
    await NotificationService.showFriendRequestNotification(
      title:
          message.notification?.title ?? NotificationService.friendRequestTitle,
      body:
          message.notification?.body ??
          NotificationService.friendRequestBodyFrom(senderName ?? ''),
      friendRequestId: message.data['friend_request_id'],
    );
  } else if (message.data['type'] == 'friend_request_cancelled') {
    await NotificationService.cancelFriendRequestNotification(
      message.data['friend_request_id'],
    );
  } else if (message.data['type'] == 'turn_notification') {
    await NotificationService.showTurnNotification(message.data);
  } else if (message.data['type'] == 'turn_notification_end') {
    await NotificationService.cancelTurnNotificationById(message.data);
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
  } else if (message.data['type'] == 'friend_request') {
    final senderName = message.data['sender_name'] as String?;
    await NotificationService.showFriendRequestNotification(
      title:
          message.notification?.title ?? NotificationService.friendRequestTitle,
      body:
          message.notification?.body ??
          NotificationService.friendRequestBodyFrom(senderName ?? ''),
      friendRequestId: message.data['friend_request_id'],
    );
  } else if (message.data['type'] == 'friend_request_cancelled') {
    await NotificationService.cancelFriendRequestNotification(
      message.data['friend_request_id'],
    );
  } else if (message.data['type'] == 'turn_notification') {
    await NotificationService.showTurnNotification(message.data);
  } else if (message.data['type'] == 'turn_notification_end') {
    await NotificationService.cancelTurnNotificationById(message.data);
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
