import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamico/commons/services/animation.dart';
import 'package:gamico/commons/generics/button.dart';

class GamicoElevatedButton extends StatefulWidget {
  final Widget child;
  final Widget? foregroundChild;
  final void Function()? onPressed;

  final double width;
  final double height;

  final Color? foregroundColor;
  final Color? backgroundColor;
  final Color? borderColor;

  final Color? disabledForegroundColor;
  final Color? disabledBackgroundColor;

  final double? elevation;
  final String? bruitage;

  final double? shadowElevation;
  final double? shadowOffset;

  final BorderRadius? borderRadius;

  final double? borderWidth;

  final bool whiteBorder;

  final bool raised;

  // final Widget? foregroundChild;

  final Gradient? foregroundGradient;
  final Gradient? backgroundGradient;

  const GamicoElevatedButton({
    super.key,
    required this.child,
    required this.onPressed,
    required this.width,
    required this.height,
    this.foregroundColor,
    this.backgroundColor,
    this.disabledForegroundColor,
    this.disabledBackgroundColor,
    this.borderColor,
    this.elevation,
    this.bruitage,
    this.shadowElevation,
    this.shadowOffset,
    this.borderRadius,
    this.borderWidth,
    this.whiteBorder = true,
    this.raised = false,
    this.foregroundChild,
    this.foregroundGradient,
    this.backgroundGradient,
  });

  @override
  State<GamicoElevatedButton> createState() => _GamicoElevatedButtonState();
}

