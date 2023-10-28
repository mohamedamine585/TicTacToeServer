import 'package:mongo_dart/mongo_dart.dart';

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
}

// Implement your logic to find and pair users, then create and manage rooms
