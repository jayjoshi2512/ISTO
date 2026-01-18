import '../config/board_config.dart';
import '../models/models.dart';

/// Utility functions for path calculations
class PathUtils {
  /// Get the complete path for a player
  static List<Position> getPlayerPath(int playerId) {
    final pathList = BoardConfig.getPlayerPath(playerId);
    return pathList.map((p) => Position.fromList(p)).toList();
  }

  /// Get remaining steps to reach center
  static int getStepsToCenter(int playerId, int currentIndex) {
    final pathLength = BoardConfig.getPlayerPath(playerId).length;
    return pathLength - 1 - currentIndex;
  }

  /// Check if a path index is on the outer ring
  static bool isOnOuterRing(int playerId, int pathIndex) {
    final path = BoardConfig.getPlayerPath(playerId);
    if (pathIndex < 0 || pathIndex >= path.length) return false;
    final pos = path[pathIndex];
    return BoardConfig.isOuterPath(pos);
  }

  /// Check if a path index is on the inner path
  static bool isOnInnerPath(int playerId, int pathIndex) {
    final path = BoardConfig.getPlayerPath(playerId);
    if (pathIndex < 0 || pathIndex >= path.length) return false;
    final pos = path[pathIndex];
    return BoardConfig.isInnerPath(pos);
  }

  /// Get the path positions between two indices (exclusive of start, inclusive of end)
  static List<Position> getPathSegment(int playerId, int startIndex, int endIndex) {
    final path = BoardConfig.getPlayerPath(playerId);
    if (startIndex < 0 || endIndex >= path.length || startIndex >= endIndex) {
      return [];
    }
    
    return path
        .sublist(startIndex + 1, endIndex + 1)
        .map((p) => Position.fromList(p))
        .toList();
  }
}
