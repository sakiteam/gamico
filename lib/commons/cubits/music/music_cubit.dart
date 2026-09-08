import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:just_audio/just_audio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:gamico/commons/services/admob.dart';
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
      await AdmobService.initFuture;
      MobileAds.instance.setAppMuted(state.mute);
    } catch (e) {
      debugPrint('MobileAds.setAppMuted failed: $e');
    }
  }

  /// The session an in-game voice call needs.
  ///
  /// Only the iOS half differs from [AudioSessionConfiguration.music]: the
  /// `playback` category that one uses has no input path at all, so the moment
  /// it is applied the microphone goes silent. The Android half is left
  /// untouched on purpose — routing and focus there are WebRTC's own audio
  /// manager's business, and asking for `voiceCommunication` attributes would
  /// send the game music out of the earpiece.
  static const AudioSessionConfiguration _voiceChatSession =
      AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
        // No `defaultToSpeaker`: the call sets its own route through
        // `Helper.setSpeakerphoneOn`, and making the speaker the category
        // default would swallow the "earpiece" half of that toggle.
        avAudioSessionCategoryOptions:
            AVAudioSessionCategoryOptions.allowBluetooth,
        avAudioSessionMode: AVAudioSessionMode.voiceChat,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType: AndroidAudioFocusGainType.gain,
      );

  /// True between [duckForVoiceChat] and [restoreAfterVoiceChat].
  bool _voiceChatActive = false;

  /// The session configuration that currently applies. Every player activation
  /// re-applies it (see [_applyAudioSessionConfiguration]), so it has to
  /// follow whether a call is running.
  AudioSessionConfiguration get _sessionConfiguration => _voiceChatActive
      ? _voiceChatSession
      : const AudioSessionConfiguration.music();

  /// Applies [_sessionConfiguration] to the shared AVAudioSession.
  ///
  /// This matters far more than it looks: `just_audio` calls
  /// `AudioSession.setActive(true)` on **every** `play()` — the music, but
  /// also every single sound effect — and that re-applies whatever
  /// configuration is on file. With the music configuration on file, the first
  /// card sound of a match dropped the session back to `playback` and cut the
  /// microphone mid-call, on a table where the call had connected perfectly.
  Future<void> _applyAudioSessionConfiguration() async {
    final session = await AudioSession.instance;
    await session.configure(_sessionConfiguration);
  }

  /// Configures the iOS AVAudioSession and handles audio interruptions (calls, Siri, etc.).
  Future<void> _initAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(_sessionConfiguration);

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

  // Fixed pool of 2 players for every one-shot bruitage (click, lock, move,
  // win, lose, voices…).
  //
  // A `just_audio` player builds a whole ExoPlayer pipeline — around three
  // native threads — the first time it is handed an asset, and a 32-bit
  // low-end device runs out of thread stacks long before it runs out of heap
  // (`OutOfMemoryError: pthread_create (1040KB stack) failed`). Two pipelines
  // shared by every one-shot sound, rather than one dedicated player per
  // sound, is what keeps that budget in hand.
  final _oneShotPool = [AudioPlayer(), AudioPlayer()];
  int _oneShotIndex = 0;

  static const String _clockAsset = "assets/bruitages/clock.opus";
  static const String _fireAsset = "assets/bruitages/fire.opus";

  /// Looping sound effects are the only ones that need a player of their own,
  /// and only while they actually loop: they are built on first use and
  /// released [_loopReleaseDelay] after they stop, so an app sitting in a menu
  /// holds no audio pipeline it isn't using.
  ///
  /// [_loopPlayers] holds the in-flight creation so two concurrent starts share
  /// one player; [_readyLoopPlayers] holds the ones that exist right now (used
  /// for volume, ducking and shutdown).
  final Map<String, Future<AudioPlayer>> _loopPlayers = {};
  final Map<String, AudioPlayer> _readyLoopPlayers = {};
  final Map<String, Timer> _loopReleaseTimers = {};
  static const Duration _loopReleaseDelay = Duration(seconds: 30);

  // Bruitage players list
  List<AudioPlayer> get _bruitagePlayers => [
    ..._oneShotPool,
    ..._readyLoopPlayers.values,
  ];

  // All players list
  List<AudioPlayer> get _allPlayers => [_mainPlayer, ..._bruitagePlayers];

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

  /// An in-game voice chat started: hand the audio session over to the call
  /// and lower the music to 10% of its volume, the sound effects to 50%.
  Future<void> duckForVoiceChat() async {
    _voiceChatActive = true;
    try {
      await _applyAudioSessionConfiguration();
    } catch (e) {
      debugPrint('AudioSession duckForVoiceChat failed: $e');
    }
    _musicDuck = 0.1;
    _bruitageDuck = 0.5;
    await _applyDucking();
  }

  /// The voice chat ended: the session goes back to plain music playback, and
  /// music and sound effects return to normal volume.
  Future<void> restoreAfterVoiceChat() async {
    _voiceChatActive = false;
    _musicDuck = 1;
    _bruitageDuck = 1;
    await _applyDucking();
    try {
      await _applyAudioSessionConfiguration();
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
      await _mainPlayer.safelySetAsset(
        Gamico.instance.musicSettings.mainMusicAsset,
      );
    }

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

  /// Sets any music asset with loop mode.
  Future<void> setMusicAsset(String assetPath, {bool loop = true}) async {
    await _mainPlayer.safelySetAsset(assetPath);
    await _mainPlayer.setLoopMode(loop ? LoopMode.all : LoopMode.off);
  }

  Future<void> setMainMusicAsset() async {
    await _mainPlayer.safelySetAsset(
      Gamico.instance.musicSettings.mainMusicAsset,
    );
  }

  Future<void> setVictoryMusicAsset() async {
    await _mainPlayer.safelySetAsset(
      Gamico.instance.musicSettings.victoryMusicAsset,
    );
  }

  Future<void> setDefeatMusicAsset() async {
    await _mainPlayer.safelySetAsset(
      Gamico.instance.musicSettings.defeatMusicAsset,
    );
  }

  Future<void> setDrawMusicAsset() async {
    await _mainPlayer.safelySetAsset(
      Gamico.instance.musicSettings.drawMusicAsset,
    );
  }

  //

  Future<void> playMainPlayer() async {
    await _mainPlayer.safelyPlay();
  }

  /// Plays any music asset track in loop or one-shot mode.
  Future<void> playMusic(String assetPath, {bool loop = true}) async {
    if (!state.mute) {
      await _mainPlayer.safelySetAsset(assetPath);
      await _mainPlayer.setLoopMode(loop ? LoopMode.all : LoopMode.off);
      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> playMainMusic() async {
    if (!state.mute) {
      await _mainPlayer.safelySetAsset(
        Gamico.instance.musicSettings.mainMusicAsset,
      );
      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> playVictoryMusic() async {
    if (!state.mute) {
      await _mainPlayer.safelySetAsset(
        Gamico.instance.musicSettings.victoryMusicAsset,
      );
      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> playDrawMusic() async {
    if (!state.mute) {
      await _mainPlayer.safelySetAsset(
        Gamico.instance.musicSettings.drawMusicAsset,
      );
      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> playDefeatMusic() async {
    if (!state.mute) {
      await _mainPlayer.safelySetAsset(
        Gamico.instance.musicSettings.defeatMusicAsset,
      );
      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> playGameMusic() async {
    if (!state.mute) {
      await _mainPlayer.safelySetAsset(
        Gamico.instance.musicSettings.gameMusicAsset,
      );
      await _mainPlayer.safelyPlay();
    }
  }

  // Init bruitages
  //
  // Nothing is preloaded any more: one-shots set their asset on a pool player
  // at play time and looping effects are built on demand, so no audio pipeline
  // exists until a sound is actually played.
  Future<void> _initBruitages() async {
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

  /// Returns the player looping [asset], building it on first use.
  ///
  /// The future is memoised, so two starts racing each other share one player
  /// instead of leaving an orphaned pipeline behind.
  Future<AudioPlayer> _loopPlayer(String asset) {
    _loopReleaseTimers.remove(asset)?.cancel();

    return _loopPlayers.putIfAbsent(asset, () async {
      final player = AudioPlayer();
      await player.safelySetAsset(asset);
      await player.setLoopMode(LoopMode.all);
      await player.setVolume(_currentVolume * _bruitageDuck);
      _readyLoopPlayers[asset] = player;
      return player;
    });
  }

  /// Starts [asset] looping, unless it already is.
  Future<void> _startLoop(String asset) async {
    if (_isDisposed || state.mute) return;

    final player = await _loopPlayer(asset);
    if (_isDisposed) return;
    if (player.playing) return;

    await player.setVolume(_currentVolume * _bruitageDuck);
    await player.seek(Duration.zero);
    await player.safelyPlay(false, _isDisposed);
  }

  /// Stops [asset] and schedules its player for release.
  ///
  /// The delay matters: a clock effect is stopped and restarted on every turn,
  /// and rebuilding the pipeline each time would cost more than it saves. Only
  /// a loop that stays silent for [_loopReleaseDelay] gives its threads back.
  Future<void> _stopLoop(String asset, {bool immediate = false}) async {
    final player = _readyLoopPlayers[asset];
    if (player == null) {
      // Still being built: wait for it, then stop it like any other — without
      // this the pipeline would outlive the sound that asked for it.
      final pending = _loopPlayers[asset];
      if (pending == null) return;

      await pending;
      if (immediate) {
        await _releaseLoop(asset);
      } else {
        await _stopLoop(asset);
      }
      return;
    }

    try {
      await player.stop();
      await player.seek(Duration.zero);
    } catch (_) {}

    if (immediate) {
      await _releaseLoop(asset);
      return;
    }

    _loopReleaseTimers.remove(asset)?.cancel();
    _loopReleaseTimers[asset] = Timer(_loopReleaseDelay, () {
      _loopReleaseTimers.remove(asset);
      final current = _readyLoopPlayers[asset];
      if (current == null || current.playing) return;
      _releaseLoop(asset);
    });
  }

  /// Disposes the player of [asset], handing its native threads back.
  Future<void> _releaseLoop(String asset) async {
    _loopReleaseTimers.remove(asset)?.cancel();
    _loopPlayers.remove(asset);
    final player = _readyLoopPlayers.remove(asset);
    if (player == null) return;

    try {
      await player.dispose();
    } catch (_) {}
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
    await playBruitage("assets/bruitages/win.opus");
  }

  // Play draw bruitage
  Future<void> playDrawBruitage() async {
    await playBruitage("assets/bruitages/draw.opus");
  }

  // Play lose bruitage
  Future<void> playLoseBruitage() async {
    await playBruitage("assets/bruitages/lose.opus");
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
    await _startLoop(_clockAsset);
  }

  Future<void> stopClockBruitage() async {
    await _stopLoop(_clockAsset);
  }

  Future<void> playFireBruitage() async {
    await _startLoop(_fireAsset);
  }

  Future<void> stopFireBruitage() async {
    await _stopLoop(_fireAsset);
  }

  /// Stops every looping in-game sound effect at once (fire + clock) and gives
  /// their pipelines back right away. Called when leaving a game, so no
  /// bruitage keeps playing past the game screen and nothing keeps a native
  /// audio pipeline alive in the menus.
  Future<void> stopGameBruitages() async {
    await Future.wait([
      _stopLoop(_fireAsset, immediate: true),
      _stopLoop(_clockAsset, immediate: true),
    ]);
  }

  // Close cubit
  @override
  Future<void> close() async {
    _isDisposed = true;
    await _interruptionSub?.cancel();
    _interruptionSub = null;

    for (final timer in _loopReleaseTimers.values) {
      timer.cancel();
    }
    _loopReleaseTimers.clear();

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

    _loopPlayers.clear();
    _readyLoopPlayers.clear();

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
