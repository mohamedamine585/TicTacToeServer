import 'package:crypt/crypt.dart';

String hashIT(String psw) {
  return Crypt.sha256(psw, salt: "salt&&&").hash;
}

String dbname = "TictactoeTest";
