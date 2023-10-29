import 'dart:convert';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../Data/Services/Tokensservice.dart';
import '../Servers/Controllers/Gameservercontroller.dart';
import '../consts.dart';

class Tokenmiddleware {
  static Check_Token(String? token) async {
    try {
      if (token == null) {
        print("Invalid token");
        throw Exception("Invalid token");
      }
      // Verify a token (SecretKey for HMAC & PublicKey for all the others)
      final jwt = JWT.verify(token, SecretKey(SECRET_SAUCE));

      if (jwt.payload == null) {
        throw Exception("No payload");
      }
      String? fetched_token =
          await Tokensservice.getInstance().fetch_token(token: token);
      if (fetched_token != null) {
        return jwt.payload["playerid"];
      }
    } on JWTExpiredException {
      print('Jwt expired');
    } on JWTException catch (e) {
      print(e.message); // ex: invalid signature
    } catch (e) {
      print("Cannot check Token"); // ex: invalid signature
    }
    return null;
  }
}
