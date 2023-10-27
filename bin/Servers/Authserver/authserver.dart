import 'dart:io';
import 'Services.dart';

class AuthServer {
  static late HttpServer server;

  /// ****     initialize server on localhost *****

  static Future<void> init() async {
    server = await HttpServer.bind("0.0.0.0", 8081);
    print(
        "Auth server is running on ${server.address.address} port ${server.port}");
  }

  static DoJob() async {
    await init();
    try {
      server.listen((HttpRequest authrequest) async {
        authrequest.response.headers.contentType = ContentType.json;
        authrequest.response.headers
            .add(HttpHeaders.contentTypeHeader, "application/json");
        Map<String, String> queryparm = authrequest.uri.queryParameters;
        if (authrequest.uri.path == '/Signup/') {
          await Signup(authrequest.response, queryparm);
        } else if (authrequest.uri.path == '/Signin/') {
          await Signin(authrequest.response, queryparm);
        } else if (authrequest.uri.path == '/Delete/') {
          await Delete_player(authrequest.response, queryparm);
        } else if (authrequest.uri.path == '/ChangePassword/') {
          await Change_Password(authrequest.response, queryparm);
        }

        authrequest.response.close();
      });
    } catch (e) {
      // should close gameserver
      print("cannot start authserver !");
    }
  }
}
