import 'package:flutter/widgets.dart';
import 'package:gamico/commons/enums/game_type.dart';
import 'package:gamico/commons/models/adventure_utility.dart';
import 'package:gamico/commons/models/remote_utility.dart';
import 'package:gamico/features/game/utilities/replay_option.dart';

class GameUtility {
  final GameType type;
  final void Function()? onBackButtonPressed;

  /// The game's own end-of-match popup — a score table only it can draw. When
  /// null, or when it returns null (nothing to show a table about yet), the
  /// framework shows its generic [GamicoGamePopup] instead. Either way the
  /// framework decides *when* it opens (once the result animation, music and
  /// rewards have played out) and what happens around it.
  ///
  /// It is called with the game page's own context, which carries the
  /// framework cubits — the popup itself is mounted under the navigator and no
  /// longer sees the game's providers, so anything the game needs must be read
  /// here.
  final Widget? Function(BuildContext context)? endGamePopupBuilder;

  const GameUtility({
    required this.type,
    required this.onBackButtonPressed,
    this.endGamePopupBuilder,
  });
}

class AdventureGameUtility extends GameUtility {
  final int level;
  final AdventureUtility adventureUtility;
  final RemoteUtility? remoteUtility;

  const AdventureGameUtility({
    required super.onBackButtonPressed,
    required this.level,
    required this.adventureUtility,
    required this.remoteUtility,
  }) : super(type: GameType.adventure);
}

class PassAndPlayGameUtility extends GameUtility {
  const PassAndPlayGameUtility({required super.onBackButtonPressed})
    : super(type: GameType.passAndPlay);
}

class RemoteGameUtility extends GameUtility {
  final int? level;
  final String gameId;
  final bool fakeOpponent;
  final bool creatorOfCurrentGame;
  final RemoteUtility remoteUtility;
  final AdventureUtility? adventureUtility;
  final bool friend;

  /// What the players may choose from for the rematch (game modes, typically).
  /// Empty keeps "Rejouer" a plain ready/cancel vote.
  final List<GamicoReplayOption> replayOptions;

  /// The option this match is being played with, pre-selected on the first tap
  /// so a straight rematch stays one tap away.
  final String? currentReplayOption;

  /// Opt in to the vote-based rematch (live "2/4", countdown, players who do
  /// not answer left behind) instead of the older one-to-one invitation
  /// exchange. Implied by [replayOptions] being non-empty.
  final bool replayVote;

  const RemoteGameUtility({
    required super.onBackButtonPressed,
    required this.level,
    required this.creatorOfCurrentGame,
    required this.fakeOpponent,
    required this.gameId,
    required this.remoteUtility,
    required this.adventureUtility,
    this.friend = false,
    this.replayOptions = const [],
    this.currentReplayOption,
    this.replayVote = false,
    super.endGamePopupBuilder,
  }) : super(type: GameType.remote);
}

/// A WiFi-local (LAN) table: several devices on the same network, one of them
/// hosting. There is no backend behind it, so the host app owns the transport
/// and the board; this describes everything the framework needs to run the end
/// of the match — where the result is recorded, who may restart the table, and
/// which popup closes it.
class LocalNetworkGameUtility extends GameUtility {
  /// Progression namespace the result is booked under, e.g. "ludo".
  final String progressionKey;

  /// Sub-map of [progressionKey] the result is booked under. The default keeps
  /// LAN play out of the online ladder.
  final String modeKey;

  /// Whether this device currently drives the table. Clients promoted to host
  /// mid-match update it through
  /// [GamicoLocalNetworkGameCubit.setHost] rather than rebuilding this.
  final bool isHost;

  /// Deals a fresh match to the same table, host only. Null on a client (its
  /// popup waits for the host instead) and on a table that cannot restart.
  final void Function()? onNewGame;

  /// Whether a LAN win pays out of the shared wallet. Off by default: two
  /// devices on a private network can play each other as often as they like,
  /// so a paying LAN table is a coin printer. Rewarded-ad coins stay available
  /// either way.
  final bool rewardsCoins;

  const LocalNetworkGameUtility({
    required super.onBackButtonPressed,
    required this.progressionKey,
    required this.isHost,
    this.modeKey = "local",
    this.onNewGame,
    this.rewardsCoins = false,
    super.endGamePopupBuilder,
  }) : super(type: GameType.localNetwork);
}

class TutorialGameUtility extends GameUtility {
  final int tutorialLessonIndex;

  const TutorialGameUtility({
    required super.onBackButtonPressed,
    required this.tutorialLessonIndex,
  }) : super(type: GameType.tutorial);
}
