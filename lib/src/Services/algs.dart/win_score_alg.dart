import 'package:tic_tac_toe_server/src/Services/algs.dart/utils.dart';

int winScoreAlg(int playerScore, int opponentScore) {
  return (playerScore + winningReward(playerScore, opponentScore)).ceil();
}
