import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
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
        GamicoMusicState(
          musicMuted: MusicService.musicMute,
          bruitagesMuted: MusicService.bruitagesMute,
        ),
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

  /// The session the game plays in outside a voice call.
  ///
  /// Mixable on purpose. The former `AudioSessionConfiguration.music()` used
  /// the exclusive `playback` category: the moment the session went active,
  /// iOS paused whatever the player was listening to in another app (a
  /// WhatsApp voice note, their own music) — even with every channel muted —
  /// and it ignored the silent switch. `ambient` mixes with other apps and
  /// goes quiet on the silent switch. On Android, transient focus that lets
  /// the other app duck plays the same role: it lowers its volume instead of
  /// pausing.
  static const AudioSessionConfiguration _gameSession =
      AudioSessionConfiguration(
        avAudioSessionCategory: AVAudioSessionCategory.ambient,
        avAudioSessionMode: AVAudioSessionMode.defaultMode,
        androidAudioAttributes: AndroidAudioAttributes(
          contentType: AndroidAudioContentType.music,
          usage: AndroidAudioUsage.media,
        ),
        androidAudioFocusGainType:
            AndroidAudioFocusGainType.gainTransientMayDuck,
      );

  /// The session an in-game voice call needs.
  ///
  /// Only the iOS half differs from [_gameSession]: the `ambient` category
  /// that one uses has no input path at all, so the moment it is applied the
  /// microphone goes silent. The Android half is left untouched on purpose —
  /// routing and focus there are WebRTC's own audio manager's business, and
  /// asking for `voiceCommunication` attributes would send the game music out
  /// of the earpiece.
  static const AudioSessionConfiguration
  _voiceChatSession = AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.playAndRecord,
    // No `defaultToSpeaker`: the call sets its own route through
    // `Helper.setSpeakerphoneOn`, and making the speaker the category
    // default would swallow the "earpiece" half of that toggle.
    avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.allowBluetooth,
    avAudioSessionMode: AVAudioSessionMode.voiceChat,
    androidAudioAttributes: AndroidAudioAttributes(
      contentType: AndroidAudioContentType.music,
      usage: AndroidAudioUsage.media,
    ),
    androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransientMayDuck,
  );

  /// True between [duckForVoiceChat] and [restoreAfterVoiceChat].
  bool _voiceChatActive = false;

  /// The session configuration that currently applies. Every player activation
  /// re-applies it (see [_applyAudioSessionConfiguration]), so it has to
  /// follow whether a call is running.
  AudioSessionConfiguration get _sessionConfiguration =>
      _voiceChatActive ? _voiceChatSession : _gameSession;

  /// Applies [_sessionConfiguration] to the shared AVAudioSession.
  ///
  /// This matters far more than it looks: `just_audio` calls
  /// `AudioSession.setActive(true)` on **every** `play()` — the music, but
  /// also every single sound effect — and that re-applies whatever
  /// configuration is on file. With the game configuration on file, the first
  /// card sound of a match dropped the session back to `ambient` and cut the
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

  // Pool of players for every one-shot bruitage (click, lock, move, win,
  // lose, voices…). Starts at [_baseOneShotPoolSize] — enough for the common
  // case without paying pipeline setup for sounds that mostly land one at a
  // time — and grows on demand (see [_claimOneShotPlayer]) whenever every
  // existing player is already busy, rather than cutting one of them short
  // or making the new sound wait. Extra players beyond the base are released
  // again once they've sat idle for a while (see [_trimOneShotPool]), so a
  // burst does not leave a permanent trail of native pipelines behind it.
  //
  // A `just_audio` player builds a whole ExoPlayer pipeline — around three
  // native threads — the first time it is handed an asset, and a 32-bit
  // low-end device runs out of thread stacks long before it runs out of heap
  // (`OutOfMemoryError: pthread_create (1040KB stack) failed`). Growing the
  // pool risks exactly that on such a device in a big enough pile-up of
  // sounds — accepted deliberately: never cutting a sound short matters more
  // here than that edge case.
  // [_maxOneShotPoolSize] caps the growth: beyond that ceiling we reuse the
  // oldest busy slot rather than spawning yet another native pipeline. A burst
  // large enough to exhaust the cap is already several sounds deep; the
  // recycled player has played its sound for the longest and is the best
  // candidate for reuse with minimal audible impact.
  final List<AudioPlayer> _oneShotPool = [AudioPlayer(), AudioPlayer()];

  /// Players always kept around even once idle, so the common case (one or
  /// two sounds at a time) never pays pipeline setup cost. Anything beyond
  /// this in [_oneShotPool] is an on-demand extra, trimmed back down once
  /// idle — see [_trimOneShotPool].
  static const int _baseOneShotPoolSize = 2;

  /// Hard ceiling on pool size. Each just_audio player spawns ~3 native
  /// threads (ExoPlayer on Android, AVPlayer + CoreMedia queues on iOS).
  /// Exceeding this ceiling risks `OutOfMemoryError: pthread_create` on
  /// low-end Android and raster-thread crashes on iOS from CoreMedia
  /// exhaustion (observed at ~12 concurrent AVPlayer instances).
  static const int _maxOneShotPoolSize = 7;

  /// How long an extra (beyond [_baseOneShotPoolSize]) one-shot player waits
  /// idle before it is disposed — long enough that a sound-heavy moment
  /// (a chain landing, cards impacting, the win fanfare) doesn't thrash
  /// pipelines up and down within itself.
  static const Duration _oneShotPoolTrimDelay = Duration(seconds: 8);

  /// Whether idle extra one-shot players are kept rather than disposed. The
  /// trim exists for Android's native-thread budget; on iOS/macOS `dispose`
  /// itself is the risk — just_audio's teardown crashes now and then in
  /// `-[AVPlayerItem dealloc]`, and the trims were most of its calls.
  /// [_maxOneShotPoolSize] still bounds what is kept.
  static bool get _keepsIdleExtras =>
      defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;

  Timer? _oneShotPoolTrimTimer;

  /// How many game screens currently hold the pool (see [holdOneShotPool]).
  /// While above zero, extra players are never trimmed: a game fires its
  /// bursts (a deal, a chain) every few seconds, and trimming between two of
  /// them only meant rebuilding the same pipelines at the next one.
  int _oneShotPoolHolders = 0;

  /// The asset each pool slot has loaded. A slot asked for the same sound
  /// again only rewinds it instead of loading it anew — see [_playOneShot].
  final Map<AudioPlayer, String> _slotAsset = {};

  /// When each pool slot was last handed a sound, so a new one goes to a slot
  /// that is free — or, failing that, a freshly created one (see
  /// [_claimOneShotPlayer]).
  final Map<AudioPlayer, DateTime> _slotClaimedAt = {};

  /// How long a slot counts as taken after being claimed, whatever its player
  /// reports: between `stop()` and the new asset loading it reads as idle, and
  /// a second sound fired in that gap would land on it too.
  static const Duration _slotClaimGrace = Duration(milliseconds: 300);

  /// Slots currently undergoing asset loading/preparation before playback begins.
  final Set<AudioPlayer> _loadingSlots = {};

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

  /// Gain each loop was last started with, on top of the shared bruitage
  /// level — so a loop meant as a soft backdrop stays soft when the volume or
  /// the voice-chat ducking is reapplied to every player.
  final Map<String, double> _loopGains = {};

  /// Pitch each loop was last started with. Only touched when it differs
  /// from 1 now or did last time: a platform round-trip the plain loops
  /// (the in-game fire and clock) never need.
  final Map<String, double> _loopPitches = {};
  static const Duration _loopReleaseDelay = Duration(seconds: 30);

  // Bruitage players list
  List<AudioPlayer> get _bruitagePlayers => [
    ..._oneShotPool,
    ..._readyLoopPlayers.values,
  ];

  // All players list
  List<AudioPlayer> get _allPlayers => [_mainPlayer, ..._bruitagePlayers];

  /// Volume a sound-effect player should sit at right now: the shared level,
  /// times its loop's own gain when it is one. One-shots set theirs per play.
  double _bruitageLevel(AudioPlayer player) {
    for (final entry in _readyLoopPlayers.entries) {
      if (identical(entry.value, player)) {
        return _currentVolume * _bruitageDuck * (_loopGains[entry.key] ?? 1);
      }
    }
    return _currentVolume * _bruitageDuck;
  }

  /// Gap between two native teardowns in [_stopAll].
  static const Duration _teardownStagger = Duration(milliseconds: 40);

  /// Stops [player] only if it holds a loaded source. In just_audio a
  /// `stop()` destroys the native player (AVPlayer / ExoPlayer), so an idle
  /// one — never loaded, or already stopped — is left alone. The slot forgets
  /// its asset, since [_playOneShot] would otherwise only rewind a player that
  /// no longer has anything to rewind.
  Future<void> _stopIfLoaded(AudioPlayer player) async {
    if (player.processingState == ProcessingState.idle) return;
    _slotAsset.remove(player);
    try {
      await player.stop();
    } catch (_) {}
  }

  /// [_stopIfLoaded] over [players], one after the other with a short gap
  /// instead of all at once: tearing down several AVPlayerItems in the same
  /// run-loop turn is what the iOS `AVPlayerItem dealloc` crash looked like.
  Future<void> _stopAll(Iterable<AudioPlayer> players) async {
    for (final player in players.toList()) {
      if (player.processingState == ProcessingState.idle) continue;
      await _stopIfLoaded(player);
      await Future<void>.delayed(_teardownStagger);
    }
  }

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

  /// The tape-stop slowdown (see [tapeStop]), multiplying the tempo and the
  /// pitch. 1 at rest.
  double _tapeFactor = 1;
  Timer? _tapeTimer;

  /// What the music player's volume should be right now.
  double get _musicLevel =>
      _currentVolume * _musicDuck * _musicTension * _musicPunch;

  void setGlobalVolume(double volume) {
    _currentVolume = volume;

    _mainPlayer.setVolume(_musicLevel);
    for (final player in _bruitagePlayers) {
      player.setVolume(_bruitageLevel(player));
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
        (player) => player.setVolume(_bruitageLevel(player)),
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
      if (_isDisposed || state.musicMuted) return;
      _mainPlayer.setVolume(_musicLevel);
      _mainPlayer.setSpeed(_musicTempo * _tapeFactor);
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
    if (_isDisposed || state.musicMuted) return;

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
      if (!state.musicMuted) _mainPlayer.setVolume(_musicLevel);
      if (t >= 1.0) {
        _musicPunch = 1;
        timer.cancel();
        if (identical(_punchTimer, timer)) _punchTimer = null;
      }
    });
  }

  /// Slows the music down like a tape that stalls, then lets it run again:
  /// tempo and pitch sink together to [depth] over [down], stay there for
  /// [hold], then come back to normal over [up].
  ///
  /// Meant for a game's most brutal moments — a death, a crushing blow. The
  /// pitch only follows on platforms that support it (Android); elsewhere the
  /// music just slows. A second call while one is running takes over from
  /// wherever the tape is.
  Future<void> tapeStop({
    double depth = 0.55,
    Duration down = const Duration(milliseconds: 350),
    Duration hold = const Duration(milliseconds: 250),
    Duration up = const Duration(milliseconds: 500),
  }) async {
    if (_isDisposed || state.musicMuted) return;

    _tapeTimer?.cancel();
    const int stepMs = 40;
    final int downSteps = (down.inMilliseconds / stepMs).ceil().clamp(1, 60);
    final int holdSteps = (hold.inMilliseconds / stepMs).ceil();
    final int upSteps = (up.inMilliseconds / stepMs).ceil().clamp(1, 60);
    final double from = _tapeFactor;
    final double low = depth.clamp(0.3, 1.0);
    int step = 0;

    _tapeTimer = Timer.periodic(const Duration(milliseconds: stepMs), (timer) {
      step++;
      if (_isDisposed) {
        timer.cancel();
        return;
      }
      double factor;
      if (step <= downSteps) {
        // Ease-in: the tape drags more and more.
        final double t = step / downSteps;
        factor = from + (low - from) * t * t;
      } else if (step <= downSteps + holdSteps) {
        factor = low;
      } else {
        final double t = ((step - downSteps - holdSteps) / upSteps).clamp(
          0.0,
          1.0,
        );
        factor = low + (1.0 - low) * (1.0 - (1.0 - t) * (1.0 - t));
        if (t >= 1.0) {
          factor = 1;
          timer.cancel();
          if (identical(_tapeTimer, timer)) _tapeTimer = null;
        }
      }
      _tapeFactor = factor;
      if (state.musicMuted) return;
      _mainPlayer.safelySetSpeed(_musicTempo * factor);
      _mainPlayer.safelySetPitch(factor);
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

    if (!state.musicMuted) {
      await GamicoGlobalService.waitWhile(
        () =>
            WidgetsBinding.instance.lifecycleState != AppLifecycleState.resumed,
      );

      await _mainPlayer.safelyPlayMusic();
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
    await _mainPlayer.safelyPlayMusic();
  }

  /// Plays any music asset track in loop or one-shot mode.
  Future<void> playMusic(String assetPath, {bool loop = true}) async {
    _wantedMusicAsset = assetPath;
    _wantedLoopMode = loop ? LoopMode.all : LoopMode.off;

    if (!state.musicMuted) {
      await _loadMusicAsset(assetPath);
      await _mainPlayer.setLoopMode(_wantedLoopMode);
      await _mainPlayer.safelyPlayMusic();
    }
  }

  Future<void> playMainMusic() async {
    final asset = Gamico.instance.musicSettings.mainMusicAsset;
    _wantedMusicAsset = asset;

    if (!state.musicMuted) {
      await _loadMusicAsset(asset);
      await _mainPlayer.safelyPlayMusic();
    }
  }

  Future<void> playVictoryMusic() async {
    final asset = Gamico.instance.musicSettings.victoryMusicAsset;
    _wantedMusicAsset = asset;

    if (!state.musicMuted) {
      await _loadMusicAsset(asset);
      await _mainPlayer.safelyPlayMusic();
    }
  }

  Future<void> playDrawMusic() async {
    final asset = Gamico.instance.musicSettings.drawMusicAsset;
    _wantedMusicAsset = asset;

    if (!state.musicMuted) {
      await _loadMusicAsset(asset);
      await _mainPlayer.safelyPlayMusic();
    }
  }

  Future<void> playDefeatMusic() async {
    final asset = Gamico.instance.musicSettings.defeatMusicAsset;
    _wantedMusicAsset = asset;

    if (!state.musicMuted) {
      await _loadMusicAsset(asset);
      await _mainPlayer.safelyPlayMusic();
    }
  }

  Future<void> playGameMusic() async {
    final asset = Gamico.instance.musicSettings.gameMusicAsset;
    _wantedMusicAsset = asset;

    if (!state.musicMuted) {
      await _loadMusicAsset(asset);
      await _mainPlayer.safelyPlayMusic();
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

    await _mainPlayer.safelyPlayMusic(_isDisposed);
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
  ]) => _playOneShot(source, force, gain, speed, pitch);

  /// Same as [playBruitage] — kept as its own name for call sites that
  /// specifically mean "this one must be heard through to its end" (a game's
  /// final blow, the win or lose sting). Every one-shot gets that guarantee
  /// now anyway: nothing in the pool is ever cut short for another (see
  /// [_claimOneShotPlayer]) — the two names stay distinct only so those call
  /// sites keep documenting their own intent.
  Future<void> playKeyBruitage(
    String source, {
    double gain = 1.0,
    double speed = 1.0,
    double pitch = 1.0,
  }) => _playOneShot(source, false, gain, speed, pitch);

  /// Whether [player] is still busy with the sound it was last handed.
  bool _slotBusy(AudioPlayer player) {
    if (_loadingSlots.contains(player)) return true;

    final processing = player.processingState;
    if (processing == ProcessingState.completed ||
        processing == ProcessingState.idle) {
      return false;
    }

    final claimed = _slotClaimedAt[player];
    if (claimed != null &&
        DateTime.now().difference(claimed) < _slotClaimGrace) {
      return true;
    }
    return player.playing;
  }

  /// A player for a new one-shot sound: a free one from the pool if there is
  /// one, else a brand new one, appended to the pool up to
  /// [_maxOneShotPoolSize]. Once the ceiling is reached the slot that has been
  /// busy the longest is recycled — it has already played most of its sound
  /// and is the least audibly disruptive candidate.
  AudioPlayer _claimOneShotPlayer() {
    for (final player in _oneShotPool) {
      if (!_slotBusy(player)) {
        _loadingSlots.add(player);
        _trimIdleExtras(except: player);
        return player;
      }
    }

    // All slots are busy. Grow the pool if under the ceiling.
    if (_oneShotPool.length < _maxOneShotPoolSize) {
      final player = AudioPlayer();
      _oneShotPool.add(player);
      _loadingSlots.add(player);
      _scheduleOneShotPoolTrim();
      return player;
    }

    // Ceiling reached: reuse the slot claimed the longest ago (it has played
    // the most of its sound already). This avoids unbounded thread growth that
    // causes OutOfMemoryError (Android) and AVPlayer exhaustion (iOS).
    final oldest = _oneShotPool.reduce(
      (a, b) =>
          (_slotClaimedAt[a] ?? DateTime(0)).isBefore(
            _slotClaimedAt[b] ?? DateTime(0),
          )
          ? a
          : b,
    );
    _loadingSlots.add(oldest);
    _trimIdleExtras(except: oldest);
    return oldest;
  }

  /// Disposes extra one-shot players (beyond [_baseOneShotPoolSize]) that have
  /// gone idle, handing their native threads back without cutting any sound.
  void _trimIdleExtras({AudioPlayer? except}) {
    if (_isDisposed || _keepsIdleExtras) return;
    if (_oneShotPool.length <= _baseOneShotPoolSize) return;

    final extras = _oneShotPool.sublist(_baseOneShotPoolSize);
    final idle = extras
        .where((player) => !identical(player, except) && !_slotBusy(player))
        .toList();

    for (final player in idle) {
      _oneShotPool.remove(player);
      _slotClaimedAt.remove(player);
      _shapedSlots.remove(player);
      _slotAsset.remove(player);
      _loadingSlots.remove(player);
      try {
        player.dispose();
      } catch (_) {}
    }
  }

  Future<void> _playOneShot(
    String source,
    bool force,
    double gain,
    double speed,
    double pitch,
  ) async {
    if (_isDisposed) return;
    if (state.bruitagesMuted && !force) return;

    final player = _claimOneShotPlayer();
    _slotClaimedAt[player] = DateTime.now();

    try {
      // Never `stop()` here: in just_audio it tears the native player down
      // (ExoPlayer / AVPlayer and their threads), and the next load builds a
      // new one — once per sound, on the thread that also runs the UI. A slot
      // that already holds this sound is only rewound; another sound is
      // loaded into the native player the slot already has.
      if (_slotAsset[player] == source) {
        await player.pause();
        await player.seek(Duration.zero);
      } else {
        _slotAsset.remove(player);
        await player.pause();
        await player.setAsset(source);
        _slotAsset[player] = source;
      }
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
    } finally {
      _loadingSlots.remove(player);
    }
  }

  /// Debounces [_trimOneShotPool]: every extra player created restarts the
  /// clock, so a sound-heavy stretch that keeps them all busy doesn't get its
  /// pool trimmed out from under it mid-stretch.
  void _scheduleOneShotPoolTrim() {
    _oneShotPoolTrimTimer?.cancel();
    _oneShotPoolTrimTimer = Timer(_oneShotPoolTrimDelay, _trimOneShotPool);
  }

  /// Keeps every one-shot player the pool grows to until the matching
  /// [releaseOneShotPool], instead of trimming the extras after
  /// [_oneShotPoolTrimDelay] of quiet. For a game screen, whose sound bursts
  /// come back every few seconds. Backgrounding still frees their native
  /// pipelines ([pause] stops every bruitage player); only the Dart side stays.
  void holdOneShotPool() {
    _oneShotPoolHolders++;
  }

  void releaseOneShotPool() {
    if (_oneShotPoolHolders == 0) return;
    _oneShotPoolHolders--;
    if (_oneShotPoolHolders == 0 && !_isDisposed) _scheduleOneShotPoolTrim();
  }

  /// Disposes extra one-shot players (beyond [_baseOneShotPoolSize]) that
  /// have gone idle, handing their native threads back. A still-busy extra
  /// player is left alone and reschedules this for later rather than being
  /// stopped early — the whole point of growing the pool was to never cut a
  /// sound short, and trimming must not undo that.
  Future<void> _trimOneShotPool() async {
    if (_isDisposed || _keepsIdleExtras) return;
    if (_oneShotPool.length <= _baseOneShotPoolSize) return;

    final extras = _oneShotPool.sublist(_baseOneShotPoolSize);
    final idle = extras.where((player) => !_slotBusy(player)).toList();

    for (final player in idle) {
      _oneShotPool.remove(player);
      _slotClaimedAt.remove(player);
      _shapedSlots.remove(player);
      _slotAsset.remove(player);
      _loadingSlots.remove(player);
      try {
        await player.dispose();
      } catch (_) {}
    }

    if (_oneShotPool.length > _baseOneShotPoolSize) {
      _scheduleOneShotPoolTrim();
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

  /// Starts [asset] looping at [gain] of the bruitage level and at [pitch],
  /// unless it already is — a loop already playing keeps what it started
  /// with.
  Future<void> _startLoop(
    String asset, [
    double gain = 1.0,
    double pitch = 1.0,
  ]) async {
    if (_isDisposed || state.bruitagesMuted) return;

    final player = await _loopPlayer(asset);
    if (_isDisposed) return;
    if (player.playing) return;

    _loopGains[asset] = gain.clamp(0.0, 1.0);
    await player.setVolume(_bruitageLevel(player));
    if (pitch != 1.0 || (_loopPitches[asset] ?? 1.0) != 1.0) {
      await player.safelySetPitch(pitch.clamp(0.5, 2.0));
      _loopPitches[asset] = pitch;
    }
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

    // `pause`, not `stop`: just_audio's stop tears the native player down, and
    // the next start would rebuild it — the very cost the delayed release is
    // there to avoid.
    try {
      await player.pause();
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
    _loopGains.remove(asset);
    _loopPitches.remove(asset);
    final player = _readyLoopPlayers.remove(asset);
    if (player == null) return;

    try {
      await player.dispose();
    } catch (_) {}
  }

  /// Mutes or unmutes everything at once — music and sound effects. With
  /// only one of the two muted, this mutes the other as well.
  Future<void> toggle() =>
      _setMuted(music: !state.mute, bruitages: !state.mute);

  /// Mutes or unmutes the music alone.
  Future<void> toggleMusic() =>
      _setMuted(music: !state.musicMuted, bruitages: state.bruitagesMuted);

  /// Mutes or unmutes the sound effects alone.
  Future<void> toggleBruitages() =>
      _setMuted(music: state.musicMuted, bruitages: !state.bruitagesMuted);

  Future<void> setMusicMuted(bool muted) =>
      _setMuted(music: muted, bruitages: state.bruitagesMuted);

  Future<void> setBruitagesMuted(bool muted) =>
      _setMuted(music: state.musicMuted, bruitages: muted);

  Future<void> _setMuted({required bool music, required bool bruitages}) async {
    playBruitage("assets/bruitages/click.opus", true);

    final musicChanged = music != state.musicMuted;
    final bruitagesChanged = bruitages != state.bruitagesMuted;
    if (!musicChanged && !bruitagesChanged) return;

    // Saved before the players react: [safelyPlay] reads it back from storage
    // once an ad pause is over.
    MusicService.musicMute = music;
    MusicService.bruitagesMute = bruitages;

    emit(state.copyWith(musicMuted: music, bruitagesMuted: bruitages));

    final List<Future<void>> work = [];

    if (musicChanged) {
      if (music) {
        work.add(() async {
          await _mainPlayer.setVolume(0);
          await _stopIfLoaded(_mainPlayer);
        }());
      } else {
        unawaited(_playMusic());
      }
    }

    if (bruitagesChanged) {
      if (bruitages) {
        work.add(() async {
          await Future.wait([
            for (final player in _oneShotPool) player.setVolume(0),
          ]);
          // Looping effects (clock, fire) are released rather than stopped,
          // so the next start rebuilds a player instead of reusing a torn-down
          // one.
          await stopGameBruitages();
          await _stopAll(_oneShotPool);
        }());
      } else {
        for (final player in _bruitagePlayers) {
          player.setVolume(_bruitageLevel(player));
        }
      }
    }

    await Future.wait([
      ...work,
      // Ads only go silent once everything is.
      MobileAds.instance.setAppMuted(state.mute),
      // Older builds only read this one key.
      LocalStorageService.setBool("mute", state.mute),
    ]);
  }

  // Pause players
  Future<void> pause() async {
    await GamicoGlobalService.waitWhile(
      () => !musicInitialized || !bruitagesInitialized,
    );

    await _mainPlayer.pause();
    await _stopAll(_bruitagePlayers);
  }

  // Resume players
  Future<void> resume() async {
    if (!state.musicMuted) {
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

    await playKeyBruitage("assets/voices/$finalLanguageCode/$voice.mp3");
  }

  Future<void> playClockBruitage() async {
    await _startLoop(_clockAsset);
  }

  Future<void> stopClockBruitage() async {
    await _stopLoop(_clockAsset);
  }

  /// [gain] scales the loop under the bruitage level: below 1 it becomes a
  /// backdrop, such as the soft crackle behind the streak popup. [pitch]
  /// gives the fire a voice: higher and lively, or low and roaring.
  Future<void> playFireBruitage({double gain = 1.0, double pitch = 1.0}) async {
    await _startLoop(_fireAsset, gain, pitch);
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
    _oneShotPoolTrimTimer?.cancel();
    _tensionFade?.cancel();
    _punchTimer?.cancel();
    _tapeTimer?.cancel();
    await _interruptionSub?.cancel();
    _interruptionSub = null;

    for (final timer in _loopReleaseTimers.values) {
      timer.cancel();
    }
    _loopReleaseTimers.clear();

    // `dispose()` already stops a player: a prior `stop()` would tear the
    // native player down twice. Spaced out, as in [_stopAll].
    for (final player in _allPlayers.toList()) {
      try {
        await player.dispose();
      } catch (_) {}
      await Future<void>.delayed(_teardownStagger);
    }

    _loopPlayers.clear();
    _readyLoopPlayers.clear();
    _loadingSlots.clear();

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

  /// Plays a sound effect — held back while sound effects are muted, unless
  /// [force].
  Future<void> safelyPlay([bool force = false, bool isDisposed = false]) =>
      _safelyPlay(() => MusicService.bruitagesMute, force, isDisposed);

  /// Plays the music — held back while the music is muted.
  Future<void> safelyPlayMusic([bool isDisposed = false]) =>
      _safelyPlay(() => MusicService.musicMute, false, isDisposed);

  /// [muted] is read once the ad pause is over, not before: the player may
  /// have muted that channel while the ad was on screen.
  Future<void> _safelyPlay(
    bool Function() muted,
    bool force,
    bool isDisposed,
  ) async {
    try {
      await GamicoGlobalService.waitWhile(() => MusicService.pausedByAd);
      if (isDisposed) return;

      if (!muted() || force) {
        await play();
      }
    } catch (e) {
      debugPrint("AudioPlayer.play error caught safely: $e");
    }
  }
}
