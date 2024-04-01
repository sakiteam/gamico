import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gamico/commons/services/layout.dart';
import 'package:gamico/commons/generics/card.dart';
import 'package:gamico/commons/generics/showcase_widget.dart';

class GamicoShowcaseTooltip extends StatelessWidget {
  const GamicoShowcaseTooltip({
    super.key,
    required this.arrowContainerTop,
    required this.arrowContainerLeft,
    required this.arrowContainerWidth,
    required this.arrowHeight,
    required this.activeRect,
    required this.activeShowcaseWidget,
  });

  final double arrowContainerTop;
  final double arrowContainerLeft;
  final double arrowContainerWidth;
  final double arrowHeight;
  final Rect activeRect;
  final GamicoShowcaseWidget activeShowcaseWidget;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: arrowContainerTop,
          left: arrowContainerLeft,
          width: arrowContainerWidth,
          // left: 0,
          height: arrowHeight,
          // right: 0,
          child: Center(
            // color: Colors.red,
            // alignment: Alignment.center,
            child: Transform.rotate(
              angle: pi / 4,
              child: GamicoCard(
                borderColor: Colors.black,
                width: arrowHeight,
                height: arrowHeight,
                borderRadius: BorderRadius.circular(2),
                // borderColor: Colors.transparent,
                // borderWidth: 0,
              ),
            ),
          ),
        ),
        Positioned(
          top: activeRect.top + activeRect.height + 32,
          // left: activeRect.left,
          left: 0,
          right: 0,
          child: Center(
            child: GamicoCard(
              // borderColor: Colors.transparent,
              // borderWidth: 0,
              margin: EdgeInsets.symmetric(
                horizontal: 14 * LayoutService.ratio,
              ),
              width: LayoutService.referenceWidth * LayoutService.ratio,
              height: 60 * LayoutService.ratio,
              borderColor: Colors.black,
              padding: EdgeInsets.symmetric(
                horizontal: 12 * LayoutService.ratio,
              ),
              child: Center(
                child: Text(
                  activeShowcaseWidget.description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade700,
                    fontSize: 14 * LayoutService.ratio,
                  ),
                ),
              ),
            ),
          ),
        ),
        Positioned(
          top: arrowContainerTop + 1,
          left: arrowContainerLeft,
          width: arrowContainerWidth,
          // left: 0,
          height: arrowHeight,
          // right: 0,
          child: Center(
            // color: Colors.red,
            // alignment: Alignment.center,
            child: Transform.rotate(
              angle: pi / 4,
              child: GamicoCard(
                width: arrowHeight,
                height: arrowHeight,
                borderRadius: BorderRadius.circular(0),
                borderColor: Colors.transparent,
                borderWidth: 0,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
