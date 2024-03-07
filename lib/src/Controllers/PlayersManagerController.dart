import 'dart:io';

import 'package:tic_tac_toe_server/src/Services/online_activity_service.dart';
import 'package:tic_tac_toe_server/src/Services/player_service.dart';

class PlayersManagerController {
  static onlineActivity({required WebSocket webSocket}) {
    OnlineActivityService.instance.getOnlineActivity(webSocket: webSocket);
  }

  static getdoc({required String playerid}) async {
    try {
      return await PlayerService.instance.getdoc(id: playerid);
    } catch (e) {
      print(e);
    }
  }

  static updatedoc(
      {required Map<String, dynamic> playerupdate, required String id}) async {
    try {
      return await PlayerService.instance
          .updatePlayer(id: id, playerupdate: playerupdate);
    } catch (e) {
      print(e);
    }
  }
}
