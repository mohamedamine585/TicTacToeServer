import 'package:mongo_dart/mongo_dart.dart';

Db db = Db("");
DbCollection playerscollection = DbCollection(db, "");
DbCollection tokenscollection = DbCollection(db, "");
DbCollection playroomscollection = DbCollection(db, "");
