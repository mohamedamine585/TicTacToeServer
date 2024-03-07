import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';


class Player_Socket {
  WebSocket socket;
  ObjectId Id;
  Player_Socket(this.socket, this.Id);
}
