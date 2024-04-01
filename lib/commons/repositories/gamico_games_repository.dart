import 'package:gamico/commons/models/gamico_game_model.dart';
import 'package:gamico/commons/providers/gamico_games_provider.dart';

class GamicoGamesRepository {
  final GamicoGamesProvider gamesProvider;

  GamicoGamesRepository({
    required this.gamesProvider,
  });

  Future<String> createGame(GamicoGameModel game) async {
    return await gamesProvider.createGame(game.toJson());
  }

  Future<GamicoGameModel> readGame(String id) async {
    return GamicoGameModel.fromJson(await gamesProvider.readGame(id));
  }

  Future<void> updateGame(String id, GamicoGameModel game) async {
    await gamesProvider.updateGame(id, game.toJson());
  }

  Future<void> updateGameStatus(String id, String status) async {
    await gamesProvider.updateGame(id, {
      "status": status,
    });
  }

  Future<void> deleteGame(String id) async {
    await gamesProvider.deleteGame(id);
  }

  //

  Future<String> addGamePlayer(
      String gameId, GamicoGamePlayerModel gamePlayer) {
    return gamesProvider.addGamePlayer(gameId, gamePlayer.toJson());
  }

  Future<void> removeGamePlayer(String gameId, String gamePlayerId) {
    return gamesProvider.removeGamePlayer(gameId, gamePlayerId);
  }

  //

  Future<String> addGameEvent(String gameId, GamicoGameEventModel gameEvent) {
    return gamesProvider.addGameEvent(gameId, gameEvent.toJson());
  }

  Future<void> removeGameEvent(String gameId, String gameEventId) {
    return gamesProvider.removeGameEvent(gameId, gameEventId);
  }
}
