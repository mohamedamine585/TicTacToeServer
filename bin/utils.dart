import 'package:crypt/crypt.dart';
import 'package:mongo_dart/mongo_dart.dart';

import 'Servers/authserver.dart';
import 'Servers/game_server.dart';
import 'Services/DbService.dart';

Db db = Db("");
DbCollection playerscollection = DbCollection(db, "");
DbCollection tokenscollection = DbCollection(db, "");
DbCollection playroomscollection = DbCollection(db, "");

String hashIT(String psw) {
  return Crypt.sha256(psw, salt: "salt&&&").hash;
}

init() async {
  final dbs = Dbservice.getInstance();
  await dbs.init();
}

runServer() async {
  await init();
  await GameServer.serve();
  await AuthServer.DoJob();
}
