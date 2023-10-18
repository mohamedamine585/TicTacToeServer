import 'dart:async';
import 'dart:convert';
import 'dart:io';

import '../Modules/Player.dart';
import '../Services/Authservice.dart';

class AuthServer {
  static late HttpServer server;

  /// ****     initialize server on localhost *****

  static Future<void> init() async {
    server = await HttpServer.bind(InternetAddress("127.0.0.1"), 8081);
    print(
        "Auth server is running on ${server.address.address} port ${server.port}");
  }

  static DoJob() async {
    await init();
    server.listen((HttpRequest authrequest) async {
      Player? player;
      authrequest.response.headers.contentType = ContentType.json;
      authrequest.response.headers.add(HttpHeaders.contentTypeHeader, "json");
      Map<String, String> queryparm = authrequest.uri.queryParameters;
      if (authrequest.uri.path == '/Signup/') {
        player = await Authservice.getInstance().Signup(
            queryparm.entries.first.value,
            queryparm.entries.elementAt(1).value);

        if (player != null) {
          authrequest.response
              .write(json.encode({"message": "Player is signed up"}));
        } else {
          authrequest.response
              .write(json.encode({"message": "Signing up failed"}));
        }
      } else if (authrequest.uri.path == '/Signin/') {
        player = await Authservice.getInstance().Signin(
            queryparm.entries.first.value,
            queryparm.entries.elementAt(1).value);

        if (player != null) {
          authrequest.response
              .write(json.encode({"message": "Player is signed in"}));
        } else {
          authrequest.response
              .write(json.encode({"message": "Signing in failed"}));
        }
      }
      authrequest.response.close();
    });
  }
}
