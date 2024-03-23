import 'dart:io';

import 'package:tic_tac_toe_server/src/Services/imagesService.dart';

Function(HttpRequest) updateImage = (HttpRequest request) async {
  final playerid = request.response.headers.value("playerid");

  if (playerid != null) {
    final dataBytes = await ImagesService.extractImageBytes(request);
    if (dataBytes != null) {
      final imagePath = await ImagesService.saveImage(playerid, dataBytes,
          request.headers.contentType?.parameters['boundary'] ?? "");
      if (imagePath != null) {
        request.response.write('Image uploaded successfully');
      } else {
        request.response.statusCode = HttpStatus.badRequest;
      }
    } else {
      request.response.statusCode = HttpStatus.badRequest;
    }
  } else {
    request.response.statusCode = HttpStatus.badRequest;
  }
};
Function(HttpRequest) getImage = (HttpRequest request) async {
  final image =
      File('./upload/${request.response.headers.value("playerid")}.jpg');
  if (image.existsSync()) {
    request.response
      ..headers.contentType = ContentType.binary
      ..add(await image.readAsBytes());
    request.response.write(await image.readAsBytes());
  } else {
    request.response.statusCode = HttpStatus.badRequest;
  }
};
