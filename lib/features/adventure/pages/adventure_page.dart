import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/pop_scope.dart';
import 'package:gamico/commons/services/animation.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/features/adventure/cubits/adventure_cubit.dart';
import 'package:gamico/features/adventure/utilities/remote_utility.dart';
import 'package:gamico/features/adventure/utilities/adventure_utility.dart';

/// Page on which game levels are selected.
class GamicoAdventurePage extends StatefulWidget {
  final Widget Function(
    BuildContext context,
    PageController pageController,
  ) builder;

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

    pageController = PageController(
      viewportFraction: widget.viewportFraction ?? 1.0,
      initialPage: min(
        getChapterByLevel(widget.adventureUtility
            .getUserLevel(context.read<GamicoUserCubit>().state.user)),
        getChapterByLevel(widget.adventureUtility.maxLevel),
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

  @override
  Widget build(BuildContext context) {
    return BlocListener<GamicoUserCubit, GamicoUserState>(
      listener: (context, state) {
        final currentLevel = widget.adventureUtility.getUserLevel(state.user);

        if (currentLevel > widget.adventureUtility.maxLevel) return;

        final currentChapter = getChapterByLevel(currentLevel);

        if (pageController.page != currentChapter) {
          pageController.animateToPage(
            currentChapter,
            duration: AnimationService.animationDuration,
            curve: Curves.linear,
          );
        }
      },
      listenWhen: (previous, current) {
        final previousLevel =
            widget.adventureUtility.getUserLevel(previous.user);
        final currentLevel = widget.adventureUtility.getUserLevel(current.user);

        return previousLevel != currentLevel;
      },
      child: BlocProvider(
        lazy: false,
        create: (context) => GamicoAdventureCubit(
          adventureUtility: widget.adventureUtility,
          remoteUtility: widget.remoteUtility,
        )..init(),
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
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }
}
