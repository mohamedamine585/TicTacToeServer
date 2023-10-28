import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';

import '../../Core/Modules/Player.dart';
import '../../Data/Services/Authservice.dart';
import '../../Data/Services/Tokensservice.dart';

class Authserver_Controller {
  static Signup(HttpResponse response, Map<String, String> queryparm) async {
    try {
      final player = await Authservice.getInstance().Signup(
          queryparm.entries.first.value, queryparm.entries.elementAt(1).value);

      if (player != null) {
        response.write(json.encode({"message": "Player is signed up"}));
      } else {
        response.write(json.encode({"message": "Signing up failed"}));
      }
    } catch (e) {
      print("cannot signup");
    }
  }

  static Signin(HttpResponse response, Map<String, String> queryparm) async {
    try {
      final player = await Authservice.getInstance().Signin(
          queryparm.entries.first.value, queryparm.entries.elementAt(1).value);
      if (player != null) {
        String? token =
            await Tokensservice.getInstance().prepare_token(player: player);
        response.write(
            json.encode({"message": "Player is signed in", "token": token}));
      } else {
        response.write(json.encode({"message": "Signing in failed"}));
      }
    } catch (e) {
      print("Cannot Sign in");
    }
  }

  static Delete_player(
      HttpResponse response, Map<String, String> queryparm) async {
    try {
      final resp = await Authservice.getInstance().delete_user(
          playername: queryparm.entries.first.value,
          password: queryparm.entries.elementAt(1).value);
      response.write(json.encode(resp));
    } catch (e) {
      print("Cannot Delete player");
    }
  }

  static Change_Password(
      HttpResponse response, Map<String, String> queryparm) async {
    try {
      if (await Authservice.getInstance().change_password(
          id: ObjectId.fromHexString(queryparm.entries.first.value),
          old_password: queryparm.entries.elementAt(1).value,
          newpassword: queryparm.entries.elementAt(2).value)) {
        response.write(json.encode({"message": "password changed"}));
      } else {
        response.write(json.encode({"message": "failed to change password"}));
      }
    } catch (e) {
      print("Cannot change password");
    }
  }

  static Change_name(
      HttpResponse response, Map<String, String> queryparm) async {
    try {
      Player? player = await Authservice.getInstance()
          .get_playerbyName(playername: queryparm.values.first);
      if (player != null) {
        if (await Authservice.getInstance().change_Name(
            id: player.Id,
            old_name: player.playername,
            new_name: queryparm.values.elementAt(1))) {
          response.write(json.encode({
            "message": "playername changed to ${queryparm.values.elementAt(1)}"
          }));
        }
      } else {
        response.write(json.encode({"message": "failed to change playername"}));
      }
    } catch (e) {
      print("Cannot change name !");
    }
  }
}
