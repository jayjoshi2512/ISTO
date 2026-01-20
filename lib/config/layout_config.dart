import 'dart:ui';

/// Layout configuration for player positioning
/// Players are positioned on BOTTOM and TOP sides only (not 4 sides)
/// 
/// 2 Players: Both on bottom, left and right ends
/// 3 Players: P0, P1 on bottom; P2 on top center
/// 4 Players: P0, P1 on bottom; P2, P3 on top
class LayoutConfig {
  /// Get home area position for a player based on total player count
  /// Returns (xPosition, yPosition, isHorizontal)
  static PlayerHomePosition getHomePosition(int playerId, int playerCount, double boardSize, double offset) {
    switch (playerCount) {
      case 2:
        return _get2PlayerLayout(playerId, boardSize, offset);
      case 3:
        return _get3PlayerLayout(playerId, boardSize, offset);
      case 4:
        return _get4PlayerLayout(playerId, boardSize, offset);
      default:
        return _get2PlayerLayout(playerId, boardSize, offset);
    }
  }

  /// 2 Players: Both on bottom row, opposite ends
  /// P0 - Bottom Left, P1 - Bottom Right
  static PlayerHomePosition _get2PlayerLayout(int playerId, double boardSize, double offset) {
    final areaWidth = boardSize * 0.35;
    final areaHeight = boardSize * 0.16;
    final bottomY = boardSize + offset;
    
    switch (playerId) {
      case 0: // Bottom Left
        return PlayerHomePosition(
          rect: Rect.fromLTWH(0, bottomY, areaWidth, areaHeight),
          isHorizontal: true,
        );
      case 1: // Bottom Right
        return PlayerHomePosition(
          rect: Rect.fromLTWH(boardSize - areaWidth, bottomY, areaWidth, areaHeight),
          isHorizontal: true,
        );
      default:
        return PlayerHomePosition(
          rect: Rect.fromLTWH(0, bottomY, areaWidth, areaHeight),
          isHorizontal: true,
        );
    }
  }

  /// 3 Players: P0, P1 on bottom; P2 on top center
  static PlayerHomePosition _get3PlayerLayout(int playerId, double boardSize, double offset) {
    final areaWidth = boardSize * 0.35;
    final areaHeight = boardSize * 0.16;
    final bottomY = boardSize + offset;
    final topY = -areaHeight - offset;
    
    switch (playerId) {
      case 0: // Bottom Left
        return PlayerHomePosition(
          rect: Rect.fromLTWH(0, bottomY, areaWidth, areaHeight),
          isHorizontal: true,
        );
      case 1: // Bottom Right
        return PlayerHomePosition(
          rect: Rect.fromLTWH(boardSize - areaWidth, bottomY, areaWidth, areaHeight),
          isHorizontal: true,
        );
      case 2: // Top Center
        return PlayerHomePosition(
          rect: Rect.fromLTWH((boardSize - areaWidth) / 2, topY, areaWidth, areaHeight),
          isHorizontal: true,
        );
      default:
        return PlayerHomePosition(
          rect: Rect.fromLTWH(0, bottomY, areaWidth, areaHeight),
          isHorizontal: true,
        );
    }
  }

  /// 4 Players: P0, P1 on bottom; P2, P3 on top
  static PlayerHomePosition _get4PlayerLayout(int playerId, double boardSize, double offset) {
    final areaWidth = boardSize * 0.35;
    final areaHeight = boardSize * 0.16;
    final bottomY = boardSize + offset;
    final topY = -areaHeight - offset;
    
    switch (playerId) {
      case 0: // Bottom Left
        return PlayerHomePosition(
          rect: Rect.fromLTWH(0, bottomY, areaWidth, areaHeight),
          isHorizontal: true,
        );
      case 1: // Bottom Right
        return PlayerHomePosition(
          rect: Rect.fromLTWH(boardSize - areaWidth, bottomY, areaWidth, areaHeight),
          isHorizontal: true,
        );
      case 2: // Top Left
        return PlayerHomePosition(
          rect: Rect.fromLTWH(0, topY, areaWidth, areaHeight),
          isHorizontal: true,
        );
      case 3: // Top Right
        return PlayerHomePosition(
          rect: Rect.fromLTWH(boardSize - areaWidth, topY, areaWidth, areaHeight),
          isHorizontal: true,
        );
      default:
        return PlayerHomePosition(
          rect: Rect.fromLTWH(0, bottomY, areaWidth, areaHeight),
          isHorizontal: true,
        );
    }
  }

  /// Get pawn home position within home area
  static Offset getPawnHomeOffset(int playerId, int pawnIndex, int playerCount, double boardSize, double pawnSize) {
    final position = getHomePosition(playerId, playerCount, boardSize, 10.0);
    final rect = position.rect;
    final innerRect = rect.deflate(6);
    
    // Always horizontal layout since all home areas are horizontal now
    final cellW = innerRect.width / 4;
    final px = innerRect.left + cellW * pawnIndex + cellW / 2;
    final py = innerRect.center.dy;
    
    return Offset(px, py);
  }
}

/// Represents a player's home area position
class PlayerHomePosition {
  final Rect rect;
  final bool isHorizontal;

  const PlayerHomePosition({
    required this.rect,
    required this.isHorizontal,
  });
}
