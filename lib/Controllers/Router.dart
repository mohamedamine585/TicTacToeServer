import 'dart:convert';
import 'dart:io';

import 'package:tic_tac_toe_server/Controllers/Gameservercontroller.dart';
import 'package:tic_tac_toe_server/middleware/gamemiddleware.dart';
import 'package:tic_tac_toe_server/middleware/requestmiddleware.dart';
import 'package:tic_tac_toe_server/middleware/tokenmiddleware.dart';

import '../../Services/PlayRoomService.dart';

class Router {
  static route(HttpRequest request) async {
    String? playerid;
    try {
      playerid =
          Tokenmiddleware.Check_Token(request.headers.value("Authorization"));
      if (playerid != null) {
        switch (request.requestedUri.path) {
          case "/":
            final roomid =
                await GameMiddleware.checkforSepecificRoom(request: request);

            await Gameserver_controller.MakeHimPlay(request, roomid, playerid);

            break;
          case "/player":
            if (request.method == "GET") {
              request.response.write(json
                  .encode(await PlayRoomService.instance.getdoc(id: playerid)));
            } else if (request.method == "PUT") {
              final reqBody = await Requestmiddleware.checkbodyForPlayerupdate(
                  request: request);
              if (reqBody != null) {
                final updateddoc = await PlayRoomService.instance
                    .updatePlayer(playerupdate: reqBody, id: playerid);
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
            request.response
                .write(json.encode({"message": "Request Received"}));
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
  }
}
