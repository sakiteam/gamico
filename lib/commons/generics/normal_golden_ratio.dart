import 'package:flutter/material.dart';
import 'package:gamico/commons/services/math.dart';

class GamicoNormalGoldenRatio extends StatelessWidget {
  final Widget child;

  const GamicoNormalGoldenRatio({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: MathService.phi,
      child: child,
    );
  }
}
