import 'dart:math';

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:gamico/commons/services/paint.dart';
import 'package:gamico/commons/generics/content_container.dart';

class GamicoConfetti extends StatelessWidget {
  static Path Function(Size size) pathBuilder = PaintService.getPath1;

  final ConfettiController controller;

  const GamicoConfetti({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return IgnorePointer(
      child: GamicoContentContainer(
        characterAnimation: false,
        safeChild: Align(
          alignment: Alignment.topCenter,
          child: Transform.translate(
            offset: Offset(0, -max(topPadding, bottomPadding) - 20),
            child: ConfettiWidget(
              confettiController: controller,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: true,
              numberOfParticles: 20,
              colors: const [
                Colors.red,
                Colors.orange,
                Colors.amber,
                Colors.green,
                Colors.blue,
                Colors.indigo,
                Colors.purple,
              ],
              createParticlePath: pathBuilder,
            ),
          ),
        ),
      ),
    );
  }
}
