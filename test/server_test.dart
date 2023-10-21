import 'dart:io';
import 'dart:math';

import 'package:test/test.dart';

import '../bin/utils.dart';
import 'test_case.dart';

void main() {
  final port1 = '8080';
  final host1 = 'ws://127.0.0.1:$port1';
  final port2 = '8081';
  final host2 = 'http://127.0.0.1:$port2';

  String? prefix = "dssqd2547dsds3d";
  List<String> playernames = generateNames(10, prefix);
  List<String> passwords = generatePasswords(10);
  test_authandgameserver(playernames, passwords, host1, host2, 10);
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
