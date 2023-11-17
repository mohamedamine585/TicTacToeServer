import '../Core/Modules/Player_Room.dart';

String? checkWin(Play_room playRoom) {
  bool checkRowColDiagonal(String a, String b, String c) {
    return a == b && b == c && a != "null";
  }

  // Check rows
  for (int row = 0; row < 3; row++) {
    if (checkRowColDiagonal(playRoom.Grid[row][0] ?? "",
        playRoom.Grid[row][1] ?? "", playRoom.Grid[row][2] ?? "")) {
      return playRoom.Grid[row][0] ?? "";
    }
  }

  // Check columns
  for (int col = 0; col < 3; col++) {
    if (checkRowColDiagonal(playRoom.Grid[0][col] ?? "",
        playRoom.Grid[1][col] ?? "", playRoom.Grid[2][col] ?? "")) {
      return playRoom.Grid[0][col] ?? "";
    }
  }

  // Check diagonals
  if (checkRowColDiagonal(playRoom.Grid[0][0] ?? "",
      playRoom.Grid[1][1] ?? "", playRoom.Grid[2][2] ?? "")) {
    return playRoom.Grid[0][0] ?? "";
  }
  if (checkRowColDiagonal(playRoom.Grid[0][2] ?? "",
      playRoom.Grid[1][1] ?? "", playRoom.Grid[2][0] ?? "")) {
    return playRoom.Grid[0][2] ?? "";
  }

  return null; // Return null if no winner
}
