import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/features/home/cubits/home_cubit.dart';
import 'package:gamico/languages/languages.dart';

/// The page that welcomes the player.
class GamicoHomePage extends StatelessWidget {
  /// The widget that will be wrapped into this [GamicoHomePage].
  final Widget child;

  /// The page that welcomes the player.
  const GamicoHomePage({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      lazy: false,
      create: (context) =>
          GamicoHomeCubit(userCubit: context.read<GamicoUserCubit>())..init(),
      child: _GamicoHomePageContent(child: child),
    );
  }
}

class _GamicoHomePageContent extends StatelessWidget {
  final Widget child;

  const _GamicoHomePageContent({required this.child});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);
    final homeCubit = context.read<GamicoHomeCubit>();

    return MultiBlocListener(
      listeners: [
        BlocListener<GamicoHomeCubit, GamicoHomeState>(
          listener: (context, state) {
            homeCubit.setShowNotificationsPopup(false);

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
                    onAccepted: homeCubit.acceptNotifications,
                    onRejected: homeCubit.rejectNotifications,
                  ),
                );
              },
            );
          },
          listenWhen: (previous, current) =>
              !previous.showNotificationsPopup &&
              current.showNotificationsPopup,
        ),
        BlocListener<GamicoHomeCubit, GamicoHomeState>(
          listener: (context, state) {
            homeCubit.setShowNotificationsReminderPopup(false);

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
                    onAccepted: homeCubit.acceptNotificationsReminder,
                  ),
                );
              },
            );
          },
          listenWhen: (previous, current) =>
              !previous.showNotificationsReminderPopup &&
              current.showNotificationsReminderPopup,
        ),
        BlocListener<GamicoHomeCubit, GamicoHomeState>(
          listener: (context, state) {
            final forceUpdate = state.forceUpdate;
            homeCubit.setShowUpdatePopup(false);

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
                    onAccepted: homeCubit.openStore,
                  ),
                );
              },
            );
          },
          listenWhen: (previous, current) =>
              !previous.showUpdatePopup && current.showUpdatePopup,
        ),
      ],
      child: child,
    );
  }
}
