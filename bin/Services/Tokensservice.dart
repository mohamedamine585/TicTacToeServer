import 'package:mongo_dart/mongo_dart.dart';

import '../Modules/Player.dart';
import '../utils.dart';
import 'Authservice.dart';

class Tokensservice {
  static Tokensservice _instance = Tokensservice.getInstance();

  // Private constructor to prevent external instantiation
  Tokensservice._();

  factory Tokensservice.getInstance() {
    _instance = Tokensservice._();

    return _instance;
  }
  init() async {
    tokenscollection = DbCollection(db, "tokens");
  }

  Future<String?> prepare_token({required Player player}) async {
    try {
      final existing =
          await tokenscollection.findOne(where.eq("_id", player.Id));
      if (existing != null && existing.isNotEmpty && !existing["inuse"]) {
        await tokenscollection.update(where.id(player.Id), {
          "token":
              "${hashIT(player.Id.toString())} ${hashIT(player.lastconnection.toString())}",
          "inuse": false
        });
        return "${hashIT(player.Id.toString())} ${hashIT(player.lastconnection.toString())}";
      } else if (existing?.isEmpty ?? true) {
        await tokenscollection.insertOne({
          "_id": player.Id,
          "token":
              "${hashIT(player.Id.toString())} ${hashIT(player.lastconnection.toString())}",
          "inuse": false
        });
        return "${hashIT(player.Id.toString())} ${hashIT(player.lastconnection.toString())}";
      }
      return null;
    } catch (e) {
      print(e);
    }
  }

  Future<bool?> delete_token({required ObjectId id}) async {
    try {
      final existing = await tokenscollection.findOne(where.eq("_id", id));
      if (existing != null && existing.isNotEmpty) {
        final res = await tokenscollection.deleteOne(where.eq("_id", id));
        return res.isSuccess;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<Player?> fetch_player_byToken({required String token}) async {
    try {
      final existing = await tokenscollection.findOne(where.eq("token", token));
      if (existing != null && existing.isNotEmpty) {
        return await Authservice.getInstance()
            .get_playerbyId(id: existing["_id"]);
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String?> change_token_status(String token) async {
    try {
      final doc = await tokenscollection.findOne(where.eq("token", token));
      if (doc != null) {
        await tokenscollection.update(where.id(doc["_id"]),
            {"inuse": !doc["inuse"], "token": doc["token"]});
      }
    } catch (e) {
      print(e);
    }
  }

  Future<String?> fetch_token({required String token}) async {
    try {
      final existing = await tokenscollection.findOne(where.eq("token", token));
      if (existing != null && existing.isNotEmpty && !existing["inuse"]) {
        await change_token_status(token);
        return token;
      }
    } catch (e) {
      print(e);
    }
  }
}
