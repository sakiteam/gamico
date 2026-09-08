part of 'home_cubit.dart';

@immutable
class GamicoHomeState {
  final bool showNotificationsPopup;
  final bool showNotificationsReminderPopup;
  final bool showUpdatePopup;
  final bool forceUpdate;
  final bool animInit;
  final bool animGame;
  final bool animHome;
  final bool animated;

  bool get enabled => !animated;

  const GamicoHomeState({
    this.showNotificationsPopup = false,
    this.showNotificationsReminderPopup = false,
    this.showUpdatePopup = false,
    this.forceUpdate = false,
    this.animInit = false,
    this.animGame = false,
    this.animHome = false,
    this.animated = false,
  });

  GamicoHomeState copyWith({
    bool? showNotificationsPopup,
    bool? showNotificationsReminderPopup,
    bool? showUpdatePopup,
    bool? forceUpdate,
    bool? animInit,
    bool? animGame,
    bool? animHome,
    bool? animated,
  }) {
    return GamicoHomeState(
      showNotificationsPopup:
          showNotificationsPopup ?? this.showNotificationsPopup,
      showNotificationsReminderPopup:
          showNotificationsReminderPopup ?? this.showNotificationsReminderPopup,
      showUpdatePopup: showUpdatePopup ?? this.showUpdatePopup,
      forceUpdate: forceUpdate ?? this.forceUpdate,
      animInit: animInit ?? this.animInit,
      animGame: animGame ?? this.animGame,
      animHome: animHome ?? this.animHome,
      animated: animated ?? this.animated,
    );
  }
}
