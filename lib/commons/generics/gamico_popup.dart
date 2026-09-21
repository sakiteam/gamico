import 'package:flutter/material.dart';
import 'package:gamico/commons/generics/character.dart';
import 'package:gamico/commons/generics/simple_popup.dart';

class GamicoPopup extends StatelessWidget {
  static double get watchButtonDefaultHeight =>
      GamicoSimplePopup.watchButtonDefaultHeight;
  static double get watchButtonMargin => GamicoSimplePopup.watchButtonMargin;
  static double get watchButtonFinalHeight =>
      GamicoSimplePopup.watchButtonFinalHeight;
  static Widget Function(
    BuildContext context,
    GamicoSimplePopup gamicoSimplePopup,
  )
  builder = (context, gamicoSimplePopup) {
    return gamicoSimplePopup;
  };

  final Widget child;
  final Widget? topLeftWidget;
  final Widget? topRightWidget;
  final Widget? additionalChild;
  final PageController? pageController;
  final int? pageControllerLength;
  final bool squarePageIndicators;
  final bool dismissible;
  final List<GamicoCharacterPosition>? characterPositions;

  /// See [GamicoSimplePopup.customHeight]: overrides the default popup content
  /// height (in reference coordinates) when the content needs more room.
  final double? customHeight;

  const GamicoPopup({
    super.key,
    required this.child,
    this.topLeftWidget,
    this.topRightWidget,
    this.additionalChild,
    this.pageController,
    this.pageControllerLength,
    this.squarePageIndicators = false,
    this.dismissible = true,
    this.characterPositions,
    this.customHeight,
  });

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      GamicoSimplePopup(
        additionalChild: additionalChild,
        customHeight: customHeight,
        characterPositions: characterPositions,
        dismissible: dismissible,
        pageController: pageController,
        pageControllerLength: pageControllerLength,
        squarePageIndicators: squarePageIndicators,
        topLeftWidget: topLeftWidget,
        topRightWidget: topRightWidget,
        child: child,
      ),
    );
  }
}
