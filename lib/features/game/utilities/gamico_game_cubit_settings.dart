import 'package:gamico/commons/models/gamico_game_model.dart';

class GamicoGameCubitSettings {
  // REMOTE
  final void Function() onRemoteUserGaveUp;
  final void Function() onRemoteUserDisconnectedDuringGame;
  final void Function(GamicoGameEventModel event) receiveMoveFromRemotePlayer;

  // TUTORIAL
  final void Function() onUserWonByPass;

  // GLOBAL
  final void Function() initGame;
  final void Function() startGame;
  final void Function() onUserGiveUp;

  final dynamic gameCubit;

  const GamicoGameCubitSettings({
    required this.receiveMoveFromRemotePlayer,
    required this.onRemoteUserDisconnectedDuringGame,
    required this.onUserGiveUp,
    required this.onRemoteUserGaveUp,
    required this.onUserWonByPass,
    required this.initGame,
    required this.startGame,
    required this.gameCubit,
  });
}
