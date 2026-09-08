import 'package:flutter/material.dart';

@immutable
class MusicSettings {
  final String mainMusicAsset;
  final String gameMusicAsset;
  final String victoryMusicAsset;
  final String defeatMusicAsset;
  final String drawMusicAsset;

  const MusicSettings({
    this.mainMusicAsset = "assets/musics/main.opus",
    this.gameMusicAsset = "assets/musics/game.opus",
    this.victoryMusicAsset = "assets/musics/victory.opus",
    this.defeatMusicAsset = "assets/musics/defeat.opus",
    this.drawMusicAsset = "assets/musics/draw.opus",
  });
}

const defaultMusicSettings = MusicSettings();
