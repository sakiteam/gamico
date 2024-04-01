import 'package:gamico/commons/services/color.dart';
import 'package:gamico/commons/generics/elevated_button.dart';
import 'package:gamico/commons/generics/loader.dart';
import 'package:gamico/commons/generics/locker.dart';
import 'package:flutter/material.dart';
import 'package:gamico/commons/generics/outlined_icon.dart';
import 'package:gamico/commons/generics/outlined_text.dart';

class GamicoIconTextButton extends StatelessWidget {
  final void Function()? onPressed;
  final String? text;
  final IconData? iconData;
  final Widget? iconWidget;
  final Color? color;
  final Color? contentColor;
  final double? size;
  final bool loading;
  final double? iconAngle;
  final bool iconVisible;
  final Color? iconColor;
  final Color? backgroundColor;

  static double defaultSize = 100 * 450 / 400;
  static Color defaultContentColor = Colors.white;

  static Color defaultForegroundColor = Colors.blue;
  static Color defaultBackgroundColor = ColorService.backgroundBlue;

  const GamicoIconTextButton({
    super.key,
    required this.onPressed,
    this.iconData,
    this.iconWidget,
    required this.text,
    this.color,
    this.contentColor,
    this.size,
    this.loading = false,
    this.iconAngle,
    this.iconVisible = true,
    this.iconColor,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    final finalContentColor = contentColor ?? defaultContentColor;
    final finalSize = size ?? defaultSize;

    return GamicoLocker(
      size: finalSize,
      builder: (context, animate) {
        return GamicoElevatedButton(
          width: finalSize,
          height: finalSize,
          foregroundColor:
              enabled ? (color ?? defaultForegroundColor) : Colors.grey,
          backgroundColor: enabled
              ? (backgroundColor ??
                  (color == null ? defaultBackgroundColor : Colors.brown))
              : Colors.grey.shade700,
          bruitage: enabled ? null : "",
          onPressed: enabled ? onPressed : animate,
          child: loading
              ? const Center(child: GamicoLoader())
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Visibility(
                      visible: iconVisible,
                      child: Transform.rotate(
                        angle: iconAngle ?? 0,
                        child: iconWidget ??
                            GamicoOutlinedIcon(
                              iconData,
                              color: iconColor ?? finalContentColor,
                              size: (text == null ? 60 : 50) * 450 / 400,
                            ),
                      ),
                    ),
                    if (text != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: GamicoOutlinedText(
                          text!,
                          strokeWidth: 0.5,
                          textAlign: TextAlign.center,
                          style: TextStyle(color: finalContentColor),
                        ),
                      ),
                  ],
                ),
        );
      },
    );
  }
}
