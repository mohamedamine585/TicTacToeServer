import 'dart:io';

import '../Services/Tokensservice.dart';
import 'tokenmiddleware.dart';

class Requestmiddleware {
  static Future<bool> check_request({required HttpRequest request}) async {
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
