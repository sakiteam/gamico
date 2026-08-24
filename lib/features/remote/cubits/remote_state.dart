part of 'remote_cubit.dart';

enum RemoteGameStatus { initial, loading, success, failure }

@immutable
class RemoteState {
  final RemoteGameStatus status;
  final bool? creator;
  final String gameId;
  final bool finalized;

  final bool animInit;
  final bool animGame;

  final bool animated;

  bool get enabled => animInit && !animGame;

  final bool internetError;
  final bool fakeOpponent;
  final int? level;
  final bool forcePop;
  final int playersFound;
  final List<String> playerNames;
  final List<String> playerPhotos;
  final int? countdownRemaining;

  /// Bumped by every [RemoteCubit.reset] — i.e. each time the search starts
  /// over ("Nouvelle partie" after a game). The status only flickers through
  /// [RemoteGameStatus.initial] between two synchronous emits, so widgets
  /// never see it; this counter is the reliable "this is a brand new search"
  /// signal for anything caching the previous search's roster.
  final int searchGeneration;

  const RemoteState({
    this.status = RemoteGameStatus.initial,
    this.creator,
    this.gameId = "",
    this.finalized = false,
    this.animInit = false,
    this.animGame = false,
    this.internetError = false,
    this.animated = false,
    this.fakeOpponent = false,
    this.level,
    this.forcePop = false,
    this.playersFound = 0,
    this.playerNames = const [],
    this.playerPhotos = const [],
    this.countdownRemaining,
    this.searchGeneration = 0,
  });

  RemoteState copyWith({
    RemoteGameStatus? status,
    bool? Function()? creator,
    String? gameId,
    bool? finalized,
    bool? animInit,
    bool? animGame,
    bool? internetError,
    bool? animated,
    bool? fakeOpponent,
    int? Function()? level,
    bool? forcePop,
    int? playersFound,
    List<String>? playerNames,
    List<String>? playerPhotos,
    int? Function()? countdownRemaining,
    int? searchGeneration,
  }) {
    return RemoteState(
      level: level != null ? level() : this.level,
      animated: animated ?? this.animated,
      status: status ?? this.status,
      creator: creator != null ? creator() : this.creator,
      gameId: gameId ?? this.gameId,
      finalized: finalized ?? this.finalized,
      animInit: animInit ?? this.animInit,
      animGame: animGame ?? this.animGame,
      internetError: internetError ?? this.internetError,
      fakeOpponent: fakeOpponent ?? this.fakeOpponent,
      forcePop: forcePop ?? this.forcePop,
      playersFound: playersFound ?? this.playersFound,
      playerNames: playerNames ?? this.playerNames,
      playerPhotos: playerPhotos ?? this.playerPhotos,
      countdownRemaining: countdownRemaining != null
          ? countdownRemaining()
          : this.countdownRemaining,
      searchGeneration: searchGeneration ?? this.searchGeneration,
    );
  }
}
