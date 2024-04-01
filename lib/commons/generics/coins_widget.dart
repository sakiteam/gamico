import 'package:flutter/material.dart';
import 'package:gamico/commons/generics/outlined_icon.dart';
import 'package:gamico/commons/generics/outlined_image.dart';

class CoinsWidget extends StatelessWidget {
  final double size;
  final Color? color;
  final bool outlined;
  final double? strokeWidth;

  static String? image;
  static IconData? icon;

  static Widget Function(double size)? builder;

  const CoinsWidget({
    super.key,
    this.size = 100,
    this.color,
    this.outlined = true,
    this.strokeWidth,
  });

  @override
  Widget build(BuildContext context) {
    if (builder != null) {
      return builder!(size);
    }

    if (icon == null && image == null) {
      return const SizedBox();
    }

    if (icon != null) {
      return Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        child: outlined
            ? GamicoOutlinedIcon(
                icon,
                size: size,
                color: color ?? Colors.black,
                strokeWidth: strokeWidth,
              )
            : Icon(
                icon,
                color: color ?? Colors.black,
                size: size,
              ),
      );
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      child: outlined
          ? GamicoOutlinedImage(
              url: image!,
              color: color ?? Colors.black,
              width: size,
              height: size,
              strokeWidth: strokeWidth,
            )
          : Image.asset(
              image!,
              color: color ?? Colors.black,
              width: size,
              height: size,
            ),
    );
  }
}
