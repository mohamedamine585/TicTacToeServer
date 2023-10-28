import 'dart:io';

import '../Modules/Player_Room.dart';

abstract class Play_room_repository {
  Play_room play_room;
  Play_room_repository(this.play_room);
  own_that_room(HttpRequest game_request, String ptoken);
  disconnect_players();
  listen_to_player0();
  listen_to_player1();
  join_room(HttpRequest game_request, String ptoken);
  Play();
  close_room();
  declareWinner();
  sendDataToboth(String? message);
}
