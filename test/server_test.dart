import 'dart:math';

import 'test_case.dart';

void main() {
  String? prefix = Random(DateTime.now().millisecondsSinceEpoch).toString();
  List<String> playernames = generateNames(10, prefix);
  List<String> passwords = generatePasswords(10);
  test_authandgameserver(playernames, passwords, 10);
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
