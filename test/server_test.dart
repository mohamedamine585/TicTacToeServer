import 'dart:math';

import 'test_case.dart';

void main() {
  int playersnb = 10;
  String? prefix = DateTime.now().toString();
  List<String> playernames = generateNames(playersnb, prefix);
  List<String> passwords = generatePasswords(playersnb);

  test_authandgameserver(playernames, passwords, playersnb);
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
