import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/features/game/widgets/game_popup_stars_scaler.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';

class GamePopupStars extends StatelessWidget {
  const GamePopupStars({super.key});

  @override
  Widget build(BuildContext context) {
    final stars = context.select(
      (GamicoGameCubit gameCubit) => gameCubit.state.stars,
    );

    return Container(
      height: 100,
      alignment: Alignment.center,
      // color: Colors.red,
      padding: const EdgeInsets.only(top: 16),
      child: OverflowBox(
        maxWidth: double.infinity,
        maxHeight: double.infinity,
        child: Transform.translate(
          offset: Offset(0, 10),
          child: Stack(
            children: [
              Image.asset(
                "assets/images/victory_black_ribbon.png",
                width: 350 + 10,
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 15,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/images/left_star_placeholder.png",
                      width: 50,
                      fit: BoxFit.fill,
                    ),
                    Transform.translate(
                      offset: const Offset(0, -6),
                      child: Image.asset(
                        "assets/images/middle_star_placeholder.png",
                        width: 60,
                        fit: BoxFit.fill,
                      ),
                    ),
                    Image.asset(
                      "assets/images/right_star_placeholder.png",
                      width: 50,
                      fit: BoxFit.fill,
                    ),
                  ],
                ),
              ),
              Positioned(
                left: 0,
                right: 0,
                top: 15 + 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (stars >= 2)
                      GamicoGamePopupStarsScaler(
                        index: 0,
                        stars: stars,
                        child: Image.asset(
                          "assets/images/good_left_star.png",
                          width: 50,
                          fit: BoxFit.fill,
                        ),
                      )
                    else
                      const SizedBox(width: 50),
                    if (stars == 1 || stars == 3)
                      GamicoGamePopupStarsScaler(
                        index: 1,
                        stars: stars,
                        child: Transform.translate(
                          offset: const Offset(0, -6),
                          child: Image.asset(
                            "assets/images/good_middle_star.png",
                            width: 60,
                            fit: BoxFit.fill,
                          ),
                        ),
                      )
                    else
                      const SizedBox(width: 60),
                    if (stars >= 2)
                      GamicoGamePopupStarsScaler(
                        index: 2,
                        stars: stars,
                        child: Image.asset(
                          "assets/images/good_right_star.png",
                          width: 50,
                          fit: BoxFit.fill,
                        ),
                      )
                    else
                      const SizedBox(width: 50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
