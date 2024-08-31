import 'package:tic_tac_toe_server/src/services/algs.dart/utils.dart';

int looseScoreAlg(int playerScore, int opponentScore) {
  int newscore;
  newscore = (playerScore - loosingPenalty(playerScore, opponentScore)).ceil();

  return (newscore >= 0) ? newscore : 0;
}
