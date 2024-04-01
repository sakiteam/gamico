part of 'remote_game_cubit.dart';

@immutable
class GamicoRemoteGameState {
  final bool creator;
  final String newGameId;
  final String gameEndStatus;
  final bool newGameCreator;
  final bool opponentExited;
  final bool newRemoteGameActive;
  final bool remoteGameInternetError;
  final bool replay;

  String get opponentId => opponent?.id ?? "";
  final dynamic opponent;
  final bool fakeOpponent;

  const GamicoRemoteGameState({
    this.opponent,
    required this.fakeOpponent,
    required this.creator,
    this.newGameId = "",
    this.newGameCreator = false,
    this.opponentExited = false,
    this.gameEndStatus = "",
    this.newRemoteGameActive = false,
    this.remoteGameInternetError = false,
    this.replay = false,
  });

  GamicoRemoteGameState copyWith({
    bool? creator,
    String? newGameId,
    String? gameEndStatus,
    bool? newGameCreator,
    bool? opponentExited,
    bool? newRemoteGameActive,
    bool? remoteGameInternetError,
    bool? replay,
    dynamic Function()? opponent,
    bool? fakeOpponent,
  }) {
    return GamicoRemoteGameState(
      replay: replay ?? this.replay,
      creator: creator ?? this.creator,
      newGameId: newGameId ?? this.newGameId,
      gameEndStatus: gameEndStatus ?? this.gameEndStatus,
      newGameCreator: newGameCreator ?? this.newGameCreator,
      opponentExited: opponentExited ?? this.opponentExited,
      newRemoteGameActive: newRemoteGameActive ?? this.newRemoteGameActive,
      remoteGameInternetError:
          remoteGameInternetError ?? this.remoteGameInternetError,
      fakeOpponent: fakeOpponent ?? this.fakeOpponent,
      opponent: opponent != null ? opponent() : this.opponent,
    );
  }
}
