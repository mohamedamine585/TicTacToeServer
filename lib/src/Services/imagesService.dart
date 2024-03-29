import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:mime/mime.dart';

class ImagesService {
  static List<String> extensions = ['jpg', 'png', 'jpeg'];
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
      final imageextension = filename?.split('.').last;

      if (!Directory(uploadDirectory).existsSync()) {
        await Directory(uploadDirectory).create();
      }

      if (imageextension != null && extensions.contains(imageextension)) {
        deleteOldImageFiles(
            uploadDirectory: uploadDirectory,
            playerid: playerid,
            imageextension: imageextension);
        final image = await File(
                '$uploadDirectory/$playerid.${filename?.split('.').last}')
            .writeAsBytes(content[0]);
        return image.path;
      }
    }
    return null;
  }

  static Future<Uint8List?> compressImage(Uint8List imageBytes) async {
    try {
      final image = decodeImage(imageBytes);

      if (image != null) {
        // Compress the image
        int targetWidth = 200;
        int targetHeight = (image.height * (targetWidth / image.width)).round();
        Image copressedImage =
            Image.fromResized(image, width: targetWidth, height: targetHeight);
        return copressedImage.getBytes();
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static void deleteOldImageFiles(
      {required String uploadDirectory,
      required String playerid,
      required String imageextension}) async {
    try {
      for (String ext in extensions) {
        if (ext != imageextension) {
          if (File('$uploadDirectory/$playerid.$ext').existsSync()) {
            await File('$uploadDirectory/$playerid.$ext').delete();
          }
        }
      }
    } catch (e) {
      print(e);
    }
  }
}
