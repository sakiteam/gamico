import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/services/global.dart';
import 'package:gamico/commons/services/locale.dart';
import 'package:gamico/commons/services/music.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:audio_session/audio_session.dart';

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

    // Set ads mute mode once the SDK is ready (non-blocking for the
    // constructor — runs asynchronously in the background).
    _initAdsMuteState();

    // Configure AudioSession for iOS interruption handling
    _initAudioSession();
  }

  /// Waits for the MobileAds SDK to finish initialising, then applies
  /// the current mute state. Called from the constructor so it runs in
  /// the background without blocking widget creation.
  Future<void> _initAdsMuteState() async {
    try {
      await Gamico.mobileAdsInitFuture;
      MobileAds.instance.setAppMuted(state.mute);
    } catch (e) {
      debugPrint('MobileAds.setAppMuted failed: $e');
    }
  }

  /// Configures the iOS AVAudioSession and handles audio interruptions (calls, Siri, etc.).
  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());

      _interruptionSub?.cancel();
      _interruptionSub = session.interruptionEventStream.listen((event) {
        if (_isDisposed) return;
        if (event.begin) {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _mainPlayer.setVolume(_currentVolume * 0.5);
              break;
            case AudioInterruptionType.pause:
            case AudioInterruptionType.unknown:
              pause();
              break;
          }
        } else {
          switch (event.type) {
            case AudioInterruptionType.duck:
              _mainPlayer.setVolume(_currentVolume * _musicDuck);
              break;
            case AudioInterruptionType.pause:
              resume();
              break;
            case AudioInterruptionType.unknown:
              break;
          }
        }
      });
    } catch (e) {
      debugPrint('AudioSession configuration failed: $e');
    }
  }

  // Initialization states
  bool musicInitialized = false;
  bool bruitagesInitialized = false;
  bool _isDisposed = false;
  StreamSubscription<AudioInterruptionEvent>? _interruptionSub;

  // Music player
  final _mainPlayer = AudioPlayer();

  // Bruitage players
  final _winPlayer = AudioPlayer();
  final _drawPlayer = AudioPlayer();
  final _losePlayer = AudioPlayer();
  final _clockPlayer = AudioPlayer();
  final _firePlayer = AudioPlayer();
  final _voicePlayer = AudioPlayer();

  // Fixed pool of 2 players for one-shot bruitages (click, lock, move, etc.).
  // Reusing a pool avoids creating a new ExoPlayer pipeline on every call,
  // which would cause OOM on low-end devices (128 MB heap).
  final _oneShotPool = [AudioPlayer(), AudioPlayer()];
  int _oneShotIndex = 0;

  // Bruitage players list
  List<AudioPlayer> get _bruitagePlayers => [
    _winPlayer,
    _drawPlayer,
    _losePlayer,
    _voicePlayer,
    _clockPlayer,
    _firePlayer,
    ..._oneShotPool,
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
    ..._oneShotPool,
  ];

  double _currentVolume = 1;

  // Voice-chat ducking factors: while an in-game voice chat is running the
  // music drops to 10% and the sound effects to 50% so voices stay clear.
  double _musicDuck = 1;
  double _bruitageDuck = 1;

  void setGlobalVolume(double volume) {
    _currentVolume = volume;

    _mainPlayer.setVolume(volume * _musicDuck);
    for (final player in _bruitagePlayers) {
      player.setVolume(volume * _bruitageDuck);
    }
  }

  /// An in-game voice chat started: lower the music to 10% of its volume and
  /// the sound effects to 50%.
  Future<void> duckForVoiceChat() async {
    _musicDuck = 0.1;
    _bruitageDuck = 0.5;
    await _applyDucking();
  }

  /// The voice chat ended: music and sound effects return to normal volume.
  Future<void> restoreAfterVoiceChat() async {
    _musicDuck = 1;
    _bruitageDuck = 1;
    await _applyDucking();
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      debugPrint('AudioSession restoreAfterVoiceChat failed: $e');
    }
  }

  Future<void> _applyDucking() async {
    await Future.wait([
      _mainPlayer.setVolume(_currentVolume * _musicDuck),
      ..._bruitagePlayers.map(
        (player) => player.setVolume(_currentVolume * _bruitageDuck),
      ),
    ]);
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
    if (_isDisposed) return;

    await _mainPlayer.setVolume(_currentVolume);

    if (_mainPlayer.playerState.playing) {
      await _mainPlayer.stop();
      await _mainPlayer.seek(Duration.zero);
    }

    await _mainPlayer.safelyPlay(false, _isDisposed);
  }

  // Pause music
  Future<void> pauseMusic() async {
    await _mainPlayer.pause();
  }

  Future<void> playBruitage(String source, [bool force = false]) async {
    if (_isDisposed) return;
    if (!state.mute || force) {
      // Reuse a player from the fixed pool instead of allocating a new
      // ExoPlayer pipeline each time (prevents OOM on low-end devices).
      final player = _oneShotPool[_oneShotIndex % _oneShotPool.length];
      _oneShotIndex++;

      try {
        // Stop any previous sound still playing on this slot.
        await player.stop();
        await player.safelySetAsset(source);
        // One-shot effects follow the voice-chat ducking too.
        if (_bruitageDuck < 1) {
          await player.setVolume(_currentVolume * _bruitageDuck);
        } else {
          await player.setVolume(_currentVolume);
        }
        await player.safelyPlay(force, _isDisposed);
      } catch (e) {
        debugPrint("Error playing bruitage ($source): $e");
      }
    }
  }

  Future<void> _playBruitageDirectly(AudioPlayer bruitagePlayer) async {
    if (!state.mute) {
      await GamicoGlobalService.waitWhile(() => !bruitagesInitialized);
      if (_isDisposed) return;

      await bruitagePlayer.stop();
      await bruitagePlayer.seek(Duration.zero);
      await bruitagePlayer.safelyPlay(false, _isDisposed);
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

  /// Stops every looping in-game sound effect at once (fire + clock). Called
  /// when leaving a game so no bruitage keeps playing past the game screen.
  Future<void> stopGameBruitages() async {
    await Future.wait([
      _firePlayer.stop(),
      _clockPlayer.stop(),
    ]);
    await _firePlayer.seek(Duration.zero);
  }

  // Close cubit
  @override
  Future<void> close() async {
    _isDisposed = true;
    await _interruptionSub?.cancel();
    _interruptionSub = null;

    for (final player in _allPlayers) {
      try {
        await player.stop();
      } catch (_) {}
    }

    for (final player in _allPlayers) {
      try {
        await player.dispose();
      } catch (_) {}
    }

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

  Future<void> safelyPlay([bool force = false, bool isDisposed = false]) async {
    try {
      await GamicoGlobalService.waitWhile(() => MusicService.pausedByAd);
      if (isDisposed) return;

      if (!MusicService.mute || force) {
        await play();
      }
    } catch (e) {
      debugPrint("AudioPlayer.play error caught safely: $e");
    }
  }
}
