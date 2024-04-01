import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GamicoShaker extends StatefulWidget {
  final Widget child;

  const GamicoShaker({
    super.key,
    required this.child,
  });

  @override
  State<GamicoShaker> createState() => _GamicoShakerState();
}

class _GamicoShakerState extends State<GamicoShaker>
    with SingleTickerProviderStateMixin {
  late final AnimationController animationController;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (!animationController.isAnimating) {
          animationController.reset();
          animationController.forward();
        }
      },
      child: widget.child
          .animate(
            controller: animationController,
          )
          .shake(
            duration: 1.seconds,
            hz: 2,
          ),
    );
  }
}
