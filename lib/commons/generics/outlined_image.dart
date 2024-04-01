import 'package:flutter/material.dart';

class GamicoOutlinedImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final Color? color;
  final double? strokeWidth;
  final Color? strokeColor;

  const GamicoOutlinedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.color,
    this.strokeWidth,
    this.strokeColor,
  });

  @override
  Widget build(BuildContext context) {
    final double margin = -(strokeWidth ?? 0.25);
    final finalStrokeColor = strokeColor ?? Colors.black;

    final positions = [
      //
      [margin * 2, null, null, null], // left
      [null, margin * 2, null, null], // top
      [null, null, margin * 2, null], // right
      [null, null, null, margin * 2], // bottom

      //

      [margin, margin, null, null], // top left
      [null, margin, margin, null], // top right
      [margin, null, null, margin], // bottom left
      [null, null, margin, margin], // bottom right
    ];

    return SizedBox(
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ...positions.map((e) {
            return Positioned(
              left: e[0],
              top: e[1],
              right: e[2],
              bottom: e[3],
              child: Center(
                child: Image.asset(
                  url,
                  width: width,
                  height: height,
                  color: finalStrokeColor,
                ),
              ),
            );
          }),
          Center(
            child: Image.asset(
              url,
              width: width,
              height: height,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
