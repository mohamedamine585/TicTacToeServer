import 'dart:io';
import '../Controllers/Authservercontroller.dart';

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
          await Authserver_Controller.Signup(authrequest.response, queryparm);
        } else if (authrequest.uri.path == '/Signin/') {
          await Authserver_Controller.Signin(authrequest.response, queryparm);
        } else if (authrequest.uri.path == '/Delete/') {
          await Authserver_Controller.Delete_player(
              authrequest.response, queryparm);
        } else if (authrequest.uri.path == '/ChangePassword/') {
          await Authserver_Controller.Change_Password(
              authrequest.response, queryparm);
        }

        authrequest.response.close();
      });
    } catch (e) {
      // should close gameserver
      print("cannot start authserver !");
    }
  }
}
