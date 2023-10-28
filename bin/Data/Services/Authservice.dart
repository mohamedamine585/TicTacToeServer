import 'package:mongo_dart/mongo_dart.dart';

import '../../Core/Modules/Player.dart';
import '../../utils.dart';
import '../../consts.dart';
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
          "lastconnection": Timestamp(DateTime.now().second),
          "playedgames": 0,
          "wongames": 0
        });
        final player = Player(
            result.id, playername, Timestamp(DateTime.now().second), 0, 0);
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
        await playerscollection.update(where.id(existing["_id"]), {
          "_id": existing["_id"],
          "playername": playername,
          "password": hashIT(password),
          "lastconnection": Timestamp(DateTime.now().second),
          "playedgames": existing["playedgames"],
          "wongames": existing["wongames"]
        });
        final player = Player(
            existing["_id"],
            playername,
            Timestamp(DateTime.now().second),
            existing["playedgames"],
            existing["wongames"]);
        await Tokensservice.getInstance().prepare_token(player: player);
        return player;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<bool> change_password(
      {required ObjectId id,
      required String old_password,
      required String newpassword}) async {
    try {
      final doc = await playerscollection.update(
          where.eq("_id", id).eq("password", hashIT(old_password)),
          modify.set("password", hashIT(newpassword)));
      return doc.isNotEmpty;
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<Map<String, bool>?> delete_user(
      {required String playername, required String password}) async {
    try {
      final existing = await playerscollection.findOne(
          where.eq("playername", playername).eq("password", hashIT(password)));
      if (existing == null || existing.isEmpty) {
      } else {
        final rest =
            await Tokensservice.getInstance().delete_token(id: existing["_id"]);
        final res =
            await playerscollection.deleteOne(where.id(existing["_id"]));
        return {"rest": rest ?? false, "res": res.isSuccess};
      }
    } catch (e) {
      print(e);
    }
  }
}