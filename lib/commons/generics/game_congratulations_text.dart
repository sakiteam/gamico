import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamico/commons/generics/content_container.dart';
import 'package:gamico/commons/generics/outlined_text.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';

const fontSize = 40.0;
const color = Colors.orange;

class GamicoGameCongratulationsText extends StatefulWidget {
  const GamicoGameCongratulationsText({
    super.key,
  });

  static Duration animationDuration = 1.seconds;

  @override
  State<GamicoGameCongratulationsText> createState() =>
      _GamicoGameCongratulationsTextState();
}

class _GamicoGameCongratulationsTextState
    extends State<GamicoGameCongratulationsText>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation _opacityAnimation;

  String text = "";

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: GamicoGameCongratulationsText.animationDuration,
    );

    _opacityAnimation = TweenSequence([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0),
        weight: 1,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 3,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0),
        weight: 1,
      ),
    ]).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: GamicoContentContainer(
        characterAnimation: false,
        child: BlocListener<GamicoGameCubit, GamicoGameState>(
          listenWhen: (previous, current) {
            return previous.message?.text != current.message?.text;
          },
          listener: (context, state) {
            text = state.message?.text.toUpperCase() ?? "";

            _animationController.reset();
            _animationController.stop();
            _animationController.forward();
          },
          child: IgnorePointer(
            child: Center(
              child: AnimatedBuilder(
                animation: _opacityAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _opacityAnimation.value,
                    child: Container(
                      height: 80,
                      alignment: Alignment.center,
                      child: Stack(
                        children: [
                          GamicoOutlinedText(
                            text,
                            strokeColor: Colors.brown,
                            strokeWidth: 2.5,
                            style: const TextStyle(
                              fontSize: fontSize,
                              color: color,
                              fontWeight: FontWeight.bold,
                              shadows: [
                                Shadow(
                                  offset: Offset(-0, -0.5),
                                  blurRadius: 0,
                                  color: Colors.brown,
                                ),
                                Shadow(
                                  offset: Offset(0, 4),
                                  blurRadius: 0,
                                  color: Colors.brown,
                                ),
                              ],
                            ),
                          ),
                          GamicoOutlinedText(
                            text,
                            strokeColor: Colors.brown,
                            style: const TextStyle(
                              fontSize: fontSize,
                              color: color,
                            ),
                          ),
                        ],
                      ),
                    )
                        .animate(
                          controller: _animationController,
                        )
                        .slideY(
                          begin: 0.25,
                          end: -0.25,
                          duration:
                              GamicoGameCongratulationsText.animationDuration,
                        ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
