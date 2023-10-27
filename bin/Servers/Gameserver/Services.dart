import 'dart:convert';
import 'dart:io';

import '../../Core/Modules/Player_Room.dart';
import '../../Core/Repositories/Playroom_repo.dart';
import '../../Core/Modules/Player_token.dart';
import 'game_server.dart';

Pairing(HttpRequest preq, String ptoken) async {
  final available_room = look_for_available_play_room();
  if (available_room == null) {
    await create_room(preq, ptoken);
  } else {
    await join_room(preq, ptoken, available_room);
  }
}

Play_room? look_for_closed_room() {
  for (Play_room room in GameServer.rooms) {
    if (!room.opened) {
      return room;
    }
  }
}

Play_room? look_for_available_play_room() {
  for (Play_room room in GameServer.rooms) {
    if (room.player0 != null && room.opened) {
      return room;
    }
  }
}

delete_room(int id) {
  if (GameServer.rooms.length > id) {
    GameServer.rooms.removeAt(id);
  }
}

create_room(HttpRequest game_request, String ptoken) async {
  try {
    final Socket_to_player = await WebSocketTransformer.upgrade(game_request);
    Play_room play_room = Play_room(
        GameServer.rooms.length, Player_Token(Socket_to_player, ptoken), null);

    GameServer.rooms.add(play_room);

    Socket_to_player.add(json.encode({"message": "Room created"}));
    listen_to_player0(play_room);
  } catch (e) {
    print("cannot create room");
  }
}

Play_room? seek_player_room(WebSocket player_sock) {
  for (Play_room room in GameServer.rooms) {
    if (room.player0 == player_sock || room.player1 == player_sock) {
      return room;
    }
  }
}
