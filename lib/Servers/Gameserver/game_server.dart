import 'dart:async';
import 'dart:io';

import '../../Core/Modules/Player.dart';
import '../../Core/Modules/Player_Room.dart';
import '../../utils/consts.dart';
import '../../Controllers/Gameservercontroller.dart';

class GameServer {
  static var rooms = <Play_room>[];
  static late HttpServer server;
  static List<Player> players = [];

  /// ****     initialize server on localhost *****

  static Future<void> init() async {
    server = await HttpServer.bind(HOST_GAME, PORT_GAME);
    print(
        "Game server is running on ${server.address.address} port ${server.port}");
  }

  static serve() async {
    await init();
    await Gameserver_controller.init_tokens_state();
    try {
      server.listen((HttpRequest playRequest) async {
        try {
          await Gameserver_controller.DealWithRequest(playRequest);
        } catch (e) {
          print("Error");
        }
      });
    } catch (e) {
      print("Cannot start server");
    }
  }
}
