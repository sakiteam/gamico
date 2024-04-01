import 'package:flutter/material.dart';
import 'package:gamico/commons/generics/character.dart';
import 'package:gamico/commons/generics/simple_popup.dart';

class GamicoPopup extends StatelessWidget {
  static const double watchButtonDefaultHeight =
      GamicoSimplePopup.watchButtonDefaultHeight;
  static const double watchButtonMargin = GamicoSimplePopup.watchButtonMargin;
  static const double watchButtonFinalHeight =
      GamicoSimplePopup.watchButtonFinalHeight;
  static Widget Function(
          BuildContext context, GamicoSimplePopup gamicoSimplePopup) builder =
      (context, gamicoSimplePopup) {
    return gamicoSimplePopup;
  };

  final Widget child;
  final Widget? topLeftWidget;
  final Widget? topRightWidget;
  final Widget? additionalChild;
  final PageController? pageController;
  final int? pageControllerLength;
  final bool dismissible;
  final List<GamicoCharacterPosition>? characterPositions;

  const GamicoPopup({
    super.key,
    required this.child,
    this.topLeftWidget,
    this.topRightWidget,
    this.additionalChild,
    this.pageController,
    this.pageControllerLength,
    this.dismissible = true,
    this.characterPositions,
  });

  @override
  Widget build(BuildContext context) {
    return builder(
      context,
      GamicoSimplePopup(
        additionalChild: additionalChild,
        characterPositions: characterPositions,
        dismissible: dismissible,
        pageController: pageController,
        pageControllerLength: pageControllerLength,
        topLeftWidget: topLeftWidget,
        topRightWidget: topRightWidget,
        child: child,
      ),
    );
  }
}
