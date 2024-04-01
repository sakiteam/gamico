import 'package:flutter/material.dart';

class GamicoShowcaseWidget extends StatelessWidget {
  final Widget child;
  final String description;

  final double top;
  final double left;

  final double width;
  final double height;

  final BorderRadius? borderRadius;

  const GamicoShowcaseWidget({
    super.key,
    required this.child,
    required this.description,
    this.top = 0,
    this.left = 0,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return child;
  }
}
