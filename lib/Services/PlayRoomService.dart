import 'package:mongo_dart/mongo_dart.dart';

import '../Core/Modules/Player_Room.dart';

import 'utils.dart';

class PlayRoomService {
  static PlayRoomService _instance = PlayRoomService.getInstance();

  // Private constructor to prevent external instantiation
  PlayRoomService._();

  factory PlayRoomService.getInstance() {
    _instance = PlayRoomService._();

    return _instance;
  }
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
