import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/animation.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/features/adventure/cubits/adventure_cubit.dart';

/// Adventure level button.
class AdventureLevelButton extends StatelessWidget {
  final int level;
  final PageController pageController;

  final Widget Function(
    BuildContext context,
    bool active,
    bool locked,
    int stars,
    void Function() pushGamePage,
  )
  builder;

  /// Adventure level button.
  const AdventureLevelButton({
    super.key,
    required this.level,
    required this.builder,
    required this.pageController,
  });

  @override
  Widget build(BuildContext context) {
    final adventureUtility = context.select(
      (GamicoAdventureCubit adventureCubit) =>
          adventureCubit.state.adventureUtility,
    );

    // Retrieve the level of the current user
    final userLevel = context.select(
      (GamicoUserCubit userCubit) =>
          adventureUtility.getUserLevel(userCubit.state.user),
    );

    // Retrieve the stars of the current user
    final stars = context.select(
      (GamicoUserCubit userCubit) =>
          adventureUtility.getUserStars(userCubit.state.user),
    );

    // Retrieve the stars of the current level
    final currentLevelStars = stars.elementAtOrNull(level) ?? 0;

    // Holds whether this level is locked or not
    final locked = userLevel < level;

    // Holds whether this level is active or not
    final active = userLevel == level;

    // Return concrete widget
    return builder(
      context,
      active,
      locked,
      currentLevelStars,
      () => _onPressed(context),
    );
  }

  /// Callback for when the current back button is pressed.
  void _onPressed(BuildContext context) async {
    final adventureUtility = context
        .read<GamicoAdventureCubit>()
        .state
        .adventureUtility;
    final remoteUtility = context
        .read<GamicoAdventureCubit>()
        .state
        .remoteUtility;

    // Reference to the user data
    final user = context.read<GamicoUserCubit>().state.user;

    // Current user level
    final userLevel = adventureUtility.getUserLevel(user);

    final currentChapter = ((level - 1) / adventureUtility.levelsPerChapter)
        .floor();

    if (pageController.page != currentChapter) {
      await pageController.animateToPage(
        currentChapter,
        duration: AnimationService.animationDuration,
        curve: Curves.linear,
      );
    }

    // Check whether the user has enough coins to play or not
    if (adventureUtility.isUserBroke(user) && level == userLevel) {
      // Show unsufficient coins popup
      NavigationService.showCowriesPopup(
        context,
        Gamico.instance.gameSettings.playMinimumCoins,
      );
    } else {
      final adventureCubit = context.read<GamicoAdventureCubit>();

      void onBackButtonPressed() async {
        adventureCubit.setAnimGame(false);
        await Future.delayed(AnimationService.animationDuration);
        adventureCubit.setAnimated(false);
      }

      // Enable push when page is enabled
      if (adventureCubit.state.enabled) {
        // Toggle transition utilities
        adventureCubit.setAnimGame(true);
        adventureCubit.setAnimated(true);

        if (remoteUtility != null) {
          // Push remote page
          final playNextLevel =
              await NavigationService.pushPageWithAnimation<String>(
                context,
                Gamico.instance.pagesSettings.remotePage(
                  context,
                  remoteUtility,
                  adventureUtility,
                  level,
                ),
              );

          onBackButtonPressed();

          if (playNextLevel == "NEXT_LEVEL") {
            adventureCubit.setNextLevelToPlay(level + 1);
            adventureCubit.setNextLevelActive(true);
          } else if (playNextLevel == "SAME_LEVEL") {
            adventureCubit.setNextLevelToPlay(level);
            adventureCubit.setNextLevelActive(true);
          }
        } else {
          // Push game page
          NavigationService.pushPageWithAnimation(
            context,
            Gamico.instance.pagesSettings.gamePage(
              context,
              AdventureGameUtility(
                level: level,
                onBackButtonPressed: onBackButtonPressed,
                adventureUtility: adventureUtility,
                remoteUtility: null,
              ),
            ),
          );
        }
      }
    }
  }
}
