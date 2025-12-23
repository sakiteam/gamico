import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/page_indicator.dart';
import 'package:gamico/features/adventure/cubits/adventure_cubit.dart';

class AdventurePageIndicator extends StatelessWidget {
  final PageController controller;

  const AdventurePageIndicator({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final chapters = context.select(
      (GamicoAdventureCubit adventureCubit) =>
          adventureCubit.state.adventureUtility.chapters,
    );

    return GamicoPageIndicator(
      controller: controller,
      count: chapters,
      color: Colors.white,
      indicatorSize: 12 * 450 / 400,
    );
  }
}
