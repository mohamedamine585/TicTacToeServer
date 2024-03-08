import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/controllers/Gameservercontroller.dart';
import 'package:tic_tac_toe_server/src/models/Player_token.dart';
import 'package:tic_tac_toe_server/src/services/PlayRoomService.dart';
import 'package:tic_tac_toe_server/src/services/Tokensservice.dart';

import '../models/Player_Room.dart';

class RoomManagerController {
  static join_room(
      HttpRequest playerReq, ObjectId id, Play_room playRoom) async {
    try {
      playRoom.player1 =
          Player_Socket(await WebSocketTransformer.upgrade(playerReq), id);
    } catch (e) {
      print("cannot upgrade request !");
    }
    try {
      playRoom.roomid =
          await PlayRoomService.instance.open_PlayRoom(play_room: playRoom);
      playRoom.player0?.socket.add(json.encode({
        "message": "Opponent found !",
        "Grid": [
          playRoom.Grid[0][0] ?? '',
          playRoom.Grid[0][1] ?? '',
          playRoom.Grid[0][2] ?? '',
          playRoom.Grid[1][0] ?? '',
          playRoom.Grid[1][1] ?? '',
          playRoom.Grid[1][2] ?? '',
          playRoom.Grid[2][0] ?? '',
          playRoom.Grid[2][1] ?? '',
          playRoom.Grid[2][2] ?? ''
        ],
        "hand": "${playRoom.hand}"
      }));

      playRoom.player1?.socket.add(json.encode({
        "message": "Opponent found !",
        "Grid": [
          playRoom.Grid[0][0] ?? '',
          playRoom.Grid[0][1] ?? '',
          playRoom.Grid[0][2] ?? '',
          playRoom.Grid[1][0] ?? '',
          playRoom.Grid[1][1] ?? '',
          playRoom.Grid[1][2] ?? '',
          playRoom.Grid[2][0] ?? '',
          playRoom.Grid[2][1] ?? '',
          playRoom.Grid[2][2] ?? ''
        ],
        "hand": "${playRoom.hand}"
      }));
      playRoom.opened = true;
      Gameserver_controller.listen_to_player1(playRoom);
    } catch (e) {
      await playRoom.player0?.socket.close();
      await playRoom.player1?.socket.close();
      print("cannnot contact player socket");
    }
  }

  static delete_room(Play_room playRoom) async {
    try {
      if (playRoom.opened) {
        await Tokensservice.instance.change_token_status(playRoom.player0!.Id);

        await Tokensservice.instance.change_token_status(playRoom.player1!.Id);

        if (playRoom.player0 != null && playRoom.player1 != null) {
          print(playRoom.player0?.Id);
          print(playRoom.player1?.Id);
          await PlayRoomService.instance.close_PlayRoom(play_room: playRoom);
        }
      }

      for (int ids = playRoom.id + 1;
          ids < Gameserver_controller.rooms.length;
          ids++) {
        Gameserver_controller.rooms[ids].id = ids--;
      }
      Gameserver_controller.rooms.remove(playRoom);
    } catch (e) {
      print(e);
    }
  }

  static Play_room? seek_player_room(WebSocket playerSock) {
    for (Play_room room in Gameserver_controller.rooms) {
      if (room.player0 == playerSock || room.player1 == playerSock) {
        return room;
      }
    }
    return null;
  }

  static Play_room? look_for_closed_room() {
    for (Play_room room in Gameserver_controller.rooms) {
      if (!room.opened) {
        return room;
      }
    }
    return null;
  }

  static Play_room? look_for_available_play_room(ObjectId? roomid) {
    for (Play_room room in Gameserver_controller.rooms) {
      if (!room.opened && (roomid != null) ? room.roomid == roomid : true) {
        return room;
      }
    }
    return null;
  }

  static Pairing(HttpRequest playrequest, ObjectId? roomid, ObjectId id) async {
    final availableRoom = look_for_available_play_room(roomid);
    print(availableRoom?.gameWithaFriend);

    if (availableRoom == null && roomid == null) {
      await create_room(playrequest, id);
    } else if (availableRoom == null && roomid != null) {
      playrequest.response.write(json.encode({"message": "Room not Found"}));
    } else if ((availableRoom != null &&
        ((availableRoom.gameWithaFriend && roomid != null) ||
            !availableRoom.gameWithaFriend))) {
      await join_room(playrequest, id, availableRoom);
    } else {
      playrequest.response.statusCode = 404;
    }
  }

  static create_room(HttpRequest gameRequest, ObjectId id) async {
    try {
      final socketToPlayer = await WebSocketTransformer.upgrade(gameRequest);
      Play_room playRoom = Play_room(
          Gameserver_controller.rooms.length,
          ObjectId(),
          Player_Socket(socketToPlayer, id),
          null,
          0,
          (gameRequest.headers.value("mode") == "friend"));

      print(playRoom.roomid);

      Gameserver_controller.rooms.add(playRoom);
      Gameserver_controller.sendDataTo("Room created", playRoom, socketToPlayer,
          playRoom.roomid?.toHexString());
      await Tokensservice.instance.change_token_status(playRoom.player0!.Id);
      Gameserver_controller.listen_to_player0(playRoom);
    } catch (e) {
      print("cannot create room");
    }
  }
}
