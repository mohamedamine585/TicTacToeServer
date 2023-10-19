import 'package:mongo_dart/mongo_dart.dart';

import '../Modules/Player_Room.dart';
import '../utils.dart';
import 'Tokensservice.dart';

class PlayRoomService {
  static PlayRoomService _instance = PlayRoomService.getInstance();

  // Private constructor to prevent external instantiation
  PlayRoomService._();

  factory PlayRoomService.getInstance() {
    _instance = PlayRoomService._();

    return _instance;
  }
  init() async {
    playroomscollection = DbCollection(db, "playrooms");
  }

  Future<void> close_PlayRoom(
      {required Play_room play_room, required ObjectId id}) async {
    try {
      final p0 = await Tokensservice.getInstance()
          .fetch_player_byToken(token: play_room.player0!.token);
      final p1 = await Tokensservice.getInstance()
          .fetch_player_byToken(token: play_room.player1!.token);
      final doc = playroomscollection.findOne(where.id(id));

      await playerscollection.update(where.id(p0!.Id), {
        "_id": p0.Id,
        "playername": p0.playername,
        "lastconnection": p0.lastconnection,
        "playedgames": p0.playedGames + 1,
        "wongames": (play_room.hand == 0) ? p0.WonGames + 1 : p0.WonGames
      });
      await playerscollection.update(where.id(p1!.Id), {
        "_id": p1.Id,
        "playername": p1.playername,
        "lastconnection": p1.lastconnection,
        "playedgames": p1.playedGames + 1,
        "wongames": (play_room.hand == 1) ? p1.WonGames + 1 : p1.WonGames
      });
      await playroomscollection.update(where.id(id), {
        "createrid": p0.Id,
        "joinerid": p1.Id,
        "start": (await doc)!["start"],
        "winner": play_room.hand,
        "end": Timestamp(DateTime.now().second),
      });
    } catch (e) {
      print(e);
    }
  }

  Future<ObjectId?> open_PlayRoom({required Play_room play_room}) async {
    try {
      final p0 = await Tokensservice.getInstance()
          .fetch_player_byToken(token: play_room.player0!.token);
      final p1 = await Tokensservice.getInstance()
          .fetch_player_byToken(token: play_room.player1!.token);
      final doc = await playroomscollection.insertOne({
        "createrid": p0?.Id,
        "joinerid": p1?.Id,
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
  }
}
