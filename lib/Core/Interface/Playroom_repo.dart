

import '../Modules/Player_Room.dart';

abstract class Play_room_repository {
  Play_room play_room;
  Play_room_repository(this.play_room);

  close_room();
}
