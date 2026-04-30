// import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GamicoScaler extends StatelessWidget {
  final Widget child;

  const GamicoScaler({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return child
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scaleXY(begin: 1, end: 1.125, duration: 1.seconds);
  }
}
