import 'package:gamico/commons/models/gamico_game_model.dart';
import 'package:gamico/features/game/utilities/roll_call.dart';

export 'package:gamico/features/game/utilities/roll_call.dart';

class GamicoGameCubitSettings {
  // REMOTE
  final void Function(String userId) onRemoteUserGaveUp;
  final void Function(String userId) onRemoteUserDisconnectedDuringGame;
  final void Function(GamicoGameEventModel event) receiveMoveFromRemotePlayer;

  // TUTORIAL
  final void Function() onUserWonByPass;

  // GLOBAL
  final void Function() initGame;
  final void Function() startGame;
  final void Function() onUserGiveUp;

  /// Whether leaving right now is a legitimate, penalty-free exit even though
  /// the framework game state is not "over". Score-based matches with no
  /// built-in end (every settled round is a valid stopping point) report true
  /// between rounds, so a player who leaves then is neither docked coins nor
  /// asked to confirm an "abandonment". Null (or false) keeps the default
  /// rule: leaving a game that isn't over is an abandonment.
  final bool Function()? exitIsPenaltyFree;

  /// Called instead of `startGame` when the table's sealed roll-call (see
  /// `GamicoRemoteGameCubit`) went ahead without this device: the others are
  /// dealing without us, and nothing we deal ourselves would match theirs.
  /// Null lets gamico handle it: a popup explaining [GamicoRollCallReason],
  /// and the player is taken out of the table, penalty-free.
  final void Function(GamicoRollCallReason reason)? onExcludedFromRollCall;

  /// Called instead of `startGame` when the roll-call left this device alone
  /// at the table: nobody else showed up, the match is cancelled. Null lets
  /// gamico handle it: a "player unavailable" popup, and the player is taken
  /// out of the table, penalty-free. Before the roll-call was shared, this case
  /// struck the missing players one by one through
  /// [onRemoteUserDisconnectedDuringGame] — which most two-player games answer
  /// with a win by forfeit, for a match that never started.
  final void Function()? onRollCallCancelled;

  /// Whether the game can take its seat back at a table that was dealt
  /// without this page — the app reopened mid-match. Crazy Eights can (it
  /// asks the table for its full state). A game whose only way back is
  /// replaying the events log cannot once that log is pruned: its board
  /// would be rebuilt from the start and play on out of step. False: gamico
  /// gives the seat up instead — the table carries on without it — and takes
  /// the player out, to the game's spectator view when it has one.
  final bool rejoinsDealtTable;

  final dynamic gameCubit;

  const GamicoGameCubitSettings({
    required this.receiveMoveFromRemotePlayer,
    required this.onRemoteUserDisconnectedDuringGame,
    required this.onUserGiveUp,
    required this.onRemoteUserGaveUp,
    required this.onUserWonByPass,
    required this.initGame,
    required this.startGame,
    this.exitIsPenaltyFree,
    this.onExcludedFromRollCall,
    this.onRollCallCancelled,
    this.rejoinsDealtTable = true,
    required this.gameCubit,
  });
}
