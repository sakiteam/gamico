import 'package:flutter/material.dart';
import 'package:gamico/commons/services/color.dart';

class GamicoTinter extends StatelessWidget {
  final Widget child;
  final bool enabled;
  final Color color;

  const GamicoTinter({
    super.key,
    required this.child,
    this.enabled = true,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    if (enabled) {
      return ColorFiltered(
        colorFilter: ColorService.tintMatrix(color: color),
        child: child,
      );
    }

    return child;
  }
}
