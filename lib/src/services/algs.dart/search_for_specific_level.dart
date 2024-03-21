import 'package:tic_tac_toe_server/src/models/Player.dart';
import 'package:tic_tac_toe_server/src/models/Player_Room.dart';
import 'package:tic_tac_toe_server/src/Services/player_service.dart';

Future<String> playGameWithSpecificPlayer(
    {required List<Play_room> playRooms, required int levelScore}) async {
  try {
    String mostSuitableRoom = "";
    int diffInScore = levelScore, newscorediff;
    Player? player0;
    for (Play_room play_room in playRooms) {
      player0 =
          await PlayerService.instance.getPlayerById(id: play_room.player0!.Id);
      if (player0 != null) {
        newscorediff = diffInscore(player0.score, levelScore);
        if (newscorediff < diffInScore) {
          mostSuitableRoom = play_room.roomid?.toHexString() ?? "";
          diffInScore = newscorediff;
        }
      }
    }
    return mostSuitableRoom;
  } catch (e) {
    print(e);
  }
  return "";
}

int diffInscore(int player0score, int levelScore) {
  return (player0score - levelScore).abs();
}
