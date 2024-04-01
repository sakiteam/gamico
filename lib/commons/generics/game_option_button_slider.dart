import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/services/user.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';

class GamicoGameOptionButtonSlider extends StatelessWidget {
  final Widget child;
  final Offset offset;

  const GamicoGameOptionButtonSlider({
    super.key,
    required this.child,
    required this.offset,
  });

  @override
  Widget build(BuildContext context) {
    final over =
        context.select((GamicoGameCubit gameCubit) => gameCubit.state.over);
    final animInit =
        context.select((GamicoGameCubit gameCubit) => gameCubit.state.animInit);

    final optionEnabled = !animInit || over;

    if (GameService.tutorialPassed && UserService.authenticated) {
      return child
          .animate(target: optionEnabled ? 0 : 1)
          .move(begin: Offset.zero, end: offset);
    }

    return const SizedBox();
  }
}
