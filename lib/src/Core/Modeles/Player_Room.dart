import 'package:mongo_dart/mongo_dart.dart';

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
  Play_room(this.id, this.roomid, this.player0, this.player1, this.hand,
      this.gameWithaFriend);
}

// Implement your logic to find and pair users, then create and manage rooms
