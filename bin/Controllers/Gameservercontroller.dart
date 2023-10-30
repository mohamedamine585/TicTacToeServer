import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';

import '../Core/Modules/Player_Room.dart';
import '../Data/Services/PlayRoomService.dart';
import '../Data/Services/Tokensservice.dart';
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
    final available_room = look_for_available_play_room();
    if (available_room == null) {
      await create_room(preq, id);
    } else {
      await join_room(preq, id, available_room);
      listen_to_player1(available_room);
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

  static delete_room(Play_room play_room) async {
    Play_room_repo_impl(play_room).close_room();

    for (int ids = play_room.id + 1; ids < GameServer.rooms.length; ids++) {
      GameServer.rooms[ids].id = ids--;
    }
    GameServer.rooms.remove(play_room);
  }

  Play(Play_room play_room) async {
    try {
      await Tokensservice.getInstance()
          .change_token_status(play_room.player0!.Id);
    } catch (e) {
      print("error socket !");
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
      listen_to_player0(play_room);
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

  static DealWithRequest(HttpRequest play_request) async {
    String? playerid;
    try {
      playerid = await Tokenmiddleware.Check_Token(
          play_request.headers.value("token"));
    } catch (e) {
      print(e);
    }

    if (playerid != null) {
      if (WebSocketTransformer.isUpgradeRequest(play_request)) {
        await Gameserver_controller.Pairing(
            play_request, ObjectId.parse(playerid));
      } else {
        play_request.response.close();
      }
    } else {
      play_request.response.write(json.encode({"message": "Invalid token"}));
      play_request.response.close();
    }
  }

  static listen_to_player0(Play_room play_room) {
    try {
      play_room.player0?.socket.listen(
        (event) async {
          if (play_room.hand == 0) {
            event as String;

            play_room.Grid[int.parse(event[0])][int.parse(event[2])] = 'X';

            if (checkWin(play_room) == 'X') {
              sendDataToboth(
                  "Player ${play_room.hand} is The Winner", play_room);

              play_room.player0?.socket.close(null, "won");
            } else {
              play_room.hand = 1;
              print("player1 turn");

              sendDataToboth(null, play_room);
            }
          }
        },
        onDone: () async {
          if (play_room.opened) {
            play_room.player0?.socket.close();

            await Tokensservice.getInstance()
                .change_token_status(play_room.player0!.Id);
            if (play_room.player1 != null) {
              await Tokensservice.getInstance()
                  .change_token_status(play_room.player1!.Id);

              play_room.player1?.socket.close();
              if (checkWin(play_room) == null) {
                play_room.hand = null;
              }
            }
            delete_room(play_room);
          }
        },
      );
    } catch (e) {
      if (play_room.player1 != null) {
        delete_room(play_room);
      }

      print("Cannot listen to player");
    }
  }

  static listen_to_player1(Play_room play_room) {
    try {
      play_room.hand = 0;
      play_room.player1?.socket.listen(
        (event) async {
          if (play_room.hand == 1) {
            event as String;

            play_room.Grid[int.parse(event[0])][int.parse(event[2])] = 'O';

            if (checkWin(play_room) == 'O') {
              sendDataToboth(
                  "Player ${play_room.hand} is The Winner", play_room);
              play_room.player1?.socket.close(null, "won");
            } else {
              play_room.hand = 0;
              print("player0 turn");

              sendDataToboth(null, play_room);
            }
          }
        },
        onDone: () async {
          if (play_room.opened) {
            play_room.player1?.socket.close();

            await Tokensservice.getInstance()
                .change_token_status(play_room.player1!.Id);
            if (play_room.player0 != null) {
              await Tokensservice.getInstance()
                  .change_token_status(play_room.player0!.Id);

              play_room.player0?.socket.close();
            }

            if (checkWin(play_room) == null) {
              play_room.hand = null;
            }
          }
          delete_room(play_room);
        },
      );
    } catch (e) {
      delete_room(play_room);
      print("Cannot listen to player");
    }
  }

  static join_room(
      HttpRequest player_req, ObjectId id, Play_room play_room) async {
    try {
      play_room.player1 =
          Player_Socket(await WebSocketTransformer.upgrade(player_req), id);
    } catch (e) {
      print("cannot upgrade request !");
    }
    try {
      play_room.player0?.socket.add(json.encode({
        "message": "Opponent found !",
        "playroom.Grid":
            "${play_room.Grid[0][0]},${play_room.Grid[1][0]},${play_room.Grid[2][0]},${play_room.Grid[0][1]},${play_room.Grid[1][1]},${play_room.Grid[1][2]},${play_room.Grid[0][2]},${play_room.Grid[1][2]},${play_room.Grid[2][2]},",
        "play_room.hand": "${play_room.hand}"
      }));

      play_room.player1?.socket.add(json.encode({
        "message": "Opponent found !",
        "playroom.Grid":
            "${play_room.Grid[0][0]},${play_room.Grid[1][0]},${play_room.Grid[2][0]},${play_room.Grid[0][1]},${play_room.Grid[1][1]},${play_room.Grid[1][2]},${play_room.Grid[0][2]},${play_room.Grid[1][2]},${play_room.Grid[2][2]},",
        "play_room.hand": "${play_room.hand}"
      }));
    } catch (e) {
      print("cannnot contact player socket");
    }

    play_room.roomid =
        await PlayRoomService.getInstance().open_PlayRoom(play_room: play_room);
  }

  static sendDataToboth(String? message, Play_room play_room) {
    if (message != null) {
      if (play_room.hand != null) {
        play_room.player0?.socket.add(json.encode({
          "message": message,
          "Grid":
              "${play_room.Grid[0][0]},${play_room.Grid[1][0]},${play_room.Grid[2][0]},${play_room.Grid[0][1]},${play_room.Grid[1][1]},${play_room.Grid[1][2]},${play_room.Grid[0][2]},${play_room.Grid[1][2]},${play_room.Grid[2][2]},",
          "hand": "${play_room.hand}"
        }));

        play_room.player1?.socket.add(json.encode({
          "message": message,
          "Grid":
              "${play_room.Grid[0][0]},${play_room.Grid[1][0]},${play_room.Grid[2][0]},${play_room.Grid[0][1]},${play_room.Grid[1][1]},${play_room.Grid[1][2]},${play_room.Grid[0][2]},${play_room.Grid[1][2]},${play_room.Grid[2][2]},",
          "hand": "${play_room.hand}"
        }));
      }
    } else {
      if (play_room.hand != null) {
        play_room.player0?.socket.add(json.encode({
          "Grid":
              "${play_room.Grid[0][0]},${play_room.Grid[1][0]},${play_room.Grid[2][0]},${play_room.Grid[0][1]},${play_room.Grid[1][1]},${play_room.Grid[1][2]},${play_room.Grid[0][2]},${play_room.Grid[1][2]},${play_room.Grid[2][2]},",
          "hand": "${play_room.hand}"
        }));

        play_room.player1?.socket.add(json.encode({
          "Grid":
              "${play_room.Grid[0][0]},${play_room.Grid[1][0]},${play_room.Grid[2][0]},${play_room.Grid[0][1]},${play_room.Grid[1][1]},${play_room.Grid[1][2]},${play_room.Grid[0][2]},${play_room.Grid[1][2]},${play_room.Grid[2][2]},",
          "hand": "${play_room.hand}",
        }));
      }
    }
  }
}
