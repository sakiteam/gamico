import 'package:flutter/material.dart';

class GamicoDisabler extends StatelessWidget {
  final Widget? child;
  final bool disabled;
  final double opacity;

  const GamicoDisabler({
    super.key,
    this.child,
    this.opacity = 0.5,
    this.disabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: disabled,
      child: Opacity(
        opacity: disabled ? opacity : 1,
        child: child,
      ),
    );
  }
}
