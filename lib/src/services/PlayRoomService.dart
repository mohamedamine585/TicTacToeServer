import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/models/Player_Room.dart';
import 'package:tic_tac_toe_server/src/data/Mongo/Playrooms_dataacess.dart';
import 'package:tic_tac_toe_server/src/services/algs.dart/loose_score_alg.dart';
import 'package:tic_tac_toe_server/src/services/algs.dart/win_score_alg.dart';

class PlayRoomService {
  Mongo_Playroom_Repository PlayroomDataservice;
  // Private constructor to prevent external instantiation
  PlayRoomService._(this.PlayroomDataservice);
  static PlayRoomService instance =
      PlayRoomService._(Mongo_Playroom_Repository());

  init() async {
    await PlayroomDataservice.init();
  }

  Future<void> close_PlayRoom({required Play_room play_room}) async {
    await PlayroomDataservice.close_PlayRoom(
        play_room: play_room,
        winScoreAlg: winScoreAlg,
        looseScoreAlg: looseScoreAlg);
  }

  Future<ObjectId?> open_PlayRoom({required Play_room play_room}) async {
    return await PlayroomDataservice.open_PlayRoom(play_room: play_room);
  }
}
