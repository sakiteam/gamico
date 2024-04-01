import 'package:flutter/material.dart';
import 'package:gamico/commons/generics/tinter.dart';

class GamicoGreyTinter extends StatelessWidget {
  final Widget child;
  final bool enabled;

  const GamicoGreyTinter({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return GamicoTinter(
      color: Colors.grey,
      enabled: enabled,
      child: child,
    );
  }
}
