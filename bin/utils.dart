import 'package:crypt/crypt.dart';
import 'package:mongo_dart/mongo_dart.dart';

Db db = Db("");
DbCollection playerscollection = DbCollection(db, "");
DbCollection tokenscollection = DbCollection(db, "");
String hashIT(String psw) {
  return Crypt.sha256(psw, salt: "salt&&&").hash;
}
