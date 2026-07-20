import 'package:flutter/material.dart';
import 'package:gamico/commons/generics/button.dart';
import 'package:gamico/commons/generics/image.dart';
import 'package:gamico/commons/generics/elevated_container.dart';
import 'package:gamico/commons/generics/poster.dart';

class GamicoUserPhoto extends StatelessWidget {
  final String? url;
  final IconData? icon;

  static bool simple = true;

  const GamicoUserPhoto(this.url, {super.key, this.icon});

  @override
  Widget build(BuildContext context) {
    const double hypothenuse = 100 - 16;

    return url == null
        ? Icon(
            icon ?? Icons.person,
            size: 60,
            color: GamicoPoster.iconColor, // Colors.brown.shade700,
          )
        : () {
            final imageSize = hypothenuse + 1;

            final image = OverflowBox(
              minWidth: imageSize,
              minHeight: imageSize,
              maxWidth: imageSize,
              maxHeight: imageSize,
              child: GamicoImage(
                path: url!,
                width: hypothenuse,
                height: hypothenuse,
                fit: BoxFit.cover,
              ),
            );

            return (simple
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(
                      GamicoButton.defaultBorderRadius,
                    ),
                    child: Container(
                      width: hypothenuse,
                      height: hypothenuse,
                      color: Colors.white,
                      // color: ColorService.translationForegroundColor,
                      child: image,

                      // GamicoButton(
                      //   // bruitage: enabled ? null : "",
                      //   onPressed: onPressed,
                      //   child: child,
                      // ),
                    ),
                  )
                : GamicoElevatedContainer(
                    width: hypothenuse,
                    height: hypothenuse,
                    borderRadius: BorderRadius.circular(
                      GamicoButton.defaultBorderRadius,
                    ),
                    borderColor: Colors.black,
                    backgroundColor: Colors.brown,
                    foregroundColor: Colors.white,
                    child: image,
                  ));
          }();
  }
}
