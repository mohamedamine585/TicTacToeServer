import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/Controllers/utils.dart';
import 'package:tic_tac_toe_server/middleware/gamemiddleware.dart';
import 'package:tic_tac_toe_server/middleware/requestmiddleware.dart';

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

  static Pairing(HttpRequest preq, ObjectId? roomid, ObjectId id) async {
    final availableRoom = look_for_available_play_room(roomid);

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

  static Play_room? look_for_available_play_room(ObjectId? roomid) {
    for (Play_room room in GameServer.rooms) {
      if (!room.opened && (roomid != null) ? room.roomid == roomid : true) {
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

        if (playRoom.player0 != null && playRoom.player1 != null) {
          print(playRoom.player0?.Id);
          print(playRoom.player1?.Id);
          await PlayRoomService.instance.close_PlayRoom(play_room: playRoom);
        }
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

  static Router(HttpRequest request) async {
    String? playerid;
    try {
      playerid =
          Tokenmiddleware.Check_Token(request.headers.value("Authorization"));
      if (playerid != null) {
        switch (request.requestedUri.path) {
          case "/":
            final roomid =
                await GameMiddleware.checkforSepecificRoom(request: request);

            await MakeHimPlay(request, roomid, playerid);

            break;
          case "/player":
            if (request.method == "GET") {
              request.response.write(json
                  .encode(await PlayRoomService.instance.getdoc(id: playerid)));
            } else if (request.method == "PUT") {
              final reqBody = await Requestmiddleware.checkbodyForPlayerupdate(
                  request: request);
              if (reqBody != null) {
                final updateddoc = await PlayRoomService.instance
                    .updatePlayer(playerupdate: reqBody, id: playerid);
                if (updateddoc != null) {
                  request.response
                      .write(json.encode({"message": "Player Updated"}));
                }
              }
            } else if (request.method == "DELETE") {
            } else if (request.method == "POST") {}
            break;
          case "/games":
            break;
          default:
        }
      } else {
        request.response.statusCode == HttpStatus.unauthorized;
        request.response.write(json.encode({"message": "Invalid token"}));
      }
      await request.response.close();
    } catch (e) {
      print(e);
    }
  }

  static MakeHimPlay(
      HttpRequest playRequest, ObjectId? roomid, String? playerid) async {
    if (playerid != null) {
      if (WebSocketTransformer.isUpgradeRequest(playRequest)) {
        await Gameserver_controller.Pairing(
            playRequest, roomid, ObjectId.parse(playerid));
      } else {
        playRequest.response.close();
      }
    } else {
      playRequest.response.write(json.encode({"message": "Invalid token"}));
      playRequest.response.close();
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
