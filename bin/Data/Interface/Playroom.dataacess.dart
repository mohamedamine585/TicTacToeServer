import 'package:mongo_dart/mongo_dart.dart';

import '../../Core/Modules/Player_Room.dart';
import '../Mongo/Playrooms_dataacess.dart';

abstract class Mongo_Playroom_Dataaccess implements Playroom_dataAcess {
  init();
  Future<void> close_PlayRoom({required Play_room play_room});
  Future<ObjectId?> open_PlayRoom({required Play_room play_room});
}
