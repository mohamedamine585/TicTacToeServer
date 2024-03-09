import 'dart:convert';
import 'dart:io';

import 'package:tic_tac_toe_server/src/router/pipeline.dart';

import '/src/controllers/PlayRequestHandler.dart';
import '/src/controllers/PlayersManagerController.dart';

import '/src/middleware/requestmiddleware.dart';
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
          await pipeline
              .addmiddleware(checkbodyForPlayerupdate)
              .addasynchandler(updatedoc);
        } else if (request.method == "DELETE") {
        } else if (request.method == "POST") {}
        break;
      case "/test":
        request.response.statusCode == HttpStatus.ok;
        request.response.write(json.encode({"message": "Request Received"}));
        break;

      case "/activity":
        if (request.method == "GET") {
          await pipeline
              .addmiddleware(checkbodyForPlayerupdate)
              .addasynchandler(subscribeToOnlineActivity);
        } else {
          request.response.statusCode = HttpStatus.notFound;
        }

        break;

      default:
    }

    await request.response.close();
  } catch (e) {
    print(e);
  }
};
Function? onError = (e) {
  print(e);
};
