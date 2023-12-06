import 'Servers/Authserver/authserver.dart';
import 'utils/utils.dart';

void main() async {
  await init(dbname);
  await AuthServer.DoJob();
}
