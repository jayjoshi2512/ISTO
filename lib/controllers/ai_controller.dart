import 'dart:math';

import '../config/board_config.dart';
import '../models/models.dart';
import 'board_controller.dart';

/// AI Controller for ISTO game
///
/// Evaluates board state and selects optimal moves based on difficulty level.
/// Uses scoring heuristics to rank available moves.
class AIController {
  final Random _random = Random();
  final AIDifficulty difficulty;

  AIController({this.difficulty = AIDifficulty.medium});

  /// Select the best pawn to move from valid options
  Pawn selectPawn(
    List<Pawn> validPawns,
    int steps,
    CowryRoll roll,
    BoardController boardController,
    List<Pawn> allPawns,
    int playerId,
    bool hasCaptured,
  ) {
    if (validPawns.isEmpty) {
      throw StateError('No valid pawns to select');
    }

    if (validPawns.length == 1) return validPawns.first;

    switch (difficulty) {
      case AIDifficulty.easy:
        return _selectEasy(validPawns);
      case AIDifficulty.medium:
        return _selectMedium(
          validPawns,
          steps,
          roll,
          boardController,
          allPawns,
          playerId,
          hasCaptured,
        );
      case AIDifficulty.hard:
        return _selectHard(
          validPawns,
          steps,
          roll,
          boardController,
          allPawns,
          playerId,
          hasCaptured,
        );
    }
  }

  /// Easy: Pure random selection
  Pawn _selectEasy(List<Pawn> validPawns) {
    return validPawns[_random.nextInt(validPawns.length)];
  }

  /// Medium: 70% best move, 30% random
  Pawn _selectMedium(
    List<Pawn> validPawns,
    int steps,
    CowryRoll roll,
    BoardController boardController,
    List<Pawn> allPawns,
    int playerId,
    bool hasCaptured,
  ) {
    if (_random.nextDouble() < 0.3) {
      return _selectEasy(validPawns);
    }
    return _selectBest(
      validPawns,
      steps,
      roll,
      boardController,
      allPawns,
      playerId,
      hasCaptured,
    );
  }

  /// Hard: Always pick best move with full evaluation
  Pawn _selectHard(
    List<Pawn> validPawns,
    int steps,
    CowryRoll roll,
    BoardController boardController,
    List<Pawn> allPawns,
    int playerId,
    bool hasCaptured,
  ) {
    return _selectBest(
      validPawns,
      steps,
      roll,
      boardController,
      allPawns,
      playerId,
      hasCaptured,
    );
  }

  /// Select the best move using scoring heuristics
  Pawn _selectBest(
    List<Pawn> validPawns,
    int steps,
    CowryRoll roll,
    BoardController boardController,
    List<Pawn> allPawns,
    int playerId,
    bool hasCaptured,
  ) {
    double bestScore = double.negativeInfinity;
    Pawn bestPawn = validPawns.first;

    for (final pawn in validPawns) {
      final score = _evaluateMove(
        pawn,
        steps,
        roll,
        boardController,
        allPawns,
        playerId,
        hasCaptured,
      );
      if (score > bestScore) {
        bestScore = score;
        bestPawn = pawn;
      }
    }

    return bestPawn;
  }

