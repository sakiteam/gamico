import 'package:flutter/material.dart';

class ColorService {
  static const red = Colors.orange;
  static const blue = Colors.blue;

  // static const Color primaryColor = Color(0xFFFB6D1A);
  // static Color get steelblue => const Color(0xFF4682B4);

  static Color get primaryColor => Colors.brown;

  //  const Color(0xFFD2B58D);

  static const foregroundOrange = Color(0xFFFFB92B);
  static const backgroundOrange = Color(0xFFB33E36);
  static const borderOrange = Color(0xFF771023);

  static const foregroundBlue = Color(0xFF2C85F9);
  static const backgroundBlue = Color(0xFF0E4BB2);
  static const borderBlue = Color(0xFF0A3178);

  static ColorFilter tintMatrix({
    Color color = Colors.grey,
    double scale = 1,
  }) {
    final int r = color.red;
    final int g = color.green;
    final int b = color.blue;

    final double rTint = r / 255;
    final double gTint = g / 255;
    final double bTint = b / 255;

    const double rL = 0.2126;
    const double gL = 0.7152;
    const double bL = 0.0722;

    final double translate = 1 - scale * 0.5;

    return ColorFilter.matrix(<double>[
      (rL * rTint * scale),
      (gL * rTint * scale),
      (bL * rTint * scale),
      (0),
      (r * translate),
      (rL * gTint * scale),
      (gL * gTint * scale),
      (bL * gTint * scale),
      (0),
      (g * translate),
      (rL * bTint * scale),
      (gL * bTint * scale),
      (bL * bTint * scale),
      (0),
      (b * translate),
      (0),
      (0),
      (0),
      (1),
      (0),
    ]);
  }
}
