import 'package:mongo_dart/mongo_dart.dart';

Db db = Db("");
DbCollection playerscollection = DbCollection(db, "");
DbCollection tokenscollection = DbCollection(db, "");
DbCollection playroomscollection = DbCollection(db, "");

const PORT_GAME = 8080;

const PORT_AUTH = 8081;

const HOST_GAME = '0.0.0.0';
const HOST_AUTH = '0.0.0.0';
