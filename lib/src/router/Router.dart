import 'dart:convert';
import 'dart:io';

import 'package:tic_tac_toe_server/src/Controllers/PlayersManagerController.dart';
import 'package:tic_tac_toe_server/src/data/Mongo/Playrooms_dataacess.dart';
import 'package:tic_tac_toe_server/src/middleware/requestmiddleware.dart';

import 'package:tic_tac_toe_server/src/router/pipeline.dart';

import '/src/controllers/PlayRequestHandler.dart';

import '/src/middleware/tokenmiddleware.dart';

void Function(HttpRequest) router = (HttpRequest request) async {
  Pipeline pipeline = Pipeline(request);

  try {
    pipeline.addmiddleware(checkToken);
    switch (request.requestedUri.path) {
      case "/":
        await pipeline.addasynchandler(handlePlayRequestModern);
        break;
      case "/player":
        if (request.method == "GET") {
          await pipeline.addasynchandler(getdoc);
        } else if (request.method == "PUT") {
          await pipeline.addasyncmiddleware(checkbodyForPlayerupdate);
          await pipeline.addasyncmiddleware(checkemailuniqueness);
          await pipeline.addasynchandler(updatePlayer);
        } else if (request.method == "DELETE") {
        } else if (request.method == "POST") {}
        break;
      case "/health":
        request.response.statusCode == HttpStatus.ok;
        request.response.write(json.encode({"message": "Request Received"}));
        break;

      case "/activity":
        if (request.method == "GET") {
          await pipeline.addasynchandler(subscribeToOnlineActivity);
        } else {
          request.response.statusCode = HttpStatus.notFound;
        }
        break;
      case "/history":
        if (request.method == "GET") {
          await pipeline.addasynchandler(getPlayerHistory);
        }

        break;

      case "/fix":
        await Mongo_Playroom_Repository()
            .closeSpecificPlayRoom(roomid: "65f8b351c671a1e54763e81d");
        break;
      default:
        request.response.statusCode = HttpStatus.notFound;
    }
  } catch (e) {
    print(e);
  } finally {
    await pipeline.close(request);
  }
};
Function? onError = (e) {
  print(e);
};
