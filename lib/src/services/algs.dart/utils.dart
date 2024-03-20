double Function(int, int) loosingPenalty =
    (int playerscore, int opponentscore) {
  if (opponentscore != 0) {
    return (playerscore / 2 * opponentscore);
  } else {
    return (playerscore / 2);
  }
};

double Function(int, int) winningReward = (int playerscore, int opponentscore) {
  if (playerscore != 0) {
    return (10 + (10 * opponentscore / playerscore));
  } else {
    return (opponentscore / 2 + 10);
  }
};
