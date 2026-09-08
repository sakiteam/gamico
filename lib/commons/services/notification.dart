import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/settings/matchmaking_settings.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/commons/models/remote_utility.dart';
import 'package:gamico/languages/languages.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:gamico/commons/services/locale.dart';
import 'package:awesome_notifications/awesome_notifications.dart';

class NotificationService {
  static void Function(BuildContext context, String invitationId)?
  onAcceptInvitation;
  static void Function(String invitationId)? onRejectInvitation;

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

  /// Key holding the FCM token this installation completed the notification
  /// flow with. See [reconcileInstallation].
  static const String _installTokenKey = "notifications_install_token";

  static String? get _installToken =>
      LocalStorageService.getString(_installTokenKey);

  /// Records the current FCM token as the one the flags above belong to.
  /// A missing token (offline, APNs not ready yet) leaves the marker
  /// untouched: an unknown token must never be mistaken for a new install.
  static Future<void> rememberInstallToken() async {
    try {
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null && token.isNotEmpty) {
        await LocalStorageService.setString(_installTokenKey, token);
      }
    } catch (e) {
      debugPrint("Error remembering the notification install token: \$e");
    }
  }

  /// Re-opens the notification flow when the persisted flags belong to a
  /// *previous* installation of the app.
  ///
  /// Uninstalling revokes the OS notification permission, but Android's Auto
  /// Backup (and iOS' iCloud backup) restores `SharedPreferences` on the next
  /// install: `notifications_set`, `notifications_requested` and
  /// `notifications_reminder_shown` all come back as `true` while the
  /// permission is denied. The home flow then skips both the first prompt and
  /// the reminder, and the player silently never gets a notification again.
  ///
  /// The FCM token is the signal that tells the two apart: it is regenerated
  /// by every new installation and is never part of a backup. When the stored
  /// token no longer matches the live one, the flags describe an installation
  /// that is gone, so they are cleared and the normal flow runs from scratch.
  /// `default_topic_subscribed` is cleared along with them — a topic
  /// subscription is bound to the token, so the new one is not subscribed
  /// either.
  ///
  /// Returns whether the flow was reset.
  static Future<bool> reconcileInstallation() async {
    try {
      // Notifications work: nothing to re-ask. Just keep the marker in sync
      // so a later token rotation isn't read as a reinstallation.
      if (await allowed()) {
        if (notificationsSet) await rememberInstallToken();
        return false;
      }

      // The player never went through the flow — it will run on its own.
      if (!notificationsSet) return false;

      // Flags written before this marker existed (upgrade from an older
      // build): adopt the current token rather than guessing, so the reset
      // only ever fires on a token we actually recorded.
      final stored = _installToken;
      if (stored == null || stored.isEmpty) {
        await rememberInstallToken();
        return false;
      }

      String? current;
      try {
        current = await FirebaseMessaging.instance.getToken();
      } catch (e) {
        debugPrint("Error reading the FCM token for reconciliation: \$e");
      }

      // Unknown token, or the same installation that answered the prompt:
      // leave the player's answer alone.
      if (current == null || current.isEmpty) return false;
      if (current == stored) return false;

      // New installation wearing the old install's answers: start over.
      notificationsSet = false;
      notificationsAccepted = false;
      notificationsRequested = false;
      notificationsReminderShown = false;
      defaultTopicSubscribed = false;
      await LocalStorageService.setString(_installTokenKey, "");

      debugPrint(
        "Notification flow reset: the stored answers belong to a previous "
        "installation.",
      );
      return true;
    } catch (e) {
      debugPrint("Error reconciling the notification installation: \$e");
      return false;
    }
  }

  /// Serializes every call that mutates awesome_notifications' own state
  /// (creating, cancelling or dismissing a notification).
  ///
  /// The iOS side of the plugin keeps its schedules in a single
  /// unsynchronized dictionary (`SharedManager`): `createNotification` writes
  /// it from a background queue while cancels — and the plugin's own
  /// `applicationDidBecomeActive` schedule refresh — read and rewrite it from
  /// the main thread. Two of those overlapping corrupt the dictionary, which
  /// takes the app down either in `CFPropertyListCreateDeepCopy` (a value CF
  /// can no longer serialize) or on a Swift over-release. Funnelling our own
  /// calls through one queue keeps at most one of them in flight.
  static Future<void> _pluginQueue = Future<void>.value();

  /// Runs [action] once every previously queued notification call has
  /// finished. Failures are reported to the caller without breaking the
  /// queue for everyone behind them.
  static Future<T> serialized<T>(Future<T> Function() action) {
    final completer = Completer<T>();

    _pluginQueue = _pluginQueue.then((_) async {
      try {
        completer.complete(await action());
      } catch (error, stack) {
        completer.completeError(error, stack);
      }
    });

    return completer.future;
  }

  /// How long a *scheduled* notification waits before it is written.
  ///
  /// Serializing our own calls is not enough on iOS: the plugin refreshes its
  /// stored schedules by itself on `applicationDidBecomeActive`, on the main
  /// thread, and a schedule being written from the background queue at that
  /// exact moment races it. Every one of our scheduling call sites sits on
  /// that edge — the home flow schedules the moment it opens, and again right
  /// after the player comes back from the native permission dialog or from
  /// the system settings page. None of these reminders are time-critical, so
  /// they let the foreground transition finish first.
  static const Duration scheduleSettleDelay = Duration(seconds: 5);

  /// [serialized], for a call that writes a scheduled notification: waits out
  /// the foreground transition before queueing. The wait is deliberately
  /// outside the queue, so a reminder never delays an invitation landing
  /// behind it.
  static Future<T> serializedSchedule<T>(Future<T> Function() action) async {
    await Future.delayed(scheduleSettleDelay);
    return serialized(action);
  }

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

  static Future<void> init() async {
    if (!(await allowed())) return;
    if (_initialized) return;
    _initialized = true;

    // iOS renders an APNs alert itself even while the app is in the
    // foreground, which duplicates what the app is already doing: the
    // foreground handler below re-posts the ones worth seeing as local
    // notifications, and events like `game_started` are pointless on screen
    // (the player is being taken to the table anyway). Turning the OS-rendered
    // foreground alert off leaves exactly one notification per event.
    if (!kIsWeb && Platform.isIOS) {
      await FirebaseMessaging.instance
          .setForegroundNotificationPresentationOptions(
            alert: false,
            badge: false,
            sound: false,
          );
    }

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

    // Awaited, and one after the other: fired off together they raced each
    // other inside the plugin's own schedule store.
    await NotificationService.scheduleNotification();
    await NotificationService.scheduleReminder();
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

  static Future<void> scheduleNotification() async {
    try {
      if (!(await allowed())) return;

      await serializedSchedule(
        () => AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 1,
            channelKey: "default",
            title: GamicoLanguages.instance.notificationMissTitle,
            body: GamicoLanguages.instance.notificationMissBody,
            notificationLayout: NotificationLayout.BigText,
            wakeUpScreen: true,
          ),
          schedule: NotificationInterval(
            interval: 3.days,
            allowWhileIdle: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  static Future<void> scheduleReminder() async {
    try {
      if (!(await allowed())) return;

      await serializedSchedule(
        () => AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 3,
            channelKey: "default",
            title: GamicoLanguages.instance.notificationGiftTitle,
            body: GamicoLanguages.instance.notificationGiftBody,
            notificationLayout: NotificationLayout.BigText,
            wakeUpScreen: true,
            displayOnForeground: true,
          ),
          schedule: NotificationInterval(
            interval: 6.hours,
            allowWhileIdle: true,
          ),
        ),
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

    if (receivedAction.buttonKeyPressed == "ACCEPT") {
      final ref = FirebaseDatabase.instance.ref().child(
        'invitations/$invitationId',
      );
      await ref.update({
        'status': 'accepted',
        'updated_at': ServerValue.timestamp,
      });

      final acceptContext = NavigationService.globalNavigatorKey.currentContext;

      if (acceptContext != null) {
        if (onAcceptInvitation != null) {
          onAcceptInvitation!(acceptContext, invitationId);
        } else {
          NavigationService.closePopups();

          final remoteUtility = RemoteUtility(
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
          );

          NavigationService.pushPageWithAnimation(
            acceptContext,
            Gamico.instance.pagesSettings.gamePage(
              acceptContext,
              RemoteGameUtility(
                level: null,
                gameId: invitationId,
                fakeOpponent: false,
                friend: true,
                remoteUtility: remoteUtility,
                adventureUtility: null,
                creatorOfCurrentGame: false,
                onBackButtonPressed: () async {},
              ),
            ),
          );
        }
      }
    } else if (receivedAction.buttonKeyPressed == 'REJECT') {
      final ref = FirebaseDatabase.instance.ref().child(
        'invitations/$invitationId',
      );
      await ref.update({
        'status': 'rejected',
        'updated_at': ServerValue.timestamp,
      });
      onRejectInvitation?.call(invitationId);
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

  /// App-level providers for friend-request-accepted notification text, same
  /// rationale as [friendRequestTitleProvider]/[friendRequestBodyProvider].
  static String Function()? friendRequestAcceptedTitleProvider;
  static String Function(String accepterName)?
  friendRequestAcceptedBodyProvider;

  static String get friendRequestAcceptedTitle {
    try {
      return friendRequestAcceptedTitleProvider?.call() ??
          "Friend Request Accepted";
    } catch (_) {
      return "Friend Request Accepted";
    }
  }

  static String friendRequestAcceptedBodyFrom(String accepterName) {
    try {
      return friendRequestAcceptedBodyProvider?.call(accepterName) ??
          "$accepterName accepted your friend request";
    } catch (_) {
      return "$accepterName accepted your friend request";
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

  /// Appends the backend-provided game label ("Ludo — 4 joueurs") to an
  /// invitation body, so the receiver sees what kind of game is proposed
  /// straight from the notification. No-op when the backend sent no label
  /// (unknown game mode) or when it is already part of the body (iOS alert).
  static String withGameLabel(String body, String? gameLabel) {
    if (gameLabel == null || gameLabel.isEmpty || body.contains(gameLabel)) {
      return body;
    }
    return "$body\n$gameLabel";
  }

  static Future<void> showGameInvitationNotification({
    required String title,
    required String body,
    required String invitationId,
  }) async {
    if (!(await allowed())) return;

    try {
      await serialized(
        () => AwesomeNotifications().createNotification(
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
        ),
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
    await serialized(
      () => AwesomeNotifications().cancel(invitationId.hashCode & 0x7fffffff),
    );
  }

  static Future<void> showFriendRequestNotification({
    required String title,
    required String body,
    required String friendRequestId,
  }) async {
    if (!(await allowed())) return;

    try {
      await serialized(
        () => AwesomeNotifications().createNotification(
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
        ),
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
    await serialized(
      () =>
          AwesomeNotifications().cancel(friendRequestId.hashCode & 0x7fffffff),
    );
  }

  /// Informational notification shown to the original sender once the other
  /// user accepts their friend request. No action buttons, unlike
  /// [showFriendRequestNotification] — there is nothing left to do here.
  static Future<void> showFriendRequestAcceptedNotification({
    required String title,
    required String body,
    required String accepterId,
  }) async {
    if (!(await allowed())) return;

    try {
      await serialized(
        () => AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: ('accepted_$accepterId').hashCode & 0x7fffffff,
            channelKey: 'invitations',
            title: title,
            body: body,
            payload: {'accepter_id': accepterId},
            notificationLayout: NotificationLayout.BigText,
            wakeUpScreen: true,
            displayOnForeground: true,
          ),
        ),
      );
    } catch (e) {
      debugPrint("Error creating friend request accepted notification: $e");
    }
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
        await serialized(
          () => AwesomeNotifications().createNotification(
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
        await serialized(() => AwesomeNotifications().cancel(id));
      } catch (e) {
        debugPrint("Error cancelling turn notification: $e");
      }
    }
    await turnNotificationEndHandler?.call(data);
  }

  /// "Your online game has started" for a player who is away from the app
  /// while their matchmaking room fills (see `onGameCreated` in the backend).
  /// Android only: the same push carries an APNs alert on iOS, which the OS
  /// renders itself.
  ///
  /// The backend localizes the copy — gamico has no notion of the game — and
  /// sends a fixed `notification_id`, so a game the app already announced
  /// locally (the isolate was still alive when the table filled) is replaced
  /// in the tray rather than shown a second time.
  static Future<void> showGameStartedNotification(
    Map<String, dynamic> data,
  ) async {
    if (!Platform.isAndroid) return;

    final title = data['title'] as String?;
    final body = data['body'] as String?;
    if (title == null || body == null) return;

    final idStr = data['notification_id'] as String?;
    final id = int.tryParse(idStr ?? '') ?? 98;

    try {
      if (await allowed()) {
        await serialized(
          () => AwesomeNotifications().createNotification(
            content: NotificationContent(
              id: id,
              channelKey: 'default',
              title: title,
              body: body,
              notificationLayout: NotificationLayout.Default,
              category: NotificationCategory.Call,
              wakeUpScreen: true,
              locked: false,
              autoDismissible: true,
              displayOnForeground: false,
              payload: {'game_id': data['game_id'] as String? ?? ''},
            ),
          ),
        );
      }
    } catch (e) {
      debugPrint("Error showing game started notification: $e");
    }
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
      body: NotificationService.withGameLabel(
        message.notification?.body ??
            (senderName != null
                ? NotificationService.invitationBodyFrom(senderName)
                : NotificationService.invitationBody),
        message.data['game_label'] as String?,
      ),
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
  } else if (message.data['type'] == 'friend_request_accepted') {
    final accepterName = message.data['accepter_name'] as String?;
    await NotificationService.showFriendRequestAcceptedNotification(
      title:
          message.notification?.title ??
          NotificationService.friendRequestAcceptedTitle,
      body:
          message.notification?.body ??
          NotificationService.friendRequestAcceptedBodyFrom(accepterName ?? ''),
      accepterId: message.data['accepter_id'],
    );
  } else if (message.data['type'] == 'turn_notification') {
    await NotificationService.showTurnNotification(message.data);
  } else if (message.data['type'] == 'turn_notification_end') {
    await NotificationService.cancelTurnNotificationById(message.data);
  } else if (message.data['type'] == 'game_started') {
    await NotificationService.showGameStartedNotification(message.data);
  }
}

Future<void> handleForegroundMessage(RemoteMessage message) async {
  if (message.data['type'] == 'invitation') {
    final senderName = message.data['sender_name'] as String?;
    await NotificationService.showGameInvitationNotification(
      title: message.notification?.title ?? NotificationService.invitationTitle,
      body: NotificationService.withGameLabel(
        message.notification?.body ??
            (senderName != null
                ? NotificationService.invitationBodyFrom(senderName)
                : NotificationService.invitationBody),
        message.data['game_label'] as String?,
      ),
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
  } else if (message.data['type'] == 'friend_request_accepted') {
    final accepterName = message.data['accepter_name'] as String?;
    await NotificationService.showFriendRequestAcceptedNotification(
      title:
          message.notification?.title ??
          NotificationService.friendRequestAcceptedTitle,
      body:
          message.notification?.body ??
          NotificationService.friendRequestAcceptedBodyFrom(accepterName ?? ''),
      accepterId: message.data['accepter_id'],
    );
  } else if (message.data['type'] == 'turn_notification') {
    await NotificationService.showTurnNotification(message.data);
  } else if (message.data['type'] == 'turn_notification_end') {
    await NotificationService.cancelTurnNotificationById(message.data);
  } else if (message.data['type'] == 'game_started') {
    await NotificationService.showGameStartedNotification(message.data);
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
