import 'package:flutter/material.dart';
import 'package:gamico/commons/generics/image.dart';
import 'package:gamico/commons/generics/elevated_container.dart';
import 'package:gamico/commons/generics/poster.dart';

class GamicoUserPhoto extends StatelessWidget {
  final String? url;
  final IconData? icon;

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
        : GamicoElevatedContainer(
          width: hypothenuse,
          height: hypothenuse,
          // borderRadius: BorderRadius.circular(16),
          borderColor: Colors.black,
          backgroundColor: Colors.brown,
          foregroundColor: Colors.white,
          child: GamicoImage(
            path: url!,
            width: hypothenuse,
            height: hypothenuse,
            fit: BoxFit.cover,
          ),
        );
  }
}
