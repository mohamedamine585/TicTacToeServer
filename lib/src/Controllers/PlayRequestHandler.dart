import 'dart:io';

import 'package:tic_tac_toe_server/src/controllers/MatchMakerController.dart';

Function(HttpRequest) handlePlayRequestModern = (HttpRequest request) async {
  final roomid = request.headers.value("roomid");
  if (WebSocketTransformer.isUpgradeRequest(request)) {
    if (roomid != null) {
      await connectToPlayroom(request);
    }
  } else {
    await acceptPlayer(request);
  }
};
