import 'dart:convert';
import 'package:dotenv/dotenv.dart';
import 'package:http/http.dart' as http;

import 'package:test/test.dart';
import 'package:web_socket_channel/io.dart';

test_gameserver() {
  String message0 = "Room created";
  group('************** Test ***************', () {
    test("Connect to a play room", () async {
      final response = IOWebSocketChannel.connect(
          Uri.parse("ws://localhost:8080"),
          headers: {
            "Authorization":
                "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwbGF5ZXJpZCI6IjY1ZDc3NjYwZTVlYjlmN2FmMDM5YmJmNCIsImlhdCI6MTcwODYzMzQyNiwiaXNzIjoiaHR0cHM6Ly9naXRodWIuY29tL2pvbmFzcm91c3NlbC9kYXJ0X2pzb253ZWJ0b2tlbiJ9.x12ElZDhNr_HIQBz5uJwNDrd4nRwBytkQ2lK1PifC8k"
          });
      response.stream.listen((event) async {
        expect(json.decode(event)["message"], message0);
        if (json.decode(event)["message"] == "Opponent found !") {
          Future.delayed(Duration(seconds: 5));
          await response.sink.close();
        }
      });
    });
    test("Connect to a play room", () async {
      message0 = "Opponent found !";
      final response = IOWebSocketChannel.connect(
          Uri.parse("ws://localhost:8080"),
          headers: {
            "Authorization":
                "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwbGF5ZXJpZCI6IjY1ZTcyNTY3NDAzYTNlNTkxYTMwMWExNSIsImlhdCI6MTcwOTY0NzIwNywiaXNzIjoiaHR0cHM6Ly9naXRodWIuY29tL2pvbmFzcm91c3NlbC9kYXJ0X2pzb253ZWJ0b2tlbiJ9.K4fV-ReDKIomtTGFQ6-X4766rry4batvLHYPaiVzNA8"
          });

      response.stream.listen((event) async {
        expect(json.decode(event)["message"], "Opponent found !");
        if (json.decode(event)["message"] == "Opponent found !") {
          Future.delayed(Duration(seconds: 5));
          await response.sink.close();
        }
      });
    });
    test("get doc", () async {
      final response =
          await http.get(Uri.parse("http://localhost:8080/player"), headers: {
        "Authorization":
            "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwbGF5ZXJpZCI6IjY1ZDc3NjYwZTVlYjlmN2FmMDM5YmJmNCIsImlhdCI6MTcwODYzMzQyNiwiaXNzIjoiaHR0cHM6Ly9naXRodWIuY29tL2pvbmFzcm91c3NlbC9kYXJ0X2pzb253ZWJ0b2tlbiJ9.x12ElZDhNr_HIQBz5uJwNDrd4nRwBytkQ2lK1PifC8k"
      });
      expect(response.statusCode, 200);
      expect(json.decode(response.body)["email"], isNotNull);
    });
  });
}
