import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:tic_tac_toe_server/src/Data/Mongo/players_dataaccess.dart';

class OnlineActivityService {
  PlayersDataAccess playersDataAccess = PlayersDataAccess();
  OnlineActivityService._(this.playersDataAccess);
  static OnlineActivityService instance =
      OnlineActivityService._(PlayersDataAccess());
  void getOnlineActivity({required WebSocket webSocket}) async {
    final stream = playersDataAccess.getActivePlayers();
    stream.listen((event) {
      webSocket.add(json.encode({"players": event}));
    });
  }
}
