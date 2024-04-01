import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/layout.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:gamico/features/game/utilities/polygon_utility.dart';

class GameService {
  static bool get gameSkipped =>
      LocalStorageService.getBool("game_skipped") ?? false;
  static set gameSkipped(bool value) {
    LocalStorageService.setBool("game_skipped", value);
  }

  static bool get tutorialPassed =>
      LocalStorageService.getBool("tutorial_passed") ??
      ((Gamico.instance.tutorialSettings?.lessons ?? []).isEmpty == true);
  static set tutorialPassed(bool value) =>
      LocalStorageService.setBool("tutorial_passed", value);

  static int get plays => LocalStorageService.getInt("plays") ?? 0;
  static set plays(int value) => LocalStorageService.setInt("plays", value);

  static List<Offset> allPossibleOffsets = () {
    final offsets = <Offset>[];

    for (int i = 0; i < 5; i++) {
      for (int j = 0; j < 9; j++) {
        offsets.add(
          Offset(
            i * LayoutService.referenceWidth / 20 * 3,
            j * LayoutService.referenceWidth / 20 * 3,
          ),
        );
      }
    }

    return offsets;
  }();

  static PolygonUtility getPolygonFromOffsetAndSize(
      double x, double y, double width, double height) {
    return PolygonUtility([
      Point(x, y),
      Point(x + width, y),
      Point(x, y + height),
      Point(x + width, y + height),
    ]);
  }

  static Offset getRelativeReference(Offset offset) {
    final myTileReferenceX2 = offset.dx - 0; // left offset
    final myTileReferenceY2 = offset.dy - 0; // top offset

    final normalTileTrueReferenceX2 = myTileReferenceX2 / LayoutService.ratio;
    final normalTileTrueReferenceY2 = myTileReferenceY2 / LayoutService.ratio;

    return Offset(
      normalTileTrueReferenceX2,
      normalTileTrueReferenceY2,
    );
  }

  static double getSmallerMultipleOfUnitTriple(double number) {
    int quotient = (number / LayoutService.referenceWidth / 20 * 3).floor();
    return LayoutService.referenceWidth / 20 * 3 * quotient;
  }
}
