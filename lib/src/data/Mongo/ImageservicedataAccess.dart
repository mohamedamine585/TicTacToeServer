import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/data/utils.dart';

class ImageLocationServiceDataAcess {
  static Future<WriteResult?> saveImageLocation(
      {required String playerId,
      required String location,
      required String path}) async {
    try {
      final writeResult = await imageslocationscollection.insertOne({
        "location": location,
        "playerid": ObjectId.fromHexString(playerId),
        "path": path
      });
      return writeResult;
    } catch (e) {
      print(e);
    }
    return null;
  }

  static Future<Map<String, dynamic>?> fetchImageLocation(
      {required String playerId}) async {
    try {
      final imageLocation = await imageslocationscollection
          .findOne(where.eq("playerid", ObjectId.fromHexString(playerId)));
      if (imageLocation != null) {
        return imageLocation;
      }
    } catch (e) {
      print(e);
    }
    return null;
  }
}