  /// Evaluate the score of moving a specific pawn
  double _evaluateMove(
    Pawn pawn,
    int steps,
    CowryRoll roll,
    BoardController boardController,
    List<Pawn> allPawns,
    int playerId,
    bool hasCaptured,
  ) {
    double score = 0;

    // === ENTRY MOVES ===
    if (pawn.isHome) {
      score += _evaluateEntry(pawn, boardController, allPawns, playerId);
      return score;
    }

    // === ACTIVE PAWN MOVES ===
    final path = boardController.playerPaths[playerId]!;
    final newIndex = pawn.pathIndex + steps;

    // Check if reaches center (FINISH!)
    if (newIndex == path.length - 1) {
      score += 500; // Highest priority - finishing a pawn
      return score;
    }

    if (newIndex >= path.length) {
      return -1000; // Invalid move
    }

    final destPos = path[newIndex];

    // === KILL EVALUATION ===
    score += _evaluateKill(destPos, boardController, allPawns, playerId);

    // === SAFETY EVALUATION ===
    score += _evaluateSafety(
      pawn,
      destPos,
      boardController,
      allPawns,
      playerId,
    );

    // === PROGRESS EVALUATION ===
    score += _evaluateProgress(pawn, newIndex, path.length);

    // === INNER RING ENTRY ===
    if (BoardConfig.isInnerPath(destPos) &&
        !BoardConfig.isInnerPath(path[pawn.pathIndex])) {
      if (hasCaptured) {
        score += 60; // Good to enter inner ring if eligible
      }
    }

    // === LEAVING SAFE SQUARE PENALTY ===
    if (BoardConfig.isSafeSquare(path[pawn.pathIndex]) &&
        !BoardConfig.isSafeSquare(destPos)) {
      score -= 40; // Slight penalty for leaving safety
    }

    return score;
  }

  /// Evaluate entering a pawn onto the board
  double _evaluateEntry(
    Pawn pawn,
    BoardController boardController,
    List<Pawn> allPawns,
    int playerId,
  ) {
    double score = 120; // Base entry value

    // Count active pawns - prefer entering when we have few on board
    final activePawns =
        allPawns.where((p) => p.playerId == playerId && p.isActive).length;
    if (activePawns == 0) {
      score += 80; // Must enter if no pawns on board
    } else if (activePawns < 2) {
      score += 40; // Prefer entering early
    }

    // Check if entry kills opponent
    final startPos = BoardConfig.startPositions[playerId]!;
    final startSquare = boardController.getSquareAt(startPos[0], startPos[1]);
    if (startSquare != null && startSquare.hasEnemyPawns(playerId)) {
      score += 300; // Kill on entry is amazing
    }

    return score;
  }

  /// Evaluate kill potential at destination
  double _evaluateKill(
    List<int> destPos,
    BoardController boardController,
    List<Pawn> allPawns,
    int playerId,
  ) {
    if (BoardConfig.isSafeSquare(destPos)) return 0;

    final square = boardController.getSquareAt(destPos[0], destPos[1]);
    if (square == null) return 0;

    final enemies = square.getEnemyPawns(playerId);
    if (enemies.isEmpty) return 0;

    double score = 0;
    for (final enemy in enemies) {
      // More valuable to kill pawns that are further along
      score += 350 + (enemy.pathIndex * 8);

      // Extra value for killing pawns near center
      final enemyPath = boardController.playerPaths[enemy.playerId]!;
      final distToCenter = enemyPath.length - 1 - enemy.pathIndex;
      if (distToCenter < 5) {
        score += 100; // Kill pawns near finishing
      }
    }

    return score;
  }

  /// Evaluate safety of destination
  double _evaluateSafety(
    Pawn pawn,
    List<int> destPos,
    BoardController boardController,
    List<Pawn> allPawns,
    int playerId,
  ) {
    double score = 0;

    // Landing on safe square is great
    if (BoardConfig.isSafeSquare(destPos)) {
      score += 80;
    } else {
      // Check if any opponent can reach this square
      final dangerLevel = _assessDanger(
        destPos,
        boardController,
        allPawns,
        playerId,
      );
      score -= dangerLevel * 30;
    }

    return score;
  }

  /// Evaluate progress toward center
  double _evaluateProgress(Pawn pawn, int newIndex, int pathLength) {
    // Prefer moving pawns that are closer to finishing (momentum)
    final progressPct = newIndex / (pathLength - 1);
    return progressPct * 50;
  }

