String checkWin({required List<List<String?>> Grid}) {
  // Check rows and columns
  for (int i = 0; i < 3; i++) {
    // Check rows
    if (Grid[i][0] == Grid[i][1] &&
        Grid[i][1] == Grid[i][2] &&
        Grid[i][0] != null) {
      return Grid[i][0] ?? '';
    }
    // Check columns
    if (Grid[0][i] == Grid[1][i] &&
        Grid[1][i] == Grid[2][i] &&
        Grid[0][i] != null) {
      return Grid[0][i] ?? '';
    }
  }

  // Check diagonals
  if (Grid[0][0] == Grid[1][1] &&
      Grid[1][1] == Grid[2][2] &&
      Grid[0][0] != null) {
    return Grid[0][0] ?? '';
  }
  if (Grid[0][2] == Grid[1][1] &&
      Grid[1][1] == Grid[2][0] &&
      Grid[0][2] != null) {
    return Grid[0][2] ?? '';
  }

  // No winner yet
  return '';
}
