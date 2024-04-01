import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GamicoGamePopupStarsScaler extends StatelessWidget {
  final int index;
  final Widget child;
  final int stars;

  const GamicoGamePopupStarsScaler({
    super.key,
    required this.child,
    required this.index,
    required this.stars,
  });

  @override
  Widget build(BuildContext context) {
    final List<int> delays;

    if (stars == 1) {
      delays = [0, 1, 0];
    } else if (stars == 2) {
      delays = [1, 0, 3];
    } else {
      delays = [1, 5, 3];
    }

    final delay = delays[index];

    return child
        .animate()
        .scaleXY(
          begin: 2,
          end: 0.95,
          curve: Curves.easeOutBack,
          duration: 0.5.seconds,
          delay: (delay / 3).seconds,
        )
        .fadeIn();
  }
}
