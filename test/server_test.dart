import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';

import 'test_case.dart';

void main() {
  final port1 = '8080';
  final host1 = 'ws://127.0.0.1:$port1';
  final port2 = '8081';
  final host2 = 'http://127.0.0.1:$port2';
  late Process p;
  var message0;

  setUp(() async {
    p = await Process.start(
      'dart',
      ['run', 'bin/main.dart'],
    );
    await Future.delayed(Duration(seconds: 5));

    // Wait for server to start and print to stdout.
  });
  List<String> playernames = generateNames(8);
  List<String> passwords = generatePasswords(8);
  test_case(playernames, passwords, host1, host2);

  tearDownAll(() => p.kill());
}

List<String> generateNames(int count) {
  final List<String> names = [];
  for (int i = 0; i < count; i++) {
    names.add('UserAlphaa${i + 1}');
  }
  return names;
}

List<String> generatePasswords(int count) {
  final List<String> passwords = [];
  final Random random = Random();
  for (int i = 0; i < count; i++) {
    // Generate a random 8-character password
    final password =
        String.fromCharCodes(List.generate(8, (_) => random.nextInt(26) + 97));
    passwords.add(password);
  }
  return passwords;
}
