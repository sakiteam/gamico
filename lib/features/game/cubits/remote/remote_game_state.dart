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

  /// How many of the seated players have asked to play again.
  int get replayReadyCount =>
      replayVotes.keys.where(replayPlayerIds.contains).length;

  /// How many are expected to.
  int get replayTotalCount => replayPlayerIds.length;

  /// Whether a rematch with these players is still on the table: it takes two.
  bool get replayVotePossible => replayPlayerIds.length >= 2;

  /// How many players picked [optionId].
  int votesForReplayOption(String optionId) => replayVotes.entries
      .where((e) => e.value == optionId && replayPlayerIds.contains(e.key))
      .length;
  final dynamic opponent;
  final List<dynamic> opponents;
  final bool friend;
  final bool fakeOpponent;

  /// Who asked to play again, and with which option: uid → option id. Every
  /// device rebuilds the same map from the shared event log, so the counts
  /// under the "Rejouer" button are the same on every phone at the table.
  final Map<String, String> replayVotes;

  /// The players the rematch is still waiting on: everyone seated who has not
  /// left. Ids, so the popup can show "2/4" and grey the button out when a
  /// rematch is no longer possible.
  final List<String> replayPlayerIds;

  /// When the local countdown started, i.e. when at least two players agreed
  /// on the same option while somebody was still undecided. Null while there
  /// is nothing to count down to.
  final DateTime? replayCountdownStartedAt;

  /// The option the resolved rematch is played with (null until it resolves).
  /// Games read it to build the new match — Ludo carries it into the new
  /// game's config so a table that voted "Élimination" gets élimination.
  final String? replayOption;

  const GamicoRemoteGameState({
    required this.adventureUtility,
    required this.remoteUtility,
    this.opponent,
    this.opponents = const [],
    required this.fakeOpponent,
    this.replayVotes = const {},
    this.replayPlayerIds = const [],
    this.replayCountdownStartedAt,
    this.replayOption,
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
    Map<String, String>? replayVotes,
    List<String>? replayPlayerIds,
    DateTime? Function()? replayCountdownStartedAt,
    String? Function()? replayOption,
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
      replayVotes: replayVotes ?? this.replayVotes,
      replayPlayerIds: replayPlayerIds ?? this.replayPlayerIds,
      replayCountdownStartedAt: replayCountdownStartedAt != null
          ? replayCountdownStartedAt()
          : this.replayCountdownStartedAt,
      replayOption: replayOption != null ? replayOption() : this.replayOption,
      opponent: opponent != null ? opponent() : this.opponent,
      opponents: opponents ?? this.opponents,
      nextLevel: nextLevel != null ? nextLevel() : this.nextLevel,
    );
  }
}
