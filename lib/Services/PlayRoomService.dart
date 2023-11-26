import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/Repositories/Playroom.dataacess.dart';
import 'package:tic_tac_toe_server/Data/Mongo/Playrooms_dataacess.dart';

import '../Core/Modules/Player_Room.dart';

class PlayRoomService {
  Playroom_Repository PlayroomDataservice;
  // Private constructor to prevent external instantiation
  PlayRoomService._(this.PlayroomDataservice);
  static PlayRoomService instance =
      PlayRoomService._(Mongo_Playroom_dataAcess());

  init() async {
    await PlayroomDataservice.init();
  }

  Future<void> close_PlayRoom({required Play_room play_room}) async {
    await PlayroomDataservice.close_PlayRoom(play_room: play_room);
  }

  Future<ObjectId?> open_PlayRoom({required Play_room play_room}) async {
    return await PlayroomDataservice.open_PlayRoom(play_room: play_room);
  }
}
