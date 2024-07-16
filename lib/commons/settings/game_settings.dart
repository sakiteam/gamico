import 'package:flutter/material.dart';

@immutable
class GameSettings {
  final int playMinimumCoins;

  const GameSettings({
    this.playMinimumCoins = 3,
  });
}
