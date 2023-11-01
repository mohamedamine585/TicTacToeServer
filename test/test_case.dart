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
          WebSocket player0, player1;
          group(' **************    Player ${i / 2} 0    *************** ', () {
            var token0;
            message0 = "Room created";

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
              expect(
                  jsonDecode(response.body)["message"], "Player is signed in");
            });

            test('Ask To Play 0', () async {
              player0 = await WebSocket.connect('ws://$HOST_GAME:$PORT_GAME',
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
              expect(
                  jsonDecode(response.body)["message"], "Player is signed in");
            });

            test('Ask To Play 1', () async {
              player1 = await WebSocket.connect('ws://$HOST_GAME:$PORT_GAME',
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
    group('Delete players', () {
      for (int i = 1; i < playernames.length - 1; i++) {
        test('delete player', () async {
          var response = await delete(
              Uri.parse('http://$HOST_AUTH:$PORT_AUTH/Delete/'),
              body: json.encode(
                  {"playername": playernames[i], "password": passwords[i]}));
          expect(jsonDecode(response.body)["message"], "player deleted");
        });
      }
    });

    group("Change Name", () {
      WebSocket player0;
      group(' **************    Player    *************** ', () {
        var token0;

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

        test('First Ask To Play ', () async {
          player0 = await WebSocket.connect('ws://$HOST_GAME:$PORT_GAME',
              headers: {"token": token0});
          player0.listen((event) {
            expect(jsonDecode(event)["message"], "Room created");
            player0.close();
          }, onDone: () {
            player0.close();
          });
        });
        test('Update Name', () async {
          var response =
              await put(Uri.parse('http://$HOST_AUTH:$PORT_AUTH/ChangeName/'),
                  body: json.encode({
                    "playername": "${playernames[1]}K8",
                    "password": "${passwords[1]}",
                    "new_name": "${playernames[1]}K8M"
                  }));
          token0 = jsonDecode(response.body)["token"];
          expect(jsonDecode(response.body)["message"],
              "playername changed to ${playernames[1]}K8M");
        });

        test('Second Ask To Play ', () async {
          try {
            player0 = await WebSocket.connect('ws://$HOST_GAME:$PORT_GAME',
                headers: {"token": token0});
          } catch (e) {
            expect(e.toString().isNotEmpty, true);
          }
        });
        test('Second Signin', () async {
          var response = await get(
            Uri.parse(
                'http://$HOST_AUTH:$PORT_AUTH/Signin/?playername=${playernames[1]}K8M&password=${passwords[1]}'),
          );
          token0 = jsonDecode(response.body)["token"];
          expect(jsonDecode(response.body)["message"], "Player is signed in");
        });
        test('Third Ask To Play ', () async {
          WebSocket player0 = await WebSocket.connect(
              'ws://$HOST_GAME:$PORT_GAME',
              headers: {"token": token0});
          player0.listen((event) {
            expect(jsonDecode(event)["message"], "Room created");
            player0.close();
          }, onDone: () {
            player0.close();
          });
        });
      });
    });
    group("Change Password", () {
      WebSocket player0;
      group(' **************    Player    *************** ', () {
        var token0;
        message0 = "Room created";
        test('First Signin', () async {
          var response = await get(
            Uri.parse(
                'http://$HOST_AUTH:$PORT_AUTH/Signin/?playername=${playernames[1]}K8M&password=${passwords[1]}'),
          );
          token0 = jsonDecode(response.body)["token"];
          expect(jsonDecode(response.body)["message"], "Player is signed in");
        });

        test('First Ask To Play ', () async {
          player0 = await WebSocket.connect('ws://$HOST_GAME:$PORT_GAME',
              headers: {"token": token0});
          player0.listen((event) {
            expect(jsonDecode(event)["message"], message0);
            if (message0 == "Room created") {
              player0.close();
            }
          }, onDone: () {
            player0.close();
          });
        });
        test('Update Password', () async {
          var response = await put(
              Uri.parse('http://$HOST_AUTH:$PORT_AUTH/ChangePassword/'),
              body: json.encode({
                "playername": "${playernames[1]}K8M",
                "password": "${passwords[1]}",
                "new_password": "${passwords[1]}M"
              }));
          token0 = jsonDecode(response.body)["token"];
          expect(jsonDecode(response.body)["message"], "password changed");
        });
        test('Second Ask To Play ', () async {
          try {
            player0 = await WebSocket.connect('ws://$HOST_GAME:$PORT_GAME',
                headers: {"token": token0});
          } catch (e) {
            expect(e.toString().isNotEmpty, true);
          }
        });
        test('Second Signin', () async {
          var response = await get(
            Uri.parse(
                'http://$HOST_AUTH:$PORT_AUTH/Signin/?playername=${playernames[1]}K8M&password=${passwords[1]}M'),
          );
          token0 = jsonDecode(response.body)["token"];
          expect(jsonDecode(response.body)["message"], "Player is signed in");
        });
        test('Third Ask To Play ', () async {
          WebSocket player0 = await WebSocket.connect(
              'ws://$HOST_GAME:$PORT_GAME',
              headers: {"token": token0});
          player0.listen((event) {
            expect(jsonDecode(event)["message"], message0);
            if (message0 == "Room created") {
              player0.close();
            }
          }, onDone: () {
            player0.close();
          });
        });
      });
      test('Delete player', () async {
        var response = await delete(
            Uri.parse('http://$HOST_AUTH:$PORT_AUTH/Delete/'),
            body: json.encode({
              "playername": "${playernames[1]}K8M",
              "password": "${passwords[1]}M"
            }));
        expect(jsonDecode(response.body)["message"], "player deleted");
      });
    });
  });
}
