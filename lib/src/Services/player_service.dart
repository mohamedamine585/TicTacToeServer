import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/models/Player.dart';
import 'package:tic_tac_toe_server/src/data/Mongo/players_dataaccess.dart';
import 'package:tic_tac_toe_server/src/data/utils.dart';

class PlayerService {
  PlayersDataAccess playerRepository;
  PlayerService._(this.playerRepository);
  static PlayerService instance = PlayerService._(PlayersDataAccess());
  init() {
    playerscollection = DbCollection(db, "players");
  }

  Future<Player?> get_playerbyId({required ObjectId id}) async {
    return await playerRepository.get_playerbyId(id: id);
  }

  Future<Player?> get_playerbyName({required String playername}) async {
    return await playerRepository.get_playerbyName(playername: playername);
  }

  Future<String?> change_password(
      {required String playername,
      required String old_password,
      required String newpassword}) async {
    return await playerRepository.change_password(
        playername: playername,
        old_password: old_password,
        newpassword: newpassword);
  }

  Future<bool> change_name(
      {required String playername,
      required String password,
      required String new_name}) async {
    return await playerRepository.change_name(
        playername: playername, password: password, new_name: new_name);
  }

  Future<Map<String, bool>?> delete_user(
      {required String playername, required String password}) async {
    return await playerRepository.delete_user(
        playername: playername, password: password);
  }

  updateActivity({required String playerid}) async {
    try {
      await playerRepository.updateActivity(playerid: playerid);
    } catch (e) {
      print(e);
    }
  }

  Future<Map<String, dynamic>?> getdoc({required String id}) async {
    return await playerRepository.getdoc(id: id);
  }

  Future<Map<String, dynamic>?> updatePlayer(
      {required Map<String, dynamic> playerupdate, required String id}) async {
    return await playerRepository.updatePlayer(
        playerupdate: playerupdate, id: id);
  }
}
