import 'package:firebase_database/firebase_database.dart';
import 'package:gamico/commons/providers/gamico_generic_provider.dart';

class GamicoGamesProvider extends GamicoGenericProvider {
  Future<String> createGame(Map<String, dynamic> doc) async {
    final id = await createData("games", doc);
    if (id.isNotEmpty) {
      ref.child("games/$id/last_activity_at").set(ServerValue.timestamp);
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

  Future<String> addGameEvent(
      String gameId, Map<String, dynamic> gameEventDoc) {
    ref.child("games/$gameId/last_activity_at").set(ServerValue.timestamp);
    return createData("games/$gameId/events", gameEventDoc);
  }

  Future<void> removeGameEvent(String gameId, String gameEventId) {
    return deleteData("games/$gameId/events", gameEventId);
  }
}
