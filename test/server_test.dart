import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';

void main() {
  final port1 = '8080';
  final host1 = 'ws://127.0.0.1:$port1';
  final port2 = '8081';
  final host2 = 'http://127.0.0.1:$port2';
  final playername0 = 'medaminetlili11';
  final playerpassword0 = playername0;
  final playername1 = 'medaminetlili12';
  final playerpassword1 = playername0;
  late Process p;
  var message0 = "Room created";

  setUp(() async {
    p = await Process.start(
      'dart',
      ['run', 'bin/main.dart'],
    );
    await Future.delayed(Duration(seconds: 5));

    // Wait for server to start and print to stdout.
  });

  group('********** Test case **************', () {
    group(' **************    Player 0    *************** ', () {
      var token0;

      test('Signup', () async {
        var response = await get(Uri.parse(
            '$host2/Signup/?playername=$playername0&password=$playerpassword0'));
        expect(jsonDecode(response.body)["message"], "Player is signed up");
      });

      test('Signin', () async {
        var response = await get(Uri.parse(
            '$host2/Signin/?playername=$playername0&password=$playerpassword0'));
        token0 = jsonDecode(response.body)["token"];
        expect(jsonDecode(response.body)["message"], "Player is signed in");
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
    group(' **************   Player 1   *************** ', () {
      var token1;
      test('Signup', () async {
        var response = await get(Uri.parse(
            '$host2/Signup/?playername=$playername1&password=$playerpassword1'));
        expect(jsonDecode(response.body)["message"], "Player is signed up");
      });

      test('Signin', () async {
        var response = await get(Uri.parse(
            '$host2/Signin/?playername=$playername1&password=$playerpassword1'));
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

      test('Delete', () async {
        var response = await get(Uri.parse(
            '$host2/Delete/?playername=$playername0&password=$playerpassword0'));
        expect(jsonDecode(response.body)["res"], true);
        expect(jsonDecode(response.body)["res"], true);
      });
      test('Delete', () async {
        var response = await get(Uri.parse(
            '$host2/Delete/?playername=$playername1&password=$playerpassword1'));
        expect(jsonDecode(response.body)["res"], true);
        expect(jsonDecode(response.body)["res"], true);
      });
    });

    tearDownAll(() => p.kill());
  });
}
