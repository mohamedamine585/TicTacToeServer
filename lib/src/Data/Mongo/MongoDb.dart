import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/services/player_service.dart';
import '../utils.dart';
import 'package:tic_tac_toe_server/src/services/PlayroomService.dart';
import 'package:tic_tac_toe_server/src/services/TokenService.dart';

class DbRepository {
  static DbRepository instance = DbRepository.getInstance();

  // Private constructor to prevent external instantiation
  DbRepository._();

  factory DbRepository.getInstance() {
    instance = DbRepository._();

    return instance;
  }

  Future<void> init(String dbname) async {
    db = await Db.create(
        "mongodb+srv://mohamedamine:medaminetlili123@cluster0.qf8cb49.mongodb.net/$dbname");
    await db.open();

    PlayerService.instance.init(db);
    Tokensservice.instance.init(db);
    PlayRoomService.instance.init(db);
  }
}
