import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/services/global.dart';
import 'package:gamico/commons/services/locale.dart';
import 'package:gamico/commons/services/music.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gamico/commons/services/local_storage.dart';

part 'music_state.dart';

// Cubit for music management
class GamicoMusicCubit extends Cubit<GamicoMusicState> {
  // Constructor
  GamicoMusicCubit()
      : super(GamicoMusicState(
            mute: LocalStorageService.getBool("mute") ?? false)) {
    // Load music
    _initMusic();

    // Load bruitages
    _initBruitages();

    // Set ads mute mode
    MobileAds.instance.setAppMuted(state.mute);
  }

  // Initialization states
  bool musicInitialized = false;
  bool bruitagesInitialized = false;

  // Music player
  final _mainPlayer = AudioPlayer();

  // Bruitage players
  final _winPlayer = AudioPlayer();
  final _drawPlayer = AudioPlayer();
  final _losePlayer = AudioPlayer();
  final _clockPlayer = AudioPlayer();
  final _voicePlayer = AudioPlayer();

  // Bruitage players list
  List<AudioPlayer> get _bruitagePlayers => [
        _winPlayer,
        _drawPlayer,
        _losePlayer,
        _voicePlayer,
        _clockPlayer,
      ];

  // All players list
  List<AudioPlayer> get _allPlayers => [
        _mainPlayer,
        _winPlayer,
        _drawPlayer,
        _losePlayer,
        _voicePlayer,
        _clockPlayer,
      ];

