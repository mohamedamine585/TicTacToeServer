import 'package:mongo_dart/mongo_dart.dart';

import 'Player.dart';
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

  int? hand;
  Player_Socket? player0;
  Player_Socket? player1;
  Play_room(this.id, this.player0, this.player1, this.hand);
}

// Implement your logic to find and pair users, then create and manage rooms
