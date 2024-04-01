import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/enums/game_type.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/languages/languages.dart';
import 'package:gamico/commons/services/animation.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/generics/gamico_popup.dart';
import 'package:gamico/commons/services/notification.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/features/remote/cubits/remote_cubit.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:gamico/commons/repositories/gamico_games_repository.dart';

class GamicoRemotePage extends StatefulWidget {
  final Widget child;

  const GamicoRemotePage({
    super.key,
    required this.child,
  });

  @override
  State<GamicoRemotePage> createState() => _GamicoRemotePageState();
}

class _GamicoRemotePageState extends State<GamicoRemotePage> {
  late final RemoteCubit remoteCubit;

  @override
  void initState() {
    super.initState();

    remoteCubit = RemoteCubit(
      userCubit: context.read<GamicoUserCubit>(),
      gamesRepository: context.read<GamicoGamesRepository>(),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      remoteCubit.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return BlocProvider(
      // lazy: false,
      create: (context) => remoteCubit

      // RemoteCubit(
      //   userCubit: context.read<GamicoUserCubit>(),
      //   gamesRepository: context.read<GamicoGamesRepository>(),
      // )..init()

      ,
      child: MultiBlocListener(
        listeners: [
          BlocListener<RemoteCubit, RemoteState>(
            listener: (context, state) {
              context.read<RemoteCubit>().setInternetError(false);

              NavigationService.showPopup(
                context: context,
                builder: (_) {
                  return GamicoPopup(
                    child: GamicoDialogPoster(
                      icon: Icons.wifi_off,
                      title: l.remoteConnexionProblemTitle,
                      description: l.remoteConnexionProblemDescription,
                      simple: true,
                    ),
                  );
                },
              );
            },
            listenWhen: (previous, current) {
              return !previous.internetError && current.internetError;
            },
          ),
          BlocListener<RemoteCubit, RemoteState>(
            listener: (context, remoteState) async {
              final remoteCubit = context.read<RemoteCubit>();

              if (remoteState.enabled) {
                remoteCubit.setAnimGame(true);
                remoteCubit.setAnimated(true);

                NavigationService.closePopups();

                NavigationService.pushPageWithAnimation(
                  context,
                  BlocProvider.value(
                    value: remoteCubit,
                    child: Gamico.instance.pagesSettings.gamePage(
                      context,
                      GameUtility(
                        gameId: remoteState.gameId,
                        fakeOpponent: remoteState.fakeOpponent,
                        gameType: GameType.remote,
                        onBackButtonPressed: () async {
                          remoteCubit.setAnimGame(false);

                          await Future.delayed(
                              AnimationService.animationDuration);

                          remoteCubit.setAnimated(false);
                        },
                      ),
                    ),
                  ),
                );

                await Future.delayed(AnimationService.animationDuration);

                remoteCubit.setFinalized(true);

                if (await NotificationService.allowed()) {
                  AwesomeNotifications().createNotification(
                    content: NotificationContent(
                      id: 2,
                      channelKey: "default",
                      title: l.remoteInvitationTitle,
                      body: l.remoteInvitationDescription,
                      wakeUpScreen: true,
                      displayOnForeground: false,
                      category: NotificationCategory.Alarm,
                    ),
                  );
                }
              }
            },
            listenWhen: (oldState, newState) {
              return oldState.status != RemoteGameStatus.success &&
                  newState.status == RemoteGameStatus.success;
            },
          ),
        ],
        child: Builder(builder: (context) {
          final enabled = context
              .select((RemoteCubit remoteCubit) => remoteCubit.state.enabled);

          return WillPopScope(
            onWillPop: () async {
              // Enable back when page is enabled
              if (enabled) {
                final remoteCubit = context.read<RemoteCubit>();

                remoteCubit.setAnimInit(false);
                remoteCubit.setAnimated(true);

                // Wait for transition to be performed
                await Future.delayed(AnimationService.animationDuration);

                // Stop animation
                remoteCubit.setAnimated(false);

                // Enable back
                return true;
              }

              // Disable back when page is disabled
              return false;
            },
            child: widget.child,
          );
        }),
      ),
    );
  }
}
