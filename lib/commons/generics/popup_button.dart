import 'package:flutter/material.dart';
import 'package:gamico/commons/services/color.dart';
import 'package:gamico/commons/services/layout.dart';
import 'package:gamico/commons/generics/simple_popup.dart';
import 'package:gamico/commons/generics/elevated_button.dart';
import 'package:gamico/commons/generics/loader.dart';
import 'package:gamico/commons/generics/outlined_icon.dart';
import 'package:gamico/commons/generics/outlined_text.dart';

class GamicoPopupButton extends StatelessWidget {
  final void Function()? onPressed;
  final String? text;
  final Color? foregroundColor;
  final Color? backgroundColor;
  final double? height;
  final EdgeInsets? padding;
  final IconData? icon;
  final bool loading;
  final String? iconText;

  static Color defaultForegroundColor = Colors.blue;
  static Color defaultBackgroundColor = Colors.brown;

  static EdgeInsets defaultPadding = EdgeInsets.only(
    bottom: GamicoSimplePopup.watchButtonMargin,
  );

  static double get defaultWidth =>
      LayoutService.referenceWidth - LayoutService.optionButtonMargin * 2;
  static double get defaultHeight => GamicoSimplePopup.watchButtonFinalHeight;

  const GamicoPopupButton({
    super.key,
    this.onPressed,
    this.text,
    this.foregroundColor,
    this.backgroundColor,
    this.height,
    this.padding,
    this.icon,
    this.loading = false,
    this.iconText,
  });

  @override
  Widget build(BuildContext context) {
    return GamicoElevatedButton(
      whiteBorder: false,
      backgroundColor: backgroundColor ?? defaultBackgroundColor,
      foregroundColor: foregroundColor ?? defaultForegroundColor,
      borderRadius: BorderRadius.circular(20),
      // raised: true,
      onPressed: loading ? null : onPressed,
      width: defaultWidth,
      height: height ?? defaultHeight,

      child: Padding(
        padding: padding ?? defaultPadding,
        child: Center(
          child:
              loading
                  ? const GamicoLoader()
                  : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Stack(
                        children: [
                          if (icon != null)
                            GamicoOutlinedIcon(
                              icon,
                              color: Colors.white,
                              size: 40 * 450 / 400,
                              strokeWidth: 0.5,
                            ),
                          if (iconText != null)
                            Container(
                              height: 40 * 450 / 400,
                              width: 40 * 450 / 400,
                              alignment: Alignment.center,
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  top: 8.0,
                                  left: 4,
                                  right: 4,
                                ),
                                child: GamicoOutlinedText(
                                  iconText!,
                                  strokeWidth: 0.5,
                                  // minFontSize: 2,
                                  maxLines: 1,
                                  style: TextStyle(
                                    color: ColorService.accentColor,
                                    fontSize: 14,
                                    // letterSpacing: 2.5,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(width: 8),
                      GamicoOutlinedText(
                        text ?? "",
                        // textAlign: TextAlign.center,
                        // strokeWidth: 0.5,
                        style: const TextStyle(
                          fontSize: 16 * 450 / 400,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
        ),
      ),
    );
  }
}
