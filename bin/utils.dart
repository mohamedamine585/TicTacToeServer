import 'package:crypt/crypt.dart';
import 'Servers/Gameserver/game_server.dart';
import 'Data/Services/DbService.dart';
import 'Servers/Authserver/authserver.dart';

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
