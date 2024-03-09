import 'dart:io';

import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../utils/consts.dart';

Function(HttpRequest) checkToken = (HttpRequest request) {
  final token = request.headers.value("Authorization");
  if (!(token?.startsWith("Bearer ") ?? false)) {
    request.response.statusCode = HttpStatus.unauthorized;
    throw Exception("Invalid token");
  }
  final jwt = JWT.verify(token?.split(" ")[1] ?? "", SecretKey(SECRET_SAUCE));
  if (jwt.payload == null) {
    request.response.statusCode = HttpStatus.unauthorized;
    throw Exception("No payload");
  }
  final playerid = jwt.payload["playerid"];
  if (playerid != null) {
    request.response.headers
        .add("playerid", playerid, preserveHeaderCase: true);
  } else {
    request.response.statusCode = HttpStatus.unauthorized;
    throw Exception("No payload");
  }
};

String? CreateJWToken(ObjectId Playerid) {
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
