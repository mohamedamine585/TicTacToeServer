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

  setUp(() async {
    p = await Process.start(
      'dart',
      ['run', 'bin/main.dart'],
    );
    await Future.delayed(Duration(seconds: 10));

    // Wait for server to start and print to stdout.
  });

  String? rooms = "4";
  String? prefix = "dssqd97887ds3d";
  List<String> playernames = generateNames(int.parse(rooms) * 2, prefix);
  List<String> passwords = generatePasswords(int.parse(rooms) * 2);
  test_find_owned(host1, host2);

  tearDownAll(() => p.kill());
}

List<String> generateNames(int count, String prefix) {
  final List<String> names = [];
  for (int i = 0; i < count; i++) {
    names.add('User$prefix${i + 1}');
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
