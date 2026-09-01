import 'dart:math';
import 'package:flutter/material.dart';

class GamicoGameLine extends StatefulWidget {
  final Point<double> first;
  final Point<double> last;
  final double thickness;
  final Widget child;

  const GamicoGameLine({
    super.key,
    required this.first,
    required this.last,
    required this.thickness,
    required this.child,
  });

  @override
  State<GamicoGameLine> createState() => _GamicoGameLineState();
}

class _GamicoGameLineState extends State<GamicoGameLine> {
  late final double minX;
  late final double minY;

  late final double width;
  late final double height;

  late final double angle;
  late final double distance;

  @override
  void initState() {
    super.initState();

    _init();
  }

  @override
  void didUpdateWidget(covariant GamicoGameLine oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.first != oldWidget.first || widget.last != oldWidget.last) {
      _init();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: minY,
      left: minX,
      width: width,
      height: height,
      child: Center(
        child: Transform.rotate(
          angle: angle,
          child: OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: SizedBox(
              width: distance,
              height: widget.thickness,
              child: widget.child,
            ),
          ),
        ),
      ),
    );
  }

  void _init() {
    final firstX = widget.first.x;
    final firstY = widget.first.y;
    final lastX = widget.last.x;
    final lastY = widget.last.y;

    final xDifference = lastX - firstX;
    final yDifference = lastY - firstY;

    width = xDifference.abs();
    height = yDifference.abs();

    angle = atan2(yDifference, xDifference);
    distance = sqrt(pow(xDifference, 2) + pow(yDifference, 2));

    minX = min(firstX, lastX);
    minY = min(firstY, lastY);
  }
}
