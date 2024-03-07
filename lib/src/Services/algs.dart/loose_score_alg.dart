int looseScoreAlg(int playerScore, int opponentScore) {
  int newscore;
  if (opponentScore != 0) {
    newscore = (playerScore - 1 / opponentScore).ceil();
  } else {
    newscore = (playerScore / 2).ceil();
  }

  return (newscore >= 0) ? newscore : 0;
}
