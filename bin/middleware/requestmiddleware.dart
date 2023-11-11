import 'dart:io';

import '../Services/Tokensservice.dart';
import 'tokenmiddleware.dart';

class Requestmiddleware {
  static Future<bool> check_request_bodyFormat(
      {required HttpRequest request, required dynamic Jsonrequest}) async {
    try {
      switch (request.method) {
        case "PUT":
          switch (request.uri.path) {
            case "/ChangeName/":
              if ((Jsonrequest["new_name"] != null) &&
                  (Jsonrequest["playername"] != null) &&
                  (Jsonrequest["password"] != null)) {
                return true;
              }
              break;
            case "/ChangePassword/":
              if ((Jsonrequest["new_password"] != null) &&
                  (Jsonrequest["playername"] != null) &&
                  (Jsonrequest["password"] != null)) {
                return true;
              }
              break;
          }
          break;

        case "POST":
          switch (request.uri.path) {
            case "/Signup/":
              if ((Jsonrequest["playername"] != null) &&
                  (Jsonrequest["password"] != null)) {
                return true;
              }
              break;
          }
          break;

        default:
      }
    } catch (e) {
      print("Cannot check Body format !");
    }
    return false;
  }

  static Future<bool> check_signinRequest(
      {required HttpRequest request}) async {
    try {
      return request.uri.queryParameters["playername"] != null &&
          request.uri.queryParameters["password"] != null &&
          request.uri.queryParameters.values.elementAt(2) !=
              null; // this is madness
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
              (await Tokensservice.getInstance()
                      .fetch_nonfree_token(token: token!)) !=
                  null) {
            return true;
          }

          break;
        case ("DELETE"):
          if ((Tokenmiddleware.Check_Token(request.headers.value("token")) !=
                  null) &&
              (await Tokensservice.getInstance()
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
