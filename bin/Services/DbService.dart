import 'package:mongo_dart/mongo_dart.dart';

import '../utils.dart';
import 'Authservice.dart';
import 'PlayRoomService.dart';
import 'Tokensservice.dart';

class Dbservice {
  static Dbservice _instance = Dbservice.getInstance();

  // Private constructor to prevent external instantiation
  Dbservice._();

  factory Dbservice.getInstance() {
    _instance = Dbservice._();

    return _instance;
  }

  Future<void> init(String dbname) async {
    db = await Db.create(
        "mongodb+srv://mohamedamine:medaminetlili123@cluster0.qf8cb49.mongodb.net/$dbname");
    await db.open();
    Authservice.getInstance().init();
    Tokensservice.getInstance().init();
    PlayRoomService.getInstance().init();
    print(db.databaseName);
  }
}
