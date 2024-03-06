import 'dart:async';
import 'dart:io';

import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:tic_tac_toe_server/Controllers/Router.dart';

import '../../Controllers/Gameservercontroller.dart';

class GameServer {
  static late HttpServer server;

  /// ****     initialize server on localhost *****

  static Future<void> init() async {
    var env = dotenv.DotEnv()..load();
    server = await HttpServer.bind(env["HOST"], int.parse(env["PORT"] ?? ""));
    print(
        "Game server is running on ${server.address.address} port ${server.port}");
  }

  static serve() async {
    await init();
    await Gameserver_controller.init_tokens_state();
    try {
      server.listen((HttpRequest playRequest) async {
        try {
          await Router.route(playRequest);
        } catch (e) {
          print("Error");
        }
      });
    } catch (e) {
      print("Cannot start server");
    }
  }
}
