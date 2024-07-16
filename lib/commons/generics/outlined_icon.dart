import 'package:flutter/material.dart';

class GamicoOutlinedIcon extends StatelessWidget {
  final IconData? iconData;
  final double? size;
  final Color? color;
  final double? strokeWidth;
  final Color? strokeColor;

  static bool simple = false;

  const GamicoOutlinedIcon(
    this.iconData, {
    super.key,
    this.size,
    this.color,
    this.strokeWidth,
    this.strokeColor,
  });

  @override
  Widget build(BuildContext context) {
    final maxSize = (size ?? 24);
    final minSize = (size ?? 24);

    final double margin = -(strokeWidth ?? 0.25);

    final finalStrokeColor = strokeColor ?? Colors.black;

    if (simple) {
      return Icon(
        iconData,
        size: size,
        color: color,
      );
    }

    return SizedBox(
      width: maxSize,
      height: maxSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: margin * 2,
            child: Center(
              child: Icon(
                iconData,
                size: minSize,
                color: finalStrokeColor,
              ),
            ),
          ),
          Positioned(
            right: margin * 2,
            child: Center(
              child: Icon(
                iconData,
                size: minSize,
                color: finalStrokeColor,
              ),
            ),
          ),
          Positioned(
            top: margin * 2,
            child: Center(
              child: Icon(
                iconData,
                size: minSize,
                color: finalStrokeColor,
              ),
            ),
          ),
          Positioned(
            bottom: margin * 2,
            child: Center(
              child: Icon(
                iconData,
                size: minSize,
                color: finalStrokeColor,
              ),
            ),
          ),
          Positioned(
            top: margin,
            left: margin,
            child: Center(
              child: Icon(
                iconData,
                size: minSize,
                color: finalStrokeColor,
              ),
            ),
          ),
          Positioned(
            top: margin,
            right: margin,
            child: Center(
              child: Icon(
                iconData,
                size: minSize,
                color: finalStrokeColor,
              ),
            ),
          ),
          Positioned(
            bottom: margin,
            left: margin,
            child: Center(
              child: Icon(
                iconData,
                size: minSize,
                color: finalStrokeColor,
              ),
            ),
          ),
          Positioned(
            bottom: margin,
            right: margin,
            child: Center(
              child: Icon(
                iconData,
                size: minSize,
                color: finalStrokeColor,
              ),
            ),
          ),
          Center(
            child: Icon(
              iconData,
              size: minSize,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
