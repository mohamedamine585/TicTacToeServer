import 'dart:io';

import 'package:tic_tac_toe_server/src/services/imagesService.dart';

Function(HttpRequest) updateImage = (HttpRequest request) async {
  final playerid = request.response.headers.value("playerid");

  if (playerid != null) {
    final imageBytes = await ImagesService.extractImageBytes(request);
    if (imageBytes != null) {
      final imagePath = await ImagesService.saveImage(playerid, imageBytes,
          request.headers.contentType?.parameters['boundary'] ?? "");

      if (imagePath != null) {
        await ImagesService.saveImageLocation(
            playerid, InternetAddress.anyIPv4.host, imagePath);
        request.response.write('Image uploaded successfully');
      } else {
        request.response.statusCode = HttpStatus.badRequest;
      }
    }
  } else {
    request.response.statusCode = HttpStatus.badRequest;
  }
};
Function(HttpRequest) deleteImage = (HttpRequest request) async {
  final playerid = request.response.headers.value("playerid");
  final image = File('./upload/ $playerid.jpg');
  if (image.existsSync()) {
    ImagesService.deleteOldImageFiles(
        uploadDirectory: './upload',
        playerid: playerid ?? "",
        imageextension: 'jpg');
  } else {
    request.response.statusCode = HttpStatus.badRequest;
  }
};
Function(HttpRequest) getImage = (HttpRequest request) async {
  final playerId = request.response.headers.value("otherid") ??
      request.response.headers.value("playerid");

  final imageLocation = await ImagesService.getImageLocation(playerId ?? "");

  if (imageLocation != null &&
      imageLocation["location"] == InternetAddress.anyIPv4) {
    final image = File(imageLocation["path"]);

    if (image.existsSync()) {
      request.response
        ..headers.contentType = ContentType.binary
        ..add(await image.readAsBytes());
      request.response.write(await image.readAsBytes());
    } else {
      request.response.statusCode = HttpStatus.notFound;
    }
  } else {
    request.response.statusCode = HttpStatus.notFound;
  }
};
