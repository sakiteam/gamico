import 'package:flutter/foundation.dart';

/// Why the table's roster was sealed the way it was. Travels with the roster
/// on `games/<id>/roll_call`, so a player left out can be told exactly why.
enum GamicoRollCallReason {
  /// Everyone expected made it.
  allReady("all_ready"),

  /// A duel whose second player had not shown up [GamicoRollCallRules.duelGrace]
  /// after the table was formed.
  duelTimeout("duel_timeout"),

  /// More than half of the ready players voted to go on without the absent.
  vote("vote"),

  /// Nobody decided within [GamicoRollCallRules.cap]: the table starts with
  /// whoever is there.
  cap("cap"),

  /// A table playing by the older rule (a tournament leg): each device's own
  /// grace ran out.
  grace("grace");

  final String wire;
  const GamicoRollCallReason(this.wire);

  static GamicoRollCallReason fromWire(Object? value) {
    for (final reason in values) {
      if (reason.wire == value) return reason;
    }
    return grace;
  }
}

/// Where each player's answer to the roll-call lives: `games/<id>/<this>/<uid>`
/// holds `true` once they are ready, and [kGamicoRollCallLeft] once they have
/// left before the deal. Durable, unlike the events log, which is read through
/// a window and pruned.
const String kGamicoRollCallReadyField = "roll_call_ready";
const String kGamicoRollCallLeft = "left";

/// Written by the server itself (an `onDisconnect` armed with the READINESS)
/// when a ready player's connection drops before the deal — an app killed
/// or crashed on the waiting screen, which sends no EXIT and leaves no
/// "left" behind. Not a departure: the player is only no longer counted as
/// there (a table is not sealed "all ready" on them, the vote sees them
/// absent), and their device writes `true` again as soon as it reconnects.
const String kGamicoRollCallAway = "away";

/// The timings of the pre-deal wait, all counted from the moment the table
/// was formed (`games/<id>/roll_call_at`, server clock) so that every device
/// agrees on them.
abstract final class GamicoRollCallRules {
  /// A duel is cancelled when the other player is still missing after this.
  /// Stretched to effectively never in debug builds, to give time to tweak
  /// [GamicoRollCallPanel]'s design without racing the countdown.
  static const Duration duelGrace = Duration(
    seconds: kDebugMode ? 999999999 : 25,
  );

  /// From three seats up, the ready players may vote the absent out from here.
  static const Duration voteOpensAfter = Duration(seconds: 25);

  /// From three seats up, the table starts with whoever is ready at this point,
  /// vote or no vote.
  static const Duration cap = Duration(seconds: 100);

  /// A deadline never cuts off a player who has only just made it: the device
  /// that seals has to have been ready itself for at least this long. Without
  /// it, two players both arriving late in a duel would cancel a match they
  /// had both reached — whichever is ready first would seal alone.
  static const Duration minimumOwnWait = Duration(seconds: 5);

  /// Votes needed to eject the absent players, out of [voters]: strictly
  /// more than half of the players who are there to vote (see
  /// [GamicoRollCallStatus.voterCount]).
  static int ejectVotesNeeded(int voters) => (voters < 1 ? 1 : voters) ~/ 2 + 1;

  /// A duel only shows its waiting screen once the other player is late by
  /// this much: two players arriving a second apart should not see it flash.
  static const Duration duelScreenAfter = Duration(seconds: 3);

  /// The ready players who can vote: those in the app, plus anyone who voted
  /// (a vote proves they are there). A player who answered the roll-call and
  /// then left the app for another cannot vote, and counting them made the
  /// majority unreachable for the others until the cap.
  static int voterCount({
    required Iterable<String> readyIds,
    required Set<String> awayIds,
    required Set<String> ejectVotes,
  }) => readyIds
      .where((id) => !awayIds.contains(id) || ejectVotes.contains(id))
      .length;
}

/// A sealed roster, as read back from `games/<id>/roll_call`.
class GamicoRollCallVerdict {
  final Set<String> players;
  final GamicoRollCallReason reason;

  const GamicoRollCallVerdict(this.players, this.reason);

  Map<String, dynamic> toJson() => {
    "players": players.toList()..sort(),
    "reason": reason.wire,
  };

  static GamicoRollCallVerdict? fromJson(Object? raw) {
    if (raw is! Map) return null;
    final list = raw["players"];
    final Iterable<Object?>? values = list is List
        ? list
        : list is Map
        ? list.values
        : null;
    if (values == null) return null;
    final ids = values
        .whereType<Object>()
        .map((e) => e.toString())
        .where((e) => e.isNotEmpty)
        .toSet();
    if (ids.isEmpty) return null;
    return GamicoRollCallVerdict(
      ids,
      GamicoRollCallReason.fromWire(raw["reason"]),
    );
  }
}

