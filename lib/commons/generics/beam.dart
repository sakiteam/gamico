import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gamico/commons/services/math.dart';

const double beamMaxRadius = 15;

class GamicoBeam extends StatelessWidget {
  final Color color;

  final double containerRadius;
  //
  final double? beamMinRadius;
  final double? beamMaxRadius;
  //
  final double? minBorderWidth;
  final double? maxBorderWidth;

  const GamicoBeam({
    super.key,
    required this.color,
    //
    required this.containerRadius,
    //
    this.beamMinRadius,
    this.beamMaxRadius,
    //
    this.minBorderWidth,
    this.maxBorderWidth,
  });

  @override
  Widget build(BuildContext context) {
    final finalBeamMinRadius = beamMinRadius ?? containerRadius;
    final finalBeamMaxRadius = beamMaxRadius ?? containerRadius;

    return Animate(onPlay: (controller) => controller.repeat()).custom(
      begin: finalBeamMinRadius,
      end: beamMaxRadius,
      duration: 1.seconds,
      builder: (_, value, _) {
        return SizedBox(
          width: containerRadius,
          height: containerRadius,
          child: OverflowBox(
            minWidth: 0,
            minHeight: 0,
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: Center(
              child: Opacity(
                opacity: 1 - value / finalBeamMaxRadius,
                child: Container(
                  width: value,
                  height: value,
                  decoration: BoxDecoration(
                    border: Border.all(
                      width: MathService.interpolate(
                        finalBeamMinRadius,
                        minBorderWidth ?? 0,
                        finalBeamMaxRadius,
                        maxBorderWidth ?? 1,
                        value,
                      ),
                      color: color,
                    ),
                    borderRadius: BorderRadius.circular(finalBeamMaxRadius),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
