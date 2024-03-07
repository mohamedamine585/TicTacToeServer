import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/Core/Modeles/Player_Room.dart';
import 'package:tic_tac_toe_server/src/Repositories/Playroom.dataacess.dart';
import 'package:tic_tac_toe_server/src/Data/Mongo/Playrooms_dataacess.dart';

class PlayRoomService {
  Playroom_Repository PlayroomDataservice;
  // Private constructor to prevent external instantiation
  PlayRoomService._(this.PlayroomDataservice);
  static PlayRoomService instance =
      PlayRoomService._(Mongo_Playroom_Repository());

  init() async {
    await PlayroomDataservice.init();
  }

  Future<void> close_PlayRoom({required Play_room play_room}) async {
    await PlayroomDataservice.close_PlayRoom(play_room: play_room);
  }

  Future<ObjectId?> open_PlayRoom({required Play_room play_room}) async {
    return await PlayroomDataservice.open_PlayRoom(play_room: play_room);
  }

  Future<Map<String, dynamic>?> getdoc({required String id}) async {
    return await PlayroomDataservice.getdoc(id: id);
  }

  Future<Map<String, dynamic>?> updatePlayer(
      {required Map<String, dynamic> playerupdate, required String id}) async {
    return await PlayroomDataservice.updatePlayer(
        playerupdate: playerupdate, id: id);
  }
}
