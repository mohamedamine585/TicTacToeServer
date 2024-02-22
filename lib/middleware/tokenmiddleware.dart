import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../../utils/consts.dart';

class Tokenmiddleware {
  static String? Check_Token(String? token) {
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

  static String? CreateJWToken(ObjectId Playerid) {
    try {
      final jwt = JWT(
        {
          'playerid': Playerid,
        },
        issuer: 'https://github.com/jonasroussel/dart_jsonwebtoken',
      );

      return jwt.sign(SecretKey(SECRET_SAUCE));
    } catch (e) {
      print("Problem to create jwt token");
    }
    return null;
  }
}
