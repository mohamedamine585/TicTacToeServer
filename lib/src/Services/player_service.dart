import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/data/Mongo/players_dataaccess.dart';

import 'package:tic_tac_toe_server/src/models/Player.dart';
import 'package:tic_tac_toe_server/src/data/utils.dart';

class PlayerService {
  PlayersDataAccess playersDataAccess = PlayersDataAccess();
  PlayerService._(this.playersDataAccess);
  static PlayerService instance = PlayerService._(PlayersDataAccess());
  init() {
    playerscollection = DbCollection(db, "players");
  }

  Future<Player?> getPlayerById({required ObjectId id}) async {
    return await playersDataAccess.get_playerbyId(id: id);
  }

  Future<Player?> getPlayeryName({required String playername}) async {
    return await playersDataAccess.get_playerbyName(playername: playername);
  }

  Future<Player?> getPlayerByEmail({required String email}) async {
    return await playersDataAccess.getPlayerByEmail(email: email);
  }

  updateActivity({required String playerid}) async {
    try {
      await playersDataAccess.updateActivity(playerid: playerid);
    } catch (e) {
      print(e);
    }
  }

  Future<Map<String, dynamic>?> getdoc({required String id}) async {
    return await playersDataAccess.getdoc(id: id);
  }

  Future<Map<String, dynamic>?> updatePlayer(
      {required Map<String, dynamic> playerupdate, required String id}) async {
    return await playersDataAccess.updatePlayer(
        playerupdate: playerupdate, id: id);
  }

  Future<List<Map<String, dynamic>?>> getPlayerHistory(
      {required String id}) async {
    return await playersDataAccess.getPlayerHistory(playerid: id);
  }
}
