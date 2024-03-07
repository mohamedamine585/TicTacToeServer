import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/Services/Authservice.dart';
import 'package:tic_tac_toe_server/src/Services/PlayRoomService.dart';
import 'package:tic_tac_toe_server/src/Services/Tokensservice.dart';

import '../utils.dart';

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
