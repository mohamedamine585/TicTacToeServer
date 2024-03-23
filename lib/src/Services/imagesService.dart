import 'dart:io';

import 'package:mime/mime.dart';

class ImagesService {
  static Future<List<int>?> extractImageBytes(HttpRequest request) async {
    try {
      // accessing /fileupload endpoint
      List<int> dataBytes = [];

      await for (var data in request) {
        dataBytes.addAll(data);
      }
      return dataBytes;
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<String?> saveImage(
      String playerid, List<int> dataBytes, String? boundary) async {
    final transformer = MimeMultipartTransformer(boundary ?? "");
    final uploadDirectory = './upload';

    final bodyStream = Stream.fromIterable([dataBytes]);
    final parts = await transformer.bind(bodyStream).toList();
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
