import 'dart:async';
import 'dart:io';

import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:tic_tac_toe_server/src/controllers/Router.dart';
import 'package:tic_tac_toe_server/src/data/Mongo/MongoDb.dart';

import 'package:tic_tac_toe_server/src/controllers/Gameservercontroller.dart';

class GameServer {
  static late HttpServer server;

  /// ****     initialize server on localhost *****

  static Future<void> init() async {
    var env = dotenv.DotEnv()..load();

    await DbRepository.instance.init(env["DB"] ?? "TictactoeTest");
    server = await HttpServer.bind(env["HOST"], int.parse(env["PORT"] ?? ""));
    print(
        "Game server is running on ${server.address.address} port ${server.port}");
  }

  static Future<HttpServer?> serve() async {
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
      return server;
    } catch (e) {
      print("Cannot start server");
    }
    return null;
  }
}