/// What the pre-deal waiting screen shows: a table of three or more for the
/// whole wait, a duel once the other player is late.
class GamicoRollCallStatus {
  /// Every player expected at the table, in seat order.
  final List<String> playerIds;
  final Set<String> readyIds;

  /// Ready players currently voting to eject the absent.
  final Set<String> ejectVotes;

  /// Ready players whose app is in the background (presence flag down).
  final Set<String> awayIds;

  /// A duel: no vote, the table is cancelled at
  /// [GamicoRollCallRules.duelGrace].
  final bool duel;

  /// Seconds since the table was formed, on the server clock.
  final int elapsedSeconds;

  const GamicoRollCallStatus({
    required this.playerIds,
    required this.readyIds,
    required this.ejectVotes,
    required this.elapsedSeconds,
    this.awayIds = const {},
    this.duel = false,
  });

  List<String> get absentIds =>
      playerIds.where((id) => !readyIds.contains(id)).toList();

  int get readyCount => playerIds.where(readyIds.contains).length;

  /// Votes of the players still expected and ready. A player who voted and
  /// then left keeps a vote in the database, and [readyIds] may still carry
  /// them: counting it showed a majority the table was not acting on.
  int get ejectVoteCount => ejectVotes
      .where((id) => playerIds.contains(id) && readyIds.contains(id))
      .length;

  int get voterCount => GamicoRollCallRules.voterCount(
    readyIds: playerIds.where(readyIds.contains),
    awayIds: awayIds,
    ejectVotes: ejectVotes,
  );

  int get ejectVotesNeeded => GamicoRollCallRules.ejectVotesNeeded(voterCount);

  bool get voteOpen =>
      !duel &&
      absentIds.isNotEmpty &&
      elapsedSeconds >= GamicoRollCallRules.voteOpensAfter.inSeconds;

  int get secondsUntilCancel =>
      (GamicoRollCallRules.duelGrace.inSeconds - elapsedSeconds).clamp(
        0,
        GamicoRollCallRules.duelGrace.inSeconds,
      );

  int get secondsUntilVote =>
      (GamicoRollCallRules.voteOpensAfter.inSeconds - elapsedSeconds).clamp(
        0,
        GamicoRollCallRules.voteOpensAfter.inSeconds,
      );

  int get secondsUntilStart =>
      (GamicoRollCallRules.cap.inSeconds - elapsedSeconds).clamp(
        0,
        GamicoRollCallRules.cap.inSeconds,
      );

  @override
  bool operator ==(Object other) =>
      other is GamicoRollCallStatus &&
      other.elapsedSeconds == elapsedSeconds &&
      other.duel == duel &&
      _sameSet(other.awayIds, awayIds) &&
      _sameList(other.playerIds, playerIds) &&
      _sameSet(other.readyIds, readyIds) &&
      _sameSet(other.ejectVotes, ejectVotes);

  @override
  int get hashCode => Object.hash(
    elapsedSeconds,
    duel,
    Object.hashAllUnordered(awayIds),
    Object.hashAll(playerIds),
    Object.hashAllUnordered(readyIds),
    Object.hashAllUnordered(ejectVotes),
  );

  static bool _sameList(List<String> a, List<String> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  static bool _sameSet(Set<String> a, Set<String> b) =>
      a.length == b.length && a.containsAll(b);
}

/// How a pre-deal wait ended for this device when the game did not handle it
/// itself (see `GamicoGameCubitSettings.onRollCallCancelled` and
/// `onExcludedFromRollCall`). `GamicoRemoteGamePage` turns it into a popup and
/// takes the player out of the table.
class GamicoRollCallOutcome {
  /// Null when the table was cancelled (too few players showed up); set when
  /// this device was the one left out.
  final GamicoRollCallReason? exclusionReason;

  /// How many other players the table expected, to word "player" or
  /// "players".
  final int otherPlayers;

  /// A cancelled table whose other players quit before the deal, rather than
  /// never showing up.
  final bool othersLeft;

  /// This device reopened a table that was dealt — and played — without this
  /// page, and the game cannot catch up with it (see
  /// `GamicoGameCubitSettings.rejoinsDealtTable`): the seat is given up.
  final bool seatLost;

  const GamicoRollCallOutcome.cancelled({
    required this.otherPlayers,
    this.othersLeft = false,
  }) : exclusionReason = null,
       seatLost = false;

  const GamicoRollCallOutcome.excluded(
    GamicoRollCallReason reason, {
    required this.otherPlayers,
  }) : exclusionReason = reason,
       othersLeft = false,
       seatLost = false;

  const GamicoRollCallOutcome.seatLost({required this.otherPlayers})
    : exclusionReason = null,
      othersLeft = false,
      seatLost = true;

  bool get excluded => exclusionReason != null;
}
