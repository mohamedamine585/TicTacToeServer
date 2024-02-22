import 'package:mongo_dart/mongo_dart.dart';

class Player {
  final ObjectId Id;
  final String playername;
  final Timestamp? lastconnection;
  int playedGames = 0;
  int WonGames = 0;

  Player(this.Id, this.playername, this.lastconnection, this.playedGames,
      this.WonGames);
}
