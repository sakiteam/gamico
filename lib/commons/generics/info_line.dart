import 'package:flutter/material.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/utilities/couple/couple_utility.dart';
import 'package:gamico/commons/generics/poster.dart';

class GamicoInfoLine extends StatelessWidget {
  final GamicoCoupleUtility<String> coupleUtility;

  const GamicoInfoLine({super.key, required this.coupleUtility});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          coupleUtility.first,
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: GamicoPoster.descriptionFontSize,
            color:
                Gamico.instance.aboutSettings?.infoLineTitleColor ??
                Colors.black,
          ),
        ),
        Expanded(
          child: Container(
            height: 10,
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 0.5,
              color:
                  Gamico.instance.aboutSettings?.infoLineSeparatorColor ??
                  Gamico.instance.aboutSettings?.infoLineSeparatorColor ??
                  Colors.brown,
              margin: const EdgeInsets.symmetric(horizontal: 2),
            ),
          ),
        ),
        Text(
          coupleUtility.last,
          textAlign: TextAlign.justify,
          style: TextStyle(
            fontSize: GamicoPoster.descriptionFontSize,
            color:
                Gamico.instance.aboutSettings?.infoLineDescriptionColor ??
                Colors.brown,
          ),
        ),
      ],
    );
  }
}
