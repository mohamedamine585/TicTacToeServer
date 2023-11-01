import '../Core/Modules/Player_Room.dart';

String? checkWin(Play_room play_room) {
  bool checkRowColDiagonal(String a, String b, String c) {
    return a == b && b == c && a != "null";
  }

  // Check rows
  for (int row = 0; row < 3; row++) {
    if (checkRowColDiagonal(play_room.Grid[row][0] ?? "",
        play_room.Grid[row][1] ?? "", play_room.Grid[row][2] ?? "")) {
      return play_room.Grid[row][0] ?? "";
    }
  }

  // Check columns
  for (int col = 0; col < 3; col++) {
    if (checkRowColDiagonal(play_room.Grid[0][col] ?? "",
        play_room.Grid[1][col] ?? "", play_room.Grid[2][col] ?? "")) {
      return play_room.Grid[0][col] ?? "";
    }
  }

  // Check diagonals
  if (checkRowColDiagonal(play_room.Grid[0][0] ?? "",
      play_room.Grid[1][1] ?? "", play_room.Grid[2][2] ?? "")) {
    return play_room.Grid[0][0] ?? "";
  }
  if (checkRowColDiagonal(play_room.Grid[0][2] ?? "",
      play_room.Grid[1][1] ?? "", play_room.Grid[2][0] ?? "")) {
    return play_room.Grid[0][2] ?? "";
  }

  return null; // Return null if no winner
}
