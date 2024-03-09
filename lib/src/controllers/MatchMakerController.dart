import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/controllers/Gameservercontroller.dart';
import 'package:tic_tac_toe_server/src/models/Player_token.dart';

import '../models/Player_Room.dart';

class MatchMakerController {
  static String? findFreeRoom() {
    try {
      for (Play_room playRoom in Gameserver_controller.rooms) {
        if (playRoom.player1 == null && !playRoom.gameWithaFriend) {
          return playRoom.roomid?.toHexString();
        }
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static String? createRoom(bool playWithaFriend) {
    try {
      // create playroom object without sockets
      Play_room play_room = Play_room(Gameserver_controller.rooms.length,
          ObjectId(), null, null, null, playWithaFriend);

      Gameserver_controller.rooms.add(play_room);

      return play_room.roomid?.toHexString();
    } catch (e) {
      print(e);
    }
    return null;
  }

  static acceptPlayer(HttpRequest playrequest, String playerid) async {
    try {
      String? playRoomId;
      final mode = playrequest.headers.value("mode");
      if (mode == "friend") {
        playRoomId ??= createRoom(mode == "friend");
      } else {
        playRoomId = findFreeRoom();
        playRoomId ??= createRoom(mode == "friend");
      }

      playrequest.response.statusCode = HttpStatus.ok;
      playrequest.response.write(json.encode({"roomid": playRoomId}));
    } catch (e) {
      print(e);
    }
  }

  static int? findfreeRoomindex(ObjectId roomid) {
    try {
      for (int i = 0; i < Gameserver_controller.rooms.length; i++) {
        if (Gameserver_controller.rooms[i].roomid == roomid &&
            Gameserver_controller.rooms[i].player1 == null) {
          return i;
        }
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static connectToPlayroom(
      HttpRequest playrequest, ObjectId playerId, ObjectId roomid) async {
    try {
      // find playroom (can Upgrade using a Map instead of a list)

      final playroomindex = findfreeRoomindex(roomid);
      if (playroomindex != null) {
        // open websocket connection with the player
        final playerWebScoket = await WebSocketTransformer.upgrade(playrequest);
        if (Gameserver_controller.rooms[playroomindex].player0 == null) {
          Gameserver_controller.rooms[playroomindex].player0 =
              Player_Socket(playerWebScoket, playerId);

          // sending a wait message to the player
          Gameserver_controller.sendDataTo(
              "Waiting the opponent ...",
              Gameserver_controller.rooms[playroomindex],
              Gameserver_controller.rooms[playroomindex].player0!.socket,
              roomid.toHexString());
        } else if (Gameserver_controller.rooms[playroomindex].player1 == null) {
          Gameserver_controller.rooms[playroomindex].player1 =
              Player_Socket(playerWebScoket, playerId);

          startGame(Gameserver_controller.rooms[playroomindex]);
        } else {
          playrequest.response.statusCode = HttpStatus.badRequest;
        }
      }
    } catch (e) {
      print(e);
    }
  }

  static startGame(Play_room playRoom) {
    try {
      Gameserver_controller.sendDataTo("Game started", playRoom,
          playRoom.player0!.socket, playRoom.roomid?.toHexString());
      Gameserver_controller.sendDataTo("Game started", playRoom,
          playRoom.player1!.socket, playRoom.roomid?.toHexString());

      // start receiving data from players
      playRoom.hand = 0;
      Gameserver_controller.listen_to_player0(playRoom);
      Gameserver_controller.listen_to_player1(playRoom);
    } catch (e) {
      print(e);
    }
  }
}
