import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/io.dart';

void main() {
  final port1 = '8080';
  final host1 = 'ws://127.0.0.1:$port1';
  final port2 = '8081';
  final host2 = 'http://127.0.0.1:$port2';
  final playername = 'medaminetlili7';
  final playerpassword = playername;
  late Process p;
  var token;

  setUp(() async {
    p = await Process.start(
      'dart',
      ['run', 'bin/main.dart'],
    );
    await Future.delayed(Duration(seconds: 5));

    // Wait for server to start and print to stdout.
  });

  group(' **************   Auth server Test    *************** ', () {
    test('Signup', () async {
      var response = await get(Uri.parse(
          '$host2/Signup/?playername=$playername&password=$playerpassword'));
      expect(jsonDecode(response.body)["message"], "Player is signed up");
    });

    test('Signin', () async {
      var response = await get(Uri.parse(
          '$host2/Signin/?playername=$playername&password=$playerpassword'));
      token = jsonDecode(response.body)["token"];
      expect(jsonDecode(response.body)["message"], "Player is signed in");
    });

    test('Ask To Play', () async {
      WebSocket player =
          await WebSocket.connect(host1, headers: {"token": token});
      player.listen((event) {
        expect(jsonDecode(event)["message"], "Room created");
      }, onDone: () {
        player.close();
      });
    });
    test('Delete', () async {
      var response = await get(Uri.parse(
          '$host2/Delete/?playername=$playername&password=$playerpassword'));
      expect(jsonDecode(response.body)["res"], true);
      expect(jsonDecode(response.body)["res"], true);
    });
    tearDownAll(() {
      p.kill();
    });
  });
}
