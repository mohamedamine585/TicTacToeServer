import 'Servers/Gameserver/game_server.dart';
import 'utils.dart';

void main() async {
  await init(dbname);
  await GameServer.serve();
}
