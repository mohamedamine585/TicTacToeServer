import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';

import '../Core/Modules/Player_Room.dart';
import '../Services/PlayRoomService.dart';
import '../Services/Tokensservice.dart';
import '../Servers/utils.dart';
import '../middleware/tokenmiddleware.dart';
import 'repositories_impl/play_room_repo_impl.dart';
import '../Core/Modules/Player_token.dart';
import '../Servers/Gameserver/game_server.dart';

class Gameserver_controller {
  static init_tokens_state() async {
    await Tokensservice.getInstance().make_available_all_tokens();
  }

  static Pairing(HttpRequest preq, ObjectId id) async {
    final availableRoom = look_for_available_play_room();
    if (availableRoom == null) {
      await create_room(preq, id);
    } else {
      await join_room(preq, id, availableRoom);
      listen_to_player1(availableRoom);
    }
  }

  static Play_room? look_for_closed_room() {
    for (Play_room room in GameServer.rooms) {
      if (!room.opened) {
        return room;
      }
    }
    return null;
  }

  static Play_room? look_for_available_play_room() {
    for (Play_room room in GameServer.rooms) {
      if (room.player0 != null && room.opened) {
        return room;
      }
    }
    return null;
  }

  static delete_room(Play_room playRoom) async {
    Play_room_repo_impl(playRoom).close_room();

    for (int ids = playRoom.id + 1; ids < GameServer.rooms.length; ids++) {
      GameServer.rooms[ids].id = ids--;
    }
    GameServer.rooms.remove(playRoom);
  }

  Play(Play_room playRoom) async {
    try {
      await Tokensservice.getInstance()
          .change_token_status(playRoom.player0!.Id);
    } catch (e) {
      print("error socket !");
    }
  }

  static create_room(HttpRequest gameRequest, ObjectId id) async {
    try {
      final socketToPlayer = await WebSocketTransformer.upgrade(gameRequest);
      Play_room playRoom = Play_room(GameServer.rooms.length,
          Player_Socket(socketToPlayer, id), null, 0);

      GameServer.rooms.add(playRoom);

      socketToPlayer.add(json.encode({"message": "Room created"}));
      await Tokensservice.getInstance()
          .change_token_status(playRoom.player0!.Id);
      listen_to_player0(playRoom);
    } catch (e) {
      print("cannot create room");
    }
  }

  static Play_room? seek_player_room(WebSocket playerSock) {
    for (Play_room room in GameServer.rooms) {
      if (room.player0 == playerSock || room.player1 == playerSock) {
        return room;
      }
    }
    return null;
  }

  static DealWithRequest(HttpRequest playRequest) async {
    String? playerid;
    try {
      playerid = Tokenmiddleware.Check_Token(
          playRequest.headers.value("token"));
    } catch (e) {
      print(e);
    }

    if (playerid != null) {
      if (WebSocketTransformer.isUpgradeRequest(playRequest)) {
        await Gameserver_controller.Pairing(
            playRequest, ObjectId.parse(playerid));
      } else {
        playRequest.response.close();
      }
    } else {
      playRequest.response.write(json.encode({"message": "Invalid token"}));
      playRequest.response.close();
    }
  }

  static listen_to_player0(Play_room playRoom) {
    try {
      playRoom.player0?.socket.listen(
        (event) async {
          if (playRoom.hand == 0) {
            event as String;

            playRoom.Grid[int.parse(event[0])][int.parse(event[2])] = 'X';

            if (checkWin(playRoom) == 'X') {
              sendDataToboth(
                  "Player ${playRoom.hand} is The Winner", playRoom);

              playRoom.player0?.socket.close(null, "won");
            } else {
              playRoom.hand = 1;
              print("player1 turn");

              sendDataToboth(null, playRoom);
            }
          }
        },
        onDone: () async {
          if (playRoom.opened) {
            playRoom.opened = false;
            playRoom.player0?.socket.close();
            playRoom.hand = 1;
            await Tokensservice.getInstance()
                .change_token_status(playRoom.player0!.Id);
            if (playRoom.player1 != null) {
              await Tokensservice.getInstance()
                  .change_token_status(playRoom.player1!.Id);

              playRoom.player1?.socket.close();

              delete_room(playRoom);
            }
          }
        },
      );
    } catch (e) {
      if (playRoom.player1 != null) {
        delete_room(playRoom);
      }

      print("Cannot listen to player");
    }
  }

