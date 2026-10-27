import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

const bool appScreenshots = 1 == 0 && !kReleaseMode;
const bool androidScreenshots = 1 == 1 && appScreenshots;
const bool landscapeScreenshots = false;
const bool perfectSize = true;
final Size portraitSize = perfectSize
    ? Size(LayoutService.referenceWidth, LayoutService.referenceHeight) * 2
    : const Size(900, 1600);

class LayoutService {
  static void init(BuildContext context) {
    final size = androidScreenshots
        ? (landscapeScreenshots
              ? const Size(1366, 1366 * 9 / 16)
              : portraitSize)
        : MediaQuery.of(context).size;
    final padding = androidScreenshots
        ? const EdgeInsets.all(0)
        : MediaQuery.of(context).padding;

    final realTotalWidth = size.width;
    final realTotalHeight = size.height;

    final realUsefulWidth = realTotalWidth - padding.horizontal;
    final realUsefulHeight = realTotalHeight - padding.vertical;

    var ratio = min(
      realUsefulWidth / LayoutService.referenceWidth,
      realUsefulHeight / LayoutService.referenceHeight,
    );

    // Android hands out a 0×0 MediaQuery while the surface is being recreated
    // (background, split screen, rotation). A zero ratio turns every scaled*
    // getter into 0 / 0 = NaN, which reaches the OverflowBoxes under the page
    // FittedBoxes, puts NaN in the paint transform, and crashes the frame as
    // soon as a TextField has the keyboard: the engine cannot JSON-encode the
    // NaN in setEditableSizeAndTransform. Keep the last good layout instead;
    // nothing is visible at that size anyway.
    if (!(ratio > 0 && ratio.isFinite)) {
      if (_initialized) return;
      ratio = 1;
    }
    _initialized = true;

    final realUsedWidth = LayoutService.referenceWidth * ratio;
    final realUsedHeight = LayoutService.referenceHeight * ratio;

    final realUselessSpacing = padding;
    // final realUsefulSpacing = EdgeInsets.symmetric(
    //   horizontal: (realUsefulWidth - realUsedWidth) / 2,
    //   vertical: (realUsefulHeight - realUsedHeight) / 2,
    // );

    final realTotalSpacing = EdgeInsets.symmetric(
      vertical: (realTotalHeight - realUsedHeight) / 2,
      horizontal: (realTotalWidth - realUsedWidth) / 2,
    );

    final realUsefulSpacing = realTotalSpacing - realUselessSpacing;

    LayoutService.ratio = ratio;
    LayoutService.realTotalWidth = realTotalWidth;
    LayoutService.realTotalHeight = realTotalHeight;
    LayoutService.realUsefulWidth = realUsefulWidth;
    LayoutService.realUsefulHeight = realUsefulHeight;
    LayoutService.realUsefulSpacing = realUsefulSpacing;
    LayoutService.realUselessSpacing = realUselessSpacing;
  }

  static double referenceWidth = 450;
  static double referenceHeight = 750;

  static double get remainingWidth => referenceWidth - optionButtonMargin * 2;

  //

  static double optionButtonSize = 0;
  static double optionButtonMargin = 20 * 450 / 400;

  //

  static late double ratio;

  static bool _initialized = false;

  //

  static late double realTotalWidth;
  static late double realTotalHeight;

  static late double realUsefulWidth;
  static late double realUsefulHeight;

  static late EdgeInsets realUsefulSpacing;
  static late EdgeInsets realUselessSpacing;

  static EdgeInsets get realTotalSpacing =>
      realUsefulSpacing + realUselessSpacing;

  // static double get scaledUsefulHeight =

  //

  static double get scaledTotalWidth => realTotalWidth / ratio;
  static double get scaledTotalHeight => realTotalHeight / ratio;

  static double get scaledUsefulWidth => realUsefulWidth / ratio;
  static double get scaledUsefulHeight => realUsefulHeight / ratio;

  static EdgeInsets get scaledTotalSpacing => realTotalSpacing / ratio;
  static EdgeInsets get scaledUsefulSpacing => realUsefulSpacing / ratio;
  static EdgeInsets get scaledUselessSpacing => realUselessSpacing / ratio;
}
