import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:gamico/commons/global/gamico.dart';
import 'package:gamico/commons/models/gamico_game_model.dart';
import 'package:gamico/commons/models/gamico_user_model.dart';
import 'package:gamico/commons/repositories/gamico_games_repository.dart';
import 'package:gamico/commons/services/database_shutdown.dart';
import 'package:gamico/commons/services/game.dart';
import 'package:gamico/commons/services/global.dart';
import 'package:gamico/commons/services/local_storage.dart';
import 'package:gamico/commons/models/adventure_utility.dart';
import 'package:gamico/commons/models/remote_utility.dart';
import 'package:gamico/features/game/cubits/game_cubit.dart';
import 'package:gamico/features/game/utilities/replay_option.dart';
import 'package:gamico/features/game/utilities/gamico_game_cubit_settings.dart';

part 'remote_game_state.dart';

class GamicoRemoteGameCubit extends Cubit<GamicoRemoteGameState> {
  GamicoRemoteGameCubit({
    required this.gameId,
    required bool creator,
    required this.gamesRepository,
    required this.gameCubit,
    required bool fakeOpponent,
    required this.remoteUtility,
    required int? level,
    required this.adventureUtility,
    bool friend = false,
    this.replayOptions = const [],
    this.currentReplayOption,
    bool replayVote = false,
    this.legacyRollCall = false,
  }) : _replayVoteEnabled = replayVote || replayOptions.isNotEmpty,
       super(
         GamicoRemoteGameState(
           creator: creator,
           fakeOpponent: fakeOpponent,
           remoteUtility: remoteUtility,
           adventureUtility: adventureUtility,
           friend: friend,
           level: level,
           userInitialLevel: adventureUtility?.getUserLevel(
             gameCubit.userCubit.state.user,
           ),
         ),
       ) {
    GamicoDatabaseShutdown.register(this, cancelDatabaseListeners);
  }

  /// Whether each opponent's `coins` leaf is watched for the length of the
  /// match, on top of being read once at the start. Declared by the game, on
  /// [RemoteUtility], so every way into a table agrees — matchmaking, a friend
  /// room, an invitation from a notification.
  ///
  /// Only worth it for a game that shows an opponent's balance moving while
  /// they play. It is not free: a balance changes whenever that player is paid
  /// — at every settled hand in a scoring game — and each change rebuilds the
  /// opponent, re-sorts the roster and emits a new state, which every listener
  /// of this cubit then reacts to. A game that never displays the figure pays
  /// that for nothing, N-1 times over per payout.
  ///
  /// Turning it off does NOT take the value away: `coins` moves to the
  /// one-shot read alongside `name` and `photo`, so the opponent still carries
  /// the balance it had when the table was formed. Only live updates are lost.
  ///
  /// Defaults to true so no existing game changes behaviour by accident.
  bool get watchOpponentCoins => remoteUtility.watchOpponentCoins;

  /// See [GamicoDatabaseShutdown]: drops every game listener while the app is
  /// being torn down, before the Flutter engine dies.
  Future<void> cancelDatabaseListeners() async {
    await newGameStreamSubscription?.cancel();
    newGameStreamSubscription = null;
    await opponentStreamSubscription?.cancel();
    opponentStreamSubscription = null;
    for (final s in opponentStreamSubscriptions) {
      await s.cancel();
    }
    opponentStreamSubscriptions = [];
    await gameEventsStreamSubscription?.cancel();
    gameEventsStreamSubscription = null;
    await _rollCallSubscription?.cancel();
    _rollCallSubscription = null;
    await _rollCallVotesSubscription?.cancel();
    _rollCallVotesSubscription = null;
    await _rollCallReadySubscription?.cancel();
    _rollCallReadySubscription = null;
    _stopRollCallTicker();
    await _disconnectionPenaltySubscription?.cancel();
    _disconnectionPenaltySubscription = null;
  }

  @override
  void emit(GamicoRemoteGameState state) {
    if (isClosed) return;
    super.emit(state);
  }

  final GamicoGameCubit gameCubit;

  final RemoteUtility remoteUtility;
  final AdventureUtility? adventureUtility;

  /// What players may pick from for the rematch, and what is being played now
  /// (see [GamicoReplayVoteButton]). Empty leaves "Rejouer" a plain vote.
  ///
  /// Declared on the [RemoteGameUtility] when the launcher already knows them,
  /// or handed over later through [configureReplayVote] — a game whose modes
  /// only become known once the table's config has loaded (Ludo reads them off
  /// its board) configures them from its own page.
  List<GamicoReplayOption> replayOptions;
  String? currentReplayOption;

  bool _replayVoteEnabled;

  /// Whether this match closes on the vote-based rematch rather than the older
  /// invitation exchange.
  bool get replayVoteEnabled => _replayVoteEnabled;

  /// Declares (or updates) what the rematch may be played with. Safe to call
  /// on every build: it only touches the cubit when something actually
  /// changed, and never once a resolved rematch is already on its way.
  void configureReplayVote({
    List<GamicoReplayOption> options = const [],
    String? currentOption,
    bool enabled = true,
  }) {
    if (_replayLaunched) return;

    final bool nextEnabled = enabled || options.isNotEmpty;
    if (_replayVoteEnabled == nextEnabled &&
        currentReplayOption == currentOption &&
        _sameOptions(replayOptions, options)) {
      return;
    }

    replayOptions = options;
    currentReplayOption = currentOption;
    _replayVoteEnabled = nextEnabled;
  }

