import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/cubits/user/user_cubit.dart';
import 'package:gamico/features/adventure/cubits/adventure_cubit.dart';

class AdventureChaptersPageView extends StatelessWidget {
  final PageController controller;
  final Widget Function(
    BuildContext context,
    int index,
    bool locked,
  ) itemBuilder;

  const AdventureChaptersPageView({
    super.key,
    required this.controller,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final adventureUtility = context.select(
        (GamicoAdventureCubit adventureCubit) =>
            adventureCubit.state.adventureUtility);
    final userLevel = context.select((GamicoUserCubit userCubit) =>
        adventureUtility.getUserLevel(userCubit.state.user));

    return PageView(
      controller: controller,
      children: [
        for (int i = 0; i < adventureUtility.chapters; i++)
          itemBuilder(
            context,
            i,
            userLevel < (i * adventureUtility.levelsPerChapter + 1),
          ),
      ],
    );
  }
}
