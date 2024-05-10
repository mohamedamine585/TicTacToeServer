import 'package:tic_tac_toe_server/src/Data/Mongo/players_dataaccess.dart';

class OnlineActivityService {
  PlayersDataAccess playersDataAccess = PlayersDataAccess();
  OnlineActivityService._(this.playersDataAccess);
  static OnlineActivityService instance =
      OnlineActivityService._(PlayersDataAccess());
  Stream<Map<String, dynamic>>? getOnlineActivity() {
    return playersDataAccess.getActivePlayers();
  }
}
