import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/pop_scope.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/animation.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/commons/utilities/game/game_utility.dart';
import 'package:gamico/features/adventure/cubits/adventure_cubit.dart';
import 'package:gamico/commons/models/remote_utility.dart';
import 'package:gamico/commons/models/adventure_utility.dart';

/// Page on which game levels are selected.
class GamicoAdventurePage extends StatefulWidget {
  final Widget Function(BuildContext context, PageController pageController)
  builder;

  final AdventureUtility adventureUtility;
  final RemoteUtility? remoteUtility;

  final double? viewportFraction;

  /// Page on which game levels are selected.
  const GamicoAdventurePage({
    super.key,
    required this.builder,
    required this.adventureUtility,
    required this.remoteUtility,
    this.viewportFraction,
  });

  @override
  State<GamicoAdventurePage> createState() => _GamicoAdventurePageState();
}

class _GamicoAdventurePageState extends State<GamicoAdventurePage> {
  late final PageController pageController;

  @override
  void initState() {
    super.initState();

    final user = context.read<GamicoUserCubit>().state.user;
    final userLevel = widget.adventureUtility.getUserLevel(user);
    final currentChapter = getChapterByLevel(userLevel);

    final relativeChapter = widget.adventureUtility.reversed
        ? (widget.adventureUtility.endChapter - 1) - currentChapter
        : currentChapter - widget.adventureUtility.startChapter;

    pageController = PageController(
      viewportFraction: widget.viewportFraction ?? 1.0,
      initialPage: relativeChapter.clamp(
        0,
        widget.adventureUtility.endChapter -
            widget.adventureUtility.startChapter -
            1,
      ),
    );
  }

  int getChapterByLevel(int level) {
    return ((level - 1) / widget.adventureUtility.levelsPerChapter).floor();
  }

  /// Manage back.
  Future<bool> _manageBack(BuildContext context) async {
    final adventureCubit = context.read<GamicoAdventureCubit>();

    // Enable back when page is enabled
    if (adventureCubit.state.enabled) {
      adventureCubit.setAnimInit(false);
      adventureCubit.setAnimated(true);

      // Wait for transition to be performed
      await Future.delayed(AnimationService.animationDuration);

      // Stop animation
      adventureCubit.setAnimated(false);

      // Enable back
      return true;
    }

    // Disable back when page is disabled
    return false;
  }

  late final adventureCubit = GamicoAdventureCubit(
    adventureUtility: widget.adventureUtility,
    remoteUtility: widget.remoteUtility,
  )..init();

  @override
  void didUpdateWidget(covariant GamicoAdventurePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.remoteUtility != widget.remoteUtility) {
      adventureCubit.setRemoteUtility(widget.remoteUtility);
    }

    if (oldWidget.adventureUtility != widget.adventureUtility) {
      adventureCubit.setAdventureUtility(widget.adventureUtility);

      if (pageController.hasClients) {
        final isNormalToReverse =
            oldWidget.adventureUtility.startChapter == 0 &&
            widget.adventureUtility.startChapter == 20;
        final isReverseToNormal =
            oldWidget.adventureUtility.startChapter == 20 &&
            widget.adventureUtility.startChapter == 0;

        if (isNormalToReverse || isReverseToNormal) {
          final oldPage = pageController.page?.round() ?? 0;
          final chaptersCount =
              widget.adventureUtility.endChapter -
              widget.adventureUtility.startChapter;
          final newPage = (chaptersCount - 1) - oldPage;

          pageController.jumpToPage(newPage.clamp(0, chaptersCount - 1));
          return;
        }

        final user = context.read<GamicoUserCubit>().state.user;
        final userLevel = widget.adventureUtility.getUserLevel(user);
        final currentChapter = getChapterByLevel(userLevel);
        final relativeChapter = widget.adventureUtility.reversed
            ? (widget.adventureUtility.endChapter - 1) - currentChapter
            : currentChapter - widget.adventureUtility.startChapter;

        pageController.animateToPage(
          relativeChapter.clamp(
            0,
            widget.adventureUtility.endChapter -
                widget.adventureUtility.startChapter -
                1,
          ),
          duration: AnimationService.animationDuration,
          curve: Curves.easeOutCubic,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GamicoUserCubit, GamicoUserState>(
      listener: (context, state) {
        final currentLevel = widget.adventureUtility.getUserLevel(state.user);

        if (currentLevel > widget.adventureUtility.maxLevel) return;

        final currentChapter = getChapterByLevel(currentLevel);
        final relativeChapter = widget.adventureUtility.reversed
            ? (widget.adventureUtility.endChapter - 1) - currentChapter
            : currentChapter - widget.adventureUtility.startChapter;

        if (pageController.hasClients &&
            pageController.page?.round() != relativeChapter) {
          pageController.animateToPage(
            relativeChapter,
            duration: AnimationService.animationDuration,
            curve: Curves.linear,
          );
        }
      },
      listenWhen: (previous, current) {
        final previousLevel = widget.adventureUtility.getUserLevel(
          previous.user,
        );

        final currentLevel = widget.adventureUtility.getUserLevel(current.user);

        return previousLevel != currentLevel;
      },
      child: BlocProvider.value(
        // lazy: false,
        value: adventureCubit,
        child: BlocListener<GamicoAdventureCubit, GamicoAdventureState>(
          listener: (context, state) async {
            final adventureCubit = context.read<GamicoAdventureCubit>();
            final adventureUtility = adventureCubit.state.adventureUtility;
            // final remoteUtility = adventureCubit.state.remoteUtility;

            final user = context.read<GamicoUserCubit>().state.user;
            final userLevel = adventureUtility.getUserLevel(user);
            final nextLevel = state.nextLevelToPlay ?? userLevel;

            adventureCubit.setNextLevelActive(false);

            void onBackButtonPressed() async {
              adventureCubit.setAnimGame(false);
              await Future.delayed(AnimationService.animationDuration);
              adventureCubit.setAnimated(false);
            }

            adventureCubit.setAnimGame(true);
            adventureCubit.setAnimated(true);

            if (widget.remoteUtility != null) {
              final playNextLevel =
                  await NavigationService.pushPageWithAnimation<String>(
                    context,
                    Gamico.instance.pagesSettings.remotePage(
                      context,
                      widget.remoteUtility!,
                      adventureUtility,
                      nextLevel,
                    ),
                  );

              onBackButtonPressed();

              if (playNextLevel == "NEXT_LEVEL") {
                adventureCubit.setNextLevelToPlay(nextLevel + 1);
                adventureCubit.setNextLevelActive(true);
              } else if (playNextLevel == "SAME_LEVEL") {
                adventureCubit.setNextLevelToPlay(nextLevel);
                adventureCubit.setNextLevelActive(true);
              }
            } else {
              NavigationService.pushPageWithAnimation(
                context,
                Gamico.instance.pagesSettings.gamePage(
                  context,
                  AdventureGameUtility(
                    level: nextLevel,
                    onBackButtonPressed: onBackButtonPressed,
                    adventureUtility: adventureUtility,
                    remoteUtility: null,
                  ),
                ),
              );
            }
          },
          listenWhen: (previous, current) {
            return !previous.nextLevelActive && current.nextLevelActive;
          },
          child: BlocBuilder<GamicoAdventureCubit, GamicoAdventureState>(
            builder: (context, adventureState) {
              return GamicoPopScope(
                onWillPop: () => _manageBack(context),
                child: AbsorbPointer(
                  // Activation
                  absorbing: !adventureState.enabled,

                  // Concrete content
                  child: widget.builder(context, pageController),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    adventureCubit.close();
    super.dispose();
  }
}
