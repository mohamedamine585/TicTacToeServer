import 'dart:convert';
import 'dart:io';
import '../../utils/consts.dart';
import '../../Controllers/Authservercontroller.dart';
import '../../middleware/requestmiddleware.dart';

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
            var body = json.decode(await utf8.decodeStream(authrequest));

            if (authrequest.uri.path == '/Signup/') {
              if ((await Requestmiddleware.check_request_bodyFormat(
                  request: authrequest, Jsonrequest: body))) {
                await Authserver_Controller.Signup(authrequest, body);
              } else {
                authrequest.response
                    .write(json.encode({"error": "Cannot check request body"}));
              }
            } else {
              authrequest.response.write(
                  json.encode({"error": "no such path with method request"}));
            }
            authrequest.response.close();

            break;
          case 'PUT':
            var body = json.decode(await utf8.decodeStream(authrequest));

            if ((await Requestmiddleware.check_request_token(
                request: authrequest))) {
              if ((await Requestmiddleware.check_request_bodyFormat(
                  request: authrequest, Jsonrequest: body))) {
                if (authrequest.uri.path == '/ChangePassword/') {
                  await Authserver_Controller.Change_Password(
                      authrequest, body);
                } else if (authrequest.uri.path == '/ChangeName/') {
                  await Authserver_Controller.Change_name(authrequest, body);
                } else if (authrequest.uri.path == '/Signout') {
                  ///
                  ///
                  ///
                } else {
                  authrequest.response.write(json
                      .encode({"error": "no such path with method request"}));
                }
              } else {
                authrequest.response
                    .write(json.encode({"error": "Cannot check request body"}));
              }
            } else {
              authrequest.response
                  .write(json.encode({"error": "Invalid token"}));
            }
            authrequest.response.close();
            break;

          case 'DELETE':
            if ((await Requestmiddleware.check_request_token(
                request: authrequest))) {
              if (authrequest.uri.path == '/Delete/') {
                await Authserver_Controller.Delete_player(authrequest);
              } else {
                authrequest.response.write(
                    json.encode({"error": "no such path with method request"}));
              }
            } else {
              authrequest.response
                  .write(json.encode({"error": "Invalid token"}));
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
