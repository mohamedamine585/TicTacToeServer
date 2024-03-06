import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';

class GameMiddleware {
  static Future<ObjectId?> checkforSepecificRoom(
      {required HttpRequest request}) async {
    try {
      final roomid = request.headers.value("roomid");
      if (roomid != null) {
        return ObjectId.fromHexString(roomid);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
