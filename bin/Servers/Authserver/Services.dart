import 'dart:convert';
import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';

import '../../Services/Authservice.dart';
import '../../Services/Tokensservice.dart';

Signup(HttpResponse response, Map<String, String> queryparm) async {
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

Signin(HttpResponse response, Map<String, String> queryparm) async {
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

Delete_player(HttpResponse response, Map<String, String> queryparm) async {
  try {
    final resp = await Authservice.getInstance().delete_user(
        playername: queryparm.entries.first.value,
        password: queryparm.entries.elementAt(1).value);
    response.write(json.encode(resp));
  } catch (e) {
    print("Cannot Delete player");
  }
}

Change_Password(HttpResponse response, Map<String, String> queryparm) async {
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