  bool _sameOptions(List<GamicoReplayOption> a, List<GamicoReplayOption> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  // Usual repository
  final GamicoGamesRepository gamesRepository;

  // Remote game stream subscriptions
  StreamSubscription? newGameStreamSubscription;
  StreamSubscription? opponentStreamSubscription;
  List<StreamSubscription> opponentStreamSubscriptions = [];
  StreamSubscription? gameEventsStreamSubscription;

  /// How many trailing `games/{id}/events` children the move listener attaches
  /// to. See the listener itself for why the log is windowed at all; the value
  /// only has to stay comfortably above the largest prune threshold any game
  /// uses (100, Crazy Eights' unrefereed fallback) so a live event is never
  /// left outside the window.
  static const int _eventsWindow = 200;

  // Remote game user disconnection manager
  OnDisconnect? userDisconnectionReference;

  /// Watches `.info/connected` while the disconnection penalty above is armed:
  /// Android drops the database connection almost as soon as the app is
  /// backgrounded (answering a message is enough), which fires the
  /// `onDisconnect` and docks coins/defeats before the game's own (properly
  /// grace-period-guarded) abandonment logic gets a chance to run. On every
  /// reconnection while the match is still active, the penalty is refunded and
  /// re-armed, so a quick app switch doesn't score a defeat.
  StreamSubscription<DatabaseEvent>? _disconnectionPenaltySubscription;
  bool _sawInitialConnected = false;

  /// Field path → increment applied by the armed disconnection penalty (e.g.
  /// `-5` on `coins`), so a reconnection can write back the exact opposite.
  Map<String, num>? _armedDisconnectionPenalty;

  // Remote game id
  final String gameId;

  // Remote game model
  GamicoGameModel? currentGame;

  // Remote requests managers
  int replayRequests = 0;

  /// Readiness roll-call, by uid. The game deals only when every player still
  /// expected has declared READINESS. Counting by uid (not a raw counter)
  /// survives duplicated events, and a player who EXITs before the game
  /// starts (left the app between matchmaking and launch) is struck from the
  /// expected set instead of blocking the table forever.
  final Set<String> _readyPlayerIds = {};
  final Set<String> _exitedPlayerIds = {};

  /// Players the game has already been told are gone (through
  /// [onRemoteUserDisconnectedDuringGame]), so none is reported twice — and
  /// none is missed, whichever road (EXIT event, durable "left" marker,
  /// roster) brought the news first.
  final Set<String> _reportedGone = {};
  Set<String> _expectedPlayerIds = {};

  /// [_expectedPlayerIds] in seat order, for the waiting screen.
  List<String> _expectedOrder = const [];

  /// Seats filled by `RemoteCubit.enableBotFallback`: never expected at the
  /// roll-call (no device behind them), but they take seats — so a table of
  /// two humans and two bots is no duel: it gets the waiting list and the
  /// vote. Whether a table is cancelled, though, is counted in humans (see
  /// [_applyRollCall]).
  int _botSeats = 0;
  Timer? _readinessFallbackTimer;

  /// Tournament legs keep the older rule: every device grants the missing
  /// players [_readinessGrace] from its own READINESS, and nobody votes. The
  /// bracket has its own handshake and its own idea of a forfeit.
  final bool legacyRollCall;

  /// Grace of the older rule (see [legacyRollCall]).
  static const Duration _readinessGrace = Duration(seconds: 20);

  void _startReadinessFallbackTimer() {
    if (!legacyRollCall) return;
    _readinessFallbackTimer?.cancel();
    _readinessFallbackTimer = Timer(_readinessGrace, () {
      if (isClosed || gameCubit.state.ready) return;
      // Whoever is ready by now makes the table. Proposed, not applied: see
      // [_proposeRollCall]. Nobody left but us is still a roster — the game
      // layer answers it with its penalty-free "match cancelled" verdict,
      // which beats a spinner that never stops.
      _proposeRollCall(_presentReadyIds, GamicoRollCallReason.grace);
    });
  }

  /// Expected players who have neither left nor failed to answer yet, and
  /// have answered. Always includes us once our READINESS is out.
  Set<String> get _presentReadyIds => _expectedPlayerIds
      .difference(_exitedPlayerIds)
      .intersection(_answeredIds);

  /// Players who answered the roll-call and are still connected: a READINESS
  /// (or a `true` marker) does not outlive a connection the server saw drop
  /// (see [kGamicoRollCallAway]).
  Set<String> get _answeredIds => _readyPlayerIds.difference(_disconnectedIds);

  /// Ready players whose marker the server turned to [kGamicoRollCallAway]:
  /// their connection dropped before the deal. Counted as absent — never as
  /// gone — until their marker is `true` again.
  final Set<String> _disconnectedIds = {};

  bool get _isDuel => _expectedPlayerIds.length + _botSeats == 2;

  /// Ready players whose app is in the background right now: their presence
  /// flag (watched for every opponent, see `init`) is down.
  Set<String> get _awayIds {
    final away = <String>{};
    for (final opponent in state.opponents) {
      if (opponent is GamicoUserModel &&
          opponent.online == false &&
          opponent.id != null) {
        away.add(opponent.id!);
      }
    }
    away.remove(LocalStorageService.uid);
    return away;
  }

  /// Whether the waiting list (and its vote) is shown: a table of three seats
  /// or more with at least two people to wait on each other.
  bool get _showsWaitingList =>
      _expectedPlayerIds.length >= 2 &&
      _expectedPlayerIds.length + _botSeats >= 3;

  void _checkReadiness() {
    if (gameCubit.state.ready) return;
    _publishRollCallStatus();
    // Nothing is proposed before our own READINESS: a marker left `true` by
    // an earlier session of this device (the page reopened before the deal)
    // would otherwise seal a roster seating us while this session loads —
    // then read as a table dealt without us. Our READINESS checks again.
    if (!_readinessSent) return;
    final expected = _expectedPlayerIds.difference(_exitedPlayerIds);
    if (expected.isEmpty) return;
    if (_answeredIds.containsAll(expected)) {
      _proposeRollCall(expected, GamicoRollCallReason.allReady);
      return;
    }
    _evaluateRollCallRules();
  }

  // ── Sealed roll-call ───────────────────────────────────────────────────────
  // Who sits at the table used to be decided by every device on its own: each
  // dealt the moment it had heard every READINESS, or struck the missing ones
  // when ITS grace ran out. Those verdicts drift apart at a busy table: a
  // player kept by one device and struck by another, two different deals of
  // the same game, and the struck player thrown out by the "un" the first one
  // publishes.
  //
  // So the roster is written once, at `games/<id>/roll_call`, by whichever
  // device gets there first, together with the reason it was sealed, and every
  // device deals with exactly that list. Being late costs the late player
  // alone, the same way on every screen, and they are told why.
  //
  // When to seal is counted from `games/<id>/roll_call_at` — the moment the
  // table was formed, on the server clock — so every device reaches the same
  // deadline together (see [GamicoRollCallRules]):
  //  * a duel waits [GamicoRollCallRules.duelGrace] for the other player, then
  //    is cancelled;
  //  * from three seats up, the ready players may vote the absent out from
  //    [GamicoRollCallRules.voteOpensAfter] (more than half of those who are
  //    there), and the table starts anyway at [GamicoRollCallRules.cap].
  //
  // A build that predates this ignores both nodes and keeps its local 20 s
  // verdict; the nodes live and die with the game.
  static const String _rollCallField = "roll_call";
  static const String _rollCallStartField = "roll_call_at";
  static const String _rollCallVotesField = "roll_call_votes";
  static const String _rollCallArrivalsField = "roll_call_arrivals";

  /// Who has answered the roll-call, one leaf per player. The READINESS event
  /// says the same, but the events are read through a window of the last
  /// [_eventsWindow] and pruned by some games: a long, chatty wait at a big
  /// table (chat, typing, voice signalling) could push the first players'
  /// READINESS out of a latecomer's view — who would then count them as
  /// absent, and eject them if it happened to be the one to seal at the cap.
  static const String _rollCallReadyField = kGamicoRollCallReadyField;
  StreamSubscription<DatabaseEvent>? _rollCallReadySubscription;

  /// The last value seen under [_rollCallReadyField], by uid: a marker going
  /// from [kGamicoRollCallLeft] back to `true` is a player coming back.
  final Map<String, Object?> _readyMarkers = {};

  /// Players whose pre-deal EXIT this device read in the log, so that only a
  /// READINESS coming AFTER it there readmits them. Struck through their
  /// "left" marker instead, a late device would otherwise read their first
  /// READINESS (older than the EXIT, same window) as a return — and could
  /// seal them in for the instant before the EXIT itself came through.
  final Set<String> _exitsInLog = {};

  /// A player who left before the deal answered the roll-call again (they
  /// reopened the table): expected once more. It used to stay struck for
  /// good on the devices that had seen them go — waited for by nobody, then
  /// left out of the roster with a reason that was not theirs.
  ///
  /// Driven by the order the table saw things in (their EXIT, then a fresh
  /// READINESS in the log; or their marker going from "left" to `true`), so
  /// every device, a late one included, lands on the same answer. Never
  /// after a departure the game has already been told about: that cannot be
  /// taken back.
  bool _readmitIfBack(String uid) {
    if (legacyRollCall || _rollCallApplied || gameCubit.state.ready) {
      return false;
    }
    if (_reportedGone.contains(uid)) return false;
    if (!_exitedPlayerIds.remove(uid)) return false;
    _rc("back before the deal: $uid");
    return true;
  }

  StreamSubscription<DatabaseEvent>? _rollCallSubscription;
  StreamSubscription<DatabaseEvent>? _rollCallVotesSubscription;
  Timer? _rollCallTicker;
  Timer? _rollCallRetryTimer;
  bool _rollCallProposed = false;
  bool _rollCallApplied = false;
  bool _readinessSent = false;
  GamicoRollCallVerdict? _pendingRollCall;

  /// Armed with our READINESS: turns our marker to [kGamicoRollCallAway] if
  /// the server loses our connection before the deal. An app killed on the
  /// waiting screen used to leave its `true` behind — counted ready, sealed
  /// "all ready", dealt a seat nobody played.
  OnDisconnect? _awayOnDisconnect;

  /// Watches the connection while the table waits, so that a device the
  /// server marked away says it is back (see [_reassertReadiness]).
  StreamSubscription<DatabaseEvent>? _connectedSubscription;
  bool _lostConnectionBeforeDeal = false;

  /// We left before the deal (see [declareCurrentUserExit]): our marker says
  /// so, and a reconnection must not turn it back to `true`.
  bool _leftBeforeDeal = false;

  /// Publishes our answer to the roll-call where every device can read it,
  /// with the server primed to withdraw it if our connection drops first.
  /// Sent in this order on one connection, so the server never holds a
  /// `true` without the safety net behind it.
  void _declareReadyMarker() {
    final uid = LocalStorageService.uid;
    if (uid.isEmpty || gameId.isEmpty) return;
    final marker = _gameRef.child(_rollCallReadyField).child(uid);
    if (!legacyRollCall) {
      final onDisconnect = marker.onDisconnect();
      _awayOnDisconnect = onDisconnect;
      unawaited(
        onDisconnect.set(kGamicoRollCallAway).catchError((e) {
          debugPrint("⚠️ roll_call away marker not armed => $e");
        }),
      );
    }
    unawaited(marker.set(true).catchError((_) {}));
  }

  void _cancelAwayOnDisconnect() {
    final onDisconnect = _awayOnDisconnect;
    _awayOnDisconnect = null;
    if (onDisconnect == null) return;
    unawaited(onDisconnect.cancel().catchError((_) {}));
  }

  /// A connection that dropped before the deal may have had our marker turned
  /// to [kGamicoRollCallAway] by the server: once back, we are there again.
  /// The server consumed the `onDisconnect` as it fired, so it is armed anew.
  void _watchConnectionBeforeDeal() {
    if (legacyRollCall || state.fakeOpponent) return;
    _connectedSubscription?.cancel();
    _connectedSubscription = FirebaseDatabase.instance
        .ref(".info/connected")
        .onValue
        .listen((event) {
          if (event.snapshot.value != true) {
            _lostConnectionBeforeDeal = true;
            return;
          }
          if (!_lostConnectionBeforeDeal) return;
          _lostConnectionBeforeDeal = false;
          _reassertReadiness();
        }, onError: (_) {});
  }

  void _reassertReadiness() {
    if (isClosed || _rollCallApplied || _leftBeforeDeal) return;
    if (!_readinessSent || gameCubit.state.ready) return;
    _rc("connection back before the deal — ready again");
    _declareReadyMarker();
  }

  /// When our own READINESS went out (local clock: only ever compared with
  /// itself). See [GamicoRollCallRules.minimumOwnWait].
  DateTime? _myReadyAt;

  /// `roll_call_at`, server clock, once known.
  int? _rollCallStartedAtMs;
  int _serverOffsetMs = 0;
  StreamSubscription<DatabaseEvent>? _serverOffsetSubscription;
  StreamSubscription<DatabaseEvent>? _rollCallAtSubscription;
  StreamSubscription<DatabaseEvent>? _rollCallArrivalsSubscription;
  int? _serverRollCallAt;
  int? _earliestArrivalAt;

  /// [_serverOffsetMs] measured on our own arrival stamp, which beats the
  /// connection's estimate once known.
  bool _offsetFromArrival = false;

  /// How long after our READINESS a table with no reference at all starts
  /// counting from it instead (see [_evaluateRollCallRules]).
  static const Duration _referenceFallbackAfter = Duration(seconds: 8);

  int get _serverNowMs =>
      DateTime.now().millisecondsSinceEpoch + _serverOffsetMs;

  /// Ready players currently voting to eject the absent ones.
  final Set<String> _ejectVotes = {};

  /// The roster this table dealt with, once sealed. Null before.
  Set<String>? get sealedRollCall => _sealedRollCall;
  Set<String>? _sealedRollCall;

  /// The roster was already sealed before this session sent its READINESS —
  /// and seats us all the same: that READINESS came from an earlier session
  /// of this device (the app reopened, the page rebuilt). The table has most
  /// likely been dealt and played since, so a game that deals its own opening
  /// hand in `startGame` must catch up with it instead.
  bool get rejoiningSealedTable =>
      _sealedBeforeOurReadiness &&
      (_sealedRollCall?.contains(LocalStorageService.uid) ?? false);
  bool _sealedBeforeOurReadiness = false;

  /// How many other players this table expected — to word a popup "player"
  /// or "players". The game may not have been read yet (excluded while
  /// loading): the sealed roster then says how many played on.
  int get expectedOtherPlayers {
    final myUid = LocalStorageService.uid;
    if (_expectedPlayerIds.isNotEmpty) {
      return _expectedPlayerIds.where((id) => id != myUid).length;
    }
    return _sealedRollCall?.where((id) => id != myUid).length ?? 0;
  }

  /// Whether we are currently voting to eject the absent players.
  bool get myEjectVote => _ejectVotes.contains(LocalStorageService.uid);

  DatabaseReference get _gameRef =>
      FirebaseDatabase.instance.ref("games/$gameId");

  /// One line per step of the pre-deal wait, for reading a multi-device test
  /// side by side: the end of the game id (which table), then the seconds
  /// since the table was formed on the server clock (the same on every
  /// device, once known). Filter on "🔍 [RC]".
  void _rc(String message) {
    final table = gameId.length > 6
        ? gameId.substring(gameId.length - 6)
        : gameId;
    final startedAt = _rollCallStartedAtMs;
    final elapsed = startedAt == null
        ? "?"
        : ((_serverNowMs - startedAt) / 1000).toStringAsFixed(1);
    debugPrint("🔍 [RC] $table +${elapsed}s $message");
  }

  void _listenToRollCall() {
    if (state.fakeOpponent || gameId.isEmpty) return;
    _rollCallSubscription?.cancel();
    _rollCallSubscription = _gameRef.child(_rollCallField).onValue.listen((
      event,
    ) {
      final verdict = GamicoRollCallVerdict.fromJson(event.snapshot.value);
      if (verdict != null && !_readinessSent) {
        _sealedBeforeOurReadiness = true;
      }
      if (verdict != null && !_rollCallApplied) {
        _rc(
          "roster received: ${verdict.players} (${verdict.reason.wire})"
          "${_readinessSent ? "" : " — before our READINESS"}",
        );
      }
      _applyRollCall(verdict);
    }, onError: (e) => debugPrint("⚠️ roll_call subscription error => $e"));

    _rollCallReadySubscription?.cancel();
    _rollCallReadySubscription = _gameRef
        .child(_rollCallReadyField)
        .onValue
        .listen(
          (event) {
            final raw = event.snapshot.value;
            if (raw is! Map) return;
            var changed = false;
            final myUid = LocalStorageService.uid;
            for (final entry in raw.entries) {
              final uid = entry.key.toString();
              final previous = _readyMarkers[uid];
              _readyMarkers[uid] = entry.value;
              if (entry.value == true &&
                  previous == kGamicoRollCallLeft &&
                  uid != myUid &&
                  _readmitIfBack(uid)) {
                changed = true;
              }
              if (entry.value == true && _disconnectedIds.remove(uid)) {
                _rc("reconnected before the deal: $uid");
                changed = true;
              }
              if (entry.value == true && _readyPlayerIds.add(uid)) {
                if (uid != myUid) _rc("ready: $uid");
                changed = true;
              } else if (entry.value == kGamicoRollCallAway &&
                  uid != myUid &&
                  !gameCubit.state.ready &&
                  _disconnectedIds.add(uid)) {
                // Their connection dropped on the waiting screen (see
                // [kGamicoRollCallAway]): no longer counted as there, but
                // not struck either — the roster may still seat them.
                _rc("disconnected before the deal (marker): $uid");
                changed = true;
              } else if (entry.value == kGamicoRollCallLeft &&
                  uid != myUid &&
                  !gameCubit.state.ready &&
                  _exitedPlayerIds.add(uid)) {
                // Left before the deal. Their EXIT event says the same, but
                // may sit outside the window of a device that arrived late —
                // which would otherwise count them ready (their `true` is
                // still here) and deal a seat nobody plays.
                _rc("left before the deal (marker): $uid");
                changed = true;
              }
            }
            if (changed && _expectedPlayerIds.isNotEmpty) _checkReadiness();
          },
          onError: (e) =>
              debugPrint("⚠️ roll_call_ready subscription error => $e"),
        );

    if (legacyRollCall) return;
    _rollCallVotesSubscription?.cancel();
    _rollCallVotesSubscription = _gameRef
        .child(_rollCallVotesField)
        .onValue
        .listen(
          (event) {
            final raw = event.snapshot.value;
            final before = Set.of(_ejectVotes);
            _ejectVotes
              ..clear()
              ..addAll(
                raw is Map
                    ? raw.entries
                          .where((e) => e.value == true)
                          .map((e) => e.key.toString())
                    : const <String>[],
              );
            if (before.length != _ejectVotes.length ||
                !before.containsAll(_ejectVotes)) {
              _rc("eject votes: $_ejectVotes");
            }
            _publishRollCallStatus();
            _evaluateRollCallRules();
          },
          onError: (e) =>
              debugPrint("⚠️ roll_call_votes subscription error => $e"),
        );
  }

  /// Asks the server — not the cache — whether the roster was sealed before
  /// this session answered, which is what tells a reopened table from a new
  /// one (see [rejoiningSealedTable], `rejoinsDealtTable`).
  ///
  /// The roster listener says the same, but only if its first event beats
  /// our READINESS, and with the offline cache on it may first answer with
  /// a stale "not sealed" from disk. Missed, a reopened Ludo table dealt a
  /// fresh board over a match already played — out of step for good.
  ///
  /// A transaction that writes back what it found: it is the one read the
  /// SDK always settles against the server (a mismatch with the cache reruns
  /// it on the server's value), and rewriting the same roster, or nothing,
  /// changes nothing.
  Future<void> _checkSealedOnServer() async {
    if (state.fakeOpponent || gameId.isEmpty || _readinessSent) return;
    try {
      final result = await _gameRef
          .child(_rollCallField)
          .runTransaction(
            (current) => Transaction.success(current),
            applyLocally: false,
          )
          .timeout(const Duration(seconds: 4));
      final verdict = GamicoRollCallVerdict.fromJson(result.snapshot.value);
      if (verdict == null || isClosed || _readinessSent) return;
      if (!_sealedBeforeOurReadiness) {
        _sealedBeforeOurReadiness = true;
        _rc(
          "roster already sealed on the server: ${verdict.players} "
          "(${verdict.reason.wire}) — before our READINESS",
        );
      }
      _applyRollCall(verdict);
    } catch (e) {
      // The listener still has its say; this only makes it certain.
      _rc("sealed check failed ($e) — relying on the listener");
    }
  }

  /// Where the roll-call's deadlines are counted from, without trusting any
  /// phone's clock.
  ///
  /// A matchmaking table carries `roll_call_at`, written by the server as it
  /// forms the table. Anywhere else (a friend room, or before that function
  /// is deployed) every device stamps its own arrival under
  /// `roll_call_arrivals/<uid>` with the server's timestamp, and the table
  /// counts from the earliest one — a value no device clock can bend. It used
  /// to be the first arrival's own clock, corrected by an offset that is
  /// unknown for a moment after connecting: a phone set a minute behind could
  /// hand the whole table a reference a minute in the past, opening the vote
  /// at once and cancelling duels early.
  ///
  /// The round trip of that same write also tells this device how far its
  /// clock is from the server's, which is what every deadline is then read
  /// against.
  Future<void> _resolveRollCallStart() async {
    if (legacyRollCall || state.fakeOpponent || gameId.isEmpty) return;

    _serverOffsetSubscription?.cancel();
    _serverOffsetSubscription = FirebaseDatabase.instance
        .ref(".info/serverTimeOffset")
        .onValue
        .listen((event) {
          final value = event.snapshot.value;
          if (value is num && !_offsetFromArrival) {
            _serverOffsetMs = value.toInt();
          }
        }, onError: (_) {});

    _rollCallAtSubscription?.cancel();
    _rollCallAtSubscription = _gameRef
        .child(_rollCallStartField)
        .onValue
        .listen((event) {
          final value = event.snapshot.value;
          if (value is num) {
            _serverRollCallAt = value.toInt();
            _updateRollCallReference();
          }
        }, onError: (_) {});

    _rollCallArrivalsSubscription?.cancel();
    _rollCallArrivalsSubscription = _gameRef
        .child(_rollCallArrivalsField)
        .onValue
        .listen((event) {
          final raw = event.snapshot.value;
          if (raw is! Map) return;
          int? earliest;
          for (final value in raw.values) {
            if (value is num && (earliest == null || value < earliest)) {
              earliest = value.toInt();
            }
          }
          if (earliest != null) {
            _earliestArrivalAt = earliest;
            _updateRollCallReference();
          }
        }, onError: (_) {});

    final uid = LocalStorageService.uid;
    if (uid.isEmpty) return;
    final ref = _gameRef.child(_rollCallArrivalsField).child(uid);
    try {
      // Stamped once: a reopened page must not move our arrival — possibly
      // the table's reference — to now.
      final existing = await ref.get().timeout(const Duration(seconds: 3));
      if (existing.value is num) {
        _rc("arrival already stamped (page reopened)");
        return;
      }
    } catch (e) {
      // Could not tell. Stamped anyway: this used to give up here, and a
      // table without `roll_call_at` (a friend room, a rematch) whose other
      // players never arrived then had no reference at all — a duel never
      // cancelled, a vote never opened. At worst a reopened page moves our
      // arrival later, which only makes the table wait longer.
      _rc("arrival check failed ($e) — stamping anyway");
    }
    if (isClosed) return;
    try {
      final sentAt = DateTime.now().millisecondsSinceEpoch;
      await ref.set(ServerValue.timestamp).timeout(const Duration(seconds: 5));
      final ackAt = DateTime.now().millisecondsSinceEpoch;
      final stamped = await ref.get().timeout(const Duration(seconds: 3));
      final value = stamped.value;
      // A slow round trip makes a poor estimate: keep the connection's own.
      if (value is num && ackAt - sentAt < 3000) {
        _serverOffsetMs = value.toInt() - (sentAt + ackAt) ~/ 2;
        _offsetFromArrival = true;
        _rc(
          "arrival stamped, clock offset ${_serverOffsetMs}ms "
          "(round trip ${ackAt - sentAt}ms)",
        );
        _updateRollCallReference();
      }
    } catch (e) {
      debugPrint("⚠️ roll_call arrival failed => $e");
    }
  }

  /// Re-reads the reference after any of its sources moved. A reference that
  /// reads as in the future, or as long past the cap, cannot be trusted:
  /// acting on it would cut the wait short (or skip it) and eject players who
  /// are on their way, so the wait is counted from now instead — waiting a
  /// little too long is the only error allowed here.
  void _updateRollCallReference() {
    final reference = _serverRollCallAt ?? _earliestArrivalAt;
    if (reference == null || isClosed) return;
    final skew = _serverNowMs - reference;
    final trusted =
        skew > -const Duration(seconds: 5).inMilliseconds &&
        skew <
            (GamicoRollCallRules.cap + const Duration(seconds: 30))
                .inMilliseconds;
    final previousStart = _rollCallStartedAtMs;
    if (trusted) {
      _rollCallStartedAtMs = reference;
    } else {
      _rollCallStartedAtMs ??= _serverNowMs;
    }
    if (_rollCallStartedAtMs != previousStart) {
      _rc(
        "wait counted from "
        "${_serverRollCallAt != null ? "server" : "earliest arrival"}"
        "${trusted ? "" : " — UNTRUSTED (skew ${skew}ms), counting from now"}",
      );
    }
    _publishRollCallStatus();
    _evaluateRollCallRules();
  }

  void _startRollCallTicker() {
    if (legacyRollCall || state.fakeOpponent) return;
    _rollCallTicker?.cancel();
    _rollCallTicker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isClosed || _rollCallApplied || gameCubit.state.ready) {
        _stopRollCallTicker();
        return;
      }
      _publishRollCallStatus();
      _evaluateRollCallRules();
    });
  }

  /// The roll-call's own nodes (roster, markers, votes) have nothing more to
  /// say once the roster is applied; their listeners used to stay open for
  /// the whole match. Safe from inside one of their callbacks.
  void _stopRollCallListeners() {
    _rollCallSubscription?.cancel();
    _rollCallSubscription = null;
    _rollCallReadySubscription?.cancel();
    _rollCallReadySubscription = null;
    _rollCallVotesSubscription?.cancel();
    _rollCallVotesSubscription = null;
  }

  void _stopRollCallTicker() {
    _rollCallTicker?.cancel();
    _rollCallTicker = null;
    _rollCallRetryTimer?.cancel();
    _rollCallRetryTimer = null;
    _serverOffsetSubscription?.cancel();
    _serverOffsetSubscription = null;
    _rollCallAtSubscription?.cancel();
    _rollCallAtSubscription = null;
    _rollCallArrivalsSubscription?.cancel();
    _rollCallArrivalsSubscription = null;
    _connectedSubscription?.cancel();
    _connectedSubscription = null;
  }

  /// Seals the roster when one of [GamicoRollCallRules] says so.
  void _evaluateRollCallRules() {
    if (legacyRollCall || !_readinessSent) return;
    if (_rollCallProposed || _rollCallApplied || isClosed) return;
    if (gameCubit.state.ready) return;

    final myReadyAt = _myReadyAt;
    if (myReadyAt == null) return;
    var startedAt = _rollCallStartedAtMs;
    if (startedAt == null) {
      // No reference reached us (no `roll_call_at`, and not one arrival
      // stamp readable — the network, or our own stamp failed): count from
      // our READINESS rather than wait on nothing forever. Any trusted
      // reference arriving later replaces it (see [_updateRollCallReference]).
      final waited = DateTime.now().difference(myReadyAt);
      if (waited < _referenceFallbackAfter) return;
      startedAt = _serverNowMs - waited.inMilliseconds;
      _rollCallStartedAtMs = startedAt;
      _rc(
        "no reference after ${waited.inSeconds} s — counting from our "
        "READINESS",
      );
      _publishRollCallStatus();
    }

    final elapsed = Duration(milliseconds: _serverNowMs - startedAt);
    final waitedMyself =
        DateTime.now().difference(myReadyAt) >=
        GamicoRollCallRules.minimumOwnWait;
    final ready = _presentReadyIds;

    if (_isDuel) {
      if (elapsed >= GamicoRollCallRules.duelGrace && waitedMyself) {
        _proposeRollCall(ready, GamicoRollCallReason.duelTimeout);
      }
      return;
    }

    if (elapsed >= GamicoRollCallRules.cap && waitedMyself) {
      _proposeRollCall(ready, GamicoRollCallReason.cap);
      return;
    }

    if (elapsed >= GamicoRollCallRules.voteOpensAfter &&
        _ejectMajorityReached(ready)) {
      _proposeRollCall(ready, GamicoRollCallReason.vote);
    }
  }

  /// Whether more than half of the players able to vote, among [ready], vote
  /// to go on without the absent.
  bool _ejectMajorityReached(Set<String> ready) {
    final votes = _ejectVotes.where(ready.contains).length;
    final voters = GamicoRollCallRules.voterCount(
      readyIds: ready,
      awayIds: _awayIds,
      ejectVotes: _ejectVotes,
    );
    return votes >= GamicoRollCallRules.ejectVotesNeeded(voters);
  }

  /// Flips our vote between "eject the absent" and "wait for them". Only a
  /// player who is at the table votes, and only once the vote is open.
  Future<void> toggleEjectVote() async {
    final status = state.rollCall;
    final uid = LocalStorageService.uid;
    if (status == null || !status.voteOpen || uid.isEmpty) return;
    if (!_readyPlayerIds.contains(uid) || _rollCallApplied) return;

    final eject = !_ejectVotes.contains(uid);
    _rc("my vote: ${eject ? "eject" : "wait"}");
    if (eject) {
      _ejectVotes.add(uid);
    } else {
      _ejectVotes.remove(uid);
    }
    _publishRollCallStatus();
    _evaluateRollCallRules();

    final ref = _gameRef.child(_rollCallVotesField).child(uid);
    try {
      if (eject) {
        await ref.set(true);
      } else {
        await ref.remove();
      }
    } catch (e) {
      debugPrint("⚠️ roll_call vote failed => $e");
      // Nobody else saw it: show what the table actually counts.
      if (isClosed || _rollCallApplied) return;
      if (eject) {
        _ejectVotes.remove(uid);
      } else {
        _ejectVotes.add(uid);
      }
      _publishRollCallStatus();
    }
  }

  /// What the waiting screen shows: a table of three or more for the whole
  /// wait, a duel only once the other player is late (see
  /// [GamicoRollCallRules.duelScreenAfter]) — until then it keeps the game's
  /// own loader.
  void _publishRollCallStatus() {
    if (legacyRollCall || state.fakeOpponent) return;
    if (!_showsWaitingList && !_isDuel) return;
    if (_isDuel && _expectedPlayerIds.length < 2) return;
    if (_rollCallApplied || gameCubit.state.ready) {
      if (state.rollCall != null) emit(state.copyWith(rollCall: () => null));
      return;
    }
    final startedAt = _rollCallStartedAtMs;
    final elapsed = startedAt == null
        ? 0
        : ((_serverNowMs - startedAt) / 1000).floor().clamp(0, 1 << 30);
    final playerIds = _expectedOrder
        .where((id) => !_exitedPlayerIds.contains(id))
        .toList();
    final answered = _answeredIds;
    final GamicoRollCallStatus? status;
    if (_isDuel &&
        (!_readinessSent ||
            startedAt == null ||
            elapsed < GamicoRollCallRules.duelScreenAfter.inSeconds ||
            playerIds.every(answered.contains))) {
      status = null;
    } else {
      status = GamicoRollCallStatus(
        playerIds: playerIds,
        readyIds: answered,
        ejectVotes: Set.of(_ejectVotes),
        awayIds: _awayIds,
        duel: _isDuel,
        elapsedSeconds: elapsed,
      );
    }
    if (status != state.rollCall) emit(state.copyWith(rollCall: () => status));
  }

  /// How long a deadline waits for READINESS still in flight before sealing
  /// (see [_proposeRollCall]).
  static const Duration _sealLastCall = Duration(milliseconds: 1500);

  /// Offers [ready] as the table's roster. First writer wins; everyone,
  /// ourselves included, then deals with whatever won.
  Future<void> _proposeRollCall(
    Set<String> ready,
    GamicoRollCallReason reason,
  ) async {
    if (_rollCallProposed || _rollCallApplied || isClosed) return;
    _rollCallProposed = true;
    _readinessFallbackTimer?.cancel();

    if (reason != GamicoRollCallReason.allReady) {
      // A deadline, not a full table: whoever answered by the deadline the
      // screens showed must be seated, even if their READINESS is still on
      // its way to us — a player ready at 24.9 s used to be cut from a duel
      // that then got cancelled with both players there. The listeners keep
      // running meanwhile; the roster is taken again afterwards. (Re-reading
      // the node instead would not help: a `get()` on a path we already
      // listen to answers from that same local cache.)
      await Future.delayed(_sealLastCall);
      if (isClosed || _rollCallApplied) return;
      if (gameCubit.state.ready) return;
      ready = _presentReadyIds;
      final expected = _expectedPlayerIds.difference(_exitedPlayerIds);
      if (expected.isNotEmpty && ready.containsAll(expected)) {
        reason = GamicoRollCallReason.allReady;
      } else if (reason == GamicoRollCallReason.vote &&
          !_ejectMajorityReached(ready)) {
        // A vote taken back in the meantime: the table waits on.
        _rc("vote majority lost before sealing — waiting on");
        _rollCallProposed = false;
        return;
      }
    }

    _rc(
      "propose ${reason.wire}: $ready "
      "(expected ${_expectedPlayerIds.length}, votes $_ejectVotes, "
      "away $_awayIds)",
    );

    final proposal = GamicoRollCallVerdict(ready, reason);
    final ref = _gameRef.child(_rollCallField);
    try {
      final result = await ref
          .runTransaction((current) {
            // Sealed already: never rewrite someone else's roster.
            if (current != null) return Transaction.abort();
            return Transaction.success(proposal.toJson());
          }, applyLocally: false)
          .timeout(const Duration(seconds: 5));
      final sealed = GamicoRollCallVerdict.fromJson(result.snapshot.value);
      if (sealed != null) {
        _rc(
          result.committed
              ? "sealed by us"
              : "already sealed by another device (${sealed.reason.wire})",
        );
        _applyRollCall(sealed);
        return;
      }
      final current = await ref.get().timeout(const Duration(seconds: 3));
      final read = GamicoRollCallVerdict.fromJson(current.value);
      if (read != null) {
        _applyRollCall(read);
        return;
      }
    } catch (e) {
      debugPrint("⚠️ roll_call seal failed => $e");
      _rc("seal failed ($e) — retrying in 3 s");
    }
    // Unreachable server. Dealing on our own verdict here is precisely the
    // split the shared roster exists to prevent — and a device that cannot
    // reach the database cannot play an online hand anyway. Try again in a
    // moment; the listener may well deliver someone else's roster first, and
    // leaving stays free while nothing is dealt.
    if (isClosed || _rollCallApplied) return;
    _rollCallProposed = false;
    _rollCallRetryTimer?.cancel();
    _rollCallRetryTimer = Timer(const Duration(seconds: 3), () {
      if (isClosed || _rollCallApplied || gameCubit.state.ready) return;
      if (legacyRollCall &&
          !_expectedPlayerIds
              .difference(_exitedPlayerIds)
              .every(_readyPlayerIds.contains)) {
        // The older rule's grace has already run out: seal what is there.
        _proposeRollCall(_presentReadyIds, GamicoRollCallReason.grace);
        return;
      }
      _checkReadiness();
    });
  }

  void _applyRollCall(GamicoRollCallVerdict? verdict) {
    if (verdict == null || isClosed || _rollCallApplied) return;
    if (gameCubit.state.ready) return;
    // Our own `initGame` has not run yet: a roster that seats us waits for
    // it, since the game layer can only strike seats it has built. One that
    // leaves us out needs nothing of the kind — and holding it back is what
    // left a device stuck on its game read on the loader for good.
    if (!_readinessSent && verdict.players.contains(LocalStorageService.uid)) {
      _pendingRollCall = verdict;
      _rc("roster held until our READINESS");
      return;
    }
    _rollCallApplied = true;
    _pendingRollCall = null;
    _sealedRollCall = verdict.players;
    _readinessFallbackTimer?.cancel();
    _stopRollCallTicker();
    // The roster is final: nothing a marker says from here on can change it.
    // An "away" written mid-match would even mislead a device still on its
    // way to this roster into reporting a seated player as gone.
    _cancelAwayOnDisconnect();
    _stopRollCallListeners();
    if (state.rollCall != null) emit(state.copyWith(rollCall: () => null));

    final myUid = LocalStorageService.uid;
    final otherPlayers = expectedOtherPlayers;
    // Everyone expected who is not at the table: never answered, or quit
    // before the deal. The older rule (tournament) already told the game
    // about every quitter as their EXIT arrived.
    final absent = _expectedPlayerIds
        .where((uid) => uid != myUid && !verdict.players.contains(uid))
        .where((uid) => !_reportedGone.contains(uid))
        .toList();
    // In the roster but gone since: sealed with them, then they quit before
    // this device got the roster. The table is dealt with their seat, so the
    // game hears it as a departure once dealt — the same as a quit mid-match.
    final leftSinceSeal = verdict.players
        .where(
          (uid) =>
              uid != myUid &&
              _exitedPlayerIds.contains(uid) &&
              !_reportedGone.contains(uid),
        )
        .toList();

    _rc(
      "apply ${verdict.reason.wire}: seated ${verdict.players}, "
      "absent $absent, left since seal $leftSinceSeal",
    );

    if (!verdict.players.contains(myUid)) {
      _rc("→ EXCLUDED (${verdict.reason.wire})");
      final onExcluded = gameCubit.settings?.onExcludedFromRollCall;
      if (onExcluded != null) {
        onExcluded(verdict.reason);
      } else {
        emit(
          state.copyWith(
            rollCallOutcome: () => GamicoRollCallOutcome.excluded(
              verdict.reason,
              otherPlayers: otherPlayers,
            ),
          ),
        );
      }
      return;
    }

    // Left alone at a table nobody else reached, or that everyone else left
    // before the deal: cancelled, never won. Counted in humans, bots or not:
    // a game that seats bots may well crown the last human standing (Ludo
    // does, rather than strand them alone against bots), which would turn an
    // opponent's absence into a free victory.
    if (!legacyRollCall &&
        _expectedPlayerIds.length >= 2 &&
        verdict.players.length < 2) {
      _exitedPlayerIds.addAll(absent);
      final othersLeft = verdict.reason == GamicoRollCallReason.allReady;
      _rc("→ CANCELLED (${othersLeft ? "others left" : "nobody came"})");
      final onCancelled = gameCubit.settings?.onRollCallCancelled;
      if (onCancelled != null) {
        onCancelled();
      } else {
        emit(
          state.copyWith(
            rollCallOutcome: () => GamicoRollCallOutcome.cancelled(
              otherPlayers: otherPlayers,
              othersLeft: othersLeft,
            ),
          ),
        );
      }
      return;
    }

    // Our seat, at a table dealt and played without this page (the app
    // reopened mid-match), in a game that cannot catch up with it. Dealing
    // here would rebuild the board from the start and play on out of step
    // with everyone else. Never dealt, so leaving is free — and the EXIT it
    // sends is what the others take as this seat's departure.
    if (_sealedBeforeOurReadiness &&
        gameCubit.settings?.rejoinsDealtTable == false) {
      _rc("→ SEAT LOST (reopened a dealt table, the game cannot catch up)");
      emit(
        state.copyWith(
          rollCallOutcome: () =>
              GamicoRollCallOutcome.seatLost(otherPlayers: otherPlayers),
        ),
      );
      return;
    }

    for (final uid in absent) {
      _exitedPlayerIds.add(uid);
      _tellGameGone(uid);
    }
    _rc("→ START with ${verdict.players.length} player(s) + $_botSeats bot(s)");
    gameCubit.startGame();
    for (final uid in leftSinceSeal) {
      _tellGameGone(uid);
    }
  }
  // ────────────────────────────────────────────────────────────────────────────

  // Remote game seeds.
  //
  // Derived on read from the shared `createdAt` timestamp rather than assigned
  // once during init: as `late final` fields they were a crash waiting to
  // happen — a game whose `initGame()` ran before (or without) the assignment
  // threw a fatal LateInitializationError from deep inside the game's own
  // engine construction, and a second init threw "already initialized". The
  // value is identical either way, and still identical on every device, since
  // `createdAt` is written once by the host.
  int get _seedBase => currentGame?.createdAt?.microsecondsSinceEpoch ?? 0;
  int get seed1 => _seedBase & 0x7FFFFFFF;
  int get seed2 => (_seedBase ~/ 7) & 0x7FFFFFFF;

  // Holds the id of a new hypothetical game
  String newGameId = "";

  /// Arms the abandonment penalty that fires if this device drops off the
  /// network mid-match.
  ///
  /// Called only once the table is actually dealt. It used to be armed during
  /// `onInit`, i.e. while the player was still on the pre-deal loader waiting
  /// for the readiness roll-call: a match that never started — because a
  /// matched opponent never made it to the table — cost the players who *did*
  /// show up their coins, their trophy and a defeat, for a game they never
  /// got to play.
  Future<void> _armDisconnectionPenalty() async {
    if (isClosed || _disconnectionPenaltyArmed) return;
    _disconnectionPenaltyArmed = true;

    userDisconnectionReference = FirebaseDatabase.instance
        .ref("users")
        .child(LocalStorageService.uid)
        .onDisconnect();

    if (Gamico.instance.playSettings?.exitUserWhenDisconnected == true ||
        !state.fakeOpponent) {
      // For moded games (e.g. an embedded game), the disconnection penalty
      // targets that mode's own progression namespace instead of the
      // top-level stats. Coins stay a single shared wallet.
      final mode = state.remoteUtility.matchmakingSettings.mode;

      _armedDisconnectionPenalty = {
        "coins": -Gamico.instance.gameSettings.playMinimumCoins,
        if (mode == null) "defeats": 1,
        if (mode == null) "trophies": -1,
        if (mode != null) "progression/$mode/defeats": 1,
        if (mode != null) "progression/$mode/trophies": -1,
      };

      try {
        await userDisconnectionReference?.update(
          _disconnectionPenaltyPayload(_armedDisconnectionPenalty!),
        );
      } catch (e) {
        // onDisconnect().update() peut échouer si l'utilisateur est
        // hors-ligne ou si les règles Firebase bloquent l'écriture.
        // Non-fatal : on continue l'initialisation de la partie.
        debugPrint('[GamicoRemoteGameCubit] onDisconnect update failed: $e');
      }

      // Self-healing: a brief background trip drops the database connection
      // (see field doc above) and fires the penalty above almost instantly.
      // Refund and re-arm on every genuine reconnection while the match is
      // still active, so only a real, lasting abandonment is ever scored.
      _sawInitialConnected = false;
      _disconnectionPenaltySubscription?.cancel();
      _disconnectionPenaltySubscription = FirebaseDatabase.instance
          .ref(".info/connected")
          .onValue
          .listen((event) {
            if (event.snapshot.value != true) return;
            if (!_sawInitialConnected) {
              _sawInitialConnected = true;
              return;
            }
            _refundAndRearmDisconnectionPenalty();
          });
    }
  }

  /// Guards a single arming of the penalty above.
  bool _disconnectionPenaltyArmed = false;

  void resetGameEndStatus() {
    emit(state.copyWith(gameEndStatus: ""));
  }

  void withdraw() {
    gamesRepository.addGameEvent(
      gameId,
      GamicoGameEventModel(type: "WITHDRAW", userId: LocalStorageService.uid),
    );
  }

  void acceptInvitation() {
    gamesRepository.addGameEvent(
      gameId,
      GamicoGameEventModel(
        type: "ACCEPTATION",
        userId: LocalStorageService.uid,
      ),
    );
  }

  void rejectInvitation() {
    gamesRepository.addGameEvent(
      gameId,
      GamicoGameEventModel(type: "REJECTION", userId: LocalStorageService.uid),
    );
  }

  void replay([int? level]) {
    final opponent = state.opponent;

    if (opponent == null) return;

    if (opponent.online == false || state.fakeOpponent) {
      emit(state.copyWith(gameEndStatus: "REPLAY_IMPOSSIBLE"));
    } else if (opponent.broke == true) {
      gamesRepository.addGameEvent(
        gameId,
        GamicoGameEventModel(type: "NEEDINESS", userId: state.opponentId),
      );
    } else {
      gamesRepository.addGameEvent(
        gameId,
        GamicoGameEventModel(
          type: "REPLAY",
          userId: LocalStorageService.uid,
          data: level == null ? null : {"level": level},
        ),
      );
    }
  }

  /* ---------------------------------------------------- REPLAY VOTES ---- */

  /// How long a rematch waits for the undecided once at least two players
  /// agree on the same option. When it runs out the majority plays without
  /// them, rather than the whole table being held hostage by one player who
  /// walked away from their phone without leaving the match.
  static const Duration replayCountdown = Duration(seconds: 15);

  /// Local countdown, purely for the dial the popup draws. The decision it
  /// leads to is written by one device only (see [_replayRefereeId]), so a
  /// couple of hundred milliseconds of drift between phones changes nothing.
  Timer? _replayCountdownTimer;

  /// Guards against replaying the same resolution twice — the launch is
  /// triggered from the shared event log, which can redeliver.
  bool _replayLaunched = false;

  /// The players a rematch is still waiting on: everyone seated who has
  /// neither left the match nor been dropped by an expired countdown.
  List<String> get activePlayerIds {
    final ids = _expectedPlayerIds.difference(_exitedPlayerIds).toList()
      ..sort();
    return ids;
  }

  /// The single device that writes the verdict when the countdown expires.
  ///
  /// Deterministic on every phone (the lowest uid still at the table) and it
  /// survives departures, so there is always exactly one referee and never
  /// two devices resolving a split vote differently.
  String? get _replayRefereeId {
    final ids = activePlayerIds;
    return ids.isEmpty ? null : ids.first;
  }

  /// The option the local player voted for, if any.
  String? get myReplayVote => state.replayVotes[LocalStorageService.uid];

  /// Asks to play again with [optionId]. Voting for the option already chosen
  /// takes the vote back, so the button is a toggle.
  void voteReplay([String optionId = kGamicoSameGameReplayOption]) {
    if (!gameCubit.state.over) return;
    if (myReplayVote == optionId) {
      cancelReplayVote();
      return;
    }

    _applyReplayVote(LocalStorageService.uid, optionId);

    gamesRepository.addGameEvent(
      gameId,
      GamicoGameEventModel(
        type: "REPLAY_VOTE",
        userId: LocalStorageService.uid,
        data: <String, dynamic>{"option": optionId},
      ),
    );
  }

  /// Takes back a "Rejouer" before the rematch starts.
  void cancelReplayVote() {
    if (myReplayVote == null) return;

    _applyReplayVote(LocalStorageService.uid, null);

    gamesRepository.addGameEvent(
      gameId,
      GamicoGameEventModel(
        type: "REPLAY_VOTE_CANCEL",
        userId: LocalStorageService.uid,
      ),
    );
  }

  /// Records one player's vote (or its withdrawal) and re-reads the table.
  /// Applied locally the moment the player taps and again when their own
  /// event comes back — writing the same value twice changes nothing, which
  /// is the point: votes are keyed by uid, never counted.
  void _applyReplayVote(String userId, String? optionId) {
    if (userId.isEmpty) return;

    final votes = Map<String, String>.from(state.replayVotes);
    if (optionId == null) {
      if (votes.remove(userId) == null) {
        // Nothing changed, but the roll-call may still have (a player left).
        _evaluateReplayVotes();
        return;
      }
    } else {
      if (votes[userId] == optionId) {
        _evaluateReplayVotes();
        return;
      }
      votes[userId] = optionId;
    }

    emit(state.copyWith(replayVotes: votes, replayPlayerIds: activePlayerIds));

    _evaluateReplayVotes();
  }

  /// Reads the table after every change and decides what happens next:
  /// everybody agrees → the rematch starts at once; two or more agree while
  /// somebody is undecided → the countdown runs; nobody agrees → it stops.
  void _evaluateReplayVotes() {
    if (_replayLaunched) return;

    final active = activePlayerIds;
    final votes = Map<String, String>.from(state.replayVotes)
      ..removeWhere((uid, _) => !active.contains(uid));

    if (votes.length != state.replayVotes.length ||
        !_sameList(state.replayPlayerIds, active)) {
      emit(state.copyWith(replayVotes: votes, replayPlayerIds: active));
    }

    if (active.length < 2) {
      _stopReplayCountdown();
      return;
    }

    final counts = <String, int>{};
    for (final option in votes.values) {
      counts[option] = (counts[option] ?? 0) + 1;
    }

    // Unanimous: nothing left to wait for, and every device reaches this
    // conclusion from the same event log, so they all launch together.
    for (final entry in counts.entries) {
      if (entry.value >= 2 && entry.value == active.length) {
        _stopReplayCountdown();
        _launchReplay(entry.key, active);
        return;
      }
    }

    final bool contested = counts.values.any((count) => count >= 2);
    if (contested) {
      _startReplayCountdown();
    } else {
      _stopReplayCountdown();
    }
  }

  bool _sameList(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  void _startReplayCountdown() {
    if (state.replayCountdownStartedAt != null) return;

    emit(state.copyWith(replayCountdownStartedAt: () => DateTime.now()));

    _replayCountdownTimer?.cancel();
    _replayCountdownTimer = Timer(replayCountdown, _onReplayCountdownExpired);
  }

  void _stopReplayCountdown() {
    _replayCountdownTimer?.cancel();
    _replayCountdownTimer = null;
    if (state.replayCountdownStartedAt != null) {
      emit(state.copyWith(replayCountdownStartedAt: () => null));
    }
  }

  /// The undecided ran out of time: the referee names the winning option and
  /// the players who go on with it. Everyone else — including the referee —
  /// acts on the event it writes, so all devices drop exactly the same seats.
  void _onReplayCountdownExpired() {
    _replayCountdownTimer = null;
    if (isClosed || _replayLaunched) return;
    if (_replayRefereeId != LocalStorageService.uid) return;

    final active = activePlayerIds;
    final votes = Map<String, String>.from(state.replayVotes)
      ..removeWhere((uid, _) => !active.contains(uid));

    String? winner;
    int best = 0;
    for (final entry in votes.entries) {
      final count = votes.values.where((o) => o == entry.value).length;
      if (count >= 2 && count > best) {
        best = count;
        winner = entry.value;
      }
    }

    if (winner == null) return;

    final retained =
        votes.entries.where((e) => e.value == winner).map((e) => e.key).toList()
          ..sort();

    gamesRepository.addGameEvent(
      gameId,
      GamicoGameEventModel(
        type: "REPLAY_START",
        userId: LocalStorageService.uid,
        data: <String, dynamic>{"option": winner, "players": retained},
      ),
    );
  }

  /// Starts the rematch: the players left out are struck from the table so the
  /// new game only deals to those who asked for it.
  void _launchReplay(String optionId, List<String> players) {
    if (_replayLaunched) return;
    _replayLaunched = true;

    _stopReplayCountdown();

    for (final uid in _expectedPlayerIds) {
      if (!players.contains(uid)) _exitedPlayerIds.add(uid);
    }

    emit(
      state.copyWith(replayOption: () => optionId, replayPlayerIds: players),
    );

    _launchNewGame();
  }

  void setRemoteGameInternetError(bool remoteGameInternetError) {
    emit(state.copyWith(remoteGameInternetError: remoteGameInternetError));
  }

  void setNewRemoteGameActive(bool newRemoteGameActive, [int? level]) {
    emit(
      state.copyWith(
        newRemoteGameActive: newRemoteGameActive,
        nextLevel: level == null ? null : () => level,
      ),
    );

    declareCurrentUserExit();
  }

  void declareCurrentUserExit() {
    if (state.fakeOpponent) return;

    // Leaving before the deal: withdraw our answer to the roll-call too, where
    // every device can read it (see [kGamicoRollCallLeft]).
    if (!gameCubit.state.ready && gameId.isNotEmpty) {
      _rc("leaving before the deal");
      // Disarmed first, on the same connection: the server would otherwise
      // turn this "left" into an "away" when the connection later drops.
      _leftBeforeDeal = true;
      _cancelAwayOnDisconnect();
      unawaited(
        _gameRef
            .child(_rollCallReadyField)
            .child(LocalStorageService.uid)
            .set(kGamicoRollCallLeft)
            .catchError((_) {}),
      );
    }

    gamesRepository.addGameEvent(
      gameId,
      GamicoGameEventModel(
        // data: <String, dynamic>{
        //   "row": tile.row,
        //   "col": tile.col,
        // },
        type: "EXIT",
        userId: LocalStorageService.uid,
      ),
    );
  }

  Future<void> _launchNewGame() async {
    if (Gamico.instance.playSettings?.singlePlayerWhenFake != true) {
      emit(state.copyWith(gameEndStatus: "INVITATION_ACCEPTATION"));
    }

    // A rematch resolved by vote leaves out whoever did not ask for it (see
    // [_launchReplay]); everything below then works off the shortened table.
    final retainedPlayers = _replayLaunched
        ? Map<String, GamicoGamePlayerModel>.fromEntries(
            (currentGame?.players?.entries ??
                    const <MapEntry<String, GamicoGamePlayerModel>>[])
                .where(
                  (e) =>
                      e.value.userId == null ||
                      e.value.userId.toString().startsWith("bot_") ||
                      state.replayPlayerIds.contains(e.value.userId),
                ),
          )
        : currentGame?.players;

    final playersEntries = (retainedPlayers?.entries.toList() ?? [])
      ..sort((a, b) => a.key.compareTo(b.key));
    // Bot-filled seats have no device to create the new game — see the note on
    // `playersIds` in [init].
    final sortedPlayerUids = playersEntries
        .map((e) => e.value.userId)
        .where((id) => id == null || !id.toString().startsWith("bot_"))
        .toList();
    final isFirstJoiner =
        sortedPlayerUids.length > 1 &&
        sortedPlayerUids[1] == LocalStorageService.uid;

    if (isFirstJoiner) {
      newGameId = await gamesRepository.createGame(
        GamicoGameModel(
          events: const {},
          players: retainedPlayers,
          status: "CREATED",
        ),
      );

      newGameStreamSubscription = FirebaseDatabase.instance
          .ref()
          .child("games/$newGameId/status")
          .onValue
          .listen(
            (event) {
              final status = event.snapshot.value.toString();

              if (status == "STARTED") {
                emit(
                  state.copyWith(
                    newGameCreator: true,
                    newGameId: newGameId,
                    replay: true,
                  ),
                );
              }
            },
            onError: (e) =>
                debugPrint("⚠️ newGameStreamSubscription error => $e"),
          );

      gamesRepository.addGameEvent(
        gameId,
        GamicoGameEventModel(
          data: <String, dynamic>{"id": newGameId},
          type: "IDENTIFICATION",
          userId: LocalStorageService.uid,
        ),
      );
    }
  }

  String get developerAppleId => remoteUtility.developerAppleId;
  String get developerAndroidId => remoteUtility.developerAndroidId;

  // ── Placeholder settings ──────────────────────────────────────────────────
  // A game may start the remote machinery with placeholder settings (no game
  // cubit behind them) and install the real ones once its board exists — Ludo
  // does, since its board needs a config another device writes. Whatever the
  // table sent in between went to callbacks that do nothing: the players the
  // roll-call struck (a ghost seat, each of its turns then waited out) and the
  // moves already played (a board out of step for good). Both are now kept
  // and handed over the moment the real settings arrive.
  //
  // In ONE list, in the order the table sent them: a player who quits
  // mid-match after playing is a move then a departure, and handing every
  // departure over first (as it once did) dropped that camp from the turn
  // order before its last moves were replayed — which then landed on another
  // player's turn, a lockstep board out of step for good.
  final List<({GamicoGameEventModel? move, String? goneUid})> _pendingForGame =
      [];

  bool get _onPlaceholderSettings {
    final settings = gameCubit.settings;
    return settings != null && settings.gameCubit == null;
  }

  void _onSettingsReplaced(GamicoGameCubitSettings? previous) {
    if (isClosed || previous == null || previous.gameCubit != null) return;
    final settings = gameCubit.settings;
    if (settings == null || settings.gameCubit == null) return;
    final pending = List.of(_pendingForGame);
    _pendingForGame.clear();
    _rc(
      "real settings installed: replaying "
      "${pending.where((e) => e.goneUid != null).length} departure(s), "
      "${pending.where((e) => e.move != null).length} move(s), in order",
    );
    for (final item in pending) {
      final move = item.move;
      final goneUid = item.goneUid;
      if (move != null) {
        settings.receiveMoveFromRemotePlayer(move);
      } else if (goneUid != null) {
        settings.onRemoteUserDisconnectedDuringGame(goneUid);
      }
    }
  }

  /// Tells the game [uid] is gone — or, while it has no board to tell yet
  /// (placeholder settings), keeps it in line with the moves for when it has.
  void _tellGameGone(String uid) {
    _reportedGone.add(uid);
    final settings = gameCubit.settings;
    if (settings == null || settings.gameCubit == null) {
      _pendingForGame.add((move: null, goneUid: uid));
      return;
    }
    settings.onRemoteUserDisconnectedDuringGame(uid);
  }
  // ────────────────────────────────────────────────────────────────────────────

  void init() {
    gameCubit.onSettingsReplaced = _onSettingsReplaced;
    gameCubit.onInit = () async {
      GameService.gameSkipped =
          adventureUtility != null && (state.userInitialLevel == state.level);

      // In parallel with everything below: the deadlines of the roll-call are
      // counted from it, and nothing before our READINESS needs it.
      unawaited(_resolveRollCallStart());
      // First thing, ahead of the game read: whether the roster was already
      // sealed when we arrived is what tells a reopened table from a new one
      // (see [rejoiningSealedTable]).
      _listenToRollCall();
      // Settled against the server alongside the game read, before our
      // READINESS (see [_checkSealedOnServer]).
      final sealedCheck = _checkSealedOnServer();

      // Each attempt bounded (an unbounded `get()` on a flaky connection used
      // to hang past the others' patience), and retried for as long as the
      // table can still be waiting for us. It used to give up after two
      // tries: no READINESS ever, even once the network came back, and a
      // player stranded on the loader — with the table's verdict about them
      // (sealed while they were stuck) never shown, since a roster that seats
      // us waits for our READINESS. A roster that leaves us out no longer
      // does (see [_applyRollCall]), so whichever comes first — the game read
      // or the table giving up on us — ends the wait.
      final readDeadline = DateTime.now().add(
        GamicoRollCallRules.cap + const Duration(seconds: 30),
      );
      while (true) {
        if (isClosed || _rollCallApplied) return;
        try {
          currentGame = await gamesRepository
              .readGame(gameId)
              .timeout(const Duration(seconds: 5));
          break;
        } catch (e) {
          debugPrint('[GamicoRemoteGameCubit] Error reading game data: $e');
          _rc("game read failed ($e) — retrying");
          if (DateTime.now().isAfter(readDeadline)) {
            setRemoteGameInternetError(true);
            return;
          }
          await Future.delayed(const Duration(seconds: 2));
        }
      }
      if (isClosed || _rollCallApplied) return;

      await sealedCheck;
      if (isClosed || _rollCallApplied) return;

      // Seats filled by [RemoteCubit.enableBotFallback] carry a synthetic
      // `bot_<key>` id and no device behind them. Counting them here would
      // stall the table twice over: they never answer the READINESS roll-call
      // (so every launch would burn the 20 s grace and then report each bot as
      // a player who disconnected mid-game), and they never ask to replay (so
      // `replayRequests` could never reach the table's size and "Rejouer"
      // would wait forever).
      final playersIds =
          (currentGame?.players?.values ?? <GamicoGamePlayerModel>[])
              .map<String>((e) {
                return e.userId.toString();
              })
              .where((id) => !id.startsWith("bot_"))
              .toList();

      _expectedPlayerIds = playersIds.toSet();
      _botSeats = (currentGame?.players?.values ?? <GamicoGamePlayerModel>[])
          .where((e) => e.userId.toString().startsWith("bot_"))
          .length;
      final seatEntries =
          (currentGame?.players?.entries.toList() ??
                <MapEntry<String, GamicoGamePlayerModel>>[])
            ..sort((a, b) => a.key.compareTo(b.key));
      _expectedOrder = seatEntries
          .map((e) => e.value.userId.toString())
          .where(_expectedPlayerIds.contains)
          .toSet()
          .toList();
      _rc(
        "table: expected $_expectedOrder, bots $_botSeats"
        "${legacyRollCall ? ", legacy 20 s rule" : ""}"
        "${state.fakeOpponent ? ", fake opponent" : ""}",
      );
      _publishRollCallStatus();
      _startRollCallTicker();
      emit(state.copyWith(replayPlayerIds: activePlayerIds));

      final otherPlayerIds = playersIds
          .where((element) => element != LocalStorageService.uid)
          .toList();
      final Map<String, dynamic> loadedOpponents = {};

      for (var s in opponentStreamSubscriptions) {
        s.cancel();
      }
      opponentStreamSubscriptions = [];

      if (otherPlayerIds.isEmpty) {
        final developerId = remoteUtility.developerId;
        // Read once, and only the fields the synthetic opponent is built from.
        //
        // This used to hold a live `onValue` on the whole `users/{developerId}`
        // node for the length of the match. Two costs: the node is ~1.9 kB of
        // which this uses five fields, and the developer account is a real one
        // that keeps playing — so each of its own writes (coins, progression,
        // presence) was echoed to every player currently facing a bot.
        //
        // `userCreateFakeOpponent` synthesises the name, photo, coins, level,
        // trophies and stars, and takes only `type`, `achievements`,
        // `firebase_id`, `social_id` and `token` from the real account — the
        // very set the real-opponent branch below already enumerates under
        // `state.fakeOpponent`. None of them changes during a match, so there
        // is nothing for a live listener to deliver.
        const developerFields = <String>{
          "type",
          "achievements",
          "firebase_id",
          "social_id",
          "token",
        };
        final developerData = <String, dynamic>{"id": developerId};
        await Future.wait([
          for (final field in developerFields)
            FirebaseDatabase.instance
                .ref()
                .child("users/$developerId/$field")
                .get()
                .then((snapshot) {
                  if (snapshot.exists) {
                    developerData[field] = _deepCastValue(snapshot.value);
                  }
                })
                // Same bounded wait as the real-opponent reads below: this sits
                // on the critical path to our own READINESS.
                .timeout(const Duration(seconds: 2), onTimeout: () {})
                .catchError((_) {}),
        ]);

        var finalOpponent = Gamico.instance.userFromJson(developerData);

        // Null-safe since the user cubit is no longer seeded from LocalStorage:
        // an account that has not resolved yet leaves the opponent as-is rather
        // than crashing the match.
        final currentUser = gameCubit.userCubit.state.user;

        if (currentUser != null) {
          finalOpponent = Gamico.instance.userSettings.userCreateFakeOpponent(
            currentUser,
            finalOpponent,
          );
        }

        emit(
          state.copyWith(
            opponents: [finalOpponent],
            opponent: () => finalOpponent,
          ),
        );
      } else {
        // Only the handful of fields actually rendered/consulted for an
        // opponent (see player_profile_button, game_profile_poster, the
        // `broke`/`online` checks below) are listened to individually,
        // instead of the whole `users/$opponentId` node — that node also
        // carries ~20 fields (achievements, progression, skins, trophies…)
        // that change constantly across a player's other games and used to
        // re-download the entire user object to every opponent watching them.
        // `userCreateFakeOpponent` additionally needs a few identity fields
        // to build its synthetic opponent, so those are listened to too, but
        // only when this game actually runs in fake-opponent mode.
        // `name`/`photo` are identity fields — they don't change for the
        // duration of a match, so they're read once below instead of
        // holding a live listener open on them like `online`/`coins` for
        // the whole game.
        final staticFields = <String>{
          "name",
          "photo",
          "victories",
          "defeats",
          "trophies",
          // Read once rather than watched when nobody displays it live — see
          // [watchOpponentCoins]. Still read, so the value is never missing.
          if (!watchOpponentCoins) "coins",
        };
        final fieldsToWatch = <String>{
          "online",
          if (watchOpponentCoins) "coins",
          if (state.fakeOpponent) ...{
            "type",
            "achievements",
            "firebaseId",
            "socialId",
            "token",
          },
        };

        final initialFields = <String, Map<String, dynamic>>{
          for (final id in otherPlayerIds) id: {"id": id},
        };
        // Off the critical path: READINESS no longer waits for any of this.
        // The whole table waits on its slowest READINESS, and these reads
        // (bounded at 2 s, plus up to 2 s more for the listeners below) were
        // most of what made a slow phone slow. A name or a photo is
        // display-only: the waiting list, the table and the games all patch
        // them in as they arrive (Crazy Eights re-renders its seats, see its
        // session), and no game reads them in `initGame` or `startGame`.
        Future<void> loadOpponents() async {
          await Future.wait([
            for (final opponentId in otherPlayerIds)
              for (final field in staticFields)
                FirebaseDatabase.instance
                    .ref()
                    .child("users/$opponentId/$field")
                    .get()
                    .then((snapshot) {
                      initialFields[opponentId]![field] = snapshot.exists
                          ? _deepCastValue(snapshot.value)
                          : null;
                    })
                    .timeout(const Duration(seconds: 2), onTimeout: () {})
                    .catchError((_) {}),
          ]);

          // The page may be gone by now: a listener attached after the teardown
          // would never be cancelled.
          if (isClosed) return;

          for (final opponentId in otherPlayerIds) {
            final fields = initialFields[opponentId]!;

            for (final field in fieldsToWatch) {
              final sub = FirebaseDatabase.instance
                  .ref()
                  .child("users/$opponentId/$field")
                  .onValue
                  .listen(
                    (event) {
                      fields[field] = event.snapshot.exists
                          ? _deepCastValue(event.snapshot.value)
                          : null;

                      var finalOpponent = Gamico.instance.userFromJson(
                        Map<String, dynamic>.from(fields),
                      );

                      final currentUser = gameCubit.userCubit.state.user;

                      if (state.fakeOpponent && currentUser != null) {
                        finalOpponent = Gamico.instance.userSettings
                            .userCreateFakeOpponent(currentUser, finalOpponent);
                      }

                      loadedOpponents[opponentId] = finalOpponent;

                      final sortedOpponents = otherPlayerIds
                          .map((id) => loadedOpponents[id])
                          .where((o) => o != null)
                          .toList();

                      emit(
                        state.copyWith(
                          opponents: sortedOpponents,
                          opponent: () => sortedOpponents.firstOrNull,
                        ),
                      );

                      // A dropped `online` flag (backgrounding, flaky network,
                      // even an app kill) is NOT treated as an exit here: it
                      // would race the game's own turn-timeout cascade, which
                      // already auto-plays/skips the absent player's turns and
                      // only eliminates them after repeated misses. A real
                      // departure still reaches _manageRemoteExit through the
                      // explicit "EXIT" game event sent on quit. Presence loss
                      // is only recorded once the game is already over, purely
                      // for analytics.
                      if (!state.fakeOpponent &&
                          !(finalOpponent.online ?? true) &&
                          gameCubit.state.over) {
                        gamesRepository.addGameEvent(
                          gameId,
                          GamicoGameEventModel(
                            type: "DISCONNECTION",
                            userId: opponentId,
                          ),
                        );
                      }
                    },
                    onError: (e) => debugPrint(
                      "⚠️ opponent $field subscription error => $e",
                    ),
                  );
              opponentStreamSubscriptions.add(sub);
            }
          }
        }

        // Only a fake-opponent table deals without a roll-call, straight
        // after `initGame` below: that one still waits for its opponent.
        if (state.fakeOpponent) {
          await loadOpponents();
        } else {
          unawaited(loadOpponents());
        }
      }

      // Listen to game events
      //
      // Windowed on purpose. `onChildAdded` replays every child already under
      // the node the moment it attaches, so a table that re-enters this init
      // (rejoin, replay, a page rebuilt after the OS killed the app) used to
      // re-download the whole match log. Games that prune (Crazy Eights wipes
      // it every 10 events from the referee, 100 from any seat) kept that
      // small; games that never prune paid for the entire history, every time.
      // The window is set well above the largest prune threshold so no event
      // that is still live can fall outside it — only genuinely stale replays
      // are dropped. Keys are push ids, so ordering by key is chronological
      // and the window slides forward as events arrive: each new one still
      // fires exactly once.
      if (!state.fakeOpponent) {
        gameEventsStreamSubscription = FirebaseDatabase.instance
            .ref()
            .child("games/$gameId/events")
            .limitToLast(_eventsWindow)
            .onChildAdded
            .listen(
              (event) async {
                if (event.snapshot.exists) {
                  final rawData = event.snapshot.value;
                  final validData = _deepCastMap(rawData);
                  final currentGameEvent = GamicoGameEventModel.fromJson(
                    validData,
                  );

                  if (currentGameEvent.type == "READINESS") {
                    final uid = currentGameEvent.userId;
                    if (uid != null) {
                      _readyPlayerIds.add(uid);
                      // After their EXIT in the log: they came back.
                      if (uid != LocalStorageService.uid &&
                          _exitsInLog.remove(uid)) {
                        _readmitIfBack(uid);
                      }
                    }
                    _checkReadiness();
                  } else if (currentGameEvent.type == "MOVE") {
                    if (currentGameEvent.userId != LocalStorageService.uid) {
                      if (_onPlaceholderSettings) {
                        // Nobody to hand it to yet: kept for the real
                        // settings (see [_onSettingsReplaced]).
                        if (_pendingForGame.length < 500) {
                          _pendingForGame.add((
                            move: currentGameEvent,
                            goneUid: null,
                          ));
                        }
                      } else {
                        gameCubit.settings?.receiveMoveFromRemotePlayer(
                          currentGameEvent,
                        );
                      }
                    }
                  } else if (currentGameEvent.type == "EXIT") {
                    if (currentGameEvent.userId != LocalStorageService.uid) {
                      final uid = currentGameEvent.userId ?? "";
                      final struckAtSeal =
                          _sealedRollCall != null &&
                          uid.isNotEmpty &&
                          _expectedPlayerIds.contains(uid) &&
                          !_sealedRollCall!.contains(uid);
                      if (struckAtSeal) {
                        // Left out by the roster, and already reported to the
                        // game as gone when it was applied: this is that
                        // player's page closing on its explanation popup, not
                        // a second departure.
                        _rc("EXIT of a player the roster left out: $uid");
                        _exitedPlayerIds.add(uid);
                      } else if (!gameCubit.state.ready &&
                          !legacyRollCall &&
                          uid.isNotEmpty) {
                        // Before the deal, leaving is an absence, not a
                        // forfeit: nothing was dealt, so the quitter pays
                        // nothing — and the others must not be paid either.
                        // Most two-player games answer a departure with a
                        // win (coins included), so a quit on the pre-deal
                        // loader was a free victory for the account on the
                        // other side. The roll-call settles it instead: the
                        // table goes on without them, or is cancelled when
                        // nobody is left (see [_applyRollCall]). Also covers
                        // an EXIT reaching a table already settled without a
                        // game (cancelled, or dealt without us).
                        _rc("EXIT before the deal: $uid");
                        _exitedPlayerIds.add(uid);
                        _exitsInLog.add(uid);
                        _applyReplayVote(uid, null);
                        _checkReadiness();
                      } else {
                        // A player leaving before the deal (quit between
                        // matchmaking and launch) will never declare
                        // READINESS: stop expecting them or the table waits
                        // forever.
                        if (!gameCubit.state.ready && uid.isNotEmpty) {
                          _exitedPlayerIds.add(uid);
                          _checkReadiness();
                        }
                        _manageRemoteExit(uid);
                      }
                    }
                  } else if (currentGameEvent.type == "ABANDONMENT") {
                    if (currentGameEvent.userId != LocalStorageService.uid) {
                      gameCubit.settings?.onRemoteUserGaveUp(
                        currentGameEvent.userId ?? "",
                      );
                      // endGame("B", "ABANDONMENT");
                    }
                  } else if (currentGameEvent.type == "DISCONNECTION") {
                    if (currentGameEvent.userId != LocalStorageService.uid) {
                      if (state.gameEndStatus == "INTERNAL_INVITATION") {
                        emit(
                          state.copyWith(gameEndStatus: "REPLAY_IMPOSSIBLE"),
                        );
                      }
                    }
                  } else if (currentGameEvent.type == "NEEDINESS") {
                    if (currentGameEvent.userId == LocalStorageService.uid) {
                      emit(state.copyWith(gameEndStatus: "INTERNAL_NEEDINESS"));
                    } else {
                      emit(state.copyWith(gameEndStatus: "EXTERNAL_NEEDINESS"));
                    }
                  } else if (currentGameEvent.type == "REPLAY_VOTE") {
                    _applyReplayVote(
                      currentGameEvent.userId ?? "",
                      currentGameEvent.data?["option"]?.toString() ??
                          kGamicoSameGameReplayOption,
                    );
                  } else if (currentGameEvent.type == "REPLAY_VOTE_CANCEL") {
                    _applyReplayVote(currentGameEvent.userId ?? "", null);
                  } else if (currentGameEvent.type == "REPLAY_START") {
                    // The referee's verdict on a split vote. Every device acts
                    // on this one event, so they all keep and drop exactly the
                    // same seats.
                    final option =
                        currentGameEvent.data?["option"]?.toString() ??
                        kGamicoSameGameReplayOption;
                    final players =
                        (currentGameEvent.data?["players"] as List?)
                            ?.map((e) => e.toString())
                            .toList() ??
                        activePlayerIds;
                    _launchReplay(option, players);
                  } else if (currentGameEvent.type == "REPLAY") {
                    replayRequests++;

                    final level = currentGameEvent.data?["level"]?.toInt();

                    if (level != null) {
                      final stateNextLevel = state.nextLevel;

                      if (stateNextLevel != null && level != stateNextLevel) {
                        replayRequests = 0;

                        emit(state.copyWith(gameEndStatus: ""));
                      }
                    }

                    if (replayRequests == playersIds.length) {
                      _launchNewGame();
                    } else {
                      if (currentGameEvent.userId == LocalStorageService.uid) {
                        emit(
                          state.copyWith(gameEndStatus: "INTERNAL_INVITATION"),
                        );
                      } else if (state.gameEndStatus != "INTERNAL_INVITATION") {
                        emit(
                          state.copyWith(gameEndStatus: "EXTERNAL_INVITATION"),
                        );
                      }
                    }
                  } else if (currentGameEvent.type == "WITHDRAW") {
                    replayRequests--;

                    if (currentGameEvent.userId == LocalStorageService.uid) {
                      emit(state.copyWith(gameEndStatus: ""));
                    } else {
                      emit(
                        state.copyWith(gameEndStatus: "INVITATION_WITHDRAWAL"),
                      );
                    }
                  } else if (currentGameEvent.type == "ACCEPTATION") {
                    replayRequests++;

                    if (replayRequests == playersIds.length) {
                      _launchNewGame();
                    } else {
                      if (currentGameEvent.userId == LocalStorageService.uid) {
                        emit(
                          state.copyWith(
                            gameEndStatus: "INVITATION_ACCEPTATION",
                          ),
                        );
                      } else if (replayRequests == 1) {
                        emit(
                          state.copyWith(
                            gameEndStatus: "",
                            opponentExited: true,
                          ),
                        );
                      }
                    }
                  } else if (currentGameEvent.type == "REJECTION") {
                    replayRequests = 0;

                    if (currentGameEvent.userId == LocalStorageService.uid) {
                      emit(state.copyWith(gameEndStatus: ""));
                    } else {
                      emit(
                        state.copyWith(gameEndStatus: "INVITATION_REJECTION"),
                      );
                    }
                  } else if (currentGameEvent.type == "IDENTIFICATION") {
                    if (currentGameEvent.userId != LocalStorageService.uid) {
                      newGameId = currentGameEvent.data?["id"];

                      // A rematch resolved by vote can leave the creator
                      // behind, and then nobody would ever mark the new game
                      // STARTED — every remaining device would sit on a status
                      // that never comes. The player the table already agrees
                      // on as referee steps in. Writing the same status twice
                      // when the creator is still here changes nothing.
                      if (state.creator ||
                          (_replayLaunched &&
                              _replayRefereeId == LocalStorageService.uid)) {
                        await gamesRepository.updateGameStatus(
                          newGameId,
                          "STARTED",
                        );
                      }

                      emit(
                        state.copyWith(
                          newGameCreator: false,
                          newGameId: newGameId,
                          replay: true,
                        ),
                      );
                    }
                  }
                }
              },
              onError: (e) =>
                  debugPrint("⚠️ gameEventsStreamSubscription error => $e"),
            );
      }

      // Disconnection management is deliberately not armed here: it waits for
      // the table to actually be dealt (see [_armDisconnectionPenalty]).

      // A fake-opponent table deals the moment `initGame` returns, so it
      // still waits (bounded) for the opponent it shows. A real table declares
      // its READINESS right away: the profiles load in parallel (see
      // `loadOpponents` above).
      if (state.fakeOpponent) {
        final profilesDeadline = DateTime.now().add(const Duration(seconds: 2));
        await GamicoGlobalService.waitWhile(
          () =>
              DateTime.now().isBefore(profilesDeadline) &&
              (state.opponent == null ||
                  state.opponents.length < otherPlayerIds.length),
        );
      }

      // Settled while we loaded (the table went ahead without us): there is
      // no seat to build.
      if (isClosed || _rollCallApplied) return;

      gameCubit.settings?.initGame();

      if (state.fakeOpponent) {
        gameCubit.startGame();
      } else {
        gamesRepository.addGameEvent(
          gameId,
          GamicoGameEventModel(
            type: "READINESS",
            userId: LocalStorageService.uid,
          ),
        );
        // Our own READINESS is a fact, not a message we need delivered back
        // to us: counting it only once its echo came back through the
        // (windowed, prunable) log is how a lost echo used to strand a table.
        final myUid = LocalStorageService.uid;
        if (myUid.isNotEmpty) {
          _readyPlayerIds.add(myUid);
          // The durable copy of this READINESS (see [_rollCallReadyField]).
          _declareReadyMarker();
        }
        _myReadyAt = DateTime.now();
        _rc("our READINESS sent");
        _readinessSent = true;
        _watchConnectionBeforeDeal();
        _startReadinessFallbackTimer();
        // The table may have sealed its roster while we were still loading.
        final pending = _pendingRollCall;
        if (pending != null) {
          _applyRollCall(pending);
        } else {
          _checkReadiness();
        }
      }
    };

    gameCubit.onExitGame = () {
      // A game can declare the current moment a legitimate stopping point
      // (e.g. between two settled rounds of a score-based match): leaving is
      // then treated like leaving a finished game, not an abandonment.
      final penaltyFree =
          gameCubit.settings?.exitIsPenaltyFree?.call() ?? false;

      // Leaving a game that never started is not an abandonment. Until the
      // readiness roll-call completes nothing has been dealt, nobody has
      // played a card, and the player is looking at a loader — which is
      // exactly where they end up when a matched opponent never makes it to
      // the table. Charging them coins, a trophy and a defeat for backing out
      // of that is the wrong verdict: `over` is false simply because the
      // match never began.
      final neverStarted = !gameCubit.state.ready;

      if (!gameCubit.state.over && !penaltyFree && !neverStarted) {
        final mode = state.remoteUtility.matchmakingSettings.mode;
        final onModedRemoteResult =
            Gamico.instance.playSettings?.onModedRemoteResult;

        if (mode != null && onModedRemoteResult != null) {
          // Host owns result handling for this mode (exit mid-game = defeat).
          onModedRemoteResult(gameCubit.userCubit, mode, false, 0);
        } else {
          if (adventureUtility == null ||
              (state.userInitialLevel == state.level)) {
            gameCubit.userCubit.decrementCoins(
              Gamico.instance.gameSettings.playMinimumCoins,
            );
          }

          gameCubit.userCubit.incrementDefeats();
        }
      }

      declareCurrentUserExit();
    };

    gameCubit.onGiveUp = () {
      if (state.fakeOpponent) return;

      gamesRepository.addGameEvent(
        gameId,
        GamicoGameEventModel(
          type: "ABANDONMENT",
          userId: LocalStorageService.uid,
        ),
      );
    };

    // The abandonment penalty is armed here and nowhere else: whatever starts
    // the match, it is armed exactly once, and never while the players are
    // still on the pre-deal loader.
    gameCubit.onGameStart = () => unawaited(_armDisconnectionPenalty());

    gameCubit.onGameEnd = cleanUserDisconnectionReference;
  }

  void cleanUserDisconnectionReference() {
    // Do not punish the player if he/her leaves the game after its end
    userDisconnectionReference?.cancel();
    userDisconnectionReference = null;
    _disconnectionPenaltySubscription?.cancel();
    _disconnectionPenaltySubscription = null;
    _armedDisconnectionPenalty = null;
  }

  Map<String, dynamic> _disconnectionPenaltyPayload(Map<String, num> deltas) =>
      {
        for (final entry in deltas.entries)
          entry.key: ServerValue.increment(entry.value),
        "updated_at": DateTime.now().toString(),
      };

  Future<void> _refundAndRearmDisconnectionPenalty() async {
    final deltas = _armedDisconnectionPenalty;
    if (deltas == null || gameCubit.state.over) return;

    try {
      await FirebaseDatabase.instance
          .ref("users")
          .child(LocalStorageService.uid)
          .update(
            _disconnectionPenaltyPayload(
              deltas.map((key, value) => MapEntry(key, -value)),
            ),
          );
    } catch (e) {
      debugPrint(
        '[GamicoRemoteGameCubit] disconnection penalty refund failed: $e',
      );
    }

    try {
      userDisconnectionReference = FirebaseDatabase.instance
          .ref("users")
          .child(LocalStorageService.uid)
          .onDisconnect();
      await userDisconnectionReference?.update(
        _disconnectionPenaltyPayload(deltas),
      );
    } catch (e) {
      debugPrint('[GamicoRemoteGameCubit] onDisconnect re-arm failed: $e');
    }
  }

  void _manageRemoteExit(String userId) {
    emit(state.copyWith(gameEndStatus: "", opponentExited: true));

    // One seat fewer to wait on: a table of two is now unplayable, and a
    // table of three may have just become unanimous.
    _exitedPlayerIds.add(userId);
    _applyReplayVote(userId, null);

    if (gameCubit.state.over) {
      replayRequests = 0;
    } else {
      _tellGameGone(userId); // endGame("B", "EXIT")
    }
  }

  Future<void> sendMoveToRemotePlayer(Map<String, dynamic> data) async {
    if (state.fakeOpponent) return;

    await gamesRepository.addGameEvent(
      gameId,
      GamicoGameEventModel(
        data: data,
        type: "MOVE",
        userId: LocalStorageService.uid,
      ),
    );
  }

  @override
  Future<void> close() {
    GamicoDatabaseShutdown.unregister(this);

    _readinessFallbackTimer?.cancel();
    _replayCountdownTimer?.cancel();
    // Cancel all usual streams
    newGameStreamSubscription?.cancel();
    opponentStreamSubscription?.cancel();
    for (var s in opponentStreamSubscriptions) {
      s.cancel();
    }
    gameEventsStreamSubscription?.cancel();
    _rollCallSubscription?.cancel();
    _rollCallVotesSubscription?.cancel();
    _rollCallReadySubscription?.cancel();
    _stopRollCallTicker();

    cleanUserDisconnectionReference();

    return super.close();
  }
}

Map<String, dynamic> _deepCastMap(dynamic map) {
  if (map is! Map) return {};
  return map.map(
    (key, value) => MapEntry(key.toString(), _deepCastValue(value)),
  );
}

dynamic _deepCastValue(dynamic value) {
  if (value is Map) {
    return _deepCastMap(value);
  } else if (value is List) {
    return value.map(_deepCastValue).toList();
  }
  return value;
}
