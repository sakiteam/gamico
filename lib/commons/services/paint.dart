import 'dart:math';

import 'package:flutter/material.dart';

import 'dart:ui' as ui;

import 'package:flutter/services.dart';

class PaintService {
  static double degToRad(double deg) => deg * (pi / 180.0);

  static Path p1 = drawCircle(const Size(15, 15));
  //?? drawStar(const Size(25, 15));
  static Path p2 = drawCircle(const Size(8, 8));

  static Path getPath1(Size size) => p1;
  static Path getPath2(Size size) => p2;

  static Path drawCircle(Size size) {
    // const numberOfPoints = 5;
    // final halfWidth = size.width / 2;
    // final externalRadius = halfWidth;
    // final internalRadius = halfWidth / 2.5;
    // final degreesPerStep = degToRad(360 / numberOfPoints);
    // final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    // final fullAngle = degToRad(360);

    path.moveTo(0, 0);
    path.addOval(
      Rect.fromCenter(
        center: Offset(size.width / 2, size.height / 2),
        width: min(size.width, size.height),
        height: min(size.width, size.height),
      ),
    );

    path.close();
    return path;
  }

  static Path drawStar(Size size) {
    const numberOfPoints = 5;
    final halfWidth = size.width / 2;
    final externalRadius = halfWidth;
    final internalRadius = halfWidth / 2.5;
    final degreesPerStep = degToRad(360 / numberOfPoints);
    final halfDegreesPerStep = degreesPerStep / 2;
    final path = Path();
    final fullAngle = degToRad(360);
    path.moveTo(size.width, halfWidth);

    for (double step = 0; step < fullAngle; step += degreesPerStep) {
      path.lineTo(halfWidth + externalRadius * cos(step),
          halfWidth + externalRadius * sin(step));
      path.lineTo(halfWidth + internalRadius * cos(step + halfDegreesPerStep),
          halfWidth + internalRadius * sin(step + halfDegreesPerStep));
    }

    path.close();
    return path;
  }

  // static Future<void> init() async {
  //   lightLevelIndicator =
  //       await loadImage("assets/images/light_level_indicator.png");
  //   darkLevelIndicator =
  //       await loadImage("assets/images/dark_level_indicator.png");
  // }

  // static late ui.Image lightLevelIndicator;
  // static late ui.Image darkLevelIndicator;

  static Future<ui.Image> loadImage(String imageAssetPath) async {
    final ByteData data = await rootBundle.load(imageAssetPath);

    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(),
      // targetHeight: 12,
      targetWidth: 12,
    );

    final frame = await codec.getNextFrame();

    return frame.image;
  }
}
