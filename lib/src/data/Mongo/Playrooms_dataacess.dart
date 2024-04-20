import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/services/player_service.dart';
import 'package:tic_tac_toe_server/src/models/Player_Room.dart';

import '../utils.dart';

class Mongo_Playroom_Repository {
  init() async {
    playroomscollection = DbCollection(db, "playrooms");
  }

  Future<void> close_PlayRoom(
      {required Play_room play_room,
      required int Function(int, int) winScoreAlg,
      required int Function(int, int) looseScoreAlg}) async {
    try {
      final p0 =
          await PlayerService.instance.getPlayerById(id: play_room.player0!.Id);

      final p1 =
          await PlayerService.instance.getPlayerById(id: play_room.player1!.Id);

      if (play_room.hand != null) {
        final winnerScore = winScoreAlg(p0?.score ?? 0, p1?.score ?? 0);
        final looserScore = looseScoreAlg(p0?.score ?? 0, p1?.score ?? 1);

        await playroomscollection.update(
            where.id(play_room.roomid!),
            modify
                .set("end", DateTime.now())
                .set("winner", (play_room.hand! % 2)));
        await playerscollection.update(
            where.id(p0!.Id),
            modify
                .set("playedgames", p0.playedGames + 1)
                .set("wongames",
                    (play_room.hand! % 2 == 0) ? p0.WonGames + 1 : p0.WonGames)
                .set(
                    "progress",
                    (play_room.hand! % 2 == 0)
                        ? winnerScore - p0.score
                        : looserScore - p0.score)
                .set("score",
                    (play_room.hand! % 2 == 0) ? winnerScore : looserScore));

        await playerscollection.update(
            where.id(p1!.Id),
            modify
                .set("playedgames", p1.playedGames + 1)
                .set("wongames",
                    (play_room.hand! % 2 == 1) ? p1.WonGames + 1 : p1.WonGames)
                .set(
                    "progress",
                    (play_room.hand! % 2 == 1)
                        ? winnerScore - p1.score
                        : looserScore - p1.score)
                .set(
                    "score",
                    (play_room.hand! % 2 == 1)
                        ? winScoreAlg(p1.score, p0.score)
                        : looseScoreAlg(p1.score, p0.score)));
      } else {
        await playroomscollection.update(
            where.id(play_room.roomid!), modify.set("end", DateTime.now()));
      }
    } catch (e) {
      print(e);
    }
  }

  Future<ObjectId?> open_PlayRoom({required Play_room play_room}) async {
    try {
      if (play_room.player0?.Id != null && play_room.player1?.Id != null) {
        final player0doc = await PlayerService.instance
            .getPlayerById(id: play_room.player0?.Id ?? ObjectId());
        final player1doc = await PlayerService.instance
            .getPlayerById(id: play_room.player1?.Id ?? ObjectId());

        final playRoomData = {
          "creatorid": play_room.player0?.Id,
          "joinerid": play_room.player1?.Id,
          "creatorname": player0doc?.playername,
          "joinername": player1doc?.playername,
          "start": Timestamp(DateTime.now().second),
          "end": Timestamp(DateTime.now().second),
          "winner": -1
        };
        playRoomData.addAll({"_id": play_room.roomid});
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

  Future<void> closeSpecificPlayRoom({required String roomid}) async {
    try {
      await playroomscollection.update(where.id(ObjectId.fromHexString(roomid)),
          modify.set("end", DateTime.now()).set("winner", 0));
    } catch (e) {
      print(e);
    }
  }
}
