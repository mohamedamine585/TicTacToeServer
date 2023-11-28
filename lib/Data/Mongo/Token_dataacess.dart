import 'package:mongo_dart/mongo_dart.dart';

import '../../Core/Modules/Player.dart';
import '../../../Services/Authservice.dart';
import '../utils.dart';
import '../../../utils/utils.dart';
import '../../Repositories/Token.dataacess.dart';

class Mongo_Token_Repository implements Token_Repository {
  @override
  init() async {
    tokenscollection = DbCollection(db, "tokens");
  }

  @override
  Future<void> make_available_all_tokens() async {
    try {
      await tokenscollection.update(
          where.eq("inuse", true), modify.set("inuse", false),
          multiUpdate: true);
    } catch (e) {
      print(e);
    }
  }

  @override
  Future<void> make_available_token(String token) async {
    try {
      await tokenscollection.update(
          where.eq("token", token), modify.set("inuse", false),
          multiUpdate: true);
    } catch (e) {
      print(e);
    }
  }

  /// deprecated

  @override
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
    return null;
  }

  @override
  Future<String?> store_token(
      {required String token, required ObjectId Id}) async {
    try {
      final existing = await tokenscollection.findOne(where.eq("_id", Id));
      if (existing != null && existing.isNotEmpty && !existing["inuse"]) {
        await tokenscollection
            .update(where.id(Id), {"token": token, "inuse": false});
        return token;
      } else if (existing?.isEmpty ?? true) {
        await tokenscollection
            .insertOne({"_id": Id, "token": token, "inuse": false});
        return token;
      }
      return null;
    } catch (e) {
      print(e);
    }
    return null;
  }

  @override
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
    return null;
  }

  Future<Player?> fetch_player_byToken({required String token}) async {
    try {
      final existing = await tokenscollection.findOne(where.eq("token", token));
      if (existing != null && existing.isNotEmpty) {
        return await Authservice.instance.get_playerbyId(id: existing["_id"]);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  @override
  Future<String?> change_token_status(ObjectId id) async {
    try {
      final doc = await tokenscollection.findOne(where.id(id));
      if (doc != null) {
        await tokenscollection.update(
            where.id(doc["_id"]), modify.set("inuse", !(doc["inuse"])));
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  @override
  Future<String?> fetch_nonfree_token({required String token}) async {
    try {
      final existing = await tokenscollection.findOne(where.eq("token", token));
      if (existing != null && existing.isNotEmpty) {
        return token;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  @override
  Future<String?> fetch_token({required String token}) async {
    try {
      final existing = await tokenscollection.findOne(where.eq("token", token));
      if (existing != null && existing.isNotEmpty && !existing["inuse"]) {
        return token;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  @override
  Future<String?> fetch_token_free_byId({required ObjectId id}) async {
    try {
      final existing = await tokenscollection.findOne(where.id(id));
      if (existing != null && existing.isNotEmpty && !existing["inuse"]) {
        await change_token_status(existing["_id"]);
        return existing["_id"];
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
