import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/models/Player.dart';
import 'package:tic_tac_toe_server/src/data/utils.dart';

class PlayersDataAccess {
  Stream<Map<String, dynamic>>? getActivePlayers() {
    try {
      final pipeline = AggregationPipelineBuilder()
          .addStage(Match(where
              .gte("lastconnection",
                  DateTime.now().subtract(Duration(minutes: 1)))
              .or(where.eq("lastconnection", null))
              .map['\$query']))
          .build();

      return playerscollection.modernAggregate(pipeline);
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<Player?> get_playerbyId({required ObjectId id}) async {
    try {
      final existing = await playerscollection.findOne(where.id(id));
      if (existing != null && existing.isNotEmpty) {
        return Player(
            id,
            existing["name"] ?? "",
            existing["email"] ?? "",
            DateTime.now(),
            existing["playedgames"] ?? 0,
            existing["wongames"] ?? 0,
            existing["score"] ?? 0);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<bool> deleteAccount({required String id}) async {
    try {
      final objectId = ObjectId.fromHexString(id);
      final deleted = await playerscollection.deleteOne(where.id(objectId));
      return deleted.isSuccess;
    } catch (e) {
      print(e);
    }
    return false;
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
            existing["wongames"],
            existing["score"]);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  Future<Player?> getPlayerByEmail({required String email}) async {
    try {
      final existing =
          await playerscollection.findOne(where.eq("email", email));
      if (existing != null && existing.isNotEmpty) {
        return Player(
            existing["_id"],
            existing["name"],
            existing["email"],
            existing["lastconnection"],
            existing["playedgames"],
            existing["wongames"],
            existing["score"]);
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
            "score": playerupdate["score"],
            "playedgames": playerupdate["playedgames"],
            "wongames": playerupdate["wongames"],
            "lastconnection": DateTime.now(),
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
      playerdoc?.remove("lastconnection");
      playerdoc?.remove("password");

      return playerdoc;
    } catch (e) {
      print(e);
    }
    return null;
  }

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

  Future<List<Map<String, dynamic>>> getPlayerHistory(
      {required String playerid}) async {
    get_playerbyEmail({required String playername}) {}
    try {
      final playerID = ObjectId.fromHexString(playerid);

      final history = await playroomscollection
          .find(where
              .eq("creatorid", playerID)
              .or(where.eq("joinerid", playerID)))
          .toList();
      history.forEach((element) {
        element.remove("start");
        element.remove("end");
        if ((element["creatorid"] == playerID && element["winner"] == 0) ||
            (element["joinerid"] == playerID && element["winner"] == 1)) {
          element["winner"] = 0;
        } else {
          element["winner"] = 1;
        }
      });
      return history;
    } catch (e) {
      print(e);
    }
    return [];
  }
}
