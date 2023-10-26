import '../bin/app/Servers/Authserver/authserver.dart';
import 'app/utils.dart';

void main() async {
  await init(dbname);
  await AuthServer.DoJob();
}
