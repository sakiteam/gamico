import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GamicoInfiniteRotater extends StatefulWidget {
  final Widget child;
  final Duration? duration;

  const GamicoInfiniteRotater({
    super.key,
    required this.child,
    this.duration,
  });

  @override
  State<GamicoInfiniteRotater> createState() => _GamicoInfiniteRotaterState();
}

class _GamicoInfiniteRotaterState extends State<GamicoInfiniteRotater>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (kDebugMode && Platform.isIOS) {
      _controller.loop(count: 2);
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, child) {
        return Transform.rotate(
          angle: _controller.value * 2 * pi,
          child: child,
        );
      },
      child: widget.child,
    );

    // return widget.child
    //     .animate(
    //       onPlay: kDebugMode && Platform.isIOS
    //           ? null
    //           : (controller) => controller.repeat(),
    //     )
    //     .rotate(
    //       duration: widget.duration,
    //     )
    // ;
  }
}
