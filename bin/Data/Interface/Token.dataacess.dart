import 'package:mongo_dart/mongo_dart.dart';

import '../../Core/Modules/Player.dart';

abstract class Token_dataacess {
  init();
  Future<void> make_available_all_tokens();
  Future<void> make_available_token(String token);
  Future<String?> prepare_token({required Player player});
  Future<String?> store_token({required String token, required ObjectId Id});
  Future<bool?> delete_token({required ObjectId id});
  Future<String?> change_token_status(ObjectId id);
  Future<String?> fetch_nonfree_token({required String token});

  Future<String?> fetch_token({required String token});
  Future<String?> fetch_token_free_byId({required ObjectId id});
}
