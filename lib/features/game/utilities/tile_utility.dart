import 'dart:math';
import 'package:flutter/material.dart';
import 'package:gamico/commons/services/layout.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';

/// Utility class that contains information about a game tile
class TileUtility {
  /* MEMBER PROPERTIES */

  double x;
  double y;
  late double life;
  String color;
  int coupleToGrant;
  int coupleToChoose;
  // CardUtility card;
  GamicoGameCubit gameCubit;
  bool refreshEnabled = true;
  bool wreckingEnabled = false;
  bool cloning = false;
  bool vortexing = false;
  bool destroyed = false;

  // late final BallUtility bigBall;
  // late final BallUtility smallBall;

  final DateTime date = DateTime.now();

  final List<TileUtility> targets = [];
  final List<TileUtility> paralyzers = [];
  final List<TileUtility> connectionsBoosters = [];
  final List<TileUtility> connectionsDeleters = [];
  final List<TileUtility> frozers = [];
  // final List<CoupleUtility> couplesWhereSource = [];
  // final List<CoupleUtility> couplesWhereDestination = [];
  final List<TileUtility> invulnerablers = [];
  final List<TileUtility> cancellers = [];
  final List<TileUtility> speedUppers = [];
  final List<TileUtility> attackUppers = [];
  final List<TileUtility> supportUppers = [];
  final List<TileUtility> resistanceUppers = [];
  final List<TileUtility> speedDowners = [];
  final List<TileUtility> attackDowners = [];
  final List<TileUtility> supportDowners = [];
  final List<TileUtility> resistanceDowners = [];

  TileUtility({
    required this.x,
    required this.y,
    required this.color,
    this.coupleToGrant = 0,
    this.coupleToChoose = 0,
    double? life,
    required this.gameCubit,
  });

  /* GETTERS */

  int get connections {
    return targets.length;
  }

  double get speedFactor {
    return pow(
            2,
            (speedUppers.where((element) => !element.cancelled).length -
                speedDowners.where((element) => !element.cancelled).length))
        .toDouble();
  }

  double get attackCurrentFactor {
    return pow(
            2,
            attackUppers.where((element) => !element.cancelled).length -
                attackDowners.where((element) => !element.cancelled).length)
        .toDouble();
  }

  double get supportCurrentFactor {
    return pow(
            2,
            supportUppers.where((element) => !element.cancelled).length -
                supportDowners.where((element) => !element.cancelled).length)
        .toDouble();
  }

  double get resistanceCurrentFactor {
    return pow(
            2,
            resistanceUppers.where((element) => !element.cancelled).length -
                resistanceDowners.where((element) => !element.cancelled).length)
        .toDouble();
  }

  bool get invulnerable {
    return invulnerablers.where((element) => !element.cancelled).isNotEmpty;
  }

  bool get blocked {
    return paralyzers.where((element) => !element.cancelled).isNotEmpty;
  }

  bool get emissionBlocked {
    return blocked || !refreshEnabled;
  }

  bool get cancelled {
    return cancellers.where((element) => !element.cancelled).isNotEmpty;
  }

  int get coordsX {
    return x ~/ 1;
  }

  int get coordsY {
    return y ~/ 1;
  }

  String get coords {
    return "$coordsX $coordsY";
  }

  Offset get coordsOffset {
    return Offset(coordsX.toDouble(), coordsY.toDouble());
  }

  bool get frozen {
    return frozers.where((element) => !element.cancelled).isNotEmpty;
  }

  Offset get offset {
    return Offset(x, y);
  }

  /* CONSTRUCTOR */

  // TileUtility({
  //   required this.level,
  //   required this.color,
  //   // this.onColorChanged,
  //   this.x = 0,
  //   this.y = 0,
  //   // this.connections = 0,
  //   // this.coupleToGrantIndex = 0,
  //   // this.coupleToChooseIndex = 0,
  //   required this.specialType,
  //   // required this.date,
  //   // this.blocked = false,
  //   // this.speedFactor = 1,
  // }) {
  //   life = maxLife;
  // }

  // factory TileUtility.fromTile(TileUtility tile) {
  //   return TileUtility(
  //     // level: level,
  //     // color: color,
  //     // specialType: specialType,
  //     // gameCubit: gameCubit,

  //     x: tile.x,
  //     y: tile.y,
  //     color: tile.color,
  //     // date: DateTime.now(),
  //     // connections: connections ?? this.connections,
  //     // coupleToGrantIndex: coupleToGrantIndex ?? this.coupleToGrantIndex,
  //     // coupleToChooseIndex: coupleToChooseIndex ?? this.coupleToChooseIndex,
  //     specialType: tile.specialType,
  //     level: tile.level,
  //     // blocked: blocked ?? this.blocked,
  //     // speedFactor: speedFactor ?? this.speedFactor,
  //     // inputs: inputs ?? this.inputs,
  //     // onColorChanged: tile.onColorChanged,
  //   );
  // }

