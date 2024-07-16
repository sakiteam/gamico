import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/languages/languages.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:store_redirect/store_redirect.dart';
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
  const GamicoHomePage({
    super.key,
    required this.child,
  });

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
    // if (!ShowcaseService.shown) {
    //   final showcaseCubit = context.read<ShowcaseCubit>();

    //   ShowcaseService.show(context);

    //   await GlobalService.waitWhile(() => showcaseCubit.state.active);
    // }

    // Check whether the notifications popup has already been showed
    if (NotificationService.notificationsSet &&
        !(NotificationService.notificationsAccepted &&
            !(await NotificationService.allowed()))) {
      // Display a popup that asks the player to update the current game.
      _showUpdatePopup();

      // Schedule notifications if they are allowed
      NotificationService.scheduleNotificationsIfAllowed();
    }
    // Display the notifications popup
    else {
      _showNotificationsPopup();
    }

    // Check if user tried to mislead the game
    if (GameService.gameSkipped) {
      // Wait for 1 second to let the animations complete
      await Future.delayed(const Duration(seconds: 1));

      // Remove due coins
      context
          .read<GamicoUserCubit>()
          .decrementCowries(Gamico.instance.gameSettings.playMinimumCoins);

      // Come back to the initial state
      GameService.gameSkipped = false;
    }
  }

  /// Display a popup that asks to enable or disable notifications.
  void _showNotificationsPopup() {
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
                await AwesomeNotifications()
                    .requestPermissionToSendNotifications();

                NotificationService.scheduleNotificationsIfAllowed();
              }

              NotificationService.notificationsAccepted =
                  await NotificationService.allowed();
              NotificationService.notificationsSet = true;
            },
            onRejected: () {
              NotificationService.notificationsAccepted = false;
              NotificationService.notificationsSet = true;
            },
          ),
        );
      },
    );
  }

  /// Display a popup that asks the player to update the current game.
  void _showUpdatePopup() {
    final l = GamicoLanguages.of(context);

    final status = VersionService.status;

    if ((status != null && status.canUpdate) ||
        VersionService.localVersionDeprecated()) {
      if (status != null) {
        VersionService.storeVersion = status.storeVersion;
      }

      final forceUpdate =
          VersionService.forceUpdate(VersionService.storeVersion);

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
                StoreRedirect.redirect();
              },
            ),
          );
        },
      );
    }
  }
}
