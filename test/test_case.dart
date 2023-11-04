import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';

import 'package:test/test.dart';

import '../bin/utils/consts.dart';

test_authandgameserver(
    List<String> playernames, List<String> passwords, int players) {
  List<String> tokens = [];
  var message0;
  group('************** Test ***************', () {
    group('**********  Test Create***************', () {
      for (int i = 0; i < players - 2; i++) {
        group('********** Test case $i **************', () {
          WebSocket player0, player1;
          var token0;
          var step = 0;
          message0 = "Room created";
          group(' **************    Player ${i / 2} 0    *************** ', () {
            test('Signup', () async {
              var response = await post(
                  Uri.parse('http://$HOST_AUTH:$PORT_AUTH/Signup/'),
                  body: json.encode({
                    "playername": playernames[i],
                    "password": passwords[i]
                  }));
              expect(
                  jsonDecode(response.body)["message"], "Player is signed up");
            });

            test('Signin', () async {
              var response = await get(
                Uri.parse(
                    'http://$HOST_AUTH:$PORT_AUTH/Signin/?playername=${playernames[i]}&password=${passwords[i]}'),
              );
              token0 = jsonDecode(response.body)["token"];
              tokens.add(token0);
              expect(
                  jsonDecode(response.body)["message"], "Player is signed in");
            });

            test('Ask To Play 0', () async {
              player0 = await WebSocket.connect('ws://$HOST_GAME:$PORT_GAME',
                  headers: {"token": token0});
              player0.listen((event) {
                if (jsonDecode(event)["hand"] == null) {
                  expect(jsonDecode(event)["message"], message0);
                }
                if (jsonDecode(event)["hand"] == 0) {
                  switch (step) {
                    case 0:
                      player0.add("0 0");
                      step++;
                      break;
                    case 1:
                      player0.add("1 0");
                      step++;
                      break;
                    case 2:
                      player0.add("2 0");
                      step++;
                      break;
                    default:
                  }
                  if (step == 3) {
                    expect(
                        jsonDecode(event)["message"], "Player 0 is The Winner");
                  }
                }
              }, onDone: () {
                player0.close();
              });
            });
          });
          group(' **************   Player $i 1   *************** ', () {
            var token1;
            test('Signup', () async {
              var response = await post(
                  Uri.parse('http://$HOST_AUTH:$PORT_AUTH/Signup/'),
                  body: json.encode({
                    "playername": playernames[i + 1],
                    "password": passwords[i + 1]
                  }));
              expect(
                  jsonDecode(response.body)["message"], "Player is signed up");
            });

            test('Signin', () async {
              var response = await get(
                Uri.parse(
                    'http://$HOST_AUTH:$PORT_AUTH/Signin/?playername=${playernames[i + 1]}&password=${passwords[i + 1]}'),
              );
              token1 = jsonDecode(response.body)["token"];
              tokens.add(token1);
              expect(
                  jsonDecode(response.body)["message"], "Player is signed in");
            });

            test('Ask To Play 1', () async {
              player1 = await WebSocket.connect('ws://$HOST_GAME:$PORT_GAME',
                  headers: {"token": token1});
              message0 = "Opponent found !";
              player1.listen((event) {
                if (message0 == "Opponent found !") {
                  expect(jsonDecode(event)["message"], "Opponent found !");
                }
                if (step == 3) {
                  expect(
                      jsonDecode(event)["message"], "Player 0 is The Winner");
                }
                if (jsonDecode(event)["hand"] == 1) {
                  player1.add("1 1");
                }
              }, onDone: () {
                player1.close();
              });
            });
          });
        });

        i++;
      }
    });
    group('Delete players', () {
      for (int i = 1; i < playernames.length - 1; i++) {
        test('delete player', () async {
          var response = await delete(
              Uri.parse('http://$HOST_AUTH:$PORT_AUTH/Delete/'),
              headers: {"token": tokens[i - 1]},
              body: json.encode(
                  {"playername": playernames[i], "password": passwords[i]}));
          expect(jsonDecode(response.body)["message"], "player deleted");
        });
      }
    });
  });

  group("Change Name", () {
    group(' **************    Player    *************** ', () {
      var token0, token1;

      test('Signup', () async {
        var response = await post(
            Uri.parse('http://$HOST_AUTH:$PORT_AUTH/Signup/'),
            body: json.encode({
              "playername": "${playernames[1]}K8",
              "password": "${passwords[1]}"
            }));
        expect(jsonDecode(response.body)["message"], "Player is signed up");
      });

      test('First Signin', () async {
        var response = await get(
          Uri.parse(
              'http://$HOST_AUTH:$PORT_AUTH/Signin/?playername=${playernames[1]}K8&password=${passwords[1]}'),
        );
        token0 = jsonDecode(response.body)["token"];
        expect(jsonDecode(response.body)["message"], "Player is signed in");
      });

      test('Update Name', () async {
        var response =
            await put(Uri.parse('http://$HOST_AUTH:$PORT_AUTH/ChangeName/'),
                headers: {"token": token0},
                body: json.encode({
                  "playername": "${playernames[1]}K8",
                  "password": "${passwords[1]}",
                  "new_name": "${playernames[1]}K8M"
                }));
        token1 = jsonDecode(response.body)["token"];
        expect(jsonDecode(response.body)["message"],
            "playername changed to ${playernames[1]}K8M");
      });
      test('First Ask To Play ', () async {
        try {
          WebSocket player0 = await WebSocket.connect(
              'ws://$HOST_GAME:$PORT_GAME',
              headers: {"token": token0});
        } catch (e) {
          expect(e.toString().isNotEmpty, true);
        }
      });

      test('Update Password', () async {
        var response =
            await put(Uri.parse('http://$HOST_AUTH:$PORT_AUTH/ChangePassword/'),
                headers: {"token": token1},
                body: json.encode({
                  "playername": "${playernames[1]}K8M",
                  "password": "${passwords[1]}",
                  "new_password": "${passwords[1]}M"
                }));
        token1 = jsonDecode(response.body)["token"];
        expect(jsonDecode(response.body)["message"], "password changed");
      });
      test('Second Ask To Play ', () async {
        try {
          WebSocket player0 = await WebSocket.connect(
              'ws://$HOST_GAME:$PORT_GAME',
              headers: {"token": token1});
        } catch (e) {
          expect(e.toString().isNotEmpty, false);
        }
      });
    });
  });
}
