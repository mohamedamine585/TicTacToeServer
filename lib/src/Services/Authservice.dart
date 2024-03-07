import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/Core/Modeles/Player.dart';
import 'package:tic_tac_toe_server/src/Repositories/Auth.dataacess.dart';
import 'package:tic_tac_toe_server/src/Data/Mongo/Auth_dataacess.dart';

import 'utils.dart';

class Authservice {
  Auth_Repository AuthDataservice;

  // Private constructor to prevent external instantiation
  Authservice._(this.AuthDataservice);
  static Authservice instance = Authservice._(Mongo_Auth_Repository());

  init() async {
    await AuthDataservice.init();
  }

  Future<Player?> get_playerbyId({required ObjectId id}) async {
    return await AuthDataservice.get_playerbyId(id: id);
  }

  Future<Player?> get_playerbyName({required String playername}) async {
    return await AuthDataservice.get_playerbyName(playername: playername);
  }

  Future<String?> change_password(
      {required String playername,
      required String old_password,
      required String newpassword}) async {
    return await AuthDataservice.change_password(
        playername: playername,
        old_password: old_password,
        newpassword: newpassword);
  }

  Future<bool> change_name(
      {required String playername,
      required String password,
      required String new_name}) async {
    return await AuthDataservice.change_name(
        playername: playername, password: password, new_name: new_name);
  }

  Future<Map<String, bool>?> delete_user(
      {required String playername, required String password}) async {
    return await AuthDataservice.delete_user(
        playername: playername, password: password);
  }
}
