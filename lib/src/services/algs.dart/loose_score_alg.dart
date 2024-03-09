import 'package:tic_tac_toe_server/src/services/algs.dart/utils.dart';

int looseScoreAlg(int playerScore, int opponentScore) {
  int newscore;
  if (opponentScore != 0) {
    newscore =
        (playerScore - loosingPenalty(playerScore, opponentScore)).ceil();
  } else {
    newscore = (playerScore / 2).ceil();
  }

  return (newscore >= 0) ? newscore : 0;
}
