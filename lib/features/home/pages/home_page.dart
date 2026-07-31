import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/languages/languages.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/services/store.dart';
import 'package:gamico/commons/services/version.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/services/notification.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';

/// The page that welcomes the player.
class GamicoHomePage extends StatefulWidget {
  /// The widget that will be wrapped into this [GamicoHomePage].
  final Widget child;

  /// The page that welcomes the player.
  const GamicoHomePage({super.key, required this.child});

  @override
  State<GamicoHomePage> createState() => _GamicoHomePageState();
}

class _GamicoHomePageState extends State<GamicoHomePage> {
  @override
  void initState() {
    // Call inherited method
    super.initState();

    // Call this method after page initialization
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  /// Init the current page.
  void _init() async {
    if (!mounted) return;

    // Debug helper: force the reminder popup so its layout can be reviewed
    // without having to reproduce a real refusal. No effect in release.
    if (kDebugMode && NotificationService.debugForceReminderPopup) {
      _showNotificationsReminderPopup();
      return;
    }

    // Route the player through the right notification flow.
    if (!NotificationService.notificationsSet) {
      // First launch: ask whether notifications should be enabled.
      _showNotificationsPopup();
    } else if (!NotificationService.notificationsReminderShown &&
        !(await NotificationService.allowed())) {
      if (!mounted) return;

      // The player already went through the flow but notifications are still
      // disabled — either they declined our first prompt, denied the native
      // permission, or revoked it later. Encourage them to enable it, but only
      // once: if they decline the reminder too, we don't nag them again.
      NotificationService.notificationsReminderShown = true;
      _showNotificationsReminderPopup();
    } else {
      if (!mounted) return;

      // Notifications are enabled: proceed with the normal home flow.
      // Display a popup that asks the player to update the current game.
      _showUpdatePopup();

      // Schedule notifications if they are allowed
      NotificationService.init();
      NotificationService.scheduleNotificationsIfAllowed();
    }

    // Check if user tried to mislead the game
    if (GameService.gameSkipped) {
      // Wait for 1 second to let the animations complete
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;

      // Remove due coins
      context.read<GamicoUserCubit>().decrementCowries(
        Gamico.instance.gameSettings.playMinimumCoins,
      );

      // Come back to the initial state
      GameService.gameSkipped = false;
    }
  }

  /// Display a popup that asks to enable or disable notifications.
  void _showNotificationsPopup() {
    if (!mounted) return;
    final l = GamicoLanguages.of(context);

    NavigationService.showPopup(
      context: context,
      draggable: false,
      dismissible: false,
      builder: (_) {
        return GamicoPopup(
          dismissible: false,
          child: GamicoDialogPoster(
            icon: Icons.notifications,
            title: l.homeNotificationsTitle,
            description: l.homeNotificationsDescription,
            acceptationText: l.homeNotificationsAllow,
            onAccepted: () async {
              if (!(await AwesomeNotifications().isNotificationAllowed())) {
                // The native permission dialog is being presented — remember it
                // so a later reminder knows the OS dialog has already been used.
                NotificationService.notificationsRequested = true;

                await AwesomeNotifications()
                    .requestPermissionToSendNotifications();

                NotificationService.init();
                NotificationService.scheduleNotificationsIfAllowed();
              }

              NotificationService.notificationsAccepted =
                  await NotificationService.allowed();
              NotificationService.notificationsSet = true;
            },
            onRejected: () {
              // The player declined our prompt: the native dialog was never
              // shown, so `notificationsRequested` stays false.
              NotificationService.notificationsAccepted = false;
              NotificationService.notificationsSet = true;
            },
          ),
        );
      },
    );
  }

  /// Display a reminder popup for players who have notifications disabled,
  /// explaining why they matter and offering to enable them again.
  ///
  /// Accepting resolves to one of two behaviors depending on how far the
  /// player got in the original flow:
  ///  - if the native OS dialog was never shown (they only declined our
  ///    in-app prompt), present the native permission dialog now;
  ///  - if the native dialog was already shown and denied, the OS won't show
  ///    it again, so send the player to the app's notification settings.
  void _showNotificationsReminderPopup() {
    if (!mounted) return;
    final l = GamicoLanguages.of(context);

    NavigationService.showPopup(
      context: context,
      draggable: false,
      dismissible: false,
      builder: (_) {
        return GamicoPopup(
          dismissible: false,
          child: GamicoDialogPoster(
            icon: Icons.notifications_active,
            title: l.homeNotificationsReminderTitle,
            description: l.homeNotificationsReminderDescription,
            acceptationText: l.homeNotificationsAllow,
            onAccepted: () async {
              if (NotificationService.notificationsRequested) {
                // Native dialog already used and denied: the OS won't present
                // it again, so send the player to the app's notification
                // settings to grant the permission manually.
                await AwesomeNotifications().showNotificationConfigPage();
              } else {
                // The native dialog was never shown — present it now.
                NotificationService.notificationsRequested = true;

                await AwesomeNotifications()
                    .requestPermissionToSendNotifications();
              }

              NotificationService.notificationsAccepted =
                  await NotificationService.allowed();

              // Start listening / scheduling as soon as we're granted.
              if (NotificationService.notificationsAccepted) {
                NotificationService.init();
                NotificationService.scheduleNotificationsIfAllowed();
              }
            },
          ),
        );
      },
    );
  }

  /// Display a popup that asks the player to update the current game.
  void _showUpdatePopup() {
    if (!mounted) return;
    final l = GamicoLanguages.of(context);

    final status = VersionService.status;

    if ((status != null && status.canUpdate) ||
        VersionService.localVersionDeprecated()) {
      if (status != null) {
        VersionService.storeVersion = status.storeVersion;
      }

      final forceUpdate = VersionService.forceUpdate(
        VersionService.storeVersion,
      );

      NavigationService.showPopup(
        context: context,
        dismissible: !forceUpdate,
        draggable: !forceUpdate,
        builder: (_) {
          return GamicoPopup(
            dismissible: !forceUpdate,
            child: GamicoDialogPoster(
              icon: Icons.download,
              title: l.homeUpdateTitle,
              description: forceUpdate
                  ? l.homeUpdateForceDescription
                  : l.homeUpdateSimpleDescription,
              simple: forceUpdate,
              automaticClose: !forceUpdate,
              acceptationText: l.homeUpdateInstall,
              acceptationIcon: Icons.download,
              onAccepted: () {
                StoreService.openStorePage();
              },
            ),
          );
        },
      );
    }
  }
}
