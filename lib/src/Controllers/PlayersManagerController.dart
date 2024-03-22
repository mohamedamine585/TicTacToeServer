import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/Services/imagesService.dart';
import 'package:tic_tac_toe_server/src/Services/player_service.dart';
import 'package:tic_tac_toe_server/src/services/online_activity_service.dart';

Function(HttpRequest) subscribeToOnlineActivity = (HttpRequest request) async {
  final stream = OnlineActivityService.instance.getOnlineActivity();
  if (WebSocketTransformer.isUpgradeRequest(request)) {
    final websocket = await WebSocketTransformer.upgrade(request);
    stream?.listen((event) {
      // to fix
      event.remove("lastconnection");
      websocket.add(json.encode({"players": event}));
    });
  }
};

Function(HttpRequest) getdoc = (HttpRequest request) async {
  try {
    final doc = await PlayerService.instance
        .getdoc(id: request.response.headers.value("playerid")!);
    request.response.write(json.encode(doc));
  } catch (e) {
    print(e);
  }
};
Function(HttpRequest) updatePlayer = (HttpRequest request) async {
  if (request.headers.value("update") == "name" ||
      request.headers.value("update") == "email") {
    await updatedoc(request);
  } else if (request.headers.value("update") == "image") {
    await updateProfilePhoto(request);
  }
};
Function(HttpRequest) updatedoc = (HttpRequest request) async {
  try {
    final playerid = request.response.headers.value("playerid");
    final player = await PlayerService.instance
        .getPlayerById(id: ObjectId.fromHexString(playerid ?? ""));
    if (player != null) {
      final Map<String, dynamic> playerupdate = {
        "playedgames": player.playedGames,
        "wongames": player.WonGames,
        "lastconnection": player.lastconnection,
        "score": player.score,
        "name": request.response.headers.value("name"),
        "email": request.response.headers.value("email")
      };
      final updateddoc = await PlayerService.instance
          .updatePlayer(id: playerid!, playerupdate: playerupdate);
      if (updateddoc != null) {
        request.response.write(json.encode({"message": "Player Updated"}));
      }
    } else {
      request.response.statusCode = HttpStatus.badRequest;
    }
  } catch (e) {
    print(e);
  }
};

Function(HttpRequest) updateProfilePhoto = (HttpRequest request) async {
  final imagePath = await ImagesService.saveImage(request);
  if (imagePath != null) {
    request.response.write('Image uploaded successfully');
  } else {
    request.response.statusCode = HttpStatus.badRequest;
  }
};

Function(HttpRequest) getPlayerHistory = (HttpRequest request) async {
  try {
    final playerid = request.response.headers.value("playerid");
    if (playerid != null) {
      final history =
          await PlayerService.instance.getPlayerHistory(id: playerid);
      request.response.write(json.encode({"history": history}));
    } else {
      request.response.statusCode = HttpStatus.unauthorized;
    }
  } catch (e) {
    print(e);
  }
};
