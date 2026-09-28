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

  /// When each pool slot was last handed a sound, so a new one goes to a slot
  /// that is free — or, failing that, to the one that has been playing longest.
  final Map<AudioPlayer, DateTime> _slotClaimedAt = {};

  /// Pool slots currently carrying a key sound (see [playKeyBruitage]): the
  /// ones an ordinary sound effect must not cut off while another will do.
  final Set<AudioPlayer> _keySlots = {};

  /// How long a slot counts as taken after being claimed, whatever its player
  /// reports: between `stop()` and the new asset loading it reads as idle, and
  /// a second sound fired in that gap would land on it too.
  static const Duration _slotClaimGrace = Duration(milliseconds: 300);

  /// Pool slots currently carrying a non-default speed/pitch. The slots are
  /// shared, so shaping set by one sound would otherwise leak into the next
  /// one to land on that slot; this is what says a reset is owed.
  final Set<AudioPlayer> _shapedSlots = {};

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

  /// The game's own mood on top of that: the music level and tempo a tense
  /// moment asks for (see [setMusicTension]). 1 and 1 at rest.
  double _musicTension = 1;
  double _musicTempo = 1;
  Timer? _tensionFade;

  /// The brief dip of a big impact (see [punchMusic]), on top of everything
  /// else. 1 at rest. Kept apart from [_musicTension]: the game's mood glides
  /// on its own clock, and a punch landing mid-glide must neither fight it nor
  /// leave it stranded at the wrong level.
  double _musicPunch = 1;
  Timer? _punchTimer;

  /// What the music player's volume should be right now.
  double get _musicLevel =>
      _currentVolume * _musicDuck * _musicTension * _musicPunch;

  void setGlobalVolume(double volume) {
    _currentVolume = volume;

    _mainPlayer.setVolume(_musicLevel);
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
      _mainPlayer.setVolume(_musicLevel),
      ..._bruitagePlayers.map(
        (player) => player.setVolume(_currentVolume * _bruitageDuck),
      ),
    ]);
  }

  /// Lets a game make its music follow the tension at the table: [volume]
  /// scales the music (under the user's setting and any voice-chat ducking —
  /// 0.6 pulls it back to let a ticking clock through), [tempo] speeds it up
  /// (1.06 for a table about to be won). Both glide there over [fade] rather
  /// than jumping, and only touch the music — sound effects are left alone.
  ///
  /// Call with the defaults to put the music back as it was; a game must do so
  /// when it leaves, or the next screen inherits its mood.
  Future<void> setMusicTension({
    double volume = 1,
    double tempo = 1,
    Duration fade = const Duration(milliseconds: 600),
  }) async {
    final double targetVolume = volume.clamp(0.0, 1.0);
    final double targetTempo = tempo.clamp(0.5, 2.0);
    if (targetVolume == _musicTension && targetTempo == _musicTempo) return;

    _tensionFade?.cancel();
    final double fromVolume = _musicTension;
    final double fromTempo = _musicTempo;
    const int steps = 12;
    int step = 0;

    void apply(double t) {
      _musicTension = fromVolume + (targetVolume - fromVolume) * t;
      _musicTempo = fromTempo + (targetTempo - fromTempo) * t;
      if (_isDisposed || state.mute) return;
      _mainPlayer.setVolume(_musicLevel);
      _mainPlayer.setSpeed(_musicTempo);
    }

    if (fade <= Duration.zero) {
      apply(1);
      return;
    }
    _tensionFade = Timer.periodic(fade ~/ steps, (timer) {
      step++;
      apply(step / steps);
      if (step >= steps) {
        timer.cancel();
        if (identical(_tensionFade, timer)) _tensionFade = null;
      }
    });
  }

  /// Knocks the music down for an instant so a big impact is heard on its own,
  /// then lets it swell back: [dip] is the level it drops to (0.25 leaves a
  /// quarter of it), held for [hold], then brought back to full over [release].
  ///
  /// Meant for a game's heaviest hits — a chain landing, the card that ends a
  /// hand. Sound effects are left alone, and it composes with
  /// [setMusicTension] and voice-chat ducking rather than replacing them. A
  /// second punch while one is running simply takes over from wherever the
  /// level is, so a chain of impacts keeps the music low instead of pumping it.
  Future<void> punchMusic({
    double dip = 0.3,
    Duration hold = const Duration(milliseconds: 150),
    Duration release = const Duration(milliseconds: 800),
  }) async {
    if (_isDisposed || state.mute) return;

    _punchTimer?.cancel();
    // Never rise on the way down: a lighter punch during a heavier one must
    // not lift the music back up.
    _musicPunch = _musicPunch < dip ? _musicPunch : dip.clamp(0.0, 1.0);
    _mainPlayer.setVolume(_musicLevel);

    const int stepMs = 60;
    final int releaseSteps = (release.inMilliseconds / stepMs).ceil().clamp(
      1,
      60,
    );
    final double from = _musicPunch;
    int step = -1;
    final int holdSteps = (hold.inMilliseconds / stepMs).ceil();

    _punchTimer = Timer.periodic(Duration(milliseconds: stepMs), (timer) {
      step++;
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      // Holding: nothing to change, the dip is already applied.
      if (step < holdSteps) return;

      final double t = ((step - holdSteps + 1) / releaseSteps).clamp(0.0, 1.0);
      // Ease-out: most of the level comes back at once, the tail settles.
      _musicPunch = from + (1.0 - from) * (1.0 - (1.0 - t) * (1.0 - t));
      if (!state.mute) _mainPlayer.setVolume(_musicLevel);
      if (t >= 1.0) {
        _musicPunch = 1;
        timer.cancel();
        if (identical(_punchTimer, timer)) _punchTimer = null;
      }
    });
  }

  /// The track the app wants on the music player right now, whether or not it
  /// could be loaded.
  ///
  /// While muted the `play*Music` methods deliberately load nothing, so the
  /// player keeps whatever it held last (main menu music, the previous
  /// defeat jingle…). Without this record, un-muting mid-game resumed that
  /// stale track instead of the game music the page had asked for.
  String? _wantedMusicAsset;

  /// The asset actually loaded in [_mainPlayer].
  String? _loadedMusicAsset;

  /// Loop mode of the wanted track, re-applied when it is loaded late.
  LoopMode _wantedLoopMode = LoopMode.all;

  /// Loads [asset] on the music player and records it as the wanted track.
  Future<void> _loadMusicAsset(String asset) async {
    _wantedMusicAsset = asset;
    await _mainPlayer.safelySetAsset(asset);
    _loadedMusicAsset = asset;
  }

  /// Makes sure the wanted track is the loaded one. Used when the music starts
  /// after having been muted (un-mute, resume), where the player may still hold
  /// an older track.
  Future<void> _syncWantedMusic() async {
    final wanted = _wantedMusicAsset;
    if (wanted == null || wanted == _loadedMusicAsset) return;

    await _loadMusicAsset(wanted);
    await _mainPlayer.setLoopMode(_wantedLoopMode);
  }

  // Init music
  Future<void> _initMusic() async {
    if (GameService.tutorialPassed) {
      await _loadMusicAsset(Gamico.instance.musicSettings.mainMusicAsset);
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
    _wantedLoopMode = loop ? LoopMode.all : LoopMode.off;
    await _loadMusicAsset(assetPath);
    await _mainPlayer.setLoopMode(_wantedLoopMode);
  }

  Future<void> setMainMusicAsset() async {
    await _loadMusicAsset(Gamico.instance.musicSettings.mainMusicAsset);
  }

  Future<void> setVictoryMusicAsset() async {
    await _loadMusicAsset(Gamico.instance.musicSettings.victoryMusicAsset);
  }

  Future<void> setDefeatMusicAsset() async {
    await _loadMusicAsset(Gamico.instance.musicSettings.defeatMusicAsset);
  }

  Future<void> setDrawMusicAsset() async {
    await _loadMusicAsset(Gamico.instance.musicSettings.drawMusicAsset);
  }

  //

  Future<void> playMainPlayer() async {
    await _mainPlayer.safelyPlay();
  }

  /// Plays any music asset track in loop or one-shot mode.
  Future<void> playMusic(String assetPath, {bool loop = true}) async {
    _wantedMusicAsset = assetPath;
    _wantedLoopMode = loop ? LoopMode.all : LoopMode.off;

    if (!state.mute) {
      await _loadMusicAsset(assetPath);
      await _mainPlayer.setLoopMode(_wantedLoopMode);
      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> playMainMusic() async {
    final asset = Gamico.instance.musicSettings.mainMusicAsset;
    _wantedMusicAsset = asset;

    if (!state.mute) {
      await _loadMusicAsset(asset);
      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> playVictoryMusic() async {
    final asset = Gamico.instance.musicSettings.victoryMusicAsset;
    _wantedMusicAsset = asset;

    if (!state.mute) {
      await _loadMusicAsset(asset);
      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> playDrawMusic() async {
    final asset = Gamico.instance.musicSettings.drawMusicAsset;
    _wantedMusicAsset = asset;

    if (!state.mute) {
      await _loadMusicAsset(asset);
      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> playDefeatMusic() async {
    final asset = Gamico.instance.musicSettings.defeatMusicAsset;
    _wantedMusicAsset = asset;

    if (!state.mute) {
      await _loadMusicAsset(asset);
      await _mainPlayer.safelyPlay();
    }
  }

  Future<void> playGameMusic() async {
    final asset = Gamico.instance.musicSettings.gameMusicAsset;
    _wantedMusicAsset = asset;

    if (!state.mute) {
      await _loadMusicAsset(asset);
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

    // Muted since the track was chosen: load it now (see _wantedMusicAsset).
    await _syncWantedMusic();
    if (_isDisposed) return;

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

  /// Plays a one-shot sound effect.
  ///
  /// [gain], [speed] and [pitch] shape that single play, so the same sample can
  /// escalate instead of repeating identically — a combo whose every card hits
  /// louder, tighter and higher than the last. They are always applied, never
  /// left to carry over: the pool slots are shared, so a play that did not ask
  /// for them explicitly resets them to 1.0 rather than inheriting whatever the
  /// previous sound on that slot set.
  ///
  /// [gain] multiplies the global volume and is clamped to a sane range, so a
  /// caller can never blow past the user's volume setting by more than a hair.
  /// [speed] shortens the sample without moving its pitch (both platforms keep
  /// pitch: ExoPlayer via Sonic, AVPlayer via `AVAudioTimePitchAlgorithmTimeDomain`).
  /// [pitch] is **Android-only** in just_audio — on iOS, macOS and web it is a
  /// no-op, which is why it must never be the only thing carrying an effect.
  Future<void> playBruitage(
    String source, [
    bool force = false,
    double gain = 1.0,
    double speed = 1.0,
    double pitch = 1.0,
  ]) => _playOneShot(source, force, gain, speed, pitch, key: false);

  /// Plays a one-shot sound effect that must be heard through to its end — a
  /// game's final blow, the win or lose sting. With only two pool slots, three
  /// sounds landing together (the last card, its explosion, the fanfare) used
  /// to cut one of them short; a key sound keeps its slot until it finishes,
  /// unless every slot is already holding one.
  Future<void> playKeyBruitage(
    String source, {
    double gain = 1.0,
    double speed = 1.0,
    double pitch = 1.0,
  }) => _playOneShot(source, false, gain, speed, pitch, key: true);

  /// Whether [player] is still busy with the sound it was last handed.
  bool _slotBusy(AudioPlayer player) {
    final claimed = _slotClaimedAt[player];
    if (claimed != null &&
        DateTime.now().difference(claimed) < _slotClaimGrace) {
      return true;
    }
    final processing = player.processingState;
    return player.playing &&
        processing != ProcessingState.completed &&
        processing != ProcessingState.idle;
  }

  /// The pool slot a new one-shot sound goes to: a free one if there is one,
  /// else the longest-playing one not holding a key sound, else the
  /// longest-playing one outright.
  AudioPlayer _pickOneShotSlot() {
    final epoch = DateTime.fromMillisecondsSinceEpoch(0);
    final slots = [..._oneShotPool]
      ..sort(
        (a, b) =>
            (_slotClaimedAt[a] ?? epoch).compareTo(_slotClaimedAt[b] ?? epoch),
      );
    for (final slot in slots) {
      if (!_slotBusy(slot)) return slot;
    }
    for (final slot in slots) {
      if (!_keySlots.contains(slot)) return slot;
    }
    return slots.first;
  }

  Future<void> _playOneShot(
    String source,
    bool force,
    double gain,
    double speed,
    double pitch, {
    required bool key,
  }) async {
    if (_isDisposed) return;
    if (!state.mute || force) {
      // Reuse a player from the fixed pool instead of allocating a new
      // ExoPlayer pipeline each time (prevents OOM on low-end devices).
      final player = _pickOneShotSlot();
      _slotClaimedAt[player] = DateTime.now();
      if (key) {
        _keySlots.add(player);
      } else {
        _keySlots.remove(player);
      }

      try {
        // Stop any previous sound still playing on this slot.
        await player.stop();
        await player.safelySetAsset(source);
        // One-shot effects follow the voice-chat ducking too.
        final double base = _bruitageDuck < 1
            ? _currentVolume * _bruitageDuck
            : _currentVolume;
        await player.setVolume((base * gain).clamp(0.0, 1.0));
        // Only touched when actually asked for, and reset only when the slot
        // still carries a previous caller's shaping: these are platform-channel
        // round-trips on the hot path of every sound effect in every game, and
        // the overwhelming majority of calls want neither.
        final bool shaped = speed != 1.0 || pitch != 1.0;
        if (shaped || _shapedSlots.contains(player)) {
          await player.safelySetSpeed(speed.clamp(0.5, 2.0));
          await player.safelySetPitch(pitch.clamp(0.5, 2.0));
          if (shaped) {
            _shapedSlots.add(player);
          } else {
            _shapedSlots.remove(player);
          }
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
    await playKeyBruitage("assets/bruitages/win.opus");
  }

  // Play draw bruitage
  Future<void> playDrawBruitage() async {
    await playKeyBruitage("assets/bruitages/draw.opus");
  }

  // Play lose bruitage
  Future<void> playLoseBruitage() async {
    await playKeyBruitage("assets/bruitages/lose.opus");
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
    _tensionFade?.cancel();
    _punchTimer?.cancel();
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

  /// Both are per-play shaping, and neither is worth an exception: `setPitch`
  /// in particular is implemented on Android only, so on every other platform
  /// it either no-ops or throws, and the sound must still be heard.
  Future<void> safelySetSpeed(double speed) async {
    try {
      await setSpeed(speed);
    } catch (e) {
      debugPrint("Error setting speed ($speed): $e");
    }
  }

  Future<void> safelySetPitch(double pitch) async {
    try {
      await setPitch(pitch);
    } catch (e) {
      debugPrint("Error setting pitch ($pitch): $e");
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
