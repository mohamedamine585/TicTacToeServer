import 'package:crypt/crypt.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../app/Servers/Gameserver/game_server.dart';
import 'Services/DbService.dart';
import '../app/Servers/Authserver/authserver.dart';

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
runServer() async {
  await init(dbname);
  await GameServer.serve();
  await AuthServer.DoJob();
}