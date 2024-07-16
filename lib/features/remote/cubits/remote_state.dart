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
    );
  }
}
