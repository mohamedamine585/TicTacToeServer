import 'dart:convert';
import 'dart:io';
import 'package:tic_tac_toe_server/src/services/player_service.dart';
import 'package:tic_tac_toe_server/src/models/Player.dart';

Function(HttpRequest) getotherid = (HttpRequest request) async {
  try {
    final pathelements = request.requestedUri.path.split("/");
    if ((pathelements.length == 4 &&
            pathelements[1] == "player" &&
            pathelements[3] == "image") ||
        (pathelements.length == 3 &&
            pathelements[1] == "player" &&
            pathelements[2] != "image")) {
      request.response.headers
          .add("otherid", pathelements[2], preserveHeaderCase: true);
    } else if (pathelements[1] == "history" && pathelements.length == 3) {
      request.response.headers
          .add("otherid", pathelements[2], preserveHeaderCase: true);
    }
    String finalPath = "";
    if (pathelements.contains("player")) {
      finalPath = "/player";
      if (pathelements.contains("image")) {
        finalPath = "/player/image";
      }
    } else if (pathelements.contains("history")) {
      finalPath = "/history";
    } else {
      finalPath = request.requestedUri.path;
    }
    request.response.headers.add("path", finalPath);
  } catch (e) {
    print(e);
  }
};

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
  } else {
    request.response.statusCode = HttpStatus.badRequest;
    throw Exception("Invalid body");
  }
};
