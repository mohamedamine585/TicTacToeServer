import 'dart:convert';
import 'dart:io';

import '../../Data/Services/PlayRoomService.dart';
import '../../Data/Services/Tokensservice.dart';
import '../../Servers/Gameserver/Services.dart';
import '../Modules/Player.dart';
import '../Modules/Player_Room.dart';
import '../Modules/Player_token.dart';

own_that_room(
    HttpRequest game_request, String ptoken, Play_room play_room) async {
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
      listen_to_player0(play_room);
    } catch (e) {
      print("cannot open socket !");
      close_room(play_room);
    }
  } catch (e) {
    print(e);
  }
}

diconnect_players(
    Player_Token? player0, Player_Token? player1, Play_room play_room) async {
  player0?.socket.close();
  player1?.socket.close();
}

listen_to_player0(Play_room play_room) {
  try {
    play_room.player0?.socket.listen(
      (event) async {
        if (play_room.hand == 0) {
          event as String;

          play_room.Grid[int.parse(event[0])][int.parse(event[2])] = 'X';

          if (checkWin(play_room) == 'X') {
            declareWinner(play_room);
            await PlayRoomService.getInstance()
                .close_PlayRoom(play_room: play_room);
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
          close_room(play_room);
        }
      },
    );
  } catch (e) {
    close_room(play_room);
    print("Cannot listen to player");
  }
}

listen_to_player1(Play_room play_room) {
  try {
    play_room.player1?.socket.listen(
      (event) async {
        if (play_room.hand == 1) {
          event as String;

          play_room.Grid[int.parse(event[0])][int.parse(event[2])] = 'O';

          if (checkWin(play_room) == 'O') {
            declareWinner(play_room);
            await PlayRoomService.getInstance()
                .close_PlayRoom(play_room: play_room);
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
          close_room(play_room);
        }
      },
    );
  } catch (e) {
    close_room(play_room);
    print("Cannot listen to player");
  }
}

join_room(HttpRequest player_req, String token, Play_room play_room) async {
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

  Play(play_room);
}

/// start a game in a room ***********

Play(Play_room play_room) {
  try {
    listen_to_player1(play_room);
  } catch (e) {
    print("error socket !");
  }
}

close_room(Play_room play_room) {
  play_room.opened = false;
  play_room.Grid = [
    [null, null, null],
    [null, null, null],
    [null, null, null],
  ];
  play_room.player0 = null;
  play_room.player1 = null;
  delete_room(play_room.id);
}

declareWinner(Play_room play_room) {
  sendDataToboth("Player ${play_room.hand} is The Winner", play_room);
}

String? checkWin(Play_room play_room) {
  bool checkRowColDiagonal(String a, String b, String c) {
    return a == b && b == c && a != ".";
  }

  // Check rows
  for (int row = 0; row < 3; row++) {
    if (checkRowColDiagonal(play_room.Grid[row][0] ?? "",
        play_room.Grid[row][1] ?? "", play_room.Grid[row][2] ?? "")) {
      return play_room.Grid[row][0] ?? "";
    }
  }

  // Check columns
  for (int col = 0; col < 3; col++) {
    if (checkRowColDiagonal(play_room.Grid[0][col] ?? "",
        play_room.Grid[1][col] ?? "", play_room.Grid[2][col] ?? "")) {
      return play_room.Grid[0][col] ?? "";
    }
  }

  // Check diagonals
  if (checkRowColDiagonal(play_room.Grid[0][0] ?? "",
      play_room.Grid[1][1] ?? "", play_room.Grid[2][2] ?? "")) {
    return play_room.Grid[0][0] ?? "";
  }
  if (checkRowColDiagonal(play_room.Grid[0][2] ?? "",
      play_room.Grid[1][1] ?? "", play_room.Grid[2][0] ?? "")) {
    return play_room.Grid[0][2] ?? "";
  }

  return null; // Return null if no winner
}

sendDataToboth(String? message, Play_room play_room) {
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
