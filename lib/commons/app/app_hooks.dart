import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/music/music_cubit.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/models/remote_utility.dart';
import 'package:gamico/commons/repositories/gamico_games_repository.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/services/notification.dart';
import 'package:gamico/commons/settings/matchmaking_settings.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/features/remote/cubits/remote_cubit.dart';

/// Configures global application hooks and handles lifecycle events.
class GamicoAppHooks {
  const GamicoAppHooks._();

  /// Registers global navigation popup sound effects and invitation notification handlers.
  static void setupGlobalHooks() {
    NavigationService.onPopupOpen = (ctx) {
      try {
        ctx.read<GamicoMusicCubit>().playPopupOpenBruitage();
      } catch (_) {}
    };

    NavigationService.onPopupClose = (ctx) {
      try {
        ctx.read<GamicoMusicCubit>().playPopupCloseBruitage();
      } catch (_) {}
    };

    NotificationService.onAcceptInvitation = (acceptContext, invitationId) {
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

      final remoteCubit = RemoteCubit(
        userCubit: acceptContext.read<GamicoUserCubit>(),
        gamesRepository: acceptContext.read<GamicoGamesRepository>(),
        remoteUtility: remoteUtility,
        level: null,
      );

      NavigationService.pushPageWithAnimation(
        acceptContext,
        BlocProvider.value(
          value: remoteCubit,
          child: Gamico.instance.pagesSettings.gamePage(
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
        ),
      );
    };
  }
}

/// A widget that observes the app lifecycle to perform maintenance tasks,
/// such as clearing stale notification badge counts when returning to foreground.
class GamicoLifecycleManager extends StatefulWidget {
  final Widget child;

  const GamicoLifecycleManager({super.key, required this.child});

  @override
  State<GamicoLifecycleManager> createState() => _GamicoLifecycleManagerState();
}

class _GamicoLifecycleManagerState extends State<GamicoLifecycleManager>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Clear any stale app-icon badge on launch.
    NotificationService.clearBadge();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.resumed) {
      NotificationService.clearBadge();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
