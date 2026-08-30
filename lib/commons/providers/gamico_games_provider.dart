import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:gamico/commons/providers/gamico_generic_provider.dart';

class GamicoGamesProvider extends GamicoGenericProvider {
  Future<String> createGame(Map<String, dynamic> doc) async {
    final id = await createData("games", doc);
    if (id.isNotEmpty) {
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

  // Writes the event and bumps `last_activity_at` in a single multi-path
  // update instead of two separate round-trips — this fires on every
  // lockstep action, heartbeat, resync, emote and chat message of every
  // active match, so halving the write count matters.
  Future<String> addGameEvent(
      String gameId, Map<String, dynamic> gameEventDoc) async {
    try {
      final pushRef = ref.child("games/$gameId/events").push();
      final now = DateTime.now().toString();

      final doc = Map<String, dynamic>.from(gameEventDoc);
      doc.remove("id");
      doc["created_at"] = now;
      doc["updated_at"] = now;

      final jsonDoc = jsonDecode(jsonEncode(doc, toEncodable: (dynamic item) {
        return item?.toString();
      }));

      await ref.update({
        "games/$gameId/events/${pushRef.key}": jsonDoc,
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
