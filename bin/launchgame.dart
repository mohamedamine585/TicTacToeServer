import '../bin/app/Servers/Gameserver/game_server.dart';
import 'app/utils.dart';

void main() async {
  await init(dbname);
  await GameServer.serve();
}
