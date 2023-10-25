import '../Gameserver/game_server.dart';
import 'authserver.dart';

void main(List<String> args) async {
  await AuthServer.DoJob();
}
