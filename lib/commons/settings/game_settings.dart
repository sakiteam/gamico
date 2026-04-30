import 'package:flutter/material.dart';

@immutable
class GameSettings {
  final int playMinimumCoins;
  final bool ignoreMinimumCoinsToPlay;

  const GameSettings({
    this.playMinimumCoins = 3,
    this.ignoreMinimumCoinsToPlay = false,
  });
}
