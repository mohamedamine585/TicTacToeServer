import 'package:mongo_dart/mongo_dart.dart';

import '../Modules/Player.dart';
import '../utils.dart';
import 'Tokensservice.dart';

class Authservice {
  static Authservice _instance = Authservice.getInstance();

  // Private constructor to prevent external instantiation
  Authservice._();

  factory Authservice.getInstance() {
    _instance = Authservice._();

    return _instance;
  }

  init() async {
    playerscollection = DbCollection(db, "players");
  }

  Future<Player?> Signup(String playername, String password) async {
    try {
      final existing =
          await playerscollection.findOne(where.eq("playername", playername));
      if (existing?.isEmpty ?? true) {
        WriteResult result = await playerscollection.insertOne({
          "playername": "${playername}",
          "password": hashIT(password),
          "lastconnection": Timestamp(DateTime.now().millisecondsSinceEpoch),
          "playedgames": 0,
          "wongames": 0
        });
        final player = Player(result.id, playername,
            Timestamp(DateTime.now().millisecondsSinceEpoch), 0, 0);
        await Tokensservice.getInstance().prepare_token(player: player);
        return player;
      } else {
        print("Player exists");
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Player?> get_playerbyId({required ObjectId id}) async {
    try {
      final existing = await playerscollection.findOne(where.id(id));
      if (existing != null && existing.isNotEmpty) {
        return Player(id, existing["playername"], existing["lastconnection"],
            existing["playedgames"], existing["wongames"]);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Player?> Signin(String playername, String password) async {
    try {
      final existing = await playerscollection.findOne(
          where.eq("playername", playername).eq("password", hashIT(password)));

      if (existing == null || existing.isEmpty) {
        return null;
      } else {
        final player = Player(
            existing["_id"],
            playername,
            existing["lastconnection"],
            existing["playedgames"],
            existing["wongames"]);
        await Tokensservice.getInstance().prepare_token(player: player);
        return player;
      }
    } catch (e) {
      print(e);
    }
  }
}
