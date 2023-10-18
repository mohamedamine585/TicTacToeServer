import 'Servers/authserver.dart';
import 'Servers/game_server.dart';
import 'Services/DbService.dart';

void main() async {
  final dbs = Dbservice.getInstance();
  await dbs.init();
  await GameServer.serve();
  await AuthServer.DoJob();
}
