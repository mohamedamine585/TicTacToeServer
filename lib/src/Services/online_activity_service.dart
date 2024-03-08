import 'package:tic_tac_toe_server/src/data/Mongo/players_dataaccess.dart';

class OnlineActivityService {
  PlayersDataAccess playersDataAccess = PlayersDataAccess();
  OnlineActivityService._(this.playersDataAccess);
  static OnlineActivityService instance =
      OnlineActivityService._(PlayersDataAccess());
  Future<List<Map<String, dynamic>>> getOnlineActivity() async {
    final stream = playersDataAccess.getActivePlayers();

    List<Map<String, dynamic>> onlinePlayers = [];
    await stream.forEach((element) {
      onlinePlayers.add(element);
    });
    return onlinePlayers;
  }
}