  /* COPY */

  // TileUtility copyWith({
  //   double? x,
  //   double? y,
  //   String? color,
  //   // int? connections,
  //   // int? coupleToGrantIndex,
  //   // int? coupleToChooseIndex,
  //   int? level,
  //   // bool? blocked,
  //   // double? speedFactor,
  //   // int? inputs,
  //   // void Function(String)? onColorChanged,
  //   // GameCubit? gameCubit,
  // }) {
  //   return TileUtility(
  //     x: x ?? this.x,
  //     y: y ?? this.y,
  //     color: color ?? this.color,
  //     // connections: connections ?? this.connections,
  //     // coupleToGrantIndex: coupleToGrantIndex ?? this.coupleToGrantIndex,
  //     // coupleToChooseIndex: coupleToChooseIndex ?? this.coupleToChooseIndex,
  //     specialType: specialType ?? this.specialType,
  //     level: level ?? this.level,
  //     // blocked: blocked ?? this.blocked,
  //     // speedFactor: speedFactor ?? this.speedFactor,
  //     // inputs: inputs ?? this.inputs,
  //     // onColorChanged: onColorChanged ?? this.onColorChanged,
  //     // gameCubit: gameCubit ?? this.gameCubit,
  //   );
  // }

  bool isValidBound(Offset element) {
    return element.dx >= 0 &&
        element.dx <= 4 &&
        element.dy >= 1 &&
        element.dy <= 7;
  }

  List<Offset> get adjacentOffsets {
    return [
      // Line 1
      Offset(coordsX - 1, coordsY - 1),
      Offset(coordsX + 0, coordsY - 1),
      Offset(coordsX + 1, coordsY - 1),

      // Line 2
      Offset(coordsX - 1, coordsY + 0),
      Offset(coordsX + 1, coordsY + 0),

      // Line 3
      Offset(coordsX - 1, coordsY + 1),
      Offset(coordsX + 0, coordsY + 1),
      Offset(coordsX + 1, coordsY + 1),
    ].where((element) => isValidBound(element)).toList();
  }

  List<Offset> get rowOffsets {
    final List<Offset> offsets = [];

    for (int i = 0; i < 5; i++) {
      final currentOffset = Offset(i.toDouble(), coordsY.toDouble());

      if (currentOffset != coordsOffset) {
        offsets.add(currentOffset);
      }
    }

    return offsets;
  }

  List<Offset> get colOffsets {
    final List<Offset> offsets = [];

    for (int i = 1; i <= 7; i++) {
      final currentOffset = Offset(coordsX.toDouble(), i.toDouble());

      if (currentOffset != coordsOffset) {
        offsets.add(currentOffset);
      }
    }

    return offsets;
  }

  List<Offset> get diagonalOffsets {
    final List<Offset> offsets = [];

    final double leftDiagonalX = coordsX - 4;
    final double leftDiagonalY = coordsY - 4;

    final double rightDiagonalX = coordsX + 4;
    final double rightDiagonalY = coordsY - 4;

    for (int i = 0; i < 9; i++) {
      // Left diagonal
      final leftCurrentOffset = Offset(leftDiagonalX + i, leftDiagonalY + i);

      // Right diagonal
      final rightCurrentOffset = Offset(rightDiagonalX - i, rightDiagonalY + i);

      if (leftCurrentOffset != coordsOffset) {
        offsets.add(leftCurrentOffset);
      }

      if (rightCurrentOffset != coordsOffset) {
        offsets.add(rightCurrentOffset);
      }
    }

    return offsets;
  }

  List<TileUtility> get adjacentTiles {
    return [];
  }

  List<TileUtility> get rowTiles {
    final List<TileUtility> tiles = [];

    return tiles;
  }

  List<TileUtility> get colTiles {
    final List<TileUtility> tiles = [];

    return tiles;
  }

  List<TileUtility> get diagonalTiles {
    return [];
  }

  //

  bool hasPointInside(Offset point) {
    if (point.dx < x) {
      return false;
    }

    if (point.dx > x + LayoutService.referenceWidth / 20 * 3) {
      return false;
    }

    if (point.dy < y) {
      return false;
    }

    if (point.dy > y + LayoutService.referenceWidth / 20 * 3) {
      return false;
    }

    return true;
  }
}
