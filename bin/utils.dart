import 'package:crypt/crypt.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'Servers/Gameserver/game_server.dart';
import 'Data/Services/DbService.dart';
import 'Servers/Authserver/authserver.dart';

Db db = Db("");
DbCollection playerscollection = DbCollection(db, "");
DbCollection tokenscollection = DbCollection(db, "");
DbCollection playroomscollection = DbCollection(db, "");

String hashIT(String psw) {
  return Crypt.sha256(psw, salt: "salt&&&").hash;
}

init(String dbname) async {
  final dbs = Dbservice.getInstance();
  await dbs.init(dbname);
}

String dbname = "TictactoeTest";
runServers() async {
  await init(dbname);
  await GameServer.serve();
  await AuthServer.DoJob();
}
