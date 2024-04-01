import 'package:gamico/commons/services/color.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gamico/commons/services/layout.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class GamicoLoader extends StatelessWidget {
  static Color color = ColorService.primaryColor;

  const GamicoLoader({super.key});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode && !appScreenshots) {
      return Center(
        child: Container(
          width: 40,
          height: 40,
          color: color,
        ),
      );
    }

    return LoadingAnimationWidget.threeArchedCircle(
      color: color,
      size: 40,
    );
  }
}
