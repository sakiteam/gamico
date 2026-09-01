import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:gamico/commons/providers/gamico_generic_provider.dart';

class GamicoGamesProvider extends GamicoGenericProvider {
  /// How stale `games/{id}/last_activity_at` is allowed to get before the next
  /// event re-stamps it. See [_shouldStampActivity].
  static const Duration _activityStampInterval = Duration(minutes: 5);

  /// When each game's `last_activity_at` was last written by THIS device.
  static final Map<String, DateTime> _activityStampedAt = {};

  /// Whether this event should carry a `last_activity_at` bump.
  ///
  /// The stamp exists for exactly two consumers, both scheduled sweeps:
  /// `cleanupOrphanedWaitingRooms` (2 h) and `cleanupInactiveGames` (24 h).
  /// Neither can tell a stamp apart from one five minutes older — but it used
  /// to ride along on *every* event, so a lockstep action, a heartbeat, an
  /// emote, a chat message and a typing refresh each paid for a
  /// `ServerValue.timestamp` on top of their own payload, for the whole
  /// duration of every active match.
  ///
  /// A game whose first event this is has no local record, so it stamps: a
  /// device that joins a room someone else created must not wait five minutes
  /// to mark it alive. Everything after that is throttled, which leaves the
  /// stamp at most [_activityStampInterval] behind the truth — three orders of
  /// magnitude inside the tightest sweep that reads it.
  static bool _shouldStampActivity(String gameId) {
    final now = DateTime.now();
    final last = _activityStampedAt[gameId];
    if (last != null && now.difference(last) < _activityStampInterval) {
      return false;
    }

    // A device plays one table at a time, but the provider outlives every
    // match it ever posted to: drop what can no longer be throttling anything
    // rather than keeping a row per game for the life of the process.
    if (_activityStampedAt.length >= 32) {
      _activityStampedAt.removeWhere(
        (_, at) => now.difference(at) >= _activityStampInterval,
      );
    }

    _activityStampedAt[gameId] = now;
    return true;
  }

  Future<String> createGame(Map<String, dynamic> doc) async {
    final id = await createData("games", doc);
    if (id.isNotEmpty) {
      // Recorded as a stamp so the creator's first event does not immediately
      // write the same value again.
      _activityStampedAt[id] = DateTime.now();
      ref
          .child("games/$id/last_activity_at")
          .set(ServerValue.timestamp)
          .catchError((e) => debugPrint("⚠️ last_activity_at set error => $e"));
    }
    return id;
  }

  Future<Map<String, dynamic>> readGame(String id) {
    return readData("games", id);
  }

  Future<void> updateGame(String id, Map<String, dynamic> doc) {
    return updateData("games", id, doc);
  }

  Future<void> deleteGame(String id) {
    return deleteData("games", id);
  }

  //

  Future<String> addGamePlayer(
      String gameId, Map<String, dynamic> gamePlayerDoc) {
    return createData("games/$gameId/players", gamePlayerDoc);
  }

  Future<void> removeGamePlayer(String gameId, String gamePlayerId) {
    return deleteData("games/$gameId/players", gamePlayerId);
  }

  //

  // Writes the event and, when it is due, bumps `last_activity_at` in the same
  // multi-path update instead of a second round-trip — this fires on every
  // lockstep action, heartbeat, resync, emote and chat message of every
  // active match, so halving the write count matters. The stamp itself is
  // throttled to one every [_activityStampInterval]; see
  // [_shouldStampActivity] for why that is safe.
  Future<String> addGameEvent(
      String gameId, Map<String, dynamic> gameEventDoc) async {
    try {
      final pushRef = ref.child("games/$gameId/events").push();

      final doc = Map<String, dynamic>.from(gameEventDoc);
      doc.remove("id");
      // No `created_at`/`updated_at`. They were two full `DateTime.toString()`
      // strings ("2026-08-31 08:12:34.567890") — ~52 bytes of the ~200 an
      // average event weighs — stamped onto every action, heartbeat, emote and
      // chat message of every active match, uploaded once and re-broadcast to
      // every peer. Nothing has ever read them back: the model still parses
      // them (older events keep theirs, and parse to null once they are gone),
      // no caller touches `GamicoGameEventModel.createdAt`, and the one place
      // that needs a timestamp — the shared shuffle seed — takes it from the
      // *game* node's `created_at`, not the event's. Ordering comes from the
      // push key, which is chronological by construction.
      doc.remove("created_at");
      doc.remove("updated_at");

      final jsonDoc = jsonDecode(jsonEncode(doc, toEncodable: (dynamic item) {
        return item?.toString();
      }));

      await ref.update({
        "games/$gameId/events/${pushRef.key}": jsonDoc,
        if (_shouldStampActivity(gameId))
          "games/$gameId/last_activity_at": ServerValue.timestamp,
      });

      return pushRef.key ?? "";
    } catch (e) {
      debugPrint("Error creating data games/$gameId/events: $e");
      return "";
    }
  }

  Future<void> removeGameEvent(String gameId, String gameEventId) {
    return deleteData("games/$gameId/events", gameEventId);
  }
}
