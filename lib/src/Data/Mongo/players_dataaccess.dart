import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/Core/Modeles/Player.dart';
import 'package:tic_tac_toe_server/src/Data/utils.dart';
import 'package:tic_tac_toe_server/src/Services/Tokensservice.dart';
import 'package:tic_tac_toe_server/src/middleware/tokenmiddleware.dart';
import 'package:tic_tac_toe_server/src/utils/utils.dart';

class PlayersDataAccess {
  Stream<Map<String, dynamic>> getActivePlayers() {
    return playerscollection.find(where
        .lte("lastconnection", DateTime.now().subtract(Duration(minutes: 1)))
        .or(where.eq("lastconnection", null)));
  }

  Future<Player?> get_playerbyId({required ObjectId id}) async {
    try {
      final existing = await playerscollection.findOne(where.id(id));
      if (existing != null && existing.isNotEmpty) {
        return Player(
            id,
            existing["name"] ?? "",
            existing["email"],
            (existing["lastconnection"] != null)
                ? existing["lastconnection"]
                : Timestamp(),
            (existing["playedgames"] != null) ? existing["playedgames"] : 0,
            (existing["wongames"] != null) ? existing["wongames"] : 0);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<Player?> get_playerbyName({required String playername}) async {
    try {
      final existing =
          await playerscollection.findOne(where.eq("name", playername));
      if (existing != null && existing.isNotEmpty) {
        return Player(
            existing["_id"],
            existing["name"],
            existing["email"],
            existing["lastconnection"],
            existing["playedgames"],
            existing["wongames"]);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<String?> change_password(
      {required String playername,
      required String old_password,
      required String newpassword}) async {
    try {
      final doc = await playerscollection.findOne(where
          .eq("playername", playername)
          .eq("password", hashIT(old_password)));
      if (doc?.isNotEmpty ?? false) {
        String? newToken = await Tokensservice.instance.store_token(
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
        String? newToken = await Tokensservice.instance.store_token(
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

  Future<Map<String, bool>?> delete_user(
      {required String playername, required String password}) async {
    try {
      final existing = await playerscollection.findOne(
          where.eq("playername", playername).eq("password", hashIT(password)));
      if (existing == null || existing.isEmpty) {
      } else {
        final rest =
            await Tokensservice.instance.delete_token(id: existing["_id"]);
        final res =
            await playerscollection.deleteOne(where.id(existing["_id"]));
        return {"rest": rest ?? false, "res": res.isSuccess};
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<Map<String, dynamic>?> updatePlayer(
      {required Map<String, dynamic> playerupdate, required String id}) async {
    try {
      final existingDoc =
          await playerscollection.findOne(where.id(ObjectId.fromHexString(id)));

      if (existingDoc != null) {
        final existingPassword = existingDoc['password'];

        final playerdoc = await playerscollection.update(
          where.id(existingDoc["_id"]),
          {
            "name": playerupdate["name"],
            "email": playerupdate["email"],
            "password":
                existingPassword, // Include the existing password in the update
          },
        );
        return playerdoc;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<Map<String, dynamic>?> getdoc({required String id}) async {
    try {
      final playerdoc =
          await playerscollection.findOne(where.id(ObjectId.fromHexString(id)));

      return playerdoc;
    } catch (e) {
      print(e);
    }
    return null;
  }

  @override
  Future<void> updateActivity({required String playerid}) async {
    try {
      final playerID = ObjectId.fromHexString(playerid);
      final playerdoc = await playerscollection.findOne(where.id(playerID));
      if (playerdoc != null) {
        playerdoc["lastconnection"] = DateTime.now();
        await playerscollection.update(where.id(playerID), playerdoc);
      }
    } catch (e) {
      print(e);
    }
  }
}
