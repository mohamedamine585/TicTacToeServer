import 'dart:io';
import 'dart:typed_data';

import 'package:image/image.dart';
import 'package:mime/mime.dart';
import 'package:tic_tac_toe_server/src/Data/Mongo/ImageservicedataAccess.dart';
import 'package:tic_tac_toe_server/src/utils/consts.dart';

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

      if (!Directory(uploadDirectory).existsSync()) {
        await Directory(uploadDirectory).create();
      }
      final compressedBytes =
          await compressImage(Uint8List.fromList(content[0]), IMG_QUALITY);
      final image = await File('$uploadDirectory/$playerid.jpg')
          .writeAsBytes(compressedBytes as List<int>);
      return image.path;
    }

    return null;
  }

  static Future<Uint8List?> compressImage(
      Uint8List imageBytes, int quality) async {
    try {
      final image = decodeImage(imageBytes);

      if (image != null) {
        // Compress the image

        return encodeJpg(image, quality: quality);
      }
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getImageLocation(String playerId) async {
    try {
      return await ImageLocationServiceDataAcess.fetchImageLocation(
          playerId: playerId);
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<void> saveImageLocation(
      String playerId, String location, String path) async {
    try {
      await ImageLocationServiceDataAcess.saveImageLocation(
          playerId: playerId, location: location, path: path);
    } catch (e) {
      print(e);
    }
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
