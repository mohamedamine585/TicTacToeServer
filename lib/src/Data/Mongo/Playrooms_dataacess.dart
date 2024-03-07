import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/Core/Modeles/Player_Room.dart';
import 'package:tic_tac_toe_server/src/Repositories/Playroom.dataacess.dart';
import 'package:tic_tac_toe_server/src/Services/Authservice.dart';

import '../utils.dart';

class Mongo_Playroom_Repository implements Playroom_Repository {
  init() async {
    playroomscollection = DbCollection(db, "playrooms");
  }

  Future<void> close_PlayRoom({required Play_room play_room}) async {
    try {
      final p0 =
          await Authservice.instance.get_playerbyId(id: play_room.player0!.Id);
      final p1 =
          await Authservice.instance.get_playerbyId(id: play_room.player1!.Id);
      if (play_room.hand != null) {
        await playerscollection.update(
            where.id(p0!.Id),
            modify.set("playedgames", p0.playedGames + 1).set("wongames",
                (play_room.hand == 0) ? p0.WonGames + 1 : p0.WonGames));
        await playerscollection.update(
            where.id(p1!.Id),
            modify.set("playedgames", p1.playedGames + 1).set("wongames",
                (play_room.hand == 1) ? p1.WonGames + 1 : p1.WonGames));
        await playroomscollection.update(
            where.id(play_room.roomid!),
            modify
                .set("end", Timestamp(DateTime.now().second))
                .set("winner", (play_room.hand == null) ? -1 : play_room.hand));
      } else {
        await playroomscollection.update(where.id(play_room.roomid!),
            modify.set("end", Timestamp(DateTime.now().second)));
      }
    } catch (e) {
      print(e);
    }
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

  Future<ObjectId?> open_PlayRoom({required Play_room play_room}) async {
    try {
      if (play_room.player0?.Id != null && play_room.player1?.Id != null) {
        final player0doc = await Authservice.instance
            .get_playerbyId(id: play_room.player0?.Id ?? ObjectId());
        final player1doc = await Authservice.instance
            .get_playerbyId(id: play_room.player1?.Id ?? ObjectId());
        print(player1doc?.playername);
        print(player0doc?.playername);

        final playRoomData = {
          "creatorid": play_room.player0?.Id,
          "joinerid": play_room.player1?.Id,
          "creatorname": player0doc?.playername,
          "joinername": player1doc?.playername,
          "start": Timestamp(DateTime.now().second),
          "end": Timestamp(DateTime.now().second),
          "winner": -1
        };
        playRoomData.addAll(
            (play_room.roomid == null) ? {"_id": play_room.roomid} : {});
        final doc = await playroomscollection.insertOne(playRoomData);

        if (doc.document != null) {
          return doc.document!["_id"] as ObjectId?;
        }
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
