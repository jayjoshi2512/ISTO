import 'dart:ui';

/// Layout configuration for player positioning
/// Home areas positioned relative to the board (top / bottom row).
///
/// 2 Players: P0 bottom-left, P1 top-left  (facing each other)
/// 3 Players: P0 bottom-left, P1 top-left, P2 bottom-right
/// 4 Players: P0 bottom-left, P1 top-left, P2 top-right, P3 bottom-right
class LayoutConfig {
  /// Get home area position for a player based on total player count
  /// Returns (xPosition, yPosition, isHorizontal)
  static PlayerHomePosition getHomePosition(
    int playerId,
    int playerCount,
    double boardSize,
    double offset,
  ) {
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

  /// 2 Players: P0 bottom (enters from bottom), P1 top (enters from top)
  static PlayerHomePosition _get2PlayerLayout(
    int playerId,
    double boardSize,
    double offset,
  ) {
    final areaWidth = boardSize * 0.35;
    final areaHeight = boardSize * 0.16;
    final bottomY = boardSize + offset;
    final topY = -areaHeight - offset;

    switch (playerId) {
      case 0: // Bottom Left (P0 enters bottom)
        return PlayerHomePosition(
          rect: Rect.fromLTWH(0, bottomY, areaWidth, areaHeight),
          isHorizontal: true,
        );
      case 1: // Top Left (P1 enters top — facing P0)
        return PlayerHomePosition(
          rect: Rect.fromLTWH(0, topY, areaWidth, areaHeight),
          isHorizontal: true,
        );
      default:
        return PlayerHomePosition(
          rect: Rect.fromLTWH(0, bottomY, areaWidth, areaHeight),
          isHorizontal: true,
        );
    }
  }

  /// 3 Players: P0 bottom-left (bottom), P1 top-left (top), P2 bottom-right (left)
  static PlayerHomePosition _get3PlayerLayout(
    int playerId,
    double boardSize,
    double offset,
  ) {
    final areaWidth = boardSize * 0.35;
    final areaHeight = boardSize * 0.16;
    final bottomY = boardSize + offset;
    final topY = -areaHeight - offset;

    switch (playerId) {
      case 0: // Bottom Left (P0 enters bottom)
        return PlayerHomePosition(
          rect: Rect.fromLTWH(0, bottomY, areaWidth, areaHeight),
          isHorizontal: true,
        );
      case 1: // Top Left (P1 enters top)
        return PlayerHomePosition(
          rect: Rect.fromLTWH(0, topY, areaWidth, areaHeight),
          isHorizontal: true,
        );
      case 2: // Bottom Right (P2 enters left of board)
        return PlayerHomePosition(
          rect: Rect.fromLTWH(
            boardSize - areaWidth,
            bottomY,
            areaWidth,
            areaHeight,
          ),
          isHorizontal: true,
        );
      default:
        return PlayerHomePosition(
          rect: Rect.fromLTWH(0, bottomY, areaWidth, areaHeight),
          isHorizontal: true,
        );
    }
  }

  /// 4 Players: P0 bottom-left, P1 top-left, P2 top-right, P3 bottom-right
  /// Board entries: P0=bottom, P1=top, P2=left, P3=right
  static PlayerHomePosition _get4PlayerLayout(
    int playerId,
    double boardSize,
    double offset,
  ) {
    final areaWidth = boardSize * 0.35;
    final areaHeight = boardSize * 0.16;
    final bottomY = boardSize + offset;
    final topY = -areaHeight - offset;

    switch (playerId) {
      case 0: // Bottom Left (P0 enters bottom)
        return PlayerHomePosition(
          rect: Rect.fromLTWH(0, bottomY, areaWidth, areaHeight),
          isHorizontal: true,
        );
      case 1: // Top Left (P1 enters top)
        return PlayerHomePosition(
          rect: Rect.fromLTWH(0, topY, areaWidth, areaHeight),
          isHorizontal: true,
        );
      case 2: // Top Right (P2 enters left of board)
        return PlayerHomePosition(
          rect: Rect.fromLTWH(
            boardSize - areaWidth,
            topY,
            areaWidth,
            areaHeight,
          ),
          isHorizontal: true,
        );
      case 3: // Bottom Right (P3 enters right of board)
        return PlayerHomePosition(
          rect: Rect.fromLTWH(
            boardSize - areaWidth,
            bottomY,
            areaWidth,
            areaHeight,
          ),
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
  static Offset getPawnHomeOffset(
    int playerId,
    int pawnIndex,
    int playerCount,
    double boardSize,
    double pawnSize,
  ) {
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

  const PlayerHomePosition({required this.rect, required this.isHorizontal});
}
