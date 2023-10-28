import 'dart:convert';
import 'dart:io';

import '../../Core/Modules/Player_Room.dart';
import '../repositories_impl/play_room_repo_impl.dart';
import '../../Core/Modules/Player_token.dart';
import '../Gameserver/game_server.dart';

class Gameserver_controller {
  static Pairing(HttpRequest preq, String ptoken) async {
    final available_room = look_for_available_play_room();
    if (available_room == null) {
      await create_room(preq, ptoken);
    } else {
      await Play_room_repo_impl(available_room).join_room(preq, ptoken);
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

  static create_room(HttpRequest game_request, String ptoken) async {
    try {
      final Socket_to_player = await WebSocketTransformer.upgrade(game_request);
      Play_room play_room = Play_room(GameServer.rooms.length,
          Player_Token(Socket_to_player, ptoken), null);

      GameServer.rooms.add(play_room);

      Socket_to_player.add(json.encode({"message": "Room created"}));
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
}
