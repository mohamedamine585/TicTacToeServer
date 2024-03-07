import 'dart:convert';
import 'dart:io';

import 'package:tic_tac_toe_server/src/Services/Tokensservice.dart';

import 'tokenmiddleware.dart';

class Requestmiddleware {
  static Future<Map<String, dynamic>?> checkbodyForPlayerupdate(
      {required HttpRequest request}) async {
    try {
      var body = json.decode(await utf8.decodeStream(request));
      if (body["email"] != null ||
          body["name"] != null ||
          body["lastconnection"] != null) {
        if (body["email"].length != 0 && body["name"].length != 0) {
          return body;
        }
      }
      request.response.statusCode = HttpStatus.badRequest;
      request.response.write(json.encode({"message": "Invalid Body"}));
    } catch (e) {
      print(e);
    }
    return null;
  }

  static bool check_signinRequest({required HttpRequest request}) {
    try {
      return request.uri.queryParameters["playername"] != null &&
          request.uri.queryParameters["password"] != null;
    } catch (e) {
      print("Cannot check sign in params");
    }
    return false;
  }

  static Future<bool> check_request_token(
      {required HttpRequest request}) async {
    try {
      final token = request.headers.value("token");
      switch (request.method) {
        case ("PUT"):
          if ((Tokenmiddleware.Check_Token(token) != null) &&
              (await Tokensservice.instance
                      .fetch_nonfree_token(token: token!)) !=
                  null) {
            return true;
          }

          break;
        case ("DELETE"):
          if ((Tokenmiddleware.Check_Token(request.headers.value("token")) !=
                  null) &&
              (await Tokensservice.instance
                      .fetch_nonfree_token(token: token!)) !=
                  null) {
            return true;
          }

          break;
      }
    } catch (e) {
      print("Cannot check request !");
    }
    return false;
  }
}
