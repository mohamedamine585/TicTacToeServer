import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';

import '../Services/PlayRoomService.dart';
import '../Services/Tokensservice.dart';
import 'Player_token.dart';

class Play_room {
  bool opened = true;
  int id;
  ObjectId? roomid;
  List<List<String?>> Grid = [
    [null, null, null],
    [null, null, null],
    [null, null, null],
  ];

  int? hand = 0;
  Player_Token? player0;
  Player_Token? player1;
  Play_room(this.id, this.player0, this.player1);
  own_that_room(HttpRequest game_request, String ptoken) async {
    try {
      player0 = Player_Token(
          await WebSocketTransformer.upgrade(game_request), ptoken);
      hand = 0;
      opened = true;
      player0?.socket.add(json.encode({"message": "Room Owned"}));
      listen_to_player0();
    } catch (e) {
      print(e);
    }
  }

  listen_to_player0() {
    player0?.socket.listen(
      (event) async {
        if (hand == 0) {
          event as String;

          Grid[int.parse(event[0])][int.parse(event[2])] = 'X';

          if (checkWin() == 'X') {
            declareWinner(hand!);
            await PlayRoomService.getInstance()
                .close_PlayRoom(play_room: this, id: roomid!);
            player0?.socket.close(null, "won");
          } else {
            hand = 1;
            print("player1 turn");

            sendDataToboth(null);
          }
        }
      },
      onDone: () async {
        if (opened) {
          player0?.socket.close();

          await Tokensservice.getInstance().change_token_status(player0!.token);
          if (player1 != null) {
            await Tokensservice.getInstance()
                .change_token_status(player1!.token);

            player1?.socket.close();
          }
          close_room();
        }
      },
    );
  }

  listen_to_player1() {
    player1?.socket.listen(
      (event) async {
        if (hand == 1) {
          event as String;

          Grid[int.parse(event[0])][int.parse(event[2])] = 'O';

          if (checkWin() == 'O') {
            declareWinner(hand!);
            await PlayRoomService.getInstance()
                .close_PlayRoom(play_room: this, id: roomid!);
            player1?.socket.close(null, "won");
          } else {
            hand = 0;
            print("player0 turn");

            sendDataToboth(null);
          }
        }
      },
      onDone: () async {
        if (opened) {
          player1?.socket.close();

          await Tokensservice.getInstance().change_token_status(player1!.token);
          if (player0 != null) {
            await Tokensservice.getInstance()
                .change_token_status(player0!.token);

            player0?.socket.close();
          }
          close_room();
        }
      },
    );
  }

  join_room(HttpRequest player_req, String token) async {
    player1 =
        Player_Token(await WebSocketTransformer.upgrade(player_req), token);
    player0?.socket.add(json.encode({
      "message": "Opponent found !",
      "Grid":
          "${Grid[0][0]},${Grid[1][0]},${Grid[2][0]},${Grid[0][1]},${Grid[1][1]},${Grid[1][2]},${Grid[0][2]},${Grid[1][2]},${Grid[2][2]},",
      "hand": "${hand}"
    }));

    player1?.socket.add(json.encode({
      "message": "Opponent found !",
      "Grid":
          "${Grid[0][0]},${Grid[1][0]},${Grid[2][0]},${Grid[0][1]},${Grid[1][1]},${Grid[1][2]},${Grid[0][2]},${Grid[1][2]},${Grid[2][2]},",
      "hand": "${hand}"
    }));

    roomid = await PlayRoomService.getInstance().open_PlayRoom(play_room: this);

    Play();
  }

  /// start a game in a room ***********

  Play() {
    listen_to_player1();
  }

  close_room() {
    opened = false;
    Grid = [
      [null, null, null],
      [null, null, null],
      [null, null, null],
    ];
    player0 = null;
    player1 = null;
  }

  declareWinner(int? hand) {
    sendDataToboth("Player $hand is The Winner");
  }

  String? checkWin() {
    bool checkRowColDiagonal(String a, String b, String c) {
      return a == b && b == c && a != ".";
    }

    // Check rows
    for (int row = 0; row < 3; row++) {
      if (checkRowColDiagonal(
          Grid[row][0] ?? "", Grid[row][1] ?? "", Grid[row][2] ?? "")) {
        return Grid[row][0] ?? "";
      }
    }

    // Check columns
    for (int col = 0; col < 3; col++) {
      if (checkRowColDiagonal(
          Grid[0][col] ?? "", Grid[1][col] ?? "", Grid[2][col] ?? "")) {
        return Grid[0][col] ?? "";
      }
    }

    // Check diagonals
    if (checkRowColDiagonal(
        Grid[0][0] ?? "", Grid[1][1] ?? "", Grid[2][2] ?? "")) {
      return Grid[0][0] ?? "";
    }
    if (checkRowColDiagonal(
        Grid[0][2] ?? "", Grid[1][1] ?? "", Grid[2][0] ?? "")) {
      return Grid[0][2] ?? "";
    }

    return null; // Return null if no winner
  }

  sendDataToboth(String? message) {
    if (message != null) {
      if (hand != null) {
        player0?.socket.add(json.encode({
          "message": message,
          "Grid":
              "${Grid[0][0]},${Grid[1][0]},${Grid[2][0]},${Grid[0][1]},${Grid[1][1]},${Grid[1][2]},${Grid[0][2]},${Grid[1][2]},${Grid[2][2]},",
          "hand": "${hand}"
        }));

        player1?.socket.add(json.encode({
          "message": message,
          "Grid":
              "${Grid[0][0]},${Grid[1][0]},${Grid[2][0]},${Grid[0][1]},${Grid[1][1]},${Grid[1][2]},${Grid[0][2]},${Grid[1][2]},${Grid[2][2]},",
          "hand": "${hand}"
        }));
      }
    } else {
      if (hand != null) {
        player0?.socket.add(json.encode({
          "Grid":
              "${Grid[0][0]},${Grid[1][0]},${Grid[2][0]},${Grid[0][1]},${Grid[1][1]},${Grid[1][2]},${Grid[0][2]},${Grid[1][2]},${Grid[2][2]},",
          "hand": "${hand}"
        }));

        player1?.socket.add(json.encode({
          "Grid":
              "${Grid[0][0]},${Grid[1][0]},${Grid[2][0]},${Grid[0][1]},${Grid[1][1]},${Grid[1][2]},${Grid[0][2]},${Grid[1][2]},${Grid[2][2]},",
          "hand": "${hand}",
        }));
      }
    }
  }
}

// Implement your logic to find and pair users, then create and manage rooms
