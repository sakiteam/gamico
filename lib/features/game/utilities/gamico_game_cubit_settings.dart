import 'package:gamico/commons/models/gamico_game_model.dart';

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
    required this.gameCubit,
  });
}