  // Init music
  Future<void> _initMusic() async {
    if (GameService.tutorialPassed) {
      await _mainPlayer.setAsset("assets/musics/main.aac");
    }

    // else {
    //   await _mainPlayer.setAsset("assets/musics/game.aac");
    // }

    await _mainPlayer.setLoopMode(LoopMode.all);

    musicInitialized = true;

    if (!state.mute) {
      await GamicoGlobalService.waitWhile(() =>
          WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed);

      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> setMainMusicAsset() async {
    await _mainPlayer.setAsset("assets/musics/main.aac");
  }

  Future<void> setVictoryMusicAsset() async {
    await _mainPlayer.setAsset("assets/musics/victory.aac");
  }

  Future<void> setDefeatMusicAsset() async {
    await _mainPlayer.setAsset("assets/musics/defeat.aac");
  }

  Future<void> setDrawMusicAsset() async {
    await _mainPlayer.setAsset("assets/musics/draw.aac");
  }

  //

  Future<void> playMainPlayer() async {
    await _mainPlayer.safelyPlay();
  }

  Future<void> playMainMusic() async {
    if (!state.mute) {
      await _mainPlayer.setAsset("assets/musics/main.aac");
      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> playVictoryMusic() async {
    if (!state.mute) {
      await _mainPlayer.setAsset("assets/musics/victory.aac");
      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> playDrawMusic() async {
    if (!state.mute) {
      await _mainPlayer.setAsset("assets/musics/draw.aac");
      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> playDefeatMusic() async {
    if (!state.mute) {
      await _mainPlayer.setAsset("assets/musics/defeat.aac");
      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> playGameMusic() async {
    if (!state.mute) {
      await _mainPlayer.setAsset("assets/musics/game.aac");
      await _mainPlayer.safelyPlay();
    }
  }

  // Init bruitages
  Future<void> _initBruitages() async {
    await Future.wait([
      _winPlayer.setAsset("assets/bruitages/win.wav"),
      _drawPlayer.setAsset("assets/bruitages/draw.wav"),
      _losePlayer.setAsset("assets/bruitages/lose.wav"),
      _clockPlayer.setAsset("assets/bruitages/clock.wav"),
    ]);

    await _clockPlayer.setLoopMode(LoopMode.all);

    bruitagesInitialized = true;
  }

  // Play music
  Future<void> _playMusic() async {
    await GamicoGlobalService.waitWhile(() => !musicInitialized);

    await _mainPlayer.setVolume(1);

    if (_mainPlayer.playerState.playing) {
      await _mainPlayer.stop();
      await _mainPlayer.seek(Duration.zero);
    }

    await _mainPlayer.safelyPlay();
  }

  // Pause music
  Future<void> pauseMusic() async {
    await _mainPlayer.pause();
  }

  // Play bruitage
  Future<void> playBruitage(String source, [bool force = false]) async {
    if (!state.mute || force) {
      final tmpPlayer = AudioPlayer();
      await tmpPlayer.setAsset(source);
      await tmpPlayer.safelyPlay();
      tmpPlayer.dispose();
    }
  }

  Future<void> _playBruitageDirectly(AudioPlayer bruitagePlayer) async {
    if (!state.mute) {
      await GamicoGlobalService.waitWhile(() => !bruitagesInitialized);

      await bruitagePlayer.stop();
      await bruitagePlayer.seek(Duration.zero);
      await bruitagePlayer.safelyPlay();
    }
  }

  // Toggle muting state
  Future<void> toggle() async {
    playBruitage("assets/bruitages/click.wav", true);

    // Emit state
    emit(state.copyWith(
      mute: !state.mute,
    ));

    // Toggle players playing state
    if (state.mute) {
      final List<Future<void>> playerFutures = [];

      for (final player in _allPlayers) {
        playerFutures.add(player.stop());
        playerFutures.add(player.setVolume(0));
      }

      await Future.wait(playerFutures);
    } else {
      Future.wait([
        _playMusic(),
        ..._bruitagePlayers.map((bruitagePlayer) {
          return bruitagePlayer.setVolume(1);
        })
      ]);
    }

    await Future.wait([
      // Set ads mute mode
      MobileAds.instance.setAppMuted(state.mute),

      // Save muting state
      LocalStorageService.setBool("mute", state.mute),
    ]);
  }

  // Pause players
  Future<void> pause() async {
    await GamicoGlobalService.waitWhile(
        () => !musicInitialized || !bruitagesInitialized);

    await Future.wait([
      _mainPlayer.pause(),
      ..._bruitagePlayers.map((bruitagePlayer) {
        return bruitagePlayer.stop();
      }),
    ]);
  }

  // Resume players
  Future<void> resume() async {
    if (!state.mute) {
      await _playMusic();
    }
  }

  // Play click bruitage
  Future<void> playClickBruitage() async {
    await playBruitage("assets/bruitages/click.wav");
  }

  // Play lock bruitage
  Future<void> playLockBruitage() async {
    await playBruitage("assets/bruitages/lock.wav");
  }

  // Play move bruitage
  Future<void> playMoveBruitage() async {
    await playBruitage("assets/bruitages/move.wav");
  }

  // Play popup open bruitage
  Future<void> playPopupOpenBruitage() async {
    await playBruitage("assets/bruitages/popup_open.wav");
  }

  // Play popup close bruitage
  Future<void> playPopupCloseBruitage() async {
    await playBruitage("assets/bruitages/popup_close.mp3");
  }

  // Play win bruitage
  Future<void> playWinBruitage() async {
    await _playBruitageDirectly(_winPlayer);
  }

  // Play draw bruitage
  Future<void> playDrawBruitage() async {
    await _playBruitageDirectly(_drawPlayer);
  }

  // Play lose bruitage
  Future<void> playLoseBruitage() async {
    await _playBruitageDirectly(_losePlayer);
  }

  // Play voice bruitage
  Future<void> playVoiceBruitage(String voice) async {
    final String finalLanguageCode;
    final languageCode = LocaleService.currentLocale.languageCode;

    if (["fr", "en"].contains(languageCode)) {
      finalLanguageCode = languageCode;
    } else {
      finalLanguageCode = "en";
    }

    await playBruitage("assets/voices/$finalLanguageCode/$voice.mp3");
  }

  Future<void> playClockBruitage() async {
    if (!_clockPlayer.playing) {
      await _playBruitageDirectly(_clockPlayer);
    }
  }

  Future<void> stopClockBruitage() async {
    await _clockPlayer.stop();
  }

  // Close cubit
  @override
  Future<void> close() async {
    await Future.wait([
      _mainPlayer.stop(),
      _winPlayer.stop(),
      _drawPlayer.stop(),
      _losePlayer.stop(),
      _voicePlayer.stop(),
      _clockPlayer.stop(),
    ]);

    await Future.wait([
      _mainPlayer.dispose(),
      _winPlayer.dispose(),
      _drawPlayer.dispose(),
      _losePlayer.dispose(),
      _voicePlayer.dispose(),
      _clockPlayer.dispose(),
    ]);

    return super.close();
  }

  // Future<void> playWrongBruitage() async =>
  //     await playBruitage("assets/bruitages/wrong.mp3");
  // Future<void> playPlaceBruitage() async =>
  //     await playBruitage("assets/bruitages/place.wav");
  // Future<void> playSliceBruitage() async =>
  //     await playBruitage("assets/bruitages/slice.wav");
  // Future<void> playDragBruitage() async =>
  //     await playBruitage("assets/bruitages/drag.wav");
  // Future<void> playBackBruitage() async =>
  //     await playBruitage("assets/bruitages/back.mp3");
  // Future<void> playTransformationBruitage() async =>
  //     await playBruitage("assets/bruitages/transformation.wav");
  // Future<void> playPanBruitage() async =>
  //     await playBruitage("assets/bruitages/pan.wav");
}

extension on AudioPlayer {
  Future<void> safelyPlay() async {
    await GamicoGlobalService.waitWhile(() => MusicService.pausedByAd);

    if (!MusicService.mute) {
      await play();
    }
  }
}
