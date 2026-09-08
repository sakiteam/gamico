import 'package:flutter/foundation.dart';

/// Which matchmaking implementation this build uses.
///
/// Two systems coexist for one release cycle:
///
///  * the legacy one (`matchmakings/<roomKey>`), where every client is an
///    arbiter — it arms the countdown, races the others to extract a batch and
///    writes the game node itself;
///  * the server-driven one (`pools/` + `assignments/`), where the client only
///    queues and listens.
///
/// They do NOT meet: two players running different implementations never see
/// each other. The cutover is a date rather than a remote flag so players get a
/// window to update before their pool starts emptying — and debug builds always
/// take the new path, so development never waits for the calendar.
///
/// Read from the device clock: a phone set days off will switch early or late.
/// The only consequence is landing in the other population's pool, which is why
/// this is not gated on anything more elaborate.
abstract class MatchmakingMigration {
  /// Wednesday 9 September 2026, 00:00 UTC.
  static final DateTime cutoff = DateTime.utc(2026, 9, 9);

  static bool get useServer =>
      kDebugMode || !DateTime.now().toUtc().isBefore(cutoff);
}
