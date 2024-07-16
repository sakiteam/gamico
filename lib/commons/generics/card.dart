import 'package:flutter/material.dart';

class GamicoCard extends StatelessWidget {
  final double? width;
  final double? height;
  final EdgeInsets? margin;
  final Widget? child;
  final Color? color;
  final Border? border;
  final double? borderWidth;

  final Color? borderColor;
  final BorderRadius? borderRadius;
  final EdgeInsets? padding;
  final double elevation;
  final Clip? clipBehavior;

  static const defaultBorderRadius = 16.0;

  const GamicoCard({
    super.key,
    this.width,
    this.height,
    this.margin,
    this.child,
    this.color,
    this.borderColor,
    this.borderRadius,
    this.borderWidth,
    this.padding,
    this.elevation = 0,
    this.border,
    this.clipBehavior,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: margin ?? EdgeInsets.zero,
      child: SizedBox(
        height: height,
        width: width,
        child: Card(
          elevation: elevation,
          clipBehavior: clipBehavior ?? Clip.antiAlias,
          margin: EdgeInsets.zero,
          color: color ?? Colors.white,
          shape: border ??
              RoundedRectangleBorder(
                borderRadius:
                    borderRadius ?? BorderRadius.circular(defaultBorderRadius),
                side: borderWidth == 0
                    ? BorderSide.none
                    : BorderSide(
                        color: borderColor ?? Colors.grey,
                        width: borderWidth ?? 0.5,
                      ),
              ),
          child: Padding(
            padding: padding ?? EdgeInsets.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
