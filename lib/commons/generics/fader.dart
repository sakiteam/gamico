import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GamicoFader extends StatelessWidget {
  final Widget child;
  final Duration? delay;
  final bool enabled;

  const GamicoFader({
    super.key,
    required this.child,
    this.delay,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(
          target: enabled ? 1 : 0,
        )
        .then(delay: delay)
        .fadeIn()
        .moveY(
          begin: 16,
          end: 0,
        );
  }
}
