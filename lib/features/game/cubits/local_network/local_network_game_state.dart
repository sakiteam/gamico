part of 'local_network_game_cubit.dart';

@immutable
class GamicoLocalNetworkGameState {
  /// Whether this device currently drives the table — it deals, it restarts.
  /// A client promoted after the original host left flips this to true.
  final bool isHost;

  /// (Clients) the host went away mid-match: nothing more will be dealt here.
  final bool hostGone;

  /// Set by [GamicoLocalNetworkGameCubit.requestNewGame], picked up by
  /// [LocalNetworkGamePage] which actually deals the new match.
  final bool newGameActive;

  /// Whether this match already spent its interstitial, so a table that ends
  /// in several steps (a player busts, then the winner is crowned) still shows
  /// exactly one.
  final bool adShown;

  /// Whether the result of the current match was already booked, so a replayed
  /// end-of-game notification cannot count it twice.
  final bool resultRecorded;

  const GamicoLocalNetworkGameState({
    required this.isHost,
    this.hostGone = false,
    this.newGameActive = false,
    this.adShown = false,
    this.resultRecorded = false,
  });

  GamicoLocalNetworkGameState copyWith({
    bool? isHost,
    bool? hostGone,
    bool? newGameActive,
    bool? adShown,
    bool? resultRecorded,
  }) {
    return GamicoLocalNetworkGameState(
      isHost: isHost ?? this.isHost,
      hostGone: hostGone ?? this.hostGone,
      newGameActive: newGameActive ?? this.newGameActive,
      adShown: adShown ?? this.adShown,
      resultRecorded: resultRecorded ?? this.resultRecorded,
    );
  }
}
