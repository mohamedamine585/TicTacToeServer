import 'dart:convert';
import 'dart:io';

import '../../Core/Modules/Player.dart';
import '../../Services/Authservice.dart';
import '../../Services/Tokensservice.dart';
import '../../middleware/tokenmiddleware.dart';

class Authserver_Controller {
  static Signup(HttpRequest request, dynamic body) async {
    try {
      final player = await Authservice.getInstance()
          .Signup(body["playername"], body["password"]);

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
      final player = await Authservice.getInstance().Signin(
          request.uri.queryParameters["playername"]!,
          request.uri.queryParameters["password"]!);
      if (player != null) {
        String token = Tokenmiddleware.CreateJWToken(player.Id)!;
        await Tokensservice.getInstance()
            .store_token(token: token, Id: player.Id);

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
      Player? player = await Authservice.getInstance()
          .get_playerbyName(playername: Jsonrequest["playername"]);

      final resp = await Authservice.getInstance().delete_user(
          playername: Jsonrequest["playername"],
          password: Jsonrequest["password"]);
      await Tokensservice.getInstance().delete_token(id: player!.Id);
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

  static Change_Password(HttpRequest request, dynamic Jsonrequest) async {
    try {
      Player? player = await Authservice.getInstance()
          .get_playerbyName(playername: Jsonrequest["playername"]);
      if (player != null) {
        String? newToken = await Authservice.getInstance().change_password(
            playername: Jsonrequest["playername"],
            old_password: Jsonrequest["password"],
            newpassword: Jsonrequest["new_password"]);

        if (newToken != null) {
          request.response.write(
              json.encode({"message": "password changed", "token": newToken}));
        } else {
          request.response
              .write(json.encode({"message": "failed to change password"}));
        }
      } else {
        request.response
            .write(json.encode({"message": "failed to change password"}));
      }
    } catch (e) {
      print("Cannot change password");
    }
  }

  static Change_name(HttpRequest request, dynamic Jsonrequest) async {
    try {
      Player? player = await Authservice.getInstance()
          .get_playerbyName(playername: Jsonrequest["playername"]);
      if (player != null) {
        if (await Authservice.getInstance().change_name(
            playername: player.playername,
            password: Jsonrequest["password"],
            new_name: Jsonrequest["new_name"])) {
          String? newToken = await Tokensservice.getInstance().store_token(
              token: Tokenmiddleware.CreateJWToken(player.Id)!, Id: player.Id);
          if (newToken != null) {
            request.response.write(json.encode({
              "message": "playername changed to ${Jsonrequest["new_name"]}",
              "token": newToken
            }));
          } else {
            request.response
                .write(json.encode({"message": "failed to change playername"}));
          }
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
