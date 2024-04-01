import 'package:flutter/material.dart';
import 'package:gamico/commons/services/math.dart';

class GamicoReversedGoldenRatio extends StatelessWidget {
  final Widget child;

  const GamicoReversedGoldenRatio({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: MathService.phiReversed,
      child: child,
    );
  }
}
