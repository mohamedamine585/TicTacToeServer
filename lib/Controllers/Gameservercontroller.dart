import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:tic_tac_toe_server/Controllers/utils.dart';

import '../../Core/Modules/Player_Room.dart';
import '../../Services/PlayRoomService.dart';
import '../../Services/Tokensservice.dart';
import '../Servers/Gameserver/game_server.dart';
import '../../middleware/tokenmiddleware.dart';
import '../../Core/Modules/Player_token.dart';

class Gameserver_controller {
  static init_tokens_state() async {
    await Tokensservice.instance.make_available_all_tokens();
  }

  static Pairing(Request preq, ObjectId id) async {
    final availableRoom = look_for_available_play_room();
    if (availableRoom == null) {
      await create_room(preq, id);
    } else {
      await join_room(preq, id, availableRoom);
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
      if (!room.opened) {
        return room;
      }
    }
    return null;
  }

  static delete_room(Play_room playRoom) async {
    try {
      if (playRoom.opened) {
        await Tokensservice.instance.change_token_status(playRoom.player0!.Id);
        await Tokensservice.instance.change_token_status(playRoom.player1!.Id);
      }

      if (playRoom.player0 != null && playRoom.player1 != null) {
        await PlayRoomService.instance.close_PlayRoom(play_room: playRoom);
      }

      for (int ids = playRoom.id + 1; ids < GameServer.rooms.length; ids++) {
        GameServer.rooms[ids].id = ids--;
      }
      GameServer.rooms.remove(playRoom);
    } catch (e) {
      print(e);
    }
  }

  Play(Play_room playRoom) async {
    try {
      await Tokensservice.instance.change_token_status(playRoom.player0!.Id);
    } catch (e) {
      print("error socket !");
    }
  }

  static create_room(HttpRequest gameRequest, ObjectId id) async {
    try {
      final socketToPlayer = await WebSocketTransformer.upgrade(gameRequest);
      Play_room playRoom = Play_room(
          GameServer.rooms.length, Player_Socket(socketToPlayer, id), null, 0);

      GameServer.rooms.add(playRoom);
      sendDataTo("Room created", playRoom, socketToPlayer);
      await Tokensservice.instance.change_token_status(playRoom.player0!.Id);
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

  static Response dealWithRequest(Request playRequest) {
    String? playerid;
    try {
      playerid = Tokenmiddleware.Check_Token(
          playRequest.headers["authorization"]?.split(" ")[1]);
    } catch (e) {
      print(e);
    }

    if (playerid != null) {
        // Handle WebSocket upgrade
        webSocketHandler(()async{
              await Pairing(playRequest, ObjectId.fromHexString(playerid ?? ""));
        });
      } else {
        // Non-websocket request
        return Response.forbidden("WebSocket connection required.");
      }
    } else {
      // Invalid token
      return Response.unauthorized(json.encode({"message": "Invalid token"}));
    }
  }

  static listen_to_player0(Play_room playRoom) {
    int x0 = 0, x1 = 0;
    try {
      playRoom.player0?.socket.listen((event) async {
        try {
          if (playRoom.hand == 0) {
            event as String;
            if (event.length > 3) {
              throw Exception();
            }

            x0 = int.parse(event[0]);
            x1 = int.parse(event[2]);

            playRoom.Grid[x0][x1] = 'X';

            if (checkWin(play_room: playRoom) == 'X') {
              sendDataTo("You won", playRoom, playRoom.player0!.socket);
              sendDataTo("You Lost", playRoom, playRoom.player1!.socket);
              playRoom.player0?.socket.close(null, "won");
            } else {
              playRoom.hand = 1;
              print("player1 turn");

              sendDataToboth(null, playRoom);
            }
          }
        } catch (e) {
          if (playRoom.player1 != null && playRoom.player0 != null) {
            sendDataTo("You won", playRoom, playRoom.player1!.socket);
            sendDataTo("You Lost", playRoom, playRoom.player0!.socket);
          }

          playRoom.hand = 1;
          await playRoom.player0?.socket.close();
        }
      }, onDone: () async {
        delete_room(playRoom);

        await playRoom.player0?.socket.close();

        await playRoom.player1?.socket.close();

        await Tokensservice.instance.change_token_status(playRoom.player0!.Id);
      }, onError: (e) {
        playRoom.player0?.socket.close();
      });
    } catch (e) {
      if (playRoom.player1 != null) {
        delete_room(playRoom);
      }

      print("Cannot listen to player");
    }
  }

  static listen_to_player1(Play_room playRoom) {
    int x0 = 0, x1 = 0;
    try {
      playRoom.player1?.socket.listen(
        (event) async {
          if (playRoom.hand == 1) {
            event as String;
            if (event.length > 3) {
              throw Exception();
            }

            try {
              x0 = int.parse(event[0]);
              x1 = int.parse(event[2]);

              playRoom.Grid[x0][x1] = 'O';

              if (checkWin(play_room: playRoom) == 'O') {
                sendDataTo("You won", playRoom, playRoom.player1!.socket);
                sendDataTo("You Lost", playRoom, playRoom.player0!.socket);
                playRoom.player1?.socket.close(null, "won");
              } else {
                playRoom.hand = 0;
                print("player0 turn");

                sendDataToboth(null, playRoom);
              }
            } catch (e) {
              if (playRoom.player0 != null && playRoom.player1 != null) {
                sendDataTo("You won", playRoom, playRoom.player0!.socket);
                sendDataTo("You Lost", playRoom, playRoom.player1!.socket);
              }

              playRoom.hand = 0;

              playRoom.player1?.socket.close();
            }
          }
        },
        onError: (e) {
          playRoom.player1!.socket.close();
          print("Error");
        },
        cancelOnError: true,
        onDone: () async {
          playRoom.opened = false;
          await playRoom.player1?.socket.close();
          await playRoom.player0?.socket.close();

          await Tokensservice.instance
              .change_token_status(playRoom.player1!.Id);
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
      listen_to_player1(playRoom);
    } catch (e) {
      await playRoom.player0?.socket.close();
      await playRoom.player1?.socket.close();
      print("cannnot contact player socket");
    }
  }

  static sendDataToboth(String? message, Play_room playRoom) {
    if (message != null) {
      if (playRoom.hand != null) {
        playRoom.player0?.socket.add(json.encode({
          "message": message,
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
          "message": message,
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
      }
    } else {
      if (playRoom.hand != null) {
        playRoom.player0?.socket.add(json.encode({
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
          "hand": "${playRoom.hand}",
        }));
      }
    }
  }

  static sendDataTo(
      String? message, Play_room playRoom, WebSocket playersocket) {
    if (message != null) {
      playersocket.add(json.encode({
        "message": message,
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
      }));
    }
  }
}
