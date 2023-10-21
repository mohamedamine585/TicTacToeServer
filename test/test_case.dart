import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart';

import 'package:test/test.dart';

test_authandgameserver(List<String> playernames, List<String> passwords,
    String host1, String host2, int players) {
  var message0;
  group('************** Test ***************', () {
    group('**********  Test Create***************', () {
      for (int i = 0; i < players; i++) {
        group('********** Test case $i **************', () {
          group(' **************    Player ${i / 2} 0    *************** ', () {
            var token0;
            message0 = "Room created";

            test('Signup', () async {
              var response = await get(Uri.parse(
                  '$host2/Signup/?playername=${playernames[i]}&password=${passwords[i]}'));
              expect(
                  jsonDecode(response.body)["message"], "Player is signed up");
            });

            test('Signin', () async {
              var response = await get(Uri.parse(
                  '$host2/Signin/?playername=${playernames[i]}&password=${passwords[i]}'));
              token0 = jsonDecode(response.body)["token"];
              expect(
                  jsonDecode(response.body)["message"], "Player is signed in");
            });

            test('Ask To Play 0', () async {
              WebSocket player0 =
                  await WebSocket.connect(host1, headers: {"token": token0});
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
                  '$host2/Signup/?playername=${playernames[i + 1]}&password=${passwords[i + 1]}'));
              expect(
                  jsonDecode(response.body)["message"], "Player is signed up");
            });

            test('Signin', () async {
              var response = await get(Uri.parse(
                  '$host2/Signin/?playername=${playernames[i + 1]}&password=${passwords[i + 1]}'));
              token1 = jsonDecode(response.body)["token"];
              expect(
                  jsonDecode(response.body)["message"], "Player is signed in");
            });

            test('Ask To Play 1', () async {
              WebSocket player1 =
                  await WebSocket.connect(host1, headers: {"token": token1});
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

    group('******* Test Delete  *******', () {
      for (int i = 0; i < players; i++) {
        test('Delete  ${i / 2} 0 ', () async {
          var response = await get(Uri.parse(
              '$host2/Delete/?playername=${playernames[i]}&password=${passwords[i]}'));
          expect(jsonDecode(response.body)["res"], true);
          expect(jsonDecode(response.body)["rest"], true);
        });
      }
    });
  });
}

test_find_owned(String host1, String host2) {
  group("Enter 0 and 1", () {
    var message0;
    group('**********  Test Create***************', () {
      group('********** Test case  **************', () {
        group(' **************    Player 0    *************** ', () {
          var token0;
          message0 = "Room created";

          test('Signup', () async {
            var response = await get(
                Uri.parse('$host2/Signup/?playername=leo&password=kessi'));
            expect(jsonDecode(response.body)["message"], "Player is signed up");
          });

          test('Signin', () async {
            var response = await get(
                Uri.parse('$host2/Signin/?playername=leo&password=kessi'));
            token0 = jsonDecode(response.body)["token"];
            expect(jsonDecode(response.body)["message"], "Player is signed in");
          });

          test('Ask To Play 0', () async {
            WebSocket player0 =
                await WebSocket.connect(host1, headers: {"token": token0});
            player0.listen((event) {
              if (token0 != "") {
                expect(jsonDecode(event)["message"], message0);
              }
              if (message0 == "Opponent found !") {
                token0 = "";
                player0.close();
              }
            }, onDone: () {
              player0.close();
            });
          });
        });
      });
    });
    group(' **************   Player  1   *************** ', () {
      var token1;
      test('Signup', () async {
        var response =
            await get(Uri.parse('$host2/Signup/?playername=ron&password=ron'));
        expect(jsonDecode(response.body)["message"], "Player is signed up");
      });

      test('Signin', () async {
        var response =
            await get(Uri.parse('$host2/Signin/?playername=ron&password=ron'));
        token1 = jsonDecode(response.body)["token"];
        expect(jsonDecode(response.body)["message"], "Player is signed in");
      });

      test('Ask To Play 1', () async {
        WebSocket player1 =
            await WebSocket.connect(host1, headers: {"token": token1});
        message0 = "Opponent found !";
        player1.listen((event) {
          expect(jsonDecode(event)["message"], "Opponent found !");
        }, onDone: () {
          player1.close();
        });
      });
    });
    group(' **************   Player  2   *************** ', () {
      var token1;
      test('Signup', () async {
        var response =
            await get(Uri.parse('$host2/Signup/?playername=kal&password=kal'));
        expect(jsonDecode(response.body)["message"], "Player is signed up");
      });

      test('Signin', () async {
        var response =
            await get(Uri.parse('$host2/Signin/?playername=kal&password=kal'));
        token1 = jsonDecode(response.body)["token"];
        expect(jsonDecode(response.body)["message"], "Player is signed in");
      });

      test('Ask To Play 1', () async {
        WebSocket player2 =
            await WebSocket.connect(host1, headers: {"token": token1});
        player2.listen((event) {
          expect(jsonDecode(event)["message"], "Room owned");
          player2.close();
        }, onDone: () {
          player2.close();
        });
      });
    });
  });
}

test_server_load(List<String> playernames, List<String> passwords, String host1,
    String host2, int rooms) {
  var message0;
  group('************** Test ***************', () {
    group('**********  Test Create***************', () {
      for (int i = 0; i < rooms; i++) {
        group('********** Test case $i **************', () {
          group(' **************    Player ${i / 2} 0    *************** ', () {
            var token0;
            message0 = "Room created";

            test('Signup', () async {
              var response = await get(Uri.parse(
                  '$host2/Signup/?playername=${playernames[i]}&password=${passwords[i]}'));
              expect(
                  jsonDecode(response.body)["message"], "Player is signed up");
            });

            test('Signin', () async {
              var response = await get(Uri.parse(
                  '$host2/Signin/?playername=${playernames[i]}&password=${passwords[i]}'));
              token0 = jsonDecode(response.body)["token"];
              expect(
                  jsonDecode(response.body)["message"], "Player is signed in");
            });

            test('Ask To Play 0', () async {
              WebSocket player0 =
                  await WebSocket.connect(host1, headers: {"token": token0});
              player0.listen((event) {
                if (token0 != "") {
                  expect(jsonDecode(event)["message"], message0);
                }
                if (message0 == "Opponent found !") {
                  token0 = "";
                  player0.add("0 0");
                }
              }, onDone: () {
                player0.close();
              });
            });
          });
          group(' **************   Player $i 1   *************** ', () {
            var token1;
            test('Signup', () async {
              var response = await get(Uri.parse(
                  '$host2/Signup/?playername=${playernames[i + 1]}&password=${passwords[i + 1]}'));
              expect(
                  jsonDecode(response.body)["message"], "Player is signed up");
            });

            test('Signin', () async {
              var response = await get(Uri.parse(
                  '$host2/Signin/?playername=${playernames[i + 1]}&password=${passwords[i + 1]}'));
              token1 = jsonDecode(response.body)["token"];
              expect(
                  jsonDecode(response.body)["message"], "Player is signed in");
            });

            test('Ask To Play 1', () async {
              WebSocket player1 =
                  await WebSocket.connect(host1, headers: {"token": token1});
              message0 = "Opponent found !";
              player1.listen((event) {
                if (token1 != "") {
                  expect(jsonDecode(event)["message"], "Opponent found !");
                  token1 = "";
                }
                player1.add("2 2");
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
