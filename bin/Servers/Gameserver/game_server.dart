import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../../../bin/Core/Modules/Player.dart';
import '../../../bin/Core/Modules/Player_Room.dart';
import '../../../bin/Data/Services/Tokensservice.dart';
import '../../consts.dart';
import '../Controllers/Gameservercontroller.dart';

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
    await Tokensservice.getInstance().make_available_all_tokens();
    try {
      server.listen((HttpRequest play_request) async {
        final playertoken = (await Tokensservice.getInstance()
            .fetch_token(token: play_request.headers.value("token") ?? ""));

        if (playertoken != null) {
          if (WebSocketTransformer.isUpgradeRequest(play_request)) {
            await Gameserver_controller.Pairing(play_request, playertoken);
          } else {
            play_request.response.close();
          }
        } else {
          play_request.response
              .write(json.encode({"message": "Invalid token"}));
          play_request.response.close();
        }
      });
    } catch (e) {
      print("Cannot start server");
    }
  }
}
