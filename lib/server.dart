import 'dart:async';
import 'dart:io';

import 'package:dotenv/dotenv.dart' as dotenv;
import 'package:tic_tac_toe_server/src/controllers/Gameservercontroller.dart';
import 'package:tic_tac_toe_server/src/data/Mongo/MongoDb.dart';
import 'package:tic_tac_toe_server/src/router/Router.dart';

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
}

Future<HttpServer?> run() async {
  await GameServer.init();
  await Gameserver_controller.init_tokens_state();
  try {
    GameServer.server.listen(router, onError: onError);

    return GameServer.server;
  } catch (e) {
    print("Cannot start server");
  }
  return null;
}
