import 'dart:convert';
import 'dart:io';

import '../../Core/Modules/Player_Room.dart';
import '../../Core/Modules/Player_token.dart';
import '../../Core/Repositories/Playroom_repo.dart';
import '../../Data/Services/PlayRoomService.dart';
import '../../Data/Services/Tokensservice.dart';
import '../Controllers/Gameservercontroller.dart';
import '../utils.dart';

class Play_room_repo_impl implements Play_room_repository {
  @override
  Play_room play_room;
  Play_room_repo_impl(this.play_room);
  own_that_room(HttpRequest game_request, String ptoken) async {
    try {
      try {
        play_room.player0 = Player_Token(
            await WebSocketTransformer.upgrade(game_request), ptoken);
      } catch (e) {
        print("cannot upgrade player request !");
      }

      play_room.hand = 0;
      play_room.opened = true;
      try {
        play_room.player0?.socket.add(json.encode({"message": "Room owned"}));
        listen_to_player0();
      } catch (e) {
        print("cannot open socket !");
        close_room();
      }
    } catch (e) {
      print(e);
    }
  }

  disconnect_players() async {
    play_room.player0?.socket.close();
    play_room.player1?.socket.close();
  }

  listen_to_player0() {
    try {
      play_room.player0?.socket.listen(
        (event) async {
          if (play_room.hand == 0) {
            event as String;

            play_room.Grid[int.parse(event[0])][int.parse(event[2])] = 'X';

            if (checkWin(play_room) == 'X') {
              declareWinner();
              await PlayRoomService.getInstance()
                  .close_PlayRoom(play_room: play_room);
              play_room.player0?.socket.close(null, "won");
            } else {
              play_room.hand = 1;
              print("player1 turn");

              sendDataToboth(null);
            }
          }
        },
        onDone: () async {
          if (play_room.opened) {
            play_room.player0?.socket.close();

            await Tokensservice.getInstance()
                .change_token_status(play_room.player0!.token);
            if (play_room.player1 != null) {
              await Tokensservice.getInstance()
                  .change_token_status(play_room.player1!.token);

              play_room.player1?.socket.close();
            }
            if (checkWin(play_room) == null) {
              play_room.hand = null;
              await PlayRoomService.getInstance()
                  .close_PlayRoom(play_room: play_room);
            }
            close_room();
          }
        },
      );
    } catch (e) {
      close_room();
      print("Cannot listen to player");
    }
  }

  listen_to_player1() {
    try {
      play_room.player1?.socket.listen(
        (event) async {
          if (play_room.hand == 1) {
            event as String;

            play_room.Grid[int.parse(event[0])][int.parse(event[2])] = 'O';

            if (checkWin(play_room) == 'O') {
              declareWinner();
              await PlayRoomService.getInstance()
                  .close_PlayRoom(play_room: play_room);
              play_room.player1?.socket.close(null, "won");
            } else {
              play_room.hand = 0;
              print("player0 turn");

              sendDataToboth(null);
            }
          }
        },
        onDone: () async {
          if (play_room.opened) {
            play_room.player1?.socket.close();

            await Tokensservice.getInstance()
                .change_token_status(play_room.player1!.token);
            if (play_room.player0 != null) {
              await Tokensservice.getInstance()
                  .change_token_status(play_room.player0!.token);

              play_room.player0?.socket.close();
            }

            if (checkWin(play_room) == null) {
              play_room.hand = null;
              await PlayRoomService.getInstance()
                  .close_PlayRoom(play_room: play_room);
            }
            close_room();
          }
        },
      );
    } catch (e) {
      close_room();
      print("Cannot listen to player");
    }
  }

  join_room(HttpRequest player_req, String token) async {
    try {
      play_room.player1 =
          Player_Token(await WebSocketTransformer.upgrade(player_req), token);
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

    Play();
  }

  /// start a game in a room ***********

  Play() {
    try {
      listen_to_player1();
    } catch (e) {
      print("error socket !");
    }
  }

  close_room() {
    play_room.opened = false;
    play_room.Grid = [
      [null, null, null],
      [null, null, null],
      [null, null, null],
    ];
    play_room.player0 = null;
    play_room.player1 = null;
    Gameserver_controller.delete_room(play_room.id);
  }

  declareWinner() {
    sendDataToboth("Player ${play_room.hand} is The Winner");
  }

  sendDataToboth(String? message) {
    if (message != null) {
      if (play_room.hand != null) {
        play_room.player0?.socket.add(json.encode({
          "message": message,
          "playroom.Grid":
              "${play_room.Grid[0][0]},${play_room.Grid[1][0]},${play_room.Grid[2][0]},${play_room.Grid[0][1]},${play_room.Grid[1][1]},${play_room.Grid[1][2]},${play_room.Grid[0][2]},${play_room.Grid[1][2]},${play_room.Grid[2][2]},",
          "play_room.hand": "${play_room.hand}"
        }));

        play_room.player1?.socket.add(json.encode({
          "message": message,
          "playroom.Grid":
              "${play_room.Grid[0][0]},${play_room.Grid[1][0]},${play_room.Grid[2][0]},${play_room.Grid[0][1]},${play_room.Grid[1][1]},${play_room.Grid[1][2]},${play_room.Grid[0][2]},${play_room.Grid[1][2]},${play_room.Grid[2][2]},",
          "play_room.hand": "${play_room.hand}"
        }));
      }
    } else {
      if (play_room.hand != null) {
        play_room.player0?.socket.add(json.encode({
          "playroom.Grid":
              "${play_room.Grid[0][0]},${play_room.Grid[1][0]},${play_room.Grid[2][0]},${play_room.Grid[0][1]},${play_room.Grid[1][1]},${play_room.Grid[1][2]},${play_room.Grid[0][2]},${play_room.Grid[1][2]},${play_room.Grid[2][2]},",
          "play_room.hand": "${play_room.hand}"
        }));

        play_room.player1?.socket.add(json.encode({
          "playroom.Grid":
              "${play_room.Grid[0][0]},${play_room.Grid[1][0]},${play_room.Grid[2][0]},${play_room.Grid[0][1]},${play_room.Grid[1][1]},${play_room.Grid[1][2]},${play_room.Grid[0][2]},${play_room.Grid[1][2]},${play_room.Grid[2][2]},",
          "play_room.hand": "${play_room.hand}",
        }));
      }
    }
  }
}
