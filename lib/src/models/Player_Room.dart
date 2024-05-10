import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/handlers/RoomManagerController.dart';

import 'Player_token.dart';

class Play_room {
  bool opened = false;
  int id;
  ObjectId? roomid;
  bool gameWithaFriend = false;
  List<List<String?>> Grid = [
    [null, null, null],
    [null, null, null],
    [null, null, null],
  ];

  int? hand;
  Player_Socket? player0;
  Player_Socket? player1;
  Future? timeout;
  Play_room(this.id, this.roomid, this.player0, this.player1, this.hand,
      this.gameWithaFriend, this.opened) {
    timeout = Future.delayed(Duration(seconds: 30), (() {
      if (player0 == null && player1 == null) {
        RoomManagerController.delete_room(this);
      }
    }));
  }
}
