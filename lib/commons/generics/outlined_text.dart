import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';

class TextUtility {
  final String text;
  final Color? color;
  final int? maxLines;
  final TextStyle? style;
  final Color? strokeColor;
  final double? strokeWidth;
  final TextAlign? textAlign;
  final AutoSizeGroup? group;
  final TextOverflow? overflow;
  final double minFontSize;

  const TextUtility({
    required this.text,
    required this.color,
    required this.maxLines,
    required this.style,
    required this.strokeColor,
    required this.strokeWidth,
    required this.textAlign,
    required this.group,
    required this.overflow,
    this.minFontSize = 5,
  });
}

class GamicoOutlinedText extends StatelessWidget {
  final String text;
  final Color? color;
  final int? maxLines;
  final TextStyle? style;
  final Color? strokeColor;
  final double? strokeWidth;
  final TextAlign? textAlign;
  final AutoSizeGroup? group;
  final TextOverflow? overflow;
  final double minFontSize;

  static Widget Function(TextUtility) builder = normalBuilder;

  static Widget normalBuilder(TextUtility textUtility) {
    return GamicoOutlinedTextNormal(textUtility: textUtility);
  }

  static Widget simpleBuilder(TextUtility textUtility) {
    return GamicoOutlinedTextSimple(textUtility: textUtility);
  }

  const GamicoOutlinedText(
    this.text, {
    super.key,
    this.color,
    this.style,
    this.strokeColor,
    this.textAlign,
    this.strokeWidth,
    this.maxLines,
    this.overflow,
    this.group,
    this.minFontSize = 5,
  });

  @override
  Widget build(BuildContext context) {
    return builder(
      TextUtility(
        text: text,
        color: color,
        maxLines: maxLines,
        style: style,
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
        textAlign: textAlign,
        group: group,
        overflow: overflow,
        minFontSize: minFontSize,
      ),
    );

    // return Stack(
    //   children: [
    //     //
    //     // Transform.translate(
    //     //   offset: Offset(0, (strokeWidth ?? 0.25)),
    //     //   child: AutoSizeText(
    //     //     text,
    //     //     textAlign: textAlign,
    //     //     style: (style ?? const TextStyle()).copyWith(
    //     //       color: Colors.black,
    //     //       // foreground: Paint()
    //     //       //   ..strokeWidth = strokeWidth ?? 0.25
    //     //       //   ..color = strokeColor ?? Colors.black
    //     //       //   ..style = PaintingStyle.stroke,
    //     //     ),
    //     //     maxLines: maxLines,
    //     //     overflow: overflow,
    //     //     group: group,
    //     //     minFontSize: 5,
    //     //   ),
    //     // ),
    //     // Fill
    //     AutoSizeText(
    //       text,
    //       textAlign: textAlign,
    //       style: (style ?? const TextStyle()).copyWith(
    //         color: color,
    //       ),
    //       maxLines: maxLines,
    //       overflow: overflow,
    //       group: group,
    //       minFontSize: 5,
    //     ),
    //     // Border
    //     AutoSizeText(
    //       text,
    //       textAlign: textAlign,
    //       style: (style ?? const TextStyle()).copyWith(
    //         foreground: Paint()
    //           ..strokeWidth = strokeWidth ?? 0.25
    //           ..color = strokeColor ?? Colors.black
    //           ..style = PaintingStyle.stroke,
    //       ),
    //       maxLines: maxLines,
    //       overflow: overflow,
    //       group: group,
    //       minFontSize: 5,
    //     ),
    //   ],
    // );
  }
}

class GamicoOutlinedTextNormal extends StatelessWidget {
  final TextUtility textUtility;

  const GamicoOutlinedTextNormal({
    super.key,
    required this.textUtility,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Fill
        AutoSizeText(
          textUtility.text,
          textAlign: textUtility.textAlign,
          style: (textUtility.style ?? const TextStyle()).copyWith(
            color: textUtility.color,
          ),
          maxLines: textUtility.maxLines,
          overflow: textUtility.overflow,
          group: textUtility.group,
          minFontSize: textUtility.minFontSize,
        ),

        // Border
        AutoSizeText(
          textUtility.text,
          textAlign: textUtility.textAlign,
          style: (textUtility.style ?? const TextStyle()).copyWith(
            foreground: Paint()
              ..strokeWidth = textUtility.strokeWidth ?? 0.25
              ..color = textUtility.strokeColor ?? Colors.black
              ..style = PaintingStyle.stroke,
          ),
          maxLines: textUtility.maxLines,
          overflow: textUtility.overflow,
          group: textUtility.group,
          minFontSize: textUtility.minFontSize,
        ),
      ],
    );
  }
}

class GamicoOutlinedTextSimple extends StatelessWidget {
  final TextUtility textUtility;

  const GamicoOutlinedTextSimple({
    super.key,
    required this.textUtility,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      textUtility.text,
      textAlign: textUtility.textAlign,
      style: (textUtility.style ?? const TextStyle()).copyWith(
        color: textUtility.color,
      ),
      maxLines: textUtility.maxLines,
      overflow: textUtility.overflow,
    );
  }
}
