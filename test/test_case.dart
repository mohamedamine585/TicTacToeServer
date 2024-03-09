import 'dart:convert';
import 'dart:io';

import 'package:dotenv/dotenv.dart';
import 'package:test/test.dart';
import 'package:web_socket_channel/io.dart';

test_gameserver() {
  final env = DotEnv()..load();
  String roomid = "";
  String message0 = "Waiting the opponent ...";
  group('************** Test ***************', () {
    test("get doc", () async {
      final client = HttpClient();
      final request = await client.get(env["HOST_CLIENT"] ?? "localhost",
          int.parse(env["PORT"] ?? "8080"), "/player");
      request.headers.add("Authorization",
          "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwbGF5ZXJpZCI6IjY1ZDc3NjYwZTVlYjlmN2FmMDM5YmJmNCIsImlhdCI6MTcwODYzMzQyNiwiaXNzIjoiaHR0cHM6Ly9naXRodWIuY29tL2pvbmFzcm91c3NlbC9kYXJ0X2pzb253ZWJ0b2tlbiJ9.x12ElZDhNr_HIQBz5uJwNDrd4nRwBytkQ2lK1PifC8k");
      final response = await request.close();
      expect(response.statusCode, 200);
      expect(
          json.decode(await response.transform(utf8.decoder).join())["email"],
          isNotNull);
    });
    test("get roomid", () async {
      final client = HttpClient();
      final request = await client.get(env["HOST_CLIENT"] ?? "localhost",
          int.parse(env["PORT"] ?? "8080"), "/");
      request.headers.add("Authorization",
          "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwbGF5ZXJpZCI6IjY1ZDc3NjYwZTVlYjlmN2FmMDM5YmJmNCIsImlhdCI6MTcwODYzMzQyNiwiaXNzIjoiaHR0cHM6Ly9naXRodWIuY29tL2pvbmFzcm91c3NlbC9kYXJ0X2pzb253ZWJ0b2tlbiJ9.x12ElZDhNr_HIQBz5uJwNDrd4nRwBytkQ2lK1PifC8k");
      final response = await request.close();
      expect(response.statusCode, 200);
      final resbody = await response.transform(utf8.decoder).join();
      expect(json.decode(resbody)["roomid"], isNotNull);
      roomid = json.decode(resbody)["roomid"];
    });
    test("Connect to a play room 1", () async {
      final response = IOWebSocketChannel.connect(
          Uri.parse(
              "ws://${env["HOST_CLIENT"] ?? "localhost"}:${env["PORT"] ?? "8080"}"),
          headers: {
            "Authorization":
                "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwbGF5ZXJpZCI6IjY1ZDc3NjYwZTVlYjlmN2FmMDM5YmJmNCIsImlhdCI6MTcwODYzMzQyNiwiaXNzIjoiaHR0cHM6Ly9naXRodWIuY29tL2pvbmFzcm91c3NlbC9kYXJ0X2pzb253ZWJ0b2tlbiJ9.x12ElZDhNr_HIQBz5uJwNDrd4nRwBytkQ2lK1PifC8k",
            "roomid": roomid
          });
      response.stream.listen((event) async {
        expect(json.decode(event)["message"], message0);
        if (json.decode(event)["message"] == "Game started") {
          Future.delayed(Duration(seconds: 5));
          await response.sink.close();
        }
      });
    });
    test("get roomid", () async {
      final client = HttpClient();
      final request = await client.get(env["HOST_CLIENT"] ?? "localhost",
          int.parse(env["PORT"] ?? "8080"), "/");
      request.headers.add("Authorization",
          "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwbGF5ZXJpZCI6IjY1ZTcyNTY3NDAzYTNlNTkxYTMwMWExNSIsImlhdCI6MTcwOTY0NzIwNywiaXNzIjoiaHR0cHM6Ly9naXRodWIuY29tL2pvbmFzcm91c3NlbC9kYXJ0X2pzb253ZWJ0b2tlbiJ9.K4fV-ReDKIomtTGFQ6-X4766rry4batvLHYPaiVzNA8");
      final response = await request.close();
      expect(response.statusCode, 200);
      final resbody = await response.transform(utf8.decoder).join();
      expect(json.decode(resbody)["roomid"], isNotNull);
      roomid = json.decode(resbody)["roomid"];
    });
    test("Connect to a play room 2", () async {
      message0 = "Game started";
      final response = IOWebSocketChannel.connect(
          Uri.parse(
              "ws://${env["HOST_CLIENT"] ?? "localhost"}:${env["PORT"] ?? "8080"}"),
          headers: {
            "Authorization":
                "Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJwbGF5ZXJpZCI6IjY1ZTcyNTY3NDAzYTNlNTkxYTMwMWExNSIsImlhdCI6MTcwOTY0NzIwNywiaXNzIjoiaHR0cHM6Ly9naXRodWIuY29tL2pvbmFzcm91c3NlbC9kYXJ0X2pzb253ZWJ0b2tlbiJ9.K4fV-ReDKIomtTGFQ6-X4766rry4batvLHYPaiVzNA8",
            "roomid": roomid
          });

      response.stream.listen((event) async {
        expect(json.decode(event)["message"], "Game started");
        if (json.decode(event)["message"] == "Game started") {
          Future.delayed(Duration(seconds: 5));
          await response.sink.close();
        }
      });
    });
  });
}
