import 'package:crypt/crypt.dart';
import 'package:dotenv/dotenv.dart';

String hashIT(String psw) {
  return Crypt.sha256(psw, salt: "salt&&&").hash;
}

String dbname = "TictactoeTest";
DotEnv env = DotEnv();
