import '../Data/Mongo/Auth_dataacess.dart';
import '../Data/Mongo/Playrooms_dataacess.dart';
import '../Data/Mongo/Token_dataacess.dart';
//                ^
//         Change | and use same classes name
// To change the DB service (after creating another one change )

Mongo_Auth_dataAcess AuthDataservice = Mongo_Auth_dataAcess();
Mongo_Token_dataAcess TokenDataservice = Mongo_Token_dataAcess();
Playroom_dataAcess PlayroomDataservice = Playroom_dataAcess();
