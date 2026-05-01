part of 'game_cubit.dart';

@immutable
class GamicoGameState {
  final bool? victory;
  final bool displayGamePopup;
  final bool backActive;
  final bool animInit;
  final bool animHome;
  final bool animGame;
  final bool animated;
  final MessageUtility? message;
  final bool tripleAdWatched;
  final bool ready;
  final String overReason;
  final GameType mode;
  final int stars;
  final bool secondVictory;
  final bool active;

  /// Optional narrative text shown in the end-of-game poster description.
  /// When set, it takes priority over the default mode description.
  final String? endMessage;

  bool get enabled => !animated;
  bool get tutorial => mode == GameType.tutorial;
  bool get abandonmentImpossible => over || tutorial;
  bool get over => overReason.isNotEmpty;
  GameModeSettings get gameMode => GameModeSettings(mode);

  const GamicoGameState({
    required this.mode,
    this.secondVictory = false,
    this.stars = 3,
    this.message,
    this.victory,
    this.displayGamePopup = false,
    this.backActive = false,
    this.animInit = false,
    this.animHome = false,
    this.animGame = false,
    this.animated = false,
    this.overReason = "",
    this.tripleAdWatched = false,
    this.ready = false,
    this.active = true,
    this.endMessage,
  });

  GamicoGameState copyWith({
    GameType? mode,
    int? stars,
    MessageUtility? Function()? message,
    bool? Function()? victory,
    bool? secondVictory,
    bool? displayGamePopup,
    bool? backActive,
    bool? animInit,
    bool? animGame,
    bool? animHome,
    bool? animated,
    String? overReason,
    bool? tripleAdWatched,
    bool? ready,
    bool? active,
    String? Function()? endMessage,
  }) {
    return GamicoGameState(
      mode: mode ?? this.mode,
      secondVictory: secondVictory ?? this.secondVictory,
      stars: stars ?? this.stars,
      message: message != null ? message() : this.message,
      victory: victory != null ? victory() : this.victory,
      displayGamePopup: displayGamePopup ?? this.displayGamePopup,
      backActive: backActive ?? this.backActive,
      overReason: overReason ?? this.overReason,
      tripleAdWatched: tripleAdWatched ?? this.tripleAdWatched,
      ready: ready ?? this.ready,
      animGame: animGame ?? this.animGame,
      animHome: animHome ?? this.animHome,
      animInit: animInit ?? this.animInit,
      animated: animated ?? this.animated,
      active: active ?? this.active,
      endMessage: endMessage != null ? endMessage() : this.endMessage,
    );
  }
}
