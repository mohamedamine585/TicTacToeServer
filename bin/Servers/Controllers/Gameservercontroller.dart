import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';

import '../../Core/Modules/Player.dart';
import '../../Core/Modules/Player_Room.dart';
import '../../Data/Services/Tokensservice.dart';
import '../repositories_impl/play_room_repo_impl.dart';
import '../../Core/Modules/Player_token.dart';
import '../Gameserver/game_server.dart';

class Gameserver_controller {
  static Pairing(HttpRequest preq, ObjectId id) async {
    final available_room = look_for_available_play_room();
    if (available_room == null) {
      await create_room(preq, id);
    } else {
      await Play_room_repo_impl(available_room).join_room(preq, id);
    }
  }

  static Play_room? look_for_closed_room() {
    for (Play_room room in GameServer.rooms) {
      if (!room.opened) {
        return room;
      }
    }
  }

  static Play_room? look_for_available_play_room() {
    for (Play_room room in GameServer.rooms) {
      if (room.player0 != null && room.opened) {
        return room;
      }
    }
  }

  static delete_room(int id) {
    if (GameServer.rooms.length > id) {
      GameServer.rooms.removeAt(id);
    }
  }

  static create_room(HttpRequest game_request, ObjectId id) async {
    try {
      final Socket_to_player = await WebSocketTransformer.upgrade(game_request);
      Play_room play_room = Play_room(
          GameServer.rooms.length, Player_Socket(Socket_to_player, id), null);

      GameServer.rooms.add(play_room);

      Socket_to_player.add(json.encode({"message": "Room created"}));
      await Tokensservice.getInstance()
          .change_token_status(play_room.player0!.Id);
      Play_room_repo_impl(play_room).listen_to_player0();
    } catch (e) {
      print("cannot create room");
    }
  }

  static Play_room? seek_player_room(WebSocket player_sock) {
    for (Play_room room in GameServer.rooms) {
      if (room.player0 == player_sock || room.player1 == player_sock) {
        return room;
      }
    }
  }

  static DealWithRequest(HttpRequest play_request, ObjectId id) async {
    if (WebSocketTransformer.isUpgradeRequest(play_request)) {
      await Gameserver_controller.Pairing(play_request, id);
    } else {
      play_request.response.close();
    }
  }
}
