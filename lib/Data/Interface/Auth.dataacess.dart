import 'package:mongo_dart/mongo_dart.dart';

import '../../Core/Modules/Player.dart';

abstract class Auth_dataAcess {
  init();
  Future<Player?> Signup(String playername, String password);
  Future<Player?> get_playerbyId({required ObjectId id});
  Future<Player?> get_playerbyName({required String playername});
  Future<Player?> Signin(String playername, String password);
  Future<String?> change_password(
      {required String playername,
      required String old_password,
      required String newpassword});
  Future<bool> change_name(
      {required String playername,
      required String password,
      required String new_name});
  Future<Map<String, bool>?> delete_user(
      {required String playername, required String password});
}
