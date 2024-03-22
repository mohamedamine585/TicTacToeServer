import 'dart:convert';
import 'dart:io';

import 'package:tic_tac_toe_server/src/Services/player_service.dart';
import 'package:tic_tac_toe_server/src/models/Player.dart';

Function(HttpRequest) checkemailuniqueness = (HttpRequest request) async {
  try {
    Player? player;
    if (request.response.headers.value("update") == "email") {
      player = await PlayerService.instance.getPlayerByEmail(
          email: request.response.headers.value("email") ?? "");
      if (player != null) {
        request.response.statusCode = HttpStatus.badRequest;
      }
    }
  } catch (e) {
    print(e);
  }
};
Function(HttpRequest) checkbodyForPlayerupdate = (HttpRequest request) async {
  if (request.headers.value("update") == "email" ||
      request.headers.value("update") == "name") {
    final body = json.decode(await utf8.decodeStream(request));
    if (body["email"] != null ||
        body["name"] != null ||
        body["lastconnection"] != null) {
      if (body["email"] != null && body["email"].length != 0) {
        request.response.headers.set("email", body["email"]);
      }
      if (body["name"] != null && body["name"].length != 0) {
        request.response.headers.set("name", body["name"]);
      }
    }
  } else if (request.headers.value("update") != "image") {
    request.response.statusCode = HttpStatus.badRequest;
    throw Exception("Invalid body");
  }
};
