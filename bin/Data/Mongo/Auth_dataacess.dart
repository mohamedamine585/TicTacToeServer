import 'package:mongo_dart/mongo_dart.dart';
import '../../Core/Modules/Player.dart';
import '../../Services/Tokensservice.dart';
import '../utils.dart';
import '../../middleware/tokenmiddleware.dart';
import '../../utils/utils.dart';
import '../Interface/Auth.dataacess.dart';

class Mongo_Auth_dataAcess implements Auth_dataAcess {
  @override
  init() async {
    playerscollection = DbCollection(db, "players");
  }

  @override
  Future<Player?> Signup(String playername, String password) async {
    try {
      final existing =
          await playerscollection.findOne(where.eq("playername", playername));
      if (existing?.isEmpty ?? true) {
        WriteResult result = await playerscollection.insertOne({
          "playername": playername,
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
        print("Player exists with that name");
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  @override
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
    return null;
  }

  @override
  Future<Player?> get_playerbyName({required String playername}) async {
    try {
      final existing =
          await playerscollection.findOne(where.eq("playername", playername));
      if (existing != null && existing.isNotEmpty) {
        return Player(
            existing["_id"],
            existing["playername"],
            existing["lastconnection"],
            existing["playedgames"],
            existing["wongames"]);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  @override
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
    return null;
  }

  @override
  Future<String?> change_password(
      {required String playername,
      required String old_password,
      required String newpassword}) async {
    try {
      final doc = await playerscollection.findOne(where
          .eq("playername", playername)
          .eq("password", hashIT(old_password)));
      if (doc?.isNotEmpty ?? false) {
        String? newToken = await Tokensservice.getInstance().store_token(
            token: Tokenmiddleware.CreateJWToken(doc!["_id"])!, Id: doc["_id"]);

        if (newToken != null) {
          await playerscollection.updateOne(where.id(doc["_id"]),
              modify.set("password", hashIT(newpassword)));
          return newToken;
        }
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  @override
  Future<bool> change_name(
      {required String playername,
      required String password,
      required String new_name}) async {
    try {
      final doc = await playerscollection.findOne(
          where.eq("playername", playername).eq("password", hashIT(password)));

      final docX =
          await playerscollection.findOne(where.eq("playername", new_name));
      if ((docX?.isEmpty ?? true) && (doc?.isNotEmpty ?? false)) {
        String? newToken = await Tokensservice.getInstance().store_token(
            token: Tokenmiddleware.CreateJWToken(doc!["_id"])!, Id: doc["_id"]);
        if (newToken != null) {
          final res = await playerscollection.update(
              where.id(doc["_id"]), modify.set("playername", new_name));
          return res.isNotEmpty;
        } else {
          print("Token in use");
          throw Exception();
        }
      } else {
        print("TNo player found");
        throw Exception();
      }
    } catch (e) {
      print("Cannot change name");
    }
    return false;
  }

  @override
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
    return null;
  }
}
