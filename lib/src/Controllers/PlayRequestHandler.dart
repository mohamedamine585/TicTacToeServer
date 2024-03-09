import 'dart:io';

import 'package:mongo_dart/mongo_dart.dart';
import 'package:tic_tac_toe_server/src/controllers/Gameservercontroller.dart';
import 'package:tic_tac_toe_server/src/controllers/MatchMakerController.dart';
import 'package:tic_tac_toe_server/src/middleware/gamemiddleware.dart';

Function handlePlayRequest = (HttpRequest request, String playerid) async {
  final roomid = await GameMiddleware.checkforSepecificRoom(request: request);

  await Gameserver_controller.MakeHimPlay(request, roomid, playerid);
};
Function handlePlayRequestModern =
    (HttpRequest request, String playerid) async {
  final roomid = await GameMiddleware.checkforSepecificRoom(request: request);
  if (WebSocketTransformer.isUpgradeRequest(request)) {
    if (roomid != null) {
      await MatchMakerController.connectToPlayroom(
          request, ObjectId.fromHexString(playerid), roomid);
    }
  } else {
    await MatchMakerController.acceptPlayer(request, playerid);
  }
};
