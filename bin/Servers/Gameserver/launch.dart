import 'game_server.dart';

void main(List<String> args) async {
  await GameServer.serve();
}
