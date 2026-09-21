import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/services/notification.dart';
import 'package:gamico/commons/services/play.dart';
import 'package:gamico/commons/services/store.dart';
import 'package:gamico/commons/services/version.dart';

part 'home_state.dart';

class GamicoHomeCubit extends Cubit<GamicoHomeState> {
  final GamicoUserCubit userCubit;

  GamicoHomeCubit({required this.userCubit}) : super(const GamicoHomeState());

  @override
  void emit(GamicoHomeState state) {
    if (isClosed) return;
    super.emit(state);
  }

  void setAnimInit(bool animInit) {
    emit(state.copyWith(animInit: animInit));
  }

  void setAnimGame(bool animGame) {
    emit(state.copyWith(animGame: animGame));
  }

  void setAnimHome(bool animHome) {
    emit(state.copyWith(animHome: animHome));
  }

  void setAnimated(bool animated) {
    emit(state.copyWith(animated: animated));
  }

  void setShowNotificationsPopup(bool show) {
    emit(state.copyWith(showNotificationsPopup: show));
  }

  void setShowNotificationsReminderPopup(bool show) {
    emit(state.copyWith(showNotificationsReminderPopup: show));
  }

  void setShowUpdatePopup(bool show, {bool forceUpdate = false}) {
    emit(state.copyWith(showUpdatePopup: show, forceUpdate: forceUpdate));
  }

  /// Init the home flow.
  Future<void> init() async {
    // The home page is painted: the startup rush is over and it is now safe to
    // let GameKit put its "Welcome back" banner on the main thread.
    PlayService.notifyHomeReady();

    // The persisted answers may belong to a previous installation restored by
    // Android Auto Backup / iCloud, in which case they are cleared here and
    // the first-launch prompt below runs again.
    await NotificationService.reconcileInstallation();

    // Route the player through the right notification flow.
    if (!NotificationService.notificationsSet) {
      // First launch: ask whether notifications should be enabled.
      setShowNotificationsPopup(true);
    } else if (!NotificationService.notificationsReminderShown &&
        !(await NotificationService.allowed())) {
      // The player already went through the flow but notifications are still
      // disabled — either they declined our first prompt, denied the native
      // permission, or revoked it later. Encourage them to enable it, but only
      // once: if they decline the reminder too, we don't nag them again.
      NotificationService.notificationsReminderShown = true;
      setShowNotificationsReminderPopup(true);
    } else {
      // Notifications are enabled: proceed with the normal home flow.
      // Display a popup that asks the player to update the current game if needed.
      checkUpdate();

      // Schedule notifications if they are allowed
      NotificationService.init();
      NotificationService.scheduleNotificationsIfAllowed();
    }

    // Check if user tried to mislead the game
    if (GameService.gameSkipped) {
      // Wait for 1 second to let the animations complete
      await Future.delayed(const Duration(seconds: 1));

      // Remove due coins
      userCubit.decrementCoins(Gamico.instance.gameSettings.playMinimumCoins);

      // Come back to the initial state
      GameService.gameSkipped = false;
    }
  }

  /// Shows the update popup when the remote config announces a newer version
  /// than this build's and turns the popup on. Non-dismissible when the update
  /// is flagged urgent. Does nothing until the remote config is filled in.
  void checkUpdate() {
    if (VersionService.shouldShowUpdatePopup()) {
      setShowUpdatePopup(true, forceUpdate: VersionService.forceUpdate());
    }
  }

  /// Accept notifications on the initial prompt.
  Future<void> acceptNotifications() async {
    if (!(await AwesomeNotifications().isNotificationAllowed())) {
      await AwesomeNotifications().requestPermissionToSendNotifications();

      // Only now do we know the native dialog actually resolved —
      // remember it so a later reminder knows the OS dialog has
      // already been used. Setting this before the await would mark
      // it "used" even if the request got interrupted (e.g. the app
      // backgrounded or the process died before the OS dialog could
      // be answered), permanently blocking the reminder flow from
      // ever re-presenting the real native prompt.
      NotificationService.notificationsRequested = true;

      NotificationService.init();
      NotificationService.scheduleNotificationsIfAllowed();
    }

    NotificationService.notificationsAccepted =
        await NotificationService.allowed();
    NotificationService.notificationsSet = true;

    // Tie the answer to this installation, so a backup restoring it onto a
    // fresh install is detected instead of silently trusted.
    await NotificationService.rememberInstallToken();
  }

  /// Reject notifications on the initial prompt.
  Future<void> rejectNotifications() async {
    // The player declined our prompt: the native dialog was never
    // shown, so `notificationsRequested` stays false.
    NotificationService.notificationsAccepted = false;
    NotificationService.notificationsSet = true;

    await NotificationService.rememberInstallToken();
  }

  /// Accept notifications on the reminder prompt.
  Future<void> acceptNotificationsReminder() async {
    if (NotificationService.notificationsRequested) {
      // Native dialog already used and denied: the OS won't present
      // it again, so send the player to the app's notification
      // settings to grant the permission manually.
      await AwesomeNotifications().showNotificationConfigPage();
    } else {
      // The native dialog was never shown — present it now.
      await AwesomeNotifications().requestPermissionToSendNotifications();

      // See the equivalent comment in acceptNotifications: only
      // mark the dialog "used" once we know it actually resolved.
      NotificationService.notificationsRequested = true;
    }

    NotificationService.notificationsAccepted =
        await NotificationService.allowed();

    // Start listening / scheduling as soon as we're granted.
    if (NotificationService.notificationsAccepted) {
      NotificationService.init();
      NotificationService.scheduleNotificationsIfAllowed();
    }

    await NotificationService.rememberInstallToken();
  }

  /// Open the app store page.
  void openStore() {
    StoreService.openStorePage();
  }
}
