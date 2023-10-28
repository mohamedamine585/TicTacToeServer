import 'dart:convert';
import 'dart:io';
import '../../consts.dart';
import '../Controllers/Authservercontroller.dart';

class AuthServer {
  static late HttpServer server;

  /// ****     initialize server on localhost *****

  static Future<void> init() async {
    server = await HttpServer.bind(HOST_AUTH, PORT_AUTH);
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
        switch (authrequest.method) {
          case 'GET':
            if (authrequest.uri.path == '/Signin/') {
              await Authserver_Controller.Signin(authrequest);
            } else {
              authrequest.response.write(
                  json.encode({"error": "no such path with method request"}));
            }
            authrequest.response.close();

            break;
          case 'POST':
            if (authrequest.uri.path == '/Signup/') {
              await Authserver_Controller.Signup(authrequest);
            } else {
              authrequest.response.write(
                  json.encode({"error": "no such path with method request"}));
            }
            authrequest.response.close();

            break;
          case 'PUT':
            if (authrequest.uri.path == '/ChangePassword/') {
              await Authserver_Controller.Change_Password(authrequest);
            } else if (authrequest.uri.path == '/ChangeName/') {
              await Authserver_Controller.Change_name(authrequest);
            } else {
              authrequest.response.write(
                  json.encode({"error": "no such path with method request"}));
            }
            authrequest.response.close();
            break;
          case 'DELETE':
            if (authrequest.uri.path == '/Delete/') {
              await Authserver_Controller.Delete_player(authrequest);
            } else {
              authrequest.response.write(
                  json.encode({"error": "no such path with method request"}));
            }
            authrequest.response.close();
            break;

          default:
            authrequest.response.close();
        }
      });
    } catch (e) {
      // should close gameserver
      print("cannot start authserver !");
    }
  }
}
