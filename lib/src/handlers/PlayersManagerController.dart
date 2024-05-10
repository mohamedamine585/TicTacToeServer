import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';

import 'package:tic_tac_toe_server/src/Services/player_service.dart';
import 'package:tic_tac_toe_server/src/Services/online_activity_service.dart';

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
Function(HttpRequest) deletePlayer = (HttpRequest request) async {
  try {
    final playerid = request.response.headers.value("playerid");
    if (playerid != null) {
      final deleted = await PlayerService.instance.deleteAccount(id: playerid);
      if (deleted) {
        request.response.write(json.encode({"message": "Account deleted"}));
      } else {
        request.response.statusCode = HttpStatus.badRequest;
      }
    } else {
      request.response.statusCode = HttpStatus.badRequest;
    }
  } catch (e) {
    print(e);
  }
  request.response.statusCode = HttpStatus.badRequest;
};

Function(HttpRequest) getdoc = (HttpRequest request) async {
  try {
    final doc = await PlayerService.instance.getdoc(
        id: request.response.headers.value("otherid") ??
            request.response.headers.value("playerid")!);

    request.response.write(json.encode(doc));
  } catch (e) {
    print(e);
  }
};
Function(HttpRequest) getOtherPlayerDoc = (HttpRequest request) async {
  try {
    final doc = await PlayerService.instance
        .getdoc(id: request.response.headers.value("otherid") ?? "");
    request.response.write(json.encode(doc));
  } catch (e) {
    print(e);
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

Function(HttpRequest) getTopPlayers = (HttpRequest request) async {
  try {
    final playerid = request.response.headers.value("playerid");
    if (playerid != null) {
      final topPlayers = await PlayerService.instance.getTopPlayers();
      request.response.write(json.encode({"topplayers": topPlayers}));
    } else {
      request.response.statusCode = HttpStatus.unauthorized;
    }
  } catch (e) {
    print(e);
  }
};
