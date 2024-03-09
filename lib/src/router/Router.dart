import 'dart:convert';
import 'dart:io';

import 'package:tic_tac_toe_server/src/controllers/PlayRequestHandler.dart';
import 'package:tic_tac_toe_server/src/controllers/PlayersManagerController.dart';

import 'package:tic_tac_toe_server/src/middleware/requestmiddleware.dart';
import 'package:tic_tac_toe_server/src/middleware/tokenmiddleware.dart';

void Function(HttpRequest) router = (HttpRequest request) async {
  String? playerid;
  try {
    playerid = Tokenmiddleware.Check_Token(request);
    if (playerid != null) {
      switch (request.requestedUri.path) {
        case "/":

          // v1 of match making
          await handlePlayRequest(request, playerid);

          break;
        case "/player":
          if (request.method == "GET") {
            request.response.write(json.encode(
                await PlayersManagerController.getdoc(playerid: playerid)));
          } else if (request.method == "PUT") {
            final reqBody = await Requestmiddleware.checkbodyForPlayerupdate(
                request: request);
            if (reqBody != null) {
              final updateddoc = await PlayersManagerController.updatedoc(
                  playerupdate: reqBody, id: playerid);
              if (updateddoc != null) {
                request.response
                    .write(json.encode({"message": "Player Updated"}));
              }
            }
          } else if (request.method == "DELETE") {
          } else if (request.method == "POST") {}
          break;
        case "/test":
          request.response.statusCode == HttpStatus.ok;
          request.response.write(json.encode({"message": "Request Received"}));
          break;

        case "/activity":
          if (request.method == "GET") {
            await PlayersManagerController.subscribeToOnlineActivity(
                request: request);
          } else {
            request.response.statusCode = HttpStatus.notFound;
          }

          break;

        default:
      }
    } else {
      request.response.statusCode == HttpStatus.unauthorized;
      request.response.write(json.encode({"message": "Invalid token"}));
    }
    await request.response.close();
  } catch (e) {
    print(e);
  }
};
Function? onError = (e) {
  print(e);
};
