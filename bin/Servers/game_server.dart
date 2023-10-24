import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../Modules/Player.dart';
import '../Modules/Player_Room.dart';
import '../Modules/Player_token.dart';
import '../Services/Tokensservice.dart';

class GameServer {
  static var rooms = <Play_room>[];
  static late HttpServer server;
  static List<Player> players = [];

  /// ****     initialize server on localhost *****

  static Future<void> init() async {
    try {
      server = await HttpServer.bind("0.0.0.0", 8080);
      print(
          "Game server is running on ${server.address.address} port ${server.port}");
    } catch (e) {
      print(e.toString());
    }
  }

  static serve() async {
    await init();
    try {
      // if this is the only game server ...
      await Tokensservice.getInstance().make_available_all_tokens();
      server.listen((HttpRequest play_request) async {
        String? playertoken;
        try {
          playertoken = (await Tokensservice.getInstance()
              .fetch_token(token: play_request.headers.value("token") ?? ""));
        } catch (e) {
          print("cannot fetch token !");
        }

        if (playertoken != null) {
          try {
            if (WebSocketTransformer.isUpgradeRequest(play_request)) {
              await Pairing(play_request, playertoken);
            } else {
              await Tokensservice.getInstance()
                  .make_available_token(playertoken);
              play_request.response.close();
            }
          } catch (e) {
            await Tokensservice.getInstance().make_available_token(playertoken);
            print("cannot upgrade request!");
          }
        } else {
          play_request.response
              .write(json.encode({"message": "Invalid token"}));
          play_request.response.close();
        }
      });
    } catch (e) {
      print("server issue");
    }
  }

  /// **********          Pairing a player to another or create a room for him *******
  ///
  ///
  ///

  static Pairing(HttpRequest preq, String ptoken) async {
    final available_room = look_for_available_play_room();
    final closed_r = look_for_closed_room();
    if (available_room == null) {
      if (closed_r == null) {
        try {
          await create_room(preq, ptoken);
        } catch (e) {
          print("cannot create room !");
        }
      } else {
        try {
          await closed_r.own_that_room(preq, ptoken);
        } catch (e) {
          print("cannot own room !");
        }
      }
    } else {
      try {
        await available_room.join_room(preq, ptoken);
      } catch (e) {
        print("cannot join room !");
      }
    }
  }

  static Play_room? look_for_closed_room() {
    for (Play_room room in rooms) {
      if (!room.opened) {
        return room;
      }
    }
  }

  static Play_room? look_for_available_play_room() {
    for (Play_room room in rooms) {
      if (room.player0 != null && room.opened) {
        return room;
      }
    }
  }

  static delete_room(int id) {
    if (rooms.length > id) {
      rooms.removeAt(id);
    }
  }

  static create_room(HttpRequest game_request, String ptoken) async {
    final Socket_to_player = await WebSocketTransformer.upgrade(game_request);
    Play_room play_room =
        Play_room(rooms.length, Player_Token(Socket_to_player, ptoken), null);

    rooms.add(play_room);

    Socket_to_player.add(json.encode({"message": "Room created"}));
    try {
      play_room.listen_to_player0();
    } catch (e) {
      print("cannot listen to socket !");
      play_room.close_room();
    }
  }

  static Play_room? seek_player_room(WebSocket player_sock) {
    for (Play_room room in rooms) {
      if (room.player0 == player_sock || room.player1 == player_sock) {
        return room;
      }
    }
  }
}
