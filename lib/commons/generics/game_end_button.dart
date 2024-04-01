import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/services/navigation.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/commons/generics/game_passed_tutorial_popup.dart';

class GamicoGameEndButton extends StatelessWidget {
  final Widget Function(BuildContext context, void Function() onPressed)
      builder;

  const GamicoGameEndButton({
    super.key,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      () {
        final gamicoGameCubit = context.read<GamicoGameCubit>();

        if (gamicoGameCubit.state.tutorial) {
          NavigationService.showPopup(
            context: context,
            builder: (_) {
              return BlocProvider.value(
                value: gamicoGameCubit,
                child: const GamicoGamePassedTutorialPopup(),
              );
            },
          );
        } else {
          gamicoGameCubit.setDisplayGamePopup(true);
        }
      },
    );
  }
}
