import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/gratification/gratification_cubit.dart';
import 'package:gamico/commons/cubits/internet/internet_cubit.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/generics/coins_widget.dart';
import 'package:gamico/commons/generics/dialog_poster.dart';
import 'package:gamico/commons/generics/disabler.dart';
import 'package:gamico/commons/generics/icon_text_button.dart';
import 'package:gamico/commons/generics/poster.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/services/notification.dart';
import 'package:gamico/commons/services/timestamp.dart';
import 'package:gamico/languages/languages.dart';

/// Declarative modal poster for hourly reward / gratification claim.
class GamicoGratificationPoster extends StatelessWidget {
  const GamicoGratificationPoster({super.key});

  @override
  Widget build(BuildContext context) {
    final l = GamicoLanguages.of(context);
    final isConnected = context.select((InternetCubit c) => c.state.connected);

    if (!isConnected) {
      return GamicoDialogPoster(
        icon: Icons.wifi_off,
        title: l.homeGratificationPopupConnectionErrorTitle,
        description: l.homeGratificationPopupConnectionErrorDescription,
        simple: true,
        acceptationIcon: Icons.close,
        acceptationText: l.globalClose,
      );
    }

    return BlocBuilder<GratificationCubit, GratificationState>(
      builder: (_, gratificationState) {
        if (gratificationState.loading) {
          return _buildLoadingPoster(l);
        }

        if (gratificationState.isClockDesynchronized) {
          return GamicoDialogPoster(
            icon: Icons.schedule,
            title: l.homeGratificationPopupIncorrectTimestampTitle,
            description: l.homeGratificationPopupIncorrectTimestampDescription,
            simple: true,
            acceptationIcon: Icons.close,
            acceptationText: l.globalClose,
          );
        }

        return BlocBuilder<GamicoUserCubit, GamicoUserState>(
          builder: (_, userState) {
            final user = userState.user;

            // The account can go back to null while this poster is on screen:
            // signOut, but also a transient token-refresh failure, which
            // reaches `authStateChanges` as a plain null and clears the
            // session (see GamicoAuthenticationCubit). Fall back to the
            // loading poster instead of dereferencing.
            if (user == null) {
              return _buildLoadingPoster(l);
            }

            final nextGratificationsCowries = gratificationState
                .calculateRewardCoins(user.nextGratification);

            const cowrieImage = CoinsWidget(
              color: Colors.white,
              outlined: false,
              size: 50,
            );

            return GamicoPoster(
              icon: Icons.redeem,
              description: (user.broke ?? false)
                  ? l.homeGratificationBrokeUserPopupInstructionDescription
                  : l.homeGratificationPopupInstructionDescription,
              title: gratificationState.gratificationEnabled
                  ? l.homeGratificationPopupNextReward(
                      nextGratificationsCowries,
                    )
                  : TimestampService.getCountdownString(
                      TimestampService.durationToNextHour(),
                    ),
              expandContent: true,
              content: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildRewardButton(
                    context: context,
                    cowrieImage: cowrieImage,
                    currentNext: nextGratificationsCowries,
                    targetGratification: GratificationCubit.hour1Gratification,
                    nextStepGratification:
                        GratificationCubit.hour2Gratification,
                    isEnabled: gratificationState.gratificationEnabled,
                    label: l.homeGratificationPopupHourReward(
                      GratificationCubit.hour1Gratification,
                      1,
                    ),
                  ),
                  _buildRewardButton(
                    context: context,
                    cowrieImage: cowrieImage,
                    currentNext: nextGratificationsCowries,
                    targetGratification: GratificationCubit.hour2Gratification,
                    nextStepGratification:
                        GratificationCubit.hour3Gratification,
                    isEnabled: gratificationState.gratificationEnabled,
                    label: l.homeGratificationPopupHourReward(
                      GratificationCubit.hour2Gratification,
                      2,
                    ),
                  ),
                  _buildRewardButton(
                    context: context,
                    cowrieImage: cowrieImage,
                    currentNext: nextGratificationsCowries,
                    targetGratification: GratificationCubit.hour3Gratification,
                    nextStepGratification:
                        GratificationCubit.hour1Gratification,
                    isEnabled: gratificationState.gratificationEnabled,
                    label: l.homeGratificationPopupHourReward(
                      GratificationCubit.hour3Gratification,
                      3,
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildLoadingPoster(GamicoLanguages l) {
    return GamicoPoster(
      icon: Icons.redeem,
      title: l.homeGratificationPopupLoadingTitle,
      description: l.homeGratificationPopupLoadingDescription,
      loading: true,
      padding: EdgeInsets.zero,
      expandContent: true,
    );
  }

  Widget _buildRewardButton({
    required BuildContext context,
    required Widget cowrieImage,
    required int currentNext,
    required int targetGratification,
    required int nextStepGratification,
    required bool isEnabled,
    required String label,
  }) {
    // Two different questions, and they used to share one answer: WHICH step
    // comes next (the colour) and whether it can be claimed right now (the
    // interactivity). Gating the colour on [isEnabled] too meant the whole
    // countdown was spent on three identical grey tiles — under a popup whose
    // own text promises a reward that grows hour after hour, the one thing it
    // was hiding was where the player had got to.
    //
    // The next step is therefore coloured whether it is claimable or not; the
    // dimming [GamicoDisabler] applies is what still says "not yet".
    final isNextStep = currentNext == targetGratification;
    final isClaimable = isEnabled && isNextStep;

    return GamicoDisabler(
      disabled: !isClaimable,
      child: GamicoIconTextButton(
        iconWidget: cowrieImage,
        onPressed: () =>
            _rewardUser(targetGratification, nextStepGratification, context),
        text: label,
        color: isNextStep ? ColorService.accentColor : null,
      ),
    );
  }

  void _rewardUser(
    int lastGratification,
    int nextGratification,
    BuildContext context,
  ) {
    context.read<GamicoUserCubit>().updateUserGratification(
      lastGratification,
      nextGratification,
    );

    // Closed before the reminder is scheduled, not after. This used to await
    // `isNotificationAllowed()` first, which put a plugin round-trip between
    // the tap and the pop — and awesome_notifications is slow on iOS by
    // construction (see [NotificationService.serialized]: its own scheduling
    // work is what the popup ended up queueing behind). Worse, an await here
    // means the widget can be gone by the time the pop runs, and
    // [NavigationService.pop] then bails on its `mounted` guard — leaving the
    // popup open for good.
    NavigationService.pop(context);

    // Fire and forget: [NotificationService.scheduleReminder] checks the
    // permission itself — which is what the awaited call above duplicated —
    // and swallows its own failures.
    unawaited(NotificationService.scheduleReminder());
  }
}
