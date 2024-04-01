import 'package:flutter/material.dart';
import 'package:gamico/commons/services/animation.dart';

class GamicoElevatedContainer extends StatelessWidget {
  final Widget child;

  final double width;
  final double height;

  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;

  final double? elevation;
  final BorderRadius? borderRadius;
  final double? borderWidth;

  final double? shadowElevation;
  final double? shadowOffset;

  static const double defaultBorderRadius = 16;
  static const double defaultBorderWidth = 1.5;

  final bool whiteBorder;

  final Duration? animationDuration;
  final Curve? animationCurve;

  const GamicoElevatedContainer({
    super.key,
    required this.child,
    required this.width,
    required this.height,
    this.foregroundColor,
    this.backgroundColor,
    this.borderColor,
    this.elevation,
    this.borderRadius,
    this.borderWidth,
    this.shadowElevation,
    this.shadowOffset,
    this.whiteBorder = true,
    this.animationCurve,
    this.animationDuration,
  });

  @override
  Widget build(BuildContext context) {
    final yOffset = elevation ?? 4.0;
    final finalBorderRadius =
        borderRadius ?? BorderRadius.circular(defaultBorderRadius);
    final finalBorderWidth = borderWidth ?? defaultBorderWidth;

    final finalShadowOffset = shadowOffset ?? 3.0;
    final finalShadowElevation = shadowElevation ?? 8.0;

    final finalAnimationDuration =
        animationDuration ?? AnimationService.animationDuration;
    final finalAnimationCurve = animationCurve ?? Curves.linear;

    return AnimatedContainer(
      duration: finalAnimationDuration,
      curve: finalAnimationCurve,
      width: width,
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Shadow
          AnimatedPositioned(
            duration: finalAnimationDuration,
            curve: finalAnimationCurve,
            left: -finalShadowOffset,
            right: -finalShadowOffset,
            bottom: -finalShadowOffset,
            // top: (_down ? yOffset : 0),
            top: 0,
            child: AnimatedContainer(
              duration: finalAnimationDuration,
              curve: finalAnimationCurve,
              transform: Matrix4.translationValues(0, yOffset, 0),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(25),
                borderRadius: finalBorderRadius,
                // border: Border.all(
                //   color: Colors.black.withAlpha(100),
                //   width: 1.5,
                // ),
              ),
            ),
          ),

          // Background color
          Material(
            elevation: finalShadowElevation,
            color: Colors.transparent,
            borderRadius: finalBorderRadius,
            child: AnimatedContainer(
              duration: finalAnimationDuration,
              curve: finalAnimationCurve,
              width: width,
              height: height,
              transform: Matrix4.translationValues(0, yOffset, 0),
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.black,
                borderRadius: finalBorderRadius,
                border: Border.all(
                  color: borderColor ?? Colors.black.withAlpha(100),
                  width: finalBorderWidth,
                ),
              ),
            ),
          ),

          // Child container
          AnimatedPositioned(
            duration: finalAnimationDuration,
            curve: finalAnimationCurve,
            child: AnimatedContainer(
              duration: finalAnimationDuration,
              curve: finalAnimationCurve,
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: foregroundColor,
                borderRadius: finalBorderRadius,
                border: Border.all(
                  width: finalBorderWidth,
                  color: borderColor ?? Colors.black.withAlpha(100),
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: SizedBox(
                  width: width,
                  height: height,
                  child: ClipRRect(
                    borderRadius: finalBorderRadius,
                    child: child,
                  ),
                ),
              ),
            )
            // shimmer
            ,
          ),

          // White border
          if (whiteBorder)
            AnimatedPositioned(
              duration: finalAnimationDuration,
              curve: finalAnimationCurve,
              child: IgnorePointer(
                child: AnimatedContainer(
                  duration: finalAnimationDuration,
                  curve: finalAnimationCurve,
                  width: width - 2,
                  height: height - 2,
                  margin: const EdgeInsets.all(1),
                  decoration: BoxDecoration(
                    // color: color,
                    borderRadius: finalBorderRadius,
                    border: Border.all(
                      color: Colors.white.withAlpha(75),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
