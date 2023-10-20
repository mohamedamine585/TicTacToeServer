import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart';
import 'package:test/test.dart';

void main() {
  final port1 = '8080';
  final host1 = 'ws://127.0.0.1:$port1';
  final port2 = '8081';
  final host2 = 'http://127.0.0.1:$port2';
  final playername = 'medaminetlili155';
  final playerpassword = playername;
  late Process p;

  setUp(() async {
    p = await Process.start(
      'dart',
      ['run', 'bin/main.dart'],
    );
    await Future.delayed(Duration(seconds: 3));

    // Wait for server to start and print to stdout.
  });

  group('Auth server Test', () {
    test('Signup', () async {
      var response = await get(Uri.parse(
          '$host2/Signup/?playername=$playername&password=$playerpassword'));
      expect(jsonDecode(response.body)["message"], "Player is signed up");
    });

    test('Signin', () async {
      var response = await get(Uri.parse(
          '$host2/Signin/?playername=$playername&password=$playerpassword'));
      expect(jsonDecode(response.body)["message"], "Player is signed in");
    });
    test('Delete', () async {
      var response = await get(Uri.parse(
          '$host2/Delete/?playername=$playername&password=$playerpassword'));
      expect(jsonDecode(response.body)["res"], true);
      expect(jsonDecode(response.body)["res"], true);
    });
  });

  tearDown(() => p.kill());
}
