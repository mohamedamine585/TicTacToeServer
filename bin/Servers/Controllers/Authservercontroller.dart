import 'dart:convert';
import 'dart:io';

import '../../Core/Modules/Player.dart';
import '../../Data/Services/Authservice.dart';
import '../../Data/Services/Tokensservice.dart';

class Authserver_Controller {
  static Signup(HttpRequest request) async {
    try {
      var Jsonrequest = json.decode(await utf8.decodeStream(request));

      final player = await Authservice.getInstance()
          .Signup(Jsonrequest["playername"], Jsonrequest["password"]);

      if (player != null) {
        request.response.write(json.encode({"message": "Player is signed up"}));
      } else {
        request.response.write(json.encode({"message": "Signing up failed"}));
      }
    } catch (e) {
      print("cannot signup");
    }
  }

  static Signin(HttpRequest request) async {
    try {
      var Jsonrequest = json.decode(await utf8.decodeStream(request));

      final player = await Authservice.getInstance()
          .Signin(Jsonrequest["playername"], Jsonrequest["password"]);
      if (player != null) {
        String? token =
            await Tokensservice.getInstance().prepare_token(player: player);
        request.response.write(
            json.encode({"message": "Player is signed in", "token": token}));
      } else {
        request.response.write(json.encode({"message": "Signing in failed"}));
      }
    } catch (e) {
      print("Cannot Sign in");
    }
  }

  static Delete_player(HttpRequest request) async {
    try {
      var Jsonrequest = json.decode(await utf8.decodeStream(request));

      final resp = await Authservice.getInstance().delete_user(
          playername: Jsonrequest["playername"],
          password: Jsonrequest["password"]);
      if (resp?.isNotEmpty ?? false) {
        request.response.write(json.encode({"message": "player deleted"}));
      } else {
        request.response
            .write(json.encode({"message": "failed to delete player"}));
      }
    } catch (e) {
      print("Cannot Delete player");
    }
  }

  static Change_Password(HttpRequest request) async {
    try {
      var Jsonrequest = json.decode(await utf8.decodeStream(request));

      if (await Authservice.getInstance().change_password(
          playername: Jsonrequest["playername"],
          old_password: Jsonrequest["old_password"],
          newpassword: Jsonrequest["new_password"])) {
        request.response.write(json.encode({"message": "password changed"}));
      } else {
        request.response
            .write(json.encode({"message": "failed to change password"}));
      }
    } catch (e) {
      print("Cannot change password");
    }
  }

  static Change_name(HttpRequest request) async {
    try {
      var Jsonrequest = json.decode(await utf8.decodeStream(request));

      Player? player = await Authservice.getInstance()
          .get_playerbyName(playername: Jsonrequest["playername"]);
      if (player != null) {
        if (await Authservice.getInstance().change_name(
            playername: player.playername,
            password: Jsonrequest["password"],
            new_name: Jsonrequest["new_name"])) {
          request.response.write(json.encode(
              {"message": "playername changed to ${Jsonrequest["new_name"]}"}));
        } else {
          request.response
              .write(json.encode({"message": "failed to change playername"}));
        }
      } else {
        request.response
            .write(json.encode({"message": "failed to change playername"}));
      }
    } catch (e) {
      print("Cannot change name !");
    }
  }
}
