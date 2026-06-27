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
  final RemoteUtility remoteUtility;
  final AdventureUtility? adventureUtility;
  final int? level;
  final int? userInitialLevel;
  final int? nextLevel;

  String get opponentId => opponent?.id ?? "";
  final dynamic opponent;
  final List<dynamic> opponents;
  final bool friend;
  final bool fakeOpponent;

  const GamicoRemoteGameState({
    required this.adventureUtility,
    required this.remoteUtility,
    this.opponent,
    this.opponents = const [],
    required this.fakeOpponent,
    required this.creator,
    this.friend = false,
    this.newGameId = "",
    this.newGameCreator = false,
    this.opponentExited = false,
    this.gameEndStatus = "",
    this.newRemoteGameActive = false,
    this.remoteGameInternetError = false,
    this.replay = false,
    required this.level,
    required this.userInitialLevel,
    this.nextLevel,
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
    List<dynamic>? opponents,
    bool? fakeOpponent,
    bool? friend,
    RemoteUtility? remoteUtility,
    int? Function()? level,
    AdventureUtility? Function()? adventureUtility,
    int? Function()? userInitialLevel,
    int? Function()? nextLevel,
  }) {
    return GamicoRemoteGameState(
      userInitialLevel: userInitialLevel != null
          ? userInitialLevel()
          : this.userInitialLevel,
      adventureUtility: adventureUtility != null
          ? adventureUtility()
          : this.adventureUtility,
      level: level != null ? level() : this.level,
      remoteUtility: remoteUtility ?? this.remoteUtility,
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
      friend: friend ?? this.friend,
      opponent: opponent != null ? opponent() : this.opponent,
      opponents: opponents ?? this.opponents,
      nextLevel: nextLevel != null ? nextLevel() : this.nextLevel,
    );
  }
}
