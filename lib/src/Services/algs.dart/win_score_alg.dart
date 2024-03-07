int winScoreAlg(int playerScore, int opponentScore) {
  return (playerScore + opponentScore * 0.01).ceil();
}
