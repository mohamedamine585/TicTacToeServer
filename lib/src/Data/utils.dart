import 'package:mongo_dart/mongo_dart.dart';

Db db = Db("");
DbCollection playerscollection = DbCollection(db, "playerscollection");
DbCollection tokenscollection = DbCollection(db, "tokenscollection");
DbCollection playroomscollection = DbCollection(db, "playroomscollection");
DbCollection imageslocationscollection =
    DbCollection(db, "imageslocationscollection");
