import 'package:flutter/material.dart';

class GamicoScrollBehavior extends ScrollBehavior {
  const GamicoScrollBehavior();

  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    return const BouncingScrollPhysics();
  }
}
