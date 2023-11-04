import 'dart:math';

import 'test_case.dart';

void main() {
  String? prefix = DateTime.now().toString();
  List<String> playernames = generateNames(100, prefix);
  List<String> passwords = generatePasswords(100);
  test_gameserverload(playernames, passwords, 100);
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
