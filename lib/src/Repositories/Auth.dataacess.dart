import 'package:mongo_dart/mongo_dart.dart';

import '../Core/Modeles/Player.dart';

abstract class Auth_Repository {
  init();
  Future<Player?> get_playerbyId({required ObjectId id});
  Future<Player?> get_playerbyName({required String playername});
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
