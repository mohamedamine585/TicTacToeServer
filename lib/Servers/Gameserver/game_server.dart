import 'dart:async';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;

import '../../Core/Modules/Player.dart';
import '../../Core/Modules/Player_Room.dart';
import '../../utils/consts.dart';
import '../../Controllers/Gameservercontroller.dart';

class GameServer {
  static var rooms = <Play_room>[];
  static List<Player> players = [];

  static late HttpServer server;

  static Future<void> init() async {
    server = await HttpServer.bind(HOST_GAME, 8081);
    print(
        "Game server is running on ${server.address.address} port ${server.port}");
  }

  static Response _handleRequest(Request request) {
    try {
      // Handle the request using Gameserver_controller
      return Gameserver_controller.DealWithRequest(request);
    } catch (e) {
      print("Error handling request: $e");
      return Response.internalServerError();
    }
  }

  static Future<void> serve() async {
    await init();
    await Gameserver_controller.init_tokens_state();
    try {
      await io.serve((Request request) async {
        return _handleRequest(request);
      }, server.address.host, server.port);
    } catch (e) {
      print("Cannot start server: $e");
    }
  }
}
