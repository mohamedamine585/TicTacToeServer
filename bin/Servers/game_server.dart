import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../Modules/Player.dart';
import '../Modules/Player_token.dart';
import '../Services/Tokensservice.dart';

class GameServer {
  static var rooms = <Play_room>[];
  static late HttpServer server;
  static List<Player> players = [];

  /// ****     initialize server on localhost *****

  static Future<void> init() async {
    server = await HttpServer.bind(InternetAddress("127.0.0.1"), 8080);
    print(
        "Game server is running on ${server.address.address} port ${server.port}");
  }

  static serve() async {
    await init();
    server.listen((HttpRequest play_request) async {
      final playertoken = (await Tokensservice.getInstance()
          .fetch_token(token: play_request.headers.value("token") ?? ""));
      if (playertoken != null) {
        if (WebSocketTransformer.isUpgradeRequest(play_request)) {
          await Pairing(play_request, playertoken);
        } else {
          play_request.response.close();
        }
      } else {
        play_request.response.write(json.encode({"message": "Invalid token"}));
        play_request.response.close();
      }
    });
  }

  /// **********          Pairing a player to another or create a room for him *******
  ///
  ///
  ///

  static Pairing(HttpRequest preq, String ptoken) async {
    final available_room = look_for_available_play_room();
    final closed_r = look_for_available_play_room();
    if (available_room == null) {
      if (closed_r == null) {
        await create_room(preq, ptoken);
      } else {
        await closed_r.own_that_room(preq, ptoken);
      }
    } else {
      await available_room.join_room(preq, ptoken);
    }
  }

  static Play_room? look_for_closed_room() {
    for (Play_room room in rooms) {
      if (!room.opened) {
        return room;
      }
    }
  }

  static Play_room? look_for_available_play_room() {
    for (Play_room room in rooms) {
      if (room.player0 != null && room.opened) {
        return room;
      }
    }
  }

  static delete_room(int id) {
    if (rooms.length > id) {
      rooms.removeAt(id);
    }
  }

  static create_room(HttpRequest game_request, String ptoken) async {
    final Socket_to_player = await WebSocketTransformer.upgrade(game_request);
    Play_room play_room =
        Play_room(rooms.length, Player_Token(Socket_to_player, ptoken), null);
    rooms.add(play_room);

    Socket_to_player.add(json.encode({"message": "Room created"}));
    play_room.listen_to_player0();
  }

  static Play_room? seek_player_room(WebSocket player_sock) {
    for (Play_room room in rooms) {
      if (room.player0 == player_sock || room.player1 == player_sock) {
        return room;
      }
    }
  }
}

class Play_room {
  bool opened = true;
  int id;
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

      player0?.socket.add(json.encode({"message": "Room created"}));
      listen_to_player0();
    } catch (e) {
      print(e);
    }
  }

  listen_to_player0() async {
    player0?.socket.listen(
      (event) {
        if (hand == 0) {
          event as String;

          Grid[int.parse(event[0])][int.parse(event[2])] = 'X';

          if (checkWin() == 'X') {
            declareWinner(hand!);

            hand = null;
            close_room();
          } else {
            hand = 1;
          }
          print("player1 turn");

          sendDataToboth(null);
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

  listen_to_player1() async {
    player1?.socket.listen(
      (event) {
        if (hand == 1) {
          event as String;

          Grid[int.parse(event[0])][int.parse(event[2])] = 'X';

          if (checkWin() == 'O') {
            declareWinner(hand!);
            player0?.socket.close();
            player1?.socket.close();
            hand = null;
          } else {
            hand = 0;
          }
          print("player0 turn");

          sendDataToboth(null);
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
      "message": "opponent found !",
      "Grid":
          "${Grid[0][0]},${Grid[1][0]},${Grid[2][0]},${Grid[0][1]},${Grid[1][1]},${Grid[1][2]},${Grid[0][2]},${Grid[1][2]},${Grid[2][2]},",
      "hand": "${hand}"
    }));

    player1?.socket.add(json.encode({
      "message": "opponent found !",
      "Grid":
          "${Grid[0][0]},${Grid[1][0]},${Grid[2][0]},${Grid[0][1]},${Grid[1][1]},${Grid[1][2]},${Grid[0][2]},${Grid[1][2]},${Grid[2][2]},",
      "hand": "${hand}"
    }));

    Play();
  }

  /// start a game in a room ***********

  Play() {
    listen_to_player1();
  }

  close_room() {
    opened = false;
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
