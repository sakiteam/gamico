import 'package:flutter/material.dart';
import 'package:gamico/commons/utilities/couple/couple_utility.dart';
import 'package:gamico/commons/generics/poster.dart';

class GamicoInfoLine extends StatelessWidget {
  final GamicoCoupleUtility<String> coupleUtility;

  const GamicoInfoLine({
    super.key,
    required this.coupleUtility,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          coupleUtility.first,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: GamicoPoster.descriptionFontSize,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: Container(
            height: 10,
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 0.5,
              color: Colors.brown,
              margin: const EdgeInsets.symmetric(horizontal: 2),
            ),
          ),
        ),
        Text(
          coupleUtility.last,
          textAlign: TextAlign.justify,
          style: const TextStyle(
            fontSize: GamicoPoster.descriptionFontSize,
            color: Colors.brown,
          ),
        ),
      ],
    );
  }
}
