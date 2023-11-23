import 'dart:io';

import 'package:tic_tac_toe_server/Core/Modules/Player_Room.dart';

String checkWin({required Play_room play_room}) {
  // Check rows and columns
  for (int i = 0; i < 3; i++) {
    // Check rows
    if (play_room.Grid[i][0] == play_room.Grid[i][1] &&
        play_room.Grid[i][1] == play_room.Grid[i][2] &&
        play_room.Grid[i][0] != 'null') {
      return play_room.Grid[i][0] ?? '';
    }
    // Check columns
    if (play_room.Grid[0][i] == play_room.Grid[1][i] &&
        play_room.Grid[1][i] == play_room.Grid[2][i] &&
        play_room.Grid[0][i] != 'null') {
      return play_room.Grid[0][i] ?? '';
    }
  }

  // Check diagonals
  if (play_room.Grid[0][0] == play_room.Grid[1][1] &&
      play_room.Grid[1][1] == play_room.Grid[2][2] &&
      play_room.Grid[0][0] != 'null') {
    return play_room.Grid[0][0] ?? '';
  }
  if (play_room.Grid[0][2] == play_room.Grid[1][1] &&
      play_room.Grid[1][1] == play_room.Grid[2][0] &&
      play_room.Grid[0][2] != 'null') {
    return play_room.Grid[0][2] ?? '';
  }

  // No winner yet
  return '';
}
