import 'dart:convert';
import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart';

import 'package:test/test.dart';
import 'package:web_socket_channel/io.dart';

test_gameserver() {
  String message0 = "Room created";
  final env = DotEnv()..load();

  test("Connect to a play room2", () async {
    final response = IOWebSocketChannel.connect(
        Uri.parse("ws://localhost:${env["PORT"]}"),
        headers: {
          "Authorization":
              "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwbGF5ZXJpZCI6IjY1ZTcyNTY3NDAzYTNlNTkxYTMwMWExNSIsImlhdCI6MTcwOTY0NzIwNywiaXNzIjoiaHR0cHM6Ly9naXRodWIuY29tL2pvbmFzcm91c3NlbC9kYXJ0X2pzb253ZWJ0b2tlbiJ9.K4fV-ReDKIomtTGFQ6-X4766rry4batvLHYPaiVzNA8"
        });

    response.stream.listen((event) async {
      expect(json.decode(event)["message"], message0);
      if (json.decode(event)["message"] == "Opponent found !") {
        await response.sink.close();
      }
    });
  });
  test("get doc", () async {
    final response =
        await get(Uri.parse("http://localhost:8080/player"), headers: {
      "Authorization":
          "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwbGF5ZXJpZCI6IjY1ZDc3NjYwZTVlYjlmN2FmMDM5YmJmNCIsImlhdCI6MTcwODYzMzQyNiwiaXNzIjoiaHR0cHM6Ly9naXRodWIuY29tL2pvbmFzcm91c3NlbC9kYXJ0X2pzb253ZWJ0b2tlbiJ9.x12ElZDhNr_HIQBz5uJwNDrd4nRwBytkQ2lK1PifC8k"
    });
    expect(response.statusCode, 200);
    expect(json.decode(response.body)["email"], isNotNull);
  });
}
