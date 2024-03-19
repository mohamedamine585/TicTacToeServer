import 'package:mongo_dart/mongo_dart.dart';

class Player {
  final ObjectId Id;
  final String playername;
  final String email;
  final DateTime? lastconnection;
  int playedGames = 0;
  int score;
  int WonGames = 0;

  Player(this.Id, this.playername, this.email, this.lastconnection,
      this.playedGames, this.WonGames, this.score);
}
