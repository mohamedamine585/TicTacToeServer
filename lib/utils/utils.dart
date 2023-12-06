import 'package:crypt/crypt.dart';
import 'package:tic_tac_toe_server/Servers/Gameserver/game_server.dart';
import '../Servers/Authserver/authserver.dart';
import '../Data/Mongo/MongoDb.dart';

String hashIT(String psw) {
  return Crypt.sha256(psw, salt: "salt&&&").hash;
}

init(String dbname) async {
  final dbs = DbRepository.instance;
  await dbs.init(dbname);
}

String dbname = "TictactoeTest";
runServers() async {
  await init(dbname);
  await GameServer.serve();
  await AuthServer.DoJob();
}
