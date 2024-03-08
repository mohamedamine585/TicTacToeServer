import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:tic_tac_toe_server/src/services/online_activity_service.dart';
import 'package:tic_tac_toe_server/src/services/player_service.dart';

class PlayersManagerController {
  static Future<void> subscribeToOnlineActivity(
      {required HttpRequest request}) async {
    final stream = OnlineActivityService.instance.getOnlineActivity();
    if (WebSocketTransformer.isUpgradeRequest(request)) {
      final websocket = await WebSocketTransformer.upgrade(request);
      stream?.listen((event) {
        // to fix
        event.remove("lastconnection");
        websocket.add(json.encode({"players": event}));
      });
    }
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
