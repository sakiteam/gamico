import 'package:flutter/material.dart';

enum GamicoGameTimeIndicatorType {
  simple,
  complex,
}

class GamicoGameTimeIndicator extends StatelessWidget {
  final int countdown;
  final int criticalLimit;
  final bool over;
  final GamicoGameTimeIndicatorType type;

  final Widget Function(
    BuildContext context,
    String time,
    bool critical,
  ) builder;

  const GamicoGameTimeIndicator({
    super.key,
    required this.countdown,
    required this.builder,
    this.criticalLimit = 10,
    required this.over,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    String time;

    if (type == GamicoGameTimeIndicatorType.simple) {
      time = "$countdown";
    } else {
      final minutes = (countdown ~/ 60).toString().padLeft(2, "0");
      final seconds = (countdown % 60).toString().padLeft(2, "0");
      time = "$minutes : $seconds";
    }

    return builder(
      context,
      time,
      countdown <= criticalLimit &&
          countdown > 0 &&
          !over &&
          countdown.toInt().isOdd,
    );
  }
}
