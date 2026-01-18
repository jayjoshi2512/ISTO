import 'dart:ui';

import '../models/models.dart';

/// Utility functions for position and coordinate calculations
class PositionUtils {
  /// Convert board position to screen coordinates
  static Offset boardToScreen(Position pos, double squareSize, double gap, Offset boardOffset) {
    final x = pos.col * (squareSize + gap) + boardOffset.dx;
    final y = pos.row * (squareSize + gap) + boardOffset.dy;
    return Offset(x, y);
  }

  /// Convert screen coordinates to board position
  static Position? screenToBoard(Offset screenPos, double squareSize, double gap, Offset boardOffset) {
    final adjustedX = screenPos.dx - boardOffset.dx;
    final adjustedY = screenPos.dy - boardOffset.dy;

    final col = (adjustedX / (squareSize + gap)).floor();
    final row = (adjustedY / (squareSize + gap)).floor();

    // Check if within valid range
    if (row < 0 || row > 4 || col < 0 || col > 4) return null;

    // Check if valid board square
    final pos = Position(row, col);
    return pos;
  }

  /// Get center point of a square
  static Offset getSquareCenter(Position pos, double squareSize, double gap, Offset boardOffset) {
    final topLeft = boardToScreen(pos, squareSize, gap, boardOffset);
    return Offset(topLeft.dx + squareSize / 2, topLeft.dy + squareSize / 2);
  }

  /// Calculate distance between two positions
  static double distance(Position a, Position b) {
    final dx = (a.col - b.col).toDouble();
    final dy = (a.row - b.row).toDouble();
    return (dx * dx + dy * dy);
  }

  /// Get home base screen position for a player
  static Offset getHomeBasePosition(int playerId, double boardWidth, Offset boardOffset) {
    switch (playerId) {
      case 0: // Bottom Left
        return Offset(boardOffset.dx - 100, boardOffset.dy + boardWidth - 80);
      case 1: // Top Left
        return Offset(boardOffset.dx - 100, boardOffset.dy);
      case 2: // Top Right
        return Offset(boardOffset.dx + boardWidth + 20, boardOffset.dy);
      case 3: // Bottom Right
        return Offset(boardOffset.dx + boardWidth + 20, boardOffset.dy + boardWidth - 80);
      default:
        return Offset.zero;
    }
  }
}