  static listen_to_player1(Play_room playRoom) {
    try {
      playRoom.player1?.socket.listen(
        (event) async {
          if (playRoom.hand == 1) {
            event as String;

            playRoom.Grid[int.parse(event[0])][int.parse(event[2])] = 'O';

            if (checkWin(playRoom) == 'O') {
              sendDataToboth(
                  "Player ${playRoom.hand} is The Winner", playRoom);
              playRoom.player1?.socket.close(null, "won");
            } else {
              playRoom.hand = 0;
              print("player0 turn");

              sendDataToboth(null, playRoom);
            }
          }
        },
        onDone: () async {
          if (playRoom.opened) {
            playRoom.opened = false;
            playRoom.player1?.socket.close();
            playRoom.hand = 0;

            await Tokensservice.getInstance()
                .change_token_status(playRoom.player1!.Id);
            if (playRoom.player0 != null) {
              await Tokensservice.getInstance()
                  .change_token_status(playRoom.player0!.Id);

              playRoom.player0?.socket.close();

              delete_room(playRoom);
            }
          }
        },
      );
    } catch (e) {
      delete_room(playRoom);
      print("Cannot listen to player");
    }
  }

  static join_room(
      HttpRequest playerReq, ObjectId id, Play_room playRoom) async {
    try {
      playRoom.player1 =
          Player_Socket(await WebSocketTransformer.upgrade(playerReq), id);
    } catch (e) {
      print("cannot upgrade request !");
    }
    try {
      playRoom.roomid = await PlayRoomService.getInstance()
          .open_PlayRoom(play_room: playRoom);
      playRoom.player0?.socket.add(json.encode({
        "message": "Opponent found !",
        "playroom.Grid":
            "${playRoom.Grid[0][0]},${playRoom.Grid[1][0]},${playRoom.Grid[2][0]},${playRoom.Grid[0][1]},${playRoom.Grid[1][1]},${playRoom.Grid[1][2]},${playRoom.Grid[0][2]},${playRoom.Grid[1][2]},${playRoom.Grid[2][2]},",
        "play_room.hand": "${playRoom.hand}"
      }));

      playRoom.player1?.socket.add(json.encode({
        "message": "Opponent found !",
        "playroom.Grid":
            "${playRoom.Grid[0][0]},${playRoom.Grid[1][0]},${playRoom.Grid[2][0]},${playRoom.Grid[0][1]},${playRoom.Grid[1][1]},${playRoom.Grid[1][2]},${playRoom.Grid[0][2]},${playRoom.Grid[1][2]},${playRoom.Grid[2][2]},",
        "play_room.hand": "${playRoom.hand}"
      }));
    } catch (e) {
      print("cannnot contact player socket");
    }
  }

  static sendDataToboth(String? message, Play_room playRoom) {
    if (message != null) {
      if (playRoom.hand != null) {
        playRoom.player0?.socket.add(json.encode({
          "message": message,
          "Grid":
              "${playRoom.Grid[0][0]},${playRoom.Grid[1][0]},${playRoom.Grid[2][0]},${playRoom.Grid[0][1]},${playRoom.Grid[1][1]},${playRoom.Grid[1][2]},${playRoom.Grid[0][2]},${playRoom.Grid[1][2]},${playRoom.Grid[2][2]},",
          "hand": "${playRoom.hand}"
        }));

        playRoom.player1?.socket.add(json.encode({
          "message": message,
          "Grid":
              "${playRoom.Grid[0][0]},${playRoom.Grid[1][0]},${playRoom.Grid[2][0]},${playRoom.Grid[0][1]},${playRoom.Grid[1][1]},${playRoom.Grid[1][2]},${playRoom.Grid[0][2]},${playRoom.Grid[1][2]},${playRoom.Grid[2][2]},",
          "hand": "${playRoom.hand}"
        }));
      }
    } else {
      if (playRoom.hand != null) {
        playRoom.player0?.socket.add(json.encode({
          "Grid":
              "${playRoom.Grid[0][0]},${playRoom.Grid[1][0]},${playRoom.Grid[2][0]},${playRoom.Grid[0][1]},${playRoom.Grid[1][1]},${playRoom.Grid[1][2]},${playRoom.Grid[0][2]},${playRoom.Grid[1][2]},${playRoom.Grid[2][2]},",
          "hand": "${playRoom.hand}"
        }));

        playRoom.player1?.socket.add(json.encode({
          "Grid":
              "${playRoom.Grid[0][0]},${playRoom.Grid[1][0]},${playRoom.Grid[2][0]},${playRoom.Grid[0][1]},${playRoom.Grid[1][1]},${playRoom.Grid[1][2]},${playRoom.Grid[0][2]},${playRoom.Grid[1][2]},${playRoom.Grid[2][2]},",
          "hand": "${playRoom.hand}",
        }));
      }
    }
  }
}