class _GamicoElevatedButtonState extends State<GamicoElevatedButton> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final enabled = widget.onPressed != null;

    final yOffset = widget.elevation ?? 4.0;
    final shadowOffset = widget.shadowOffset ?? 3.0;
    final shadowElevation = widget.shadowElevation ?? 8.0;
    final borderRadius =
        widget.borderRadius ??
        BorderRadius.circular(GamicoButton.defaultBorderRadius);
    final borderWidth = widget.borderWidth ?? 1.5;

    const double inset = 6.0;

    final finalDisabledForegroundColor =
        widget.disabledForegroundColor ?? Colors.grey;
    final finalDisabledBackgroundColor =
        widget.disabledBackgroundColor ?? Colors.transparent;

    final raisingWidgetRadius = borderRadius / 3 * 2;

    final raisingWidget =
        IgnorePointer(
              child: Container(
                width: widget.width,
                height: widget.height,
                // margin: const EdgeInsets.all(1),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withAlpha(50),
                      Colors.black.withAlpha(25),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: borderRadius,
                  // border: Border.all(
                  //   color: Colors.white.withAlpha(75),
                  // ),
                ),
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  margin: const EdgeInsets.all(inset),
                  decoration: BoxDecoration(
                    color: widget.foregroundColor,
                    borderRadius: raisingWidgetRadius,
                  ),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    margin: const EdgeInsets.all(inset),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: widget.backgroundColor ?? Colors.black,
                        width: 0.25,
                      ),
                      borderRadius: raisingWidgetRadius,
                    ),
                    alignment: Alignment.bottomCenter,
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Positioned(
                          left: -1,
                          right: -1,
                          // height: widget.height,
                          bottom: -1,
                          top: -1,
                          child: Container(
                            transform: Matrix4.translationValues(0, 1, 0),
                            decoration: BoxDecoration(
                              borderRadius: raisingWidgetRadius,
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  (widget.foregroundColor ?? Colors.black)
                                      .withAlpha(50),
                                  // (widget.foregroundColor ?? Colors.black)
                                  //     .withAlpha(50),
                                  widget.foregroundColor ?? Colors.black,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
            .animate(
              // target: kDebugMode && Platform.isIOS ? 0 : 1,
              onPlay: kDebugMode && Platform.isIOS
                  ? null
                  : (controller) => controller.repeat(),
            )
            .shimmer(
              delay: 5.seconds,
              duration: 1.seconds,
              // color: Colors.grey.withAlpha(100),
            );

    return AbsorbPointer(
      absorbing: !enabled,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Shadow offset
            AnimatedPositioned(
              duration: AnimationService.animationDuration,
              left: -shadowOffset,
              right: -shadowOffset,
              bottom: -shadowOffset,
              top: (_down ? yOffset : 0),
              child: Container(
                transform: Matrix4.translationValues(0, yOffset, 0),
                decoration: shadowOffset == 0
                    ? null
                    : BoxDecoration(
                        color: Colors.black.withAlpha(25),
                        borderRadius: borderRadius,
                      ),
              ),
            ),

            // Shadow elevation
            Material(
              elevation: shadowElevation,
              color: Colors.transparent,
              borderRadius: borderRadius,
              child: Container(
                width: widget.width,
                height: widget.height,
                transform: Matrix4.translationValues(0, yOffset, 0),
                decoration: BoxDecoration(
                  color: enabled
                      ? (widget.backgroundGradient == null
                            ? (widget.backgroundColor ?? Colors.black)
                            : null)
                      : finalDisabledBackgroundColor,
                  gradient: enabled ? widget.backgroundGradient : null,
                  borderRadius: borderRadius,
                  border: Border.all(
                    color: Colors.black.withAlpha(100),
                    width: borderWidth,
                  ),
                ),
              ),
            ),

            // Concrete content
            AnimatedPositioned(
              duration: AnimationService.animationDuration,
              top: _down ? yOffset : 0,
              child: Container(
                width: widget.width,
                height: widget.height,
                decoration: BoxDecoration(
                  color: enabled
                      ? (widget.foregroundGradient == null
                            ? widget.foregroundColor
                            : null)
                      : finalDisabledForegroundColor,
                  gradient: enabled ? widget.foregroundGradient : null,
                  borderRadius: borderRadius,
                  border: Border.all(
                    width: borderWidth,
                    color: widget.borderColor ?? Colors.black.withAlpha(100),
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      if (widget.raised) raisingWidget,
                      GamicoButton(
                        bruitage: widget.bruitage,
                        onPressed: widget.onPressed,
                        borderRadius: borderRadius
                            .subtract(BorderRadius.circular(borderWidth))
                            .resolve(null),
                        onDownChanged: (down) {
                          setState(() {
                            _down = down;
                          });
                        },
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Container(
                            //   decoration: BoxDecoration(
                            //     color: Colors.white,
                            //     // .withAlpha(100),
                            //     borderRadius: borderRadius,
                            //   ),
                            // ),
                            // Opacity(
                            //   opacity: 1,
                            //   child: Container(
                            //     width: widget.width,
                            //     height: widget.height,
                            //     clipBehavior: Clip.antiAlias,
                            //     decoration: BoxDecoration(
                            //       borderRadius: borderRadius,
                            //     ),
                            //     child: OverflowBox(
                            //       maxWidth: double.infinity,
                            //       maxHeight: double.infinity,
                            //       child: SizedBox(
                            //         width: widget.width,
                            //         height: widget.height + 120,
                            //         child: ColorFiltered(
                            //           colorFilter: ColorFilter.mode(
                            //               // Colors.white.withAlpha() ??
                            //               widget.foregroundColor ?? Colors.black,
                            //               BlendMode.color),
                            //           child: SizedBox(),
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            // ),
                            if (!widget.raised)
                              Positioned.fill(
                                child: Opacity(
                                  opacity: 0.125,
                                  child: ClipRRect(
                                    borderRadius: borderRadius,
                                    child: ColorFiltered(
                                      colorFilter: ColorFilter.mode(
                                        widget.foregroundColor ?? Colors.white,
                                        BlendMode.color,
                                      ),
                                      child: Image.asset(
                                        "assets/images/unlocked_card_background.jpg",
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            SizedBox(
                              width: widget.width,
                              height: widget.height,
                              child: ClipRRect(
                                borderRadius: borderRadius,
                                child: widget.child,
                              ),
                            ),
                            if (widget.foregroundChild != null)
                              IgnorePointer(
                                child: SizedBox(
                                  width: widget.width,
                                  height: widget.height,
                                  child: Container(
                                    // borderRadius: borderRadius,
                                    child: widget.foregroundChild,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            if (!widget.raised && widget.whiteBorder)
              AnimatedPositioned(
                duration: AnimationService.animationDuration,
                top: _down ? yOffset : 0,
                child: IgnorePointer(
                  child: Container(
                    width: widget.width - 2,
                    height: widget.height - 2,
                    margin: const EdgeInsets.all(1),
                    decoration: BoxDecoration(
                      borderRadius: borderRadius,
                      border: Border.all(color: Colors.white.withAlpha(75)),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
