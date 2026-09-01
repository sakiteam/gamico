import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';

class GamicoGameStars extends StatelessWidget {
  const GamicoGameStars({super.key});

  @override
  Widget build(BuildContext context) {
    final realStars =
        context.select((GamicoGameCubit gameCubit) => gameCubit.state.stars);
    final animGame =
        context.select((GamicoGameCubit gameCubit) => gameCubit.state.animGame);
    final over =
        context.select((GamicoGameCubit gameCubit) => gameCubit.state.over);
    final victory =
        context.select((GamicoGameCubit gameCubit) => gameCubit.state.victory);

    final stars = !over || victory == true ? realStars : 0;

    return Align(
      alignment: Alignment.bottomCenter,
      child: SizedBox(
        width: 100 * 450 / 400,
        height: 15 * 450 / 400,
        child: Stack(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 3; i++)
                  Image.asset("assets/images/middle_star_placeholder.png"),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (int i = 1; i <= 3; i++)
                  Image.asset("assets/images/middle_star.png")
                      .animate(target: i > stars ? 1 : 0)
                      .fadeOut()
              ],
            ),
          ],
        ),
      )
          .animate(delay: 3.seconds)
          .fadeIn()
          // Game
          .animate(target: animGame ? 1 : 0)
          .fadeOut(),
    );
  }
}
