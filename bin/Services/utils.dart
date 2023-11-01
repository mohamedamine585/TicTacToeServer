import '../Data/Mongo/Auth_dataacess.dart';
import '../Data/Mongo/Playrooms_dataacess.dart';
import '../Data/Mongo/Token_dataacess.dart';
//                ^
//         Change | and use same classes name
// To change the DB service (after creating another one change )

Auth_dataAcess AuthDataservice = Auth_dataAcess();
Token_dataAcess TokenDataservice = Token_dataAcess();
Playroom_dataAcess PlayroomDataservice = Playroom_dataAcess();
