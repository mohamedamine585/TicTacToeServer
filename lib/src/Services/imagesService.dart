import 'dart:io';

import 'package:mime/mime.dart';

class ImagesService {
  static Future<String?> saveImage(HttpRequest request) async {
    // accessing /fileupload endpoint
    List<int> dataBytes = [];

    await for (var data in request) {
      dataBytes.addAll(data);
    }

    String boundary = request.headers.contentType?.parameters['boundary'] ?? "";
    final transformer = MimeMultipartTransformer(boundary);
    final uploadDirectory = './upload';

    final bodyStream = Stream.fromIterable([dataBytes]);
    final parts = await transformer.bind(bodyStream).toList();
    final playerid = request.response.headers.value("playerid");
    for (var part in parts) {
      final content = await part.toList();
      final contentDisposition = part.headers['content-disposition'];
      final filename = RegExp(r'filename="([^"]*)"')
          .firstMatch(contentDisposition ?? "")
          ?.group(1);

      if (!Directory(uploadDirectory).existsSync()) {
        await Directory(uploadDirectory).create();
      }
      if (filename?.split('.').last != null) {
        final image = await File(
                '$uploadDirectory/$playerid.${filename?.split('.').last}')
            .writeAsBytes(content[0]);
        return image.path;
      }
    }
    return null;
  }
}
