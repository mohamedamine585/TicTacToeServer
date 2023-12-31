import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/Repositories/Auth.dataacess.dart';
import 'package:tic_tac_toe_server/Repositories/Playroom.dataacess.dart';
import 'package:tic_tac_toe_server/Data/Mongo/Auth_dataacess.dart';

import '../../Core/Modules/Player_Room.dart';
import '../../../Services/Authservice.dart';
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

  Future<ObjectId?> open_PlayRoom({required Play_room play_room}) async {
    try {
      final doc = await playroomscollection.insertOne({
        "createrid": play_room.player0?.Id,
        "joinerid": play_room.player1?.Id,
        "start": Timestamp(DateTime.now().second),
        "end": Timestamp(DateTime.now().second),
        "winner": -1
      });
      if (doc.document != null) {
        return doc.document!["_id"] as ObjectId?;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
