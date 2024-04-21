import 'dart:io';

import 'package:http/http.dart';
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
            playerid, Platform.environment["PUBLIC_HOST"] as String, imagePath);
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
      imageLocation["location"] == Platform.environment["PUBLIC_HOST"]) {
    final image = File(imageLocation["path"]);

    if (image.existsSync()) {
      request.response.statusCode = 200;
      request.response
        ..headers.contentType = ContentType.binary
        ..add(await image.readAsBytes());
    } else {
      request.response.statusCode = HttpStatus.notFound;
    }
  } else if (imageLocation != null) {
    // ************ should use a redirect but can't send headers (specifically the token ) with a redirection ******
    final response = await get(
        Uri.parse("https://${imageLocation["location"]}/player/image"),
        headers: {
          "authorization": request.headers.value("authorization") ?? ""
        });
    if (response.statusCode == 200) {
      request.response.add(response.bodyBytes);
    } else {
      request.response.statusCode = HttpStatus.notFound;
    }
  } else {
    request.response.statusCode = HttpStatus.notFound;
  }
};
