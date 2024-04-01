import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gamico/commons/generics/outlined_text.dart';

class GamicoAnimatedNumber extends StatefulWidget {
  /// Desired start value.
  final num startValue;

  /// Desired end value
  final num endValue;

  /// Duration for the animation.
  final Duration duration;

  /// Flag that controls if the iteration of the animation will be integer or floating point.
  final bool isFloatingPoint;

  /// Desired decimal points.
  final int decimalPoint;

  /// Text style.
  final TextStyle? style;

  /// How the text should be aligned horizontally.
  final TextAlign? textAlign;

  /// Desired prefix text.
  final String? prefixText;

  /// Desired sufix text.
  final String? sufixText;

  final String? replacementText;

  final Color? strokeColor;

  const GamicoAnimatedNumber({
    super.key,
    required this.startValue,
    required this.endValue,
    required this.duration,
    required this.isFloatingPoint,
    this.decimalPoint = 2,
    this.style,
    this.textAlign,
    this.prefixText = '',
    this.sufixText = '',
    this.replacementText,
    this.strokeColor,
  });

  @override
  State<GamicoAnimatedNumber> createState() => _GamicoAnimatedNumberState();
}

class _GamicoAnimatedNumberState extends State<GamicoAnimatedNumber>
    with SingleTickerProviderStateMixin {
  late Animation animation;
  late AnimationController _controller;

  double get startValue {
    return widget.startValue.toDouble();
  }

  int get roundedStartValue {
    return widget.startValue.toInt();
  }

  double get endValue {
    return widget.endValue.toDouble();
  }

  int get roundedEndValue {
    return widget.endValue.toInt();
  }

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    if (widget.isFloatingPoint) {
      animation = Tween<double>(
        begin: startValue,
        end: endValue,
      ).animate(_controller);
    } else {
      animation = IntTween(
        begin: roundedStartValue,
        end: roundedEndValue,
      ).animate(_controller);
    }

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();

    super.dispose();
  }

  String roundValue(num value, int decimalPoints) {
    if (value == value.toInt()) {
      return value.toString();
    }

    double doubleValue = value.toDouble();

    return doubleValue.toStringAsFixed(decimalPoints);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final String text;

        if (widget.replacementText != null) {
          text = widget.replacementText!;
        } else {
          text =
              '${widget.prefixText}${roundValue(animation.value, widget.decimalPoint)}${widget.sufixText}';
        }

        return GamicoOutlinedText(
          text,
          style: widget.style,
          textAlign: widget.textAlign,
          strokeColor: widget.strokeColor,
        );
      },
    );
  }
}
