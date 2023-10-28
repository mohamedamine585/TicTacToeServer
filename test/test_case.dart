import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';

import 'package:test/test.dart';

import '../bin/consts.dart';

test_authandgameserver(
    List<String> playernames, List<String> passwords, int players) {
  var message0;
  group('************** Test ***************', () {
    group('**********  Test Create***************', () {
      for (int i = 0; i < players - 2; i++) {
        group('********** Test case $i **************', () {
          group(' **************    Player ${i / 2} 0    *************** ', () {
            var token0;
            message0 = "Room created";

            test('Signup', () async {
              var response = await get(Uri.parse(
                  'http://$HOST_AUTH:$PORT_AUTH/Signup/?playername=${playernames[i]}&password=${passwords[i]}'));
              expect(
                  jsonDecode(response.body)["message"], "Player is signed up");
            });

            test('Signin', () async {
              var response = await get(Uri.parse(
                  'http://$HOST_AUTH:$PORT_AUTH/Signin/?playername=${playernames[i]}&password=${passwords[i]}'));
              token0 = jsonDecode(response.body)["token"];
              expect(
                  jsonDecode(response.body)["message"], "Player is signed in");
            });

            test('Ask To Play 0', () async {
              WebSocket player0 = await WebSocket.connect(
                  'http://$HOST_GAME:$PORT_GAME',
                  headers: {"token": token0});
              player0.listen((event) {
                expect(jsonDecode(event)["message"], message0);
              }, onDone: () {
                player0.close();
              });
            });
          });
          group(' **************   Player $i 1   *************** ', () {
            var token1;
            test('Signup', () async {
              var response = await get(Uri.parse(
                  'http://$HOST_AUTH:$PORT_AUTH/Signup/?playername=${playernames[i + 1]}&password=${passwords[i + 1]}'));
              expect(
                  jsonDecode(response.body)["message"], "Player is signed up");
            });

            test('Signin', () async {
              var response = await get(Uri.parse(
                  'http://$HOST_AUTH:$PORT_AUTH/Signin/?playername=${playernames[i + 1]}&password=${passwords[i + 1]}'));
              token1 = jsonDecode(response.body)["token"];
              expect(
                  jsonDecode(response.body)["message"], "Player is signed in");
            });

            test('Ask To Play 1', () async {
              WebSocket player1 = await WebSocket.connect(
                  'http://$HOST_GAME:$PORT_GAME',
                  headers: {"token": token1});
              message0 = "Opponent found !";
              player1.listen((event) {
                expect(jsonDecode(event)["message"], "Opponent found !");
              }, onDone: () {
                player1.close();
              });
            });
          });
        });
        i++;
      }
    });
  });
}