  /// Assess danger level at a position (0 = safe, higher = more dangerous)
  double _assessDanger(
    List<int> pos,
    BoardController boardController,
    List<Pawn> allPawns,
    int playerId,
  ) {
    if (BoardConfig.isSafeSquare(pos)) return 0;

    double danger = 0;

    // Check each opponent pawn
    for (final opponent in allPawns.where(
      (p) => p.playerId != playerId && p.isActive,
    )) {
      final opponentPath = boardController.playerPaths[opponent.playerId]!;

      // Check if opponent is within striking distance (1-8 steps)
      for (int steps = 1; steps <= 8; steps++) {
        final oppNewIndex = opponent.pathIndex + steps;
        if (oppNewIndex < opponentPath.length) {
          final oppDest = opponentPath[oppNewIndex];
          if (oppDest[0] == pos[0] && oppDest[1] == pos[1]) {
            // Weight by probability of rolling that number
            final probability = _rollProbability(steps);
            danger += probability;
          }
        }
      }
    }

    return danger;
  }

  /// Approximate probability of rolling a specific step count
  double _rollProbability(int steps) {
    // Based on 4 cowry shells (each 50% up/down)
    // 0 up (8 steps): 1/16 = 0.0625
    // 1 up (1 step):  4/16 = 0.25
    // 2 up (2 steps): 6/16 = 0.375
    // 3 up (3 steps): 4/16 = 0.25
    // 4 up (4 steps): 1/16 = 0.0625
    switch (steps) {
      case 1:
        return 0.25;
      case 2:
        return 0.375;
      case 3:
        return 0.25;
      case 4:
        return 0.0625;
      case 8:
        return 0.0625;
      default:
        return 0;
    }
  }

  /// Decide how many stacked pawns to move together
  int selectStackedPawnCount(
    List<Pawn> stackedPawns,
    int rollValue,
    BoardController boardController,
    List<Pawn> allPawns,
    int playerId,
  ) {
    if (stackedPawns.length <= 1) return 1;

    // Evaluate moving different counts
    double bestScore = double.negativeInfinity;
    int bestCount = 1;

    for (int count = 1; count <= stackedPawns.length; count++) {
      if (rollValue % count != 0) continue; // Must be divisible

      final stepsPerPawn = rollValue ~/ count;
      final pawn = stackedPawns.first;
      final path = boardController.playerPaths[playerId]!;
      final newIndex = pawn.pathIndex + stepsPerPawn;

      if (newIndex >= path.length) continue;

      double score = 0;

      // Moving together is generally strong (protection)
      if (count > 1) score += 30;

      // Check for kills with stack
      if (newIndex < path.length) {
        final destPos = path[newIndex];
        final destSquare = boardController.getSquareAt(destPos[0], destPos[1]);
        if (destSquare != null) {
          final enemies = destSquare.getEnemyPawns(playerId);
          if (enemies.isNotEmpty && count >= enemies.length) {
            score += 400; // Can kill with stack!
          }
        }
      }

      // Check if reaches center
      if (newIndex == path.length - 1) {
        score += 500 * count; // All pawns finish!
      }

      if (score > bestScore) {
        bestScore = score;
        bestCount = count;
      }
    }

    return bestCount;
  }

  /// Get delay before AI makes a move (in milliseconds)
  /// Generous delays so the AI looks like it's thinking
  int getMoveDelay() {
    switch (difficulty) {
      case AIDifficulty.easy:
        return 1200 + _random.nextInt(1000);
      case AIDifficulty.medium:
        return 900 + _random.nextInt(800);
      case AIDifficulty.hard:
        return 700 + _random.nextInt(600);
    }
  }

  /// Get delay before AI rolls (in milliseconds)
  int getRollDelay() {
    switch (difficulty) {
      case AIDifficulty.easy:
        return 1500 + _random.nextInt(1200);
      case AIDifficulty.medium:
        return 1200 + _random.nextInt(1000);
      case AIDifficulty.hard:
        return 800 + _random.nextInt(800);
    }
  }
}
