import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/Core/Modeles/Player.dart';
import 'package:tic_tac_toe_server/src/Repositories/Token.dataacess.dart';
import 'package:tic_tac_toe_server/src/Data/Mongo/Token_dataacess.dart';

class Tokensservice {
  Token_Repository TokenDataservice;

  // Private constructor to prevent external instantiation
  Tokensservice._(this.TokenDataservice);
  static Tokensservice instance = Tokensservice._(Mongo_Token_Repository());

  init() async {
    await TokenDataservice.init();
  }

  Future<void> make_available_all_tokens() async {
    await TokenDataservice.make_available_all_tokens();
  }

  Future<void> make_available_token(String token) async {
    await TokenDataservice.make_available_token(token);
  }

  /// deprecated

  Future<String?> prepare_token({required Player player}) async {
    return await TokenDataservice.prepare_token(player: player);
  }

  Future<String?> store_token(
      {required String token, required ObjectId Id}) async {
    return await TokenDataservice.store_token(token: token, Id: Id);
  }

  Future<bool?> delete_token({required ObjectId id}) async {
    return await TokenDataservice.delete_token(id: id);
  }

  Future<Player?> fetch_player_byToken({required String token}) async {
    return await TokenDataservice.fetch_player_byToken(token: token);
  }

  Future<String?> change_token_status(ObjectId id) async {
    return await TokenDataservice.change_token_status(id);
  }

  Future<String?> fetch_token({required String token}) async {
    return await TokenDataservice.fetch_token(token: token);
  }

  Future<String?> fetch_nonfree_token({required String token}) async {
    return await TokenDataservice.fetch_nonfree_token(token: token);
  }

  Future<String?> fetch_token_free_byId({required ObjectId id}) async {
    return await TokenDataservice.fetch_token_free_byId(id: id);
  }
}
