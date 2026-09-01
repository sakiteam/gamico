import 'package:flutter/material.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/features/home/widgets/home_help_popup.dart';

class GamicoHelpButton extends StatelessWidget {
  final Widget Function(BuildContext context, void Function() onPressed)
      builder;

  const GamicoHelpButton({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, () {
      NavigationService.showPopup(
        context: context,
        builder: (_) {
          return HomeHelpPopup(
            onLessonPressed: (lesson) async {
              // final homeCubit = context.read<HomeCubit>();

              // homeCubit.setAnimGame(true);
              // homeCubit.setAnimated(true);

              // await NavigationService.pushPageWithAnimation(
              //   context,
              //   GamicoGamePage(
              //     level: 0,
              //     onBackButtonPressed: () async {
              //       // homeCubit.setAnimGame(false);

              //       // await Future.delayed(AnimationService.animationDuration);

              //       // homeCubit.setAnimated(false);
              //     },
              //     tutorialLessonIndex: lesson,
              //   ),
              // );
            },
          );
        },
      );
    });
  }
}
