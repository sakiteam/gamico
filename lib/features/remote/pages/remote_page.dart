import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/pop_scope.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/features/adventure/utilities/adventure_utility.dart';
import 'package:gamico/features/adventure/utilities/remote_utility.dart';
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
  final RemoteUtility remoteUtility;
  final AdventureUtility? adventureGameUtility;
  final int? level;
  final String? senderId;
  final String? receiverId;

  const GamicoRemotePage({
    super.key,
    required this.child,
    required this.remoteUtility,
    required this.adventureGameUtility,
    required this.level,
    this.receiverId,
    this.senderId,
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
      remoteUtility: widget.remoteUtility,
      level: widget.level,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      remoteCubit.init();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);

    return BlocProvider(
      // lazy: false,
      create: (context) => remoteCubit,
      // RemoteCubit(
      //   userCubit: context.read<GamicoUserCubit>(),
      //   gamesRepository: context.read<GamicoGamesRepository>(),
      // )..init()
      child: MultiBlocListener(
        listeners: [
          BlocListener<RemoteCubit, RemoteState>(
            listener: (context, state) {
              NavigationService.showPopup(
                context: context,
                builder: (_) {
                  return GamicoPopup(
                    child: GamicoDialogPoster(
                      icon: Icons.wifi_off,
                      title: l.remoteConnexionProblemTitle,
                      description: l.remoteConnexionProblemDescription,
                      simple: true,
                      onAccepted: () {
                        context.read<RemoteCubit>().setInternetError(false);
                        Navigator.of(context).pop();
                      },
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

              final remoteUtility = widget.remoteUtility;

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
                      RemoteGameUtility(
                        level: remoteState.level,
                        gameId: remoteState.gameId,
                        fakeOpponent: remoteState.fakeOpponent,
                        remoteUtility: remoteUtility,
                        adventureUtility: widget.adventureGameUtility,
                        creatorOfCurrentGame: remoteState.creator!,
                        onBackButtonPressed: () async {
                          if (widget.remoteUtility.adventure) {
                            remoteCubit.setForcePop(true);
                            NavigationService.pop(context);
                          } else {
                            remoteCubit.setAnimGame(false);
                            await Future.delayed(
                              AnimationService.animationDuration,
                            );
                            remoteCubit.setAnimated(false);
                          }
                        },
                      ),
                    ),
                  ),
                );

                await Future.delayed(AnimationService.animationDuration);

                notifyPlayers();

                remoteCubit.setFinalized(true);
              }
            },
            listenWhen: (oldState, newState) {
              return oldState.status != RemoteGameStatus.success &&
                  newState.status == RemoteGameStatus.success;
            },
          ),
        ],
        child: Builder(
          builder: (context) {
            return GamicoPopScope(
              onWillPop: () async {
                final remoteCubit = context.read<RemoteCubit>();

                final enabled = remoteCubit.state.enabled;
                final forcePop = remoteCubit.state.forcePop;

                if (forcePop) return true;

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
          },
        ),
      ),
    );
  }

  void notifyPlayers() async {
    final l = GamicoLanguages.of(context);

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
}
