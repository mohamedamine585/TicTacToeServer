import '../../Core/Modules/Player_Room.dart';
import '../../Core/Repositories/Playroom_repo.dart';
import '../../Data/Services/PlayRoomService.dart';

class Play_room_repo_impl implements Play_room_repository {
  @override
  Play_room play_room;
  Play_room_repo_impl(this.play_room);

  /// start a game in a room ***********

  @override
  close_room() async {
    if (play_room.player1 != null) {
      await PlayRoomService.getInstance().close_PlayRoom(play_room: play_room);
    }
    play_room.opened = true;
    play_room.player0 = null;
    play_room.player1 = null;
  }
}
