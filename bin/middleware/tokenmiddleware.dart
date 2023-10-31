import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';

import '../consts.dart';

class Tokenmiddleware {
  static Future<String?> Check_Token(String? token) async {
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
      return jwt.payload["playerid"];
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
