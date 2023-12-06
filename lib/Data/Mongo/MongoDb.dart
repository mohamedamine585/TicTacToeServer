import 'package:mongo_dart/mongo_dart.dart';

import '../utils.dart';
import '../../../Services/Authservice.dart';
import '../../../Services/PlayRoomService.dart';
import '../../../Services/Tokensservice.dart';
import '../../Repositories/Db.dart';

class DbRepository implements DB_Repository {
  static DbRepository instance = DbRepository.getInstance();

  // Private constructor to prevent external instantiation
  DbRepository._();

  factory DbRepository.getInstance() {
    instance = DbRepository._();

    return instance;
  }

  @override
  Future<void> init(String dbname) async {
    db = await Db.create(
        "mongodb+srv://mohamedamine:medaminetlili123@cluster0.qf8cb49.mongodb.net/$dbname");
    await db.open();
    Authservice.instance.init();
    Tokensservice.instance.init();
    PlayRoomService.instance.init();
    print(db.databaseName);
  }
}
