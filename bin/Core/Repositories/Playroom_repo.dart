import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';

import '../Modules/Player_Room.dart';

abstract class Play_room_repository {
  Play_room play_room;
  Play_room_repository(this.play_room);
  own_that_room(HttpRequest game_request, ObjectId id);
  disconnect_players();
  listen_to_player0();
  listen_to_player1();
  join_room(HttpRequest game_request, ObjectId id);
  Play();
  close_room();
  declareWinner();
  sendDataToboth(String? message);
}
