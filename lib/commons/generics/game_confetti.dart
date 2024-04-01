import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/generics/confetti.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';

class GamicoGameConfetti extends StatefulWidget {
  const GamicoGameConfetti({super.key});

  @override
  State<GamicoGameConfetti> createState() => _GamicoGameConfettiState();
}

class _GamicoGameConfettiState extends State<GamicoGameConfetti> {
  /// Custom controller to enable confettis when a game is over.
  final _confettiController = ConfettiController(duration: 10.seconds);

  @override
  void dispose() {
    // Dispose confetti controller
    _confettiController.dispose();

    // Call inherited method
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<GamicoGameCubit, GamicoGameState>(
      listener: (context, state) {
        if (state.victory == true) {
          _confettiController.play();
        }
      },
      listenWhen: (previous, current) {
        return current.over && !previous.over;
      },
      child: GamicoConfetti(controller: _confettiController),
    );
  }
}
