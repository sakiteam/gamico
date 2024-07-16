import 'package:gamico/commons/services/color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gamico/commons/services/layout.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

enum GamicoLoaderType {
  threeArchedCircle,
  halfTriangleDot;

  Widget Function({required Color color, Key? key, required double size})
      get constructor {
    switch (this) {
      case GamicoLoaderType.threeArchedCircle:
        return LoadingAnimationWidget.threeArchedCircle;
      case GamicoLoaderType.halfTriangleDot:
        return LoadingAnimationWidget.halfTriangleDot;
    }
  }
}

class GamicoLoader extends StatelessWidget {
  static Color defaultColor = ColorService.primaryColor;
  static GamicoLoaderType type = GamicoLoaderType.threeArchedCircle;

  final Color? color;

  const GamicoLoader({
    super.key,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final finalColor = color ?? defaultColor;

    if (kDebugMode && !showTrueLoader) {
      return Center(
        child: Container(
          width: 40,
          height: 40,
          color: finalColor,
        ),
      );
    }

    return type.constructor(
      size: 40,
      color: finalColor,
    );
  }
}
