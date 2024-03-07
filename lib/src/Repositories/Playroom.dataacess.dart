import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/Core/Modeles/Player_Room.dart';

abstract class Playroom_Repository {
  @override
  init();
  @override
  Future<void> close_PlayRoom({required Play_room play_room});
  @override
  Future<ObjectId?> open_PlayRoom({required Play_room play_room});
  @override
  Future<Map<String, dynamic>?> getdoc({required String id});
  @override
  Future<Map<String, dynamic>?> updatePlayer(
      {required Map<String, dynamic> playerupdate, required String id});
}
