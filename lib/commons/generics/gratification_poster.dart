import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/generics/coins_widget.dart';
import 'package:gamico/commons/services/timestamp.dart';
import 'package:gamico/commons/generics/disabler.dart';
import 'package:gamico/commons/cubits/gratification/gratification_cubit.dart';
import 'package:gamico/commons/cubits/internet/internet_cubit.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/services/notification.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/languages/languages.dart';

class GamicoGratificationPoster extends StatelessWidget {
  const GamicoGratificationPoster({super.key});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);
    return BlocBuilder<GratificationCubit, GratificationState>(
      builder: (_, gratificationState) {
        return BlocConsumer<InternetCubit, InternetState>(
          listener: (context, state) {
            if (state.connected) {
              context.read<GratificationCubit>().loadWorldDate();
            }
          },
          listenWhen: (previous, current) {
            return !previous.connected && current.connected;
          },
          builder: (_, state) {
            if (!state.connected) {
              return GamicoDialogPoster(
                icon: Icons.wifi_off,
                title: l.homeGratificationPopupConnectionErrorTitle,
                description: l.homeGratificationPopupConnectionErrorDescription,
                simple: true,
                acceptationIcon: Icons.close,
                acceptationText: l.globalClose,
              );
            }

            if (gratificationState.loading) {
              return GamicoPoster(
                icon: Icons.redeem,
                title: l.homeGratificationPopupLoadingTitle,
                description: l.homeGratificationPopupLoadingDescription,
                loading: true,
                padding: EdgeInsets.zero,
                expandContent: true,
              );
            }

            if (gratificationState.worldDateTimeDifference.inMinutes >= 5) {
              return GamicoDialogPoster(
                icon: Icons.schedule,
                title: l.homeGratificationPopupIncorrectTimestampTitle,
                description:
                    l.homeGratificationPopupIncorrectTimestampDescription,
                simple: true,
                acceptationIcon: Icons.close,
                acceptationText: l.globalClose,
              );
            }

            return BlocBuilder<GamicoUserCubit, GamicoUserState>(
              builder: (_, state) {
                final user = state.user!;

                int nextGratificationsCowries = user.nextGratification ??
                    GratificationCubit.hour1Gratification;

                if (gratificationState.durationDifference.inHours > 1) {
                  nextGratificationsCowries =
                      GratificationCubit.hour1Gratification;
                }

                const cowrieImage = CoinsWidget(
                  color: Colors.white,
                  outlined: false,
                  size: 50,
                );

                return GamicoPoster(
                  icon: Icons.redeem,
                  description: l.homeGratificationPopupInstructionDescription,
                  title: gratificationState.gratificationEnabled
                      ? l.homeGratificationPopupNextReward(
                          nextGratificationsCowries)
                      : TimestampService.getCountdownString(
                          TimestampService.durationToNextHour()),
                  expandContent: true,
                  content: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GamicoDisabler(
                        disabled: !(gratificationState.gratificationEnabled &&
                            nextGratificationsCowries ==
                                GratificationCubit.hour1Gratification),
                        child: GamicoIconTextButton(
                          iconWidget: cowrieImage,
                          onPressed: () {
                            _rewardUser(GratificationCubit.hour1Gratification,
                                GratificationCubit.hour2Gratification, context);
                          },
                          text: l.homeGratificationPopupHourReward(
                              GratificationCubit.hour1Gratification, 1),
                          color: nextGratificationsCowries ==
                                  GratificationCubit.hour1Gratification
                              ? ColorService.accentColor
                              : null,
                        ),
                      ),
                      GamicoDisabler(
                        disabled: !(gratificationState.gratificationEnabled &&
                            nextGratificationsCowries ==
                                GratificationCubit.hour2Gratification),
                        child: GamicoIconTextButton(
                          iconWidget: cowrieImage,
                          onPressed: () {
                            _rewardUser(GratificationCubit.hour2Gratification,
                                GratificationCubit.hour3Gratification, context);
                          },
                          text: l.homeGratificationPopupHourReward(
                              GratificationCubit.hour2Gratification, 2),
                          color: nextGratificationsCowries ==
                                  GratificationCubit.hour2Gratification
                              ? ColorService.accentColor
                              : null,
                        ),
                      ),
                      GamicoDisabler(
                        disabled: !(gratificationState.gratificationEnabled &&
                            nextGratificationsCowries ==
                                GratificationCubit.hour3Gratification),
                        child: GamicoIconTextButton(
                          iconWidget: cowrieImage,
                          onPressed: () {
                            _rewardUser(GratificationCubit.hour3Gratification,
                                GratificationCubit.hour1Gratification, context);
                          },
                          text: l.homeGratificationPopupHourReward(
                              GratificationCubit.hour3Gratification, 3),
                          color: nextGratificationsCowries ==
                                  GratificationCubit.hour3Gratification
                              ? ColorService.accentColor
                              : null,
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }

  void _rewardUser(int lastGratification, int nextGratification,
      BuildContext context) async {
    context
        .read<GamicoUserCubit>()
        .updateUserGratification(lastGratification, nextGratification);

    if (await AwesomeNotifications().isNotificationAllowed()) {
      NotificationService.scheduleReminder();
    }

    NavigationService.pop(context);
  }
}
