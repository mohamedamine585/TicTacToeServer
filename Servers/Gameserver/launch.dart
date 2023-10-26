import '../../bin/app/utils.dart';
import '../../bin/Servers/Gameserver/game_server.dart';

void main(List<String> args) async {
  await init(dbname);
  await GameServer.serve();
}
