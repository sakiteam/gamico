import 'package:flutter/material.dart';
import 'package:gamico/commons/generics/card.dart';

class GamicoProgressBar extends StatelessWidget {
  final double value;

  const GamicoProgressBar({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final barValue = value;
    Color barColor;

    if (barValue < 0.25) {
      barColor = Colors.red;
    } else if (barValue < 0.5) {
      barColor = Colors.orange;
    } else if (barValue < 0.75) {
      barColor = Colors.amber;
    } else {
      barColor = Colors.green;
    }

    return GamicoCard(
      margin: const EdgeInsets.all(8),
      height: 20,
      width: double.infinity,
      // color: Colors.white,
      borderColor: Colors.black,
      borderWidth: 1,
      // elevation: 5,

      color: Colors.brown,
      borderRadius: BorderRadius.circular(100),
      child: Align(
        alignment: Alignment.centerLeft,
        child: GamicoCard(
          borderColor: Colors.black,
          borderRadius: BorderRadius.circular(100),
          elevation: 4,
          borderWidth: 1,
          margin: const EdgeInsets.all(3),
          child: FractionallySizedBox(
            widthFactor: barValue,
            heightFactor: 1,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(100),
              child: ColorFiltered(
                colorFilter: ColorFilter.mode(barColor, BlendMode.color),
                child: Image.asset(
                  "assets/images/progress_bar.png",
                  // color: Colors.brown,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
