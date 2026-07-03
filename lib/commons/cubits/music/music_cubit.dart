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
    : super(
        GamicoMusicState(mute: LocalStorageService.getBool("mute") ?? false),
      ) {
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
  final _firePlayer = AudioPlayer();
  final _voicePlayer = AudioPlayer();

  // Bruitage players list
  List<AudioPlayer> get _bruitagePlayers => [
    _winPlayer,
    _drawPlayer,
    _losePlayer,
    _voicePlayer,
    _clockPlayer,
    _firePlayer,
  ];

  // All players list
  List<AudioPlayer> get _allPlayers => [
    _mainPlayer,
    _winPlayer,
    _drawPlayer,
    _losePlayer,
    _voicePlayer,
    _clockPlayer,
    _firePlayer,
  ];

  double _currentVolume = 1;

  void setGlobalVolume(double volume) {
    _currentVolume = volume;

    for (final player in _allPlayers) {
      player.setVolume(volume);
    }
  }

  // Init music
  Future<void> _initMusic() async {
    if (GameService.tutorialPassed) {
      await _mainPlayer.safelySetAsset("assets/musics/main.opus");
    }

    // else {
    //   await _mainPlayer.setAsset("assets/musics/game.opus");
    // }

    await _mainPlayer.setLoopMode(LoopMode.all);

    musicInitialized = true;

    if (!state.mute) {
      await GamicoGlobalService.waitWhile(
        () =>
            WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed,
      );

      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> setMainMusicAsset() async {
    await _mainPlayer.safelySetAsset("assets/musics/main.opus");
  }

  Future<void> setVictoryMusicAsset() async {
    await _mainPlayer.safelySetAsset("assets/musics/victory.opus");
  }

  Future<void> setDefeatMusicAsset() async {
    await _mainPlayer.safelySetAsset("assets/musics/defeat.opus");
  }

  Future<void> setDrawMusicAsset() async {
    await _mainPlayer.safelySetAsset("assets/musics/draw.aac");
  }

  //

  Future<void> playMainPlayer() async {
    await _mainPlayer.safelyPlay();
  }

  Future<void> playMainMusic() async {
    if (!state.mute) {
      await _mainPlayer.safelySetAsset("assets/musics/main.opus");
      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> playVictoryMusic() async {
    if (!state.mute) {
      await _mainPlayer.safelySetAsset("assets/musics/victory.opus");
      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> playDrawMusic() async {
    if (!state.mute) {
      await _mainPlayer.safelySetAsset("assets/musics/draw.aac");
      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> playDefeatMusic() async {
    if (!state.mute) {
      await _mainPlayer.safelySetAsset("assets/musics/defeat.opus");
      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> playGameMusic() async {
    if (!state.mute) {
      await _mainPlayer.safelySetAsset("assets/musics/game.opus");
      await _mainPlayer.safelyPlay();
    }
  }

  // Init bruitages
  Future<void> _initBruitages() async {
    await Future.wait([
      _winPlayer.safelySetAsset("assets/bruitages/win.opus"),
      _drawPlayer.safelySetAsset("assets/bruitages/draw.opus"),
      _losePlayer.safelySetAsset("assets/bruitages/lose.opus"),
      _clockPlayer.safelySetAsset("assets/bruitages/clock.opus"),
      _firePlayer.safelySetAsset("assets/bruitages/fire.opus"),
    ]);

    await _clockPlayer.setLoopMode(LoopMode.all);
    await _firePlayer.setLoopMode(LoopMode.all);

    bruitagesInitialized = true;
  }

  // Play music
  Future<void> _playMusic() async {
    await GamicoGlobalService.waitWhile(() => !musicInitialized);

    await _mainPlayer.setVolume(_currentVolume);

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

      try {
        await tmpPlayer.safelySetAsset(source);
        await tmpPlayer.safelyPlay(force);

        // Avoid disposing immediately to prevent native crashes (e.g., _setPlatformActive)
        // We wait for the audio to finish or for a reasonable timeout before disposing
        tmpPlayer.processingStateStream
            .firstWhere((s) => s == ProcessingState.completed)
            .timeout(
              const Duration(seconds: 10),
              onTimeout: () => ProcessingState.completed,
            )
            .then((_) => tmpPlayer.dispose())
            .catchError((_) => tmpPlayer.dispose());
      } catch (e) {
        debugPrint("Error playing bruitage ($source): $e");
        tmpPlayer.dispose();
      }
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
    playBruitage("assets/bruitages/click.opus", true);

    // Emit state
    emit(state.copyWith(mute: !state.mute));

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
          return bruitagePlayer.setVolume(_currentVolume);
        }),
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
      () => !musicInitialized || !bruitagesInitialized,
    );

    await Future.wait([
      _mainPlayer.pause(),
      ..._bruitagePlayers.map((bruitagePlayer) {
        return bruitagePlayer.stop();
      }),
      _clockPlayer.stop(),
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
    await playBruitage("assets/bruitages/click.opus");
  }

  // Play lock bruitage
  Future<void> playLockBruitage() async {
    await playBruitage("assets/bruitages/lock.opus");
  }

  // Play move bruitage
  Future<void> playMoveBruitage() async {
    await playBruitage("assets/bruitages/move.opus");
  }

  // Play popup open bruitage
  Future<void> playPopupOpenBruitage() async {
    await playBruitage("assets/bruitages/popup_open.opus");
  }

  // Play popup close bruitage
  Future<void> playPopupCloseBruitage() async {
    await playBruitage("assets/bruitages/popup_close.opus");
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

  Future<void> playFireBruitage() async {
    if (!_firePlayer.playing) {
      await _playBruitageDirectly(_firePlayer);
    }
  }

  Future<void> stopFireBruitage() async {
    await _firePlayer.stop();
    await _firePlayer.seek(Duration.zero);
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
      _firePlayer.stop(),
    ]);

    await Future.wait([
      _mainPlayer.dispose(),
      _winPlayer.dispose(),
      _drawPlayer.dispose(),
      _losePlayer.dispose(),
      _voicePlayer.dispose(),
      _clockPlayer.dispose(),
      _firePlayer.dispose(),
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
  Future<void> safelySetAsset(String asset) async {
    try {
      await setAsset(asset);
    } catch (e) {
      debugPrint("Error setting asset ($asset): $e");
    }
  }

  Future<void> safelyPlay([bool force = false]) async {
    await GamicoGlobalService.waitWhile(() => MusicService.pausedByAd);

    if (!MusicService.mute || force) {
      try {
        await play();
      } catch (e) {
        debugPrint(e.toString());
      }
    }
  }
}
