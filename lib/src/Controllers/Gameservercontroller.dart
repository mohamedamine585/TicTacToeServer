import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/controllers/RoomManagerController.dart';
import 'package:tic_tac_toe_server/src/controllers/utils.dart';
import 'package:tic_tac_toe_server/src/models/Player.dart';
import 'package:tic_tac_toe_server/src/models/Player_Room.dart';
import 'package:tic_tac_toe_server/src/services/Tokensservice.dart';

class Gameserver_controller {
  static var rooms = <Play_room>[];
  static List<Player> players = [];
  static init_tokens_state() async {
    await Tokensservice.instance.make_available_all_tokens();
  }

  Play(Play_room playRoom) async {
    try {
      await Tokensservice.instance.change_token_status(playRoom.player0!.Id);
    } catch (e) {
      print("error socket !");
    }
  }

  static MakeHimPlay(
      HttpRequest playRequest, ObjectId? roomid, String? playerid) async {
    if (playerid != null) {
      if (WebSocketTransformer.isUpgradeRequest(playRequest)) {
        await RoomManagerController.Pairing(
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

            if (checkWin(Grid: playRoom.Grid) == 'X') {
              sendDataTo("You won", playRoom, playRoom.player0!.socket, null);
              sendDataTo("You Lost", playRoom, playRoom.player1!.socket, null);

              // save that player 0 won
              playRoom.hand = 2;

              playRoom.player0?.socket.close(null, "won");
            } else {
              playRoom.hand = 1;
              print("player1 turn");

              sendDataToboth(null, playRoom);
            }
          }
        } catch (e) {
          if (playRoom.player1 != null && playRoom.player0 != null) {
            sendDataTo("You won", playRoom, playRoom.player1!.socket, null);
            sendDataTo("You Lost", playRoom, playRoom.player0!.socket, null);
          }

          playRoom.hand = 1;
          await playRoom.player0?.socket.close();
        }
      }, onDone: () async {
        if (playRoom.hand != 3 && playRoom.hand != 2) {
          playRoom.hand = 1;
          if (playRoom.player1?.socket.closeCode == null) {
            sendDataTo("Connection Lost You Won", playRoom,
                playRoom.player1!.socket, playRoom.roomid?.toHexString());
          }
        }

        await RoomManagerController.delete_room(playRoom);

        await playRoom.player0?.socket.close();

        await playRoom.player1?.socket.close();
      }, onError: (e) {
        playRoom.player0?.socket.close();
      });
    } catch (e) {
      if (playRoom.player1 != null) {
        RoomManagerController.delete_room(playRoom);
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

              if (checkWin(Grid: playRoom.Grid) == 'O') {
                sendDataTo("You won", playRoom, playRoom.player1!.socket, null);
                sendDataTo(
                    "You Lost", playRoom, playRoom.player0!.socket, null);
                playRoom.hand = 3;
                playRoom.player1?.socket.close(null, "won");
              } else {
                playRoom.hand = 0;
                print("player0 turn");

                sendDataToboth(null, playRoom);
              }
            } catch (e) {
              if (playRoom.player0 != null && playRoom.player1 != null) {
                sendDataTo("You won", playRoom, playRoom.player0!.socket, null);
                sendDataTo(
                    "You Lost", playRoom, playRoom.player1!.socket, null);
              }

              playRoom.player1?.socket.close();
            }
          }
        },
        onError: (e) {
          playRoom.player1!.socket.close();
          print("Error");
        },
        onDone: () async {
          if (playRoom.hand != 3 && playRoom.hand != 2) {
            playRoom.hand = 0;
            if (playRoom.player0?.socket.closeCode == null) {
              sendDataTo("Connection Lost You Won", playRoom,
                  playRoom.player0!.socket, playRoom.roomid?.toHexString());
            }
          }
          await playRoom.player1?.socket.close();
          await playRoom.player0?.socket.close();
        },
      );
    } catch (e) {
      RoomManagerController.delete_room(playRoom);
      print("Cannot listen to player");
    }
  }

  static sendDataToboth(String? message, Play_room playRoom) {
    if (message != null) {
      if (playRoom.hand != null) {
        playRoom.player0?.socket.add(json.encode({
          "message": message,
          "grid": [
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
          "grid": [
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
          "grid": [
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
          "grid": [
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

  static sendDataTo(String? message, Play_room playRoom, WebSocket playersocket,
      String? roomid) {
    if (message != null) {
      playersocket.add(json.encode({
        "message": message,
        "grid": [
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
        "roomid": roomid
      }));
    }
  }
}
