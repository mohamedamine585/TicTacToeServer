int Function(int, int) loosingPenalty = (int playerscore, int opponentscore) {
  return (playerscore / 2 * opponentscore).ceil();
};

int Function(int, int) winningReward = (int playerscore, int opponentscore) {
  return (10 * opponentscore / playerscore).ceil();
};
