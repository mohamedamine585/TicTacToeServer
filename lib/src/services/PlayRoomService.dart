import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/Data/Mongo/PlayroomDataAccess.dart';
import 'package:tic_tac_toe_server/src/models/Player_Room.dart';
import 'package:tic_tac_toe_server/src/services/algs.dart/loose_score_alg.dart';
import 'package:tic_tac_toe_server/src/services/algs.dart/win_score_alg.dart';

class PlayRoomService {
  MongoPlayroomRepository playroomRepository;
  // Private constructor to prevent external instantiation
  PlayRoomService._(this.playroomRepository);
  static PlayRoomService instance =
      PlayRoomService._(MongoPlayroomRepository());

  init() {
    playroomRepository.init();
  }

  Future<void> closePlayRoom({required Play_room play_room}) async {
    await playroomRepository.close_PlayRoom(
        play_room: play_room,
        winScoreAlg: winScoreAlg,
        looseScoreAlg: looseScoreAlg);
  }

  Future<void> deletePlayRoom({required ObjectId roomId}) async {
    await playroomRepository.deletePlayroom(id: roomId);
  }

  Future<ObjectId?> openPlayRoom({required Play_room play_room}) async {
    return await playroomRepository.open_PlayRoom(play_room: play_room);
  }
}
