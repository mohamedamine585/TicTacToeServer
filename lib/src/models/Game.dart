import 'package:mongo_dart/mongo_dart.dart';

class Game {
  final ObjectId id;
  final String player1id;
  final String player0id;
  final Timestamp startTime;
  final Timestamp endTime;
  final int winner;

  Game(this.id, this.player1id, this.player0id, this.startTime, this.endTime,
      this.winner);
}
