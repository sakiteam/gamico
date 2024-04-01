import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GamicoShimmer extends StatelessWidget {
  final Widget child;

  const GamicoShimmer({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return child
        .animate(
          onPlay: kDebugMode ? null : ((controller) => controller.repeat()),
        )
        .shimmer(
          delay: 5.seconds,
        );
  }
}
