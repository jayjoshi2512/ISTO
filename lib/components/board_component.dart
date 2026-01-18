import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../config/board_config.dart';
import '../models/models.dart';
import '../game/game_manager.dart';

/// Player colors matching reference - vibrant and distinct
class IstoColors {
  // Board colors - dark purple theme like reference
  static const Color boardBackground = Color(0xFF2D1B3D);  // Dark purple
  static const Color squareNormal = Color(0xFF3D2952);      // Purple square
  static const Color squareBorder = Color(0xFF5C3D7A);      // Lighter border
  
  // Player colors matching reference image
  static const Color player0 = Color(0xFFE57373); // Red/Coral (Bottom)
  static const Color player1 = Color(0xFF81C784); // Green (Top)
  static const Color player2 = Color(0xFFFFD54F); // Yellow/Amber (Left)
  static const Color player3 = Color(0xFF64B5F6); // Blue (Right)
  
  static const Color highlight = Color(0xFFFFEB3B);
  static const Color centerColor = Color(0xFFE57373);  // Red center like reference
  
  static Color getPlayerColor(int playerId) {
    switch (playerId) {
      case 0: return player0;
      case 1: return player1;
      case 2: return player2;
      case 3: return player3;
      default: return player0;
    }
  }
  
  /// Get safe square color based on which player's start it is
  static Color getSafeSquareColor(int row, int col) {
    final playerId = BoardConfig.getPlayerAtStart([row, col]);
    if (playerId != null) {
      return getPlayerColor(playerId);
    }
    // Center square
    if (row == 2 && col == 2) {
      return centerColor;
    }
    return squareNormal;
  }
}

/// Main board component - renders 5x5 ISTO board like reference image
class BoardComponent extends PositionComponent with TapCallbacks {
  final GameManager gameManager;
  final double squareSize;
  final double pawnSize;
  final Function(Pawn)? onPawnTap;
  
  // Animation state
  final Map<String, Vector2> _pawnPositions = {};
  final Map<String, List<Vector2>> _pawnPaths = {};
  final Map<String, int> _pawnPathIndex = {};
  bool _isAnimating = false;

  final Set<String> _highlightedPawns = {};

  BoardComponent({
    required Vector2 position,
    required this.gameManager,
    required this.squareSize,
    required this.pawnSize,
    this.onPawnTap,
  }) : super(position: position);

  double get gap => 1.0;
  double get totalSize => 5 * squareSize + 4 * gap;

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    size = Vector2.all(totalSize);
  }

  Rect _getSquareRect(int row, int col) {
    final x = col * (squareSize + gap);
    final y = row * (squareSize + gap);
    return Rect.fromLTWH(x, y, squareSize, squareSize);
  }

  Vector2 _getSquareCenter(int row, int col) {
    final rect = _getSquareRect(row, col);
    return Vector2(rect.center.dx, rect.center.dy);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _updatePawnAnimations(dt);
  }

  void _updatePawnAnimations(double dt) {
    if (!_isAnimating) return;
    
    bool stillAnimating = false;
    final speed = squareSize * 8; // pixels per second
    
    for (final pawnId in _pawnPaths.keys.toList()) {
      final path = _pawnPaths[pawnId]!;
      var pathIndex = _pawnPathIndex[pawnId] ?? 0;
      
      if (pathIndex >= path.length) {
        _pawnPaths.remove(pawnId);
        _pawnPathIndex.remove(pawnId);
        continue;
      }
      
      final currentPos = _pawnPositions[pawnId] ?? path[0];
      final targetPos = path[pathIndex];
      
      final diff = targetPos - currentPos;
      final dist = diff.length;
      
      if (dist < speed * dt) {
        // Reached this waypoint
        _pawnPositions[pawnId] = targetPos.clone();
        _pawnPathIndex[pawnId] = pathIndex + 1;
        stillAnimating = true;
      } else {
        // Move towards target
        final move = diff.normalized() * speed * dt;
        _pawnPositions[pawnId] = currentPos + move;
        stillAnimating = true;
      }
    }
    
    _isAnimating = stillAnimating;
  }

  /// Start pawn movement animation through path
  void animatePawnMove(Pawn pawn, int fromIndex, int toIndex) {
    final path = BoardConfig.getPlayerPath(pawn.playerId);
    final positions = <Vector2>[];
    
    // Current position
    if (fromIndex >= 0 && fromIndex < path.length) {
      _pawnPositions[pawn.id] = _getSquareCenter(path[fromIndex][0], path[fromIndex][1]);
    }
    
    // Build path
    for (int i = fromIndex + 1; i <= toIndex && i < path.length; i++) {
      positions.add(_getSquareCenter(path[i][0], path[i][1]));
    }
    
    if (positions.isNotEmpty) {
      _pawnPaths[pawn.id] = positions;
      _pawnPathIndex[pawn.id] = 0;
      _isAnimating = true;
    }
  }

  /// Animate pawn entering board
  void animatePawnEnter(Pawn pawn) {
    final startPos = BoardConfig.startPositions[pawn.playerId]!;
    final target = _getSquareCenter(startPos[0], startPos[1]);
    
    // Start from home area
    final homePos = _getHomePawnPosition(pawn.playerId, pawn.pawnIndex);
    _pawnPositions[pawn.id] = homePos;
    _pawnPaths[pawn.id] = [target];
    _pawnPathIndex[pawn.id] = 0;
    _isAnimating = true;
  }

  Vector2 _getHomePawnPosition(int playerId, int pawnIndex) {
    final areaSize = squareSize * 1.0;
    final offset = 8.0;
    
    double baseX, baseY;
    switch (playerId) {
      case 0: // Bottom
        baseX = totalSize / 2;
        baseY = totalSize + offset + areaSize / 2;
        return Vector2(baseX + (pawnIndex - 1.5) * pawnSize * 1.2, baseY);
      case 1: // Top
        baseX = totalSize / 2;
        baseY = -offset - areaSize / 2;
        return Vector2(baseX + (pawnIndex - 1.5) * pawnSize * 1.2, baseY);
      case 2: // Left
        baseX = -offset - areaSize / 2;
        baseY = totalSize / 2;
        return Vector2(baseX, baseY + (pawnIndex - 1.5) * pawnSize * 1.2);
      case 3: // Right
        baseX = totalSize + offset + areaSize / 2;
        baseY = totalSize / 2;
        return Vector2(baseX, baseY + (pawnIndex - 1.5) * pawnSize * 1.2);
      default:
        return Vector2.zero();
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    // Board background with rounded corners
    final boardRect = Rect.fromLTWH(-8, -8, totalSize + 16, totalSize + 16);
    final boardRRect = RRect.fromRectAndRadius(boardRect, const Radius.circular(12));
    
    // Shadow
    canvas.drawRRect(
      boardRRect.shift(const Offset(3, 4)),
      Paint()
        ..color = Colors.black.withAlpha(100)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
    );
    canvas.drawRRect(boardRRect, Paint()..color = IstoColors.boardBackground);
    
    // Draw all 25 squares
    for (int row = 0; row < 5; row++) {
      for (int col = 0; col < 5; col++) {
        _drawSquare(canvas, row, col);
      }
    }

    // Draw player home areas
    _drawPlayerHomeAreas(canvas);

    // Draw pawns on board (with animation positions)
    _drawBoardPawns(canvas);
    
    // Draw center pawns (finished pawns visible)
    _drawCenterPawns(canvas);
  }

  void _drawSquare(Canvas canvas, int row, int col) {
    final rect = _getSquareRect(row, col);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
    
    final isCenter = BoardConfig.isCenter([row, col]);
    final isSafe = BoardConfig.isSafeSquare([row, col]);
    
    Color bgColor;
    if (isCenter || isSafe) {
      bgColor = IstoColors.getSafeSquareColor(row, col);
    } else {
      bgColor = IstoColors.squareNormal;
    }
    
    // Draw square
    canvas.drawRRect(rrect, Paint()..color = bgColor);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = IstoColors.squareBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Draw X pattern for safe squares and center
    if (isSafe || isCenter) {
      _drawDiagonalX(canvas, rect, isCenter);
    }
    
    // Draw direction arrow for start positions
    if (isSafe && !isCenter) {
      _drawDirectionArrow(canvas, rect, row, col);
    }
  }

  void _drawDiagonalX(Canvas canvas, Rect rect, bool isCenter) {
    final paint = Paint()
      ..color = Colors.white.withAlpha(isCenter ? 200 : 150)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    // Draw diagonal lines from corners
    canvas.drawLine(
      Offset(rect.left, rect.top),
      Offset(rect.right, rect.bottom),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right, rect.top),
      Offset(rect.left, rect.bottom),
      paint,
    );
  }

  void _drawDirectionArrow(Canvas canvas, Rect rect, int row, int col) {
    final playerId = BoardConfig.getPlayerAtStart([row, col]);
    if (playerId == null) return;
    
    final paint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    
    final center = rect.center;
    final arrowSize = rect.width * 0.2;
    
    // Arrow direction based on player (clockwise movement)
    Offset start, end;
    switch (playerId) {
      case 0: // Bottom - moves right
        start = Offset(center.dx - arrowSize, center.dy + rect.height * 0.3);
        end = Offset(center.dx + arrowSize, center.dy + rect.height * 0.3);
        break;
      case 1: // Top - moves left
        start = Offset(center.dx + arrowSize, center.dy - rect.height * 0.3);
        end = Offset(center.dx - arrowSize, center.dy - rect.height * 0.3);
        break;
      case 2: // Left - moves down
        start = Offset(center.dx - rect.width * 0.3, center.dy - arrowSize);
        end = Offset(center.dx - rect.width * 0.3, center.dy + arrowSize);
        break;
      case 3: // Right - moves up
        start = Offset(center.dx + rect.width * 0.3, center.dy + arrowSize);
        end = Offset(center.dx + rect.width * 0.3, center.dy - arrowSize);
        break;
      default:
        return;
    }
    
    canvas.drawLine(start, end, paint);
    
    // Arrow head
    final angle = atan2(end.dy - start.dy, end.dx - start.dx);
    final headLength = arrowSize * 0.5;
    canvas.drawLine(
      end,
      Offset(
        end.dx - headLength * cos(angle - 0.5),
        end.dy - headLength * sin(angle - 0.5),
      ),
      paint,
    );
    canvas.drawLine(
      end,
      Offset(
        end.dx - headLength * cos(angle + 0.5),
        end.dy - headLength * sin(angle + 0.5),
      ),
      paint,
    );
  }

  void _drawPlayerHomeAreas(Canvas canvas) {
    final areaHeight = squareSize * 0.8;
    final areaWidth = squareSize * 2.2;
    final offset = 8.0;
    
    for (int playerId = 0; playerId < gameManager.playerCount; playerId++) {
      Rect areaRect;
      
      switch (playerId) {
        case 0: // Bottom
          areaRect = Rect.fromLTWH(
            (totalSize - areaWidth) / 2,
            totalSize + offset,
            areaWidth,
            areaHeight,
          );
          break;
        case 1: // Top
          areaRect = Rect.fromLTWH(
            (totalSize - areaWidth) / 2,
            -areaHeight - offset,
            areaWidth,
            areaHeight,
          );
          break;
        case 2: // Left
          areaRect = Rect.fromLTWH(
            -areaHeight - offset,
            (totalSize - areaWidth) / 2,
            areaHeight,
            areaWidth,
          );
          break;
        case 3: // Right
          areaRect = Rect.fromLTWH(
            totalSize + offset,
            (totalSize - areaWidth) / 2,
            areaHeight,
            areaWidth,
          );
          break;
        default:
          continue;
      }
      
      _drawPlayerHomeArea(canvas, areaRect, playerId);
    }
  }

  void _drawPlayerHomeArea(Canvas canvas, Rect rect, int playerId) {
    final color = IstoColors.getPlayerColor(playerId);
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    
    // Shadow
    canvas.drawRRect(
      rrect.shift(const Offset(2, 2)),
      Paint()..color = Colors.black.withAlpha(40),
    );
    
    // Background
    canvas.drawRRect(rrect, Paint()..color = color);
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.white.withAlpha(60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Draw home pawns
    final homePawns = gameManager.allPawns
        .where((p) => p.playerId == playerId && p.isHome)
        .toList();

    if (homePawns.isEmpty) return;

    final pawnDrawSize = pawnSize * 0.65;
    final innerRect = rect.deflate(6);
    
    for (int i = 0; i < homePawns.length && i < 4; i++) {
      final pawn = homePawns[i];
      double px, py;
      
      if (playerId == 0 || playerId == 1) {
        // Horizontal layout
        final cellW = innerRect.width / 4;
        px = innerRect.left + cellW * i + cellW / 2 - pawnDrawSize / 2;
        py = innerRect.center.dy - pawnDrawSize / 2;
      } else {
        // Vertical layout
        final cellH = innerRect.height / 4;
        px = innerRect.center.dx - pawnDrawSize / 2;
        py = innerRect.top + cellH * i + cellH / 2 - pawnDrawSize / 2;
      }
      
      final isHighlighted = _highlightedPawns.contains(pawn.id);
      _drawPawn(canvas, Offset(px, py), pawn, pawnDrawSize, isHighlighted);
    }
  }

  void _drawBoardPawns(Canvas canvas) {
    // Group pawns by position (excluding center/finished)
    final pawnsByPos = <String, List<Pawn>>{};
    
    for (final pawn in gameManager.allPawns) {
      if (pawn.isActive && !pawn.isFinished) {
        final pos = gameManager.getPawnPosition(pawn);
        if (pos != null) {
          // Skip center pawns - drawn separately
          if (pos.row == 2 && pos.col == 2) continue;
          
          final key = pos.id;
          pawnsByPos.putIfAbsent(key, () => []);
          pawnsByPos[key]!.add(pawn);
        }
      }
    }

    for (final entry in pawnsByPos.entries) {
      final parts = entry.key.split(',');
      final row = int.parse(parts[0]);
      final col = int.parse(parts[1]);
      final pawns = entry.value;
      
      // Use animated position if available
      Vector2 center;
      if (pawns.length == 1 && _pawnPositions.containsKey(pawns[0].id)) {
        center = _pawnPositions[pawns[0].id]!;
      } else {
        center = _getSquareCenter(row, col);
      }
      
      final drawSize = pawnSize * 0.7;
      
      if (pawns.length == 1) {
        final pawn = pawns[0];
        final isHighlighted = _highlightedPawns.contains(pawn.id);
        _drawPawn(
          canvas,
          Offset(center.x - drawSize / 2, center.y - drawSize / 2),
          pawn,
          drawSize,
          isHighlighted,
        );
      } else {
        // Stack multiple pawns in 2x2 grid
        for (int i = 0; i < pawns.length && i < 4; i++) {
          final pawn = pawns[i];
          final offsetX = ((i % 2) - 0.5) * drawSize * 0.5;
          final offsetY = ((i ~/ 2) - 0.5) * drawSize * 0.5;
          final isHighlighted = _highlightedPawns.contains(pawn.id);
          _drawPawn(
            canvas,
            Offset(
              center.x - drawSize * 0.35 + offsetX,
              center.y - drawSize * 0.35 + offsetY,
            ),
            pawn,
            drawSize * 0.6,
            isHighlighted,
          );
        }
      }
    }
  }

  void _drawCenterPawns(Canvas canvas) {
    // Draw finished pawns in center
    final finishedPawns = gameManager.allPawns
        .where((p) => p.isFinished)
        .toList();
    
    if (finishedPawns.isEmpty) return;
    
    final centerRect = _getSquareRect(2, 2);
    final center = centerRect.center;
    final drawSize = pawnSize * 0.5;
    
    // Arrange in a circle around center
    for (int i = 0; i < finishedPawns.length; i++) {
      final pawn = finishedPawns[i];
      final angle = (i * 2 * pi / finishedPawns.length) - pi / 2;
      final radius = squareSize * 0.25;
      
      final px = center.dx + radius * cos(angle) - drawSize / 2;
      final py = center.dy + radius * sin(angle) - drawSize / 2;
      
      _drawPawn(canvas, Offset(px, py), pawn, drawSize, false);
    }
  }

  void _drawPawn(Canvas canvas, Offset topLeft, Pawn pawn, double size, bool isHighlighted) {
    final color = IstoColors.getPlayerColor(pawn.playerId);
    final center = Offset(topLeft.dx + size / 2, topLeft.dy + size / 2);
    final radius = size / 2;
    
    // Highlight glow (pulsing effect)
    if (isHighlighted) {
      canvas.drawCircle(
        center,
        radius + 5,
        Paint()
          ..color = Colors.yellow.withAlpha(180)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(
        center,
        radius + 2,
        Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }

    // Shadow
    canvas.drawCircle(
      center + const Offset(1.5, 2),
      radius,
      Paint()
        ..color = Colors.black.withAlpha(70)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Pawn body - gradient effect
    canvas.drawCircle(center, radius, Paint()..color = color);
    
    // Inner highlight
    canvas.drawCircle(
      Offset(center.dx - radius * 0.25, center.dy - radius * 0.25),
      radius * 0.25,
      Paint()..color = Colors.white.withAlpha(80),
    );
    
    // Star decoration
    _drawStar(canvas, center, radius * 0.45);

    // Border
    canvas.drawCircle(
      center,
      radius - 0.5,
      Paint()
        ..color = Colors.white.withAlpha(100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius) {
    final path = Path();
    final paint = Paint()..color = Colors.white.withAlpha(180);
    
    for (int i = 0; i < 5; i++) {
      final outerAngle = (i * 72 - 90) * pi / 180;
      final innerAngle = ((i * 72) + 36 - 90) * pi / 180;
      
      final outerX = center.dx + radius * cos(outerAngle);
      final outerY = center.dy + radius * sin(outerAngle);
      final innerX = center.dx + radius * 0.4 * cos(innerAngle);
      final innerY = center.dy + radius * 0.4 * sin(innerAngle);
      
      if (i == 0) {
        path.moveTo(outerX, outerY);
      } else {
        path.lineTo(outerX, outerY);
      }
      path.lineTo(innerX, innerY);
    }
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool containsLocalPoint(Vector2 point) {
    final expand = squareSize * 2;
    return point.x >= -expand &&
           point.x <= totalSize + expand &&
           point.y >= -expand &&
           point.y <= totalSize + expand;
  }

  @override
  void onTapDown(TapDownEvent event) {
    final local = event.localPosition;
    
    // Don't process taps during animation
    if (_isAnimating) return;
    
    // PRIORITY 1: Check for highlighted pawns on board
    for (final pawn in gameManager.allPawns) {
      if (pawn.isActive && _highlightedPawns.contains(pawn.id)) {
        final pos = gameManager.getPawnPosition(pawn);
        if (pos != null) {
          final center = _getSquareCenter(pos.row, pos.col);
          final hitRadius = squareSize * 0.6;
          if ((local.x - center.x).abs() < hitRadius && 
              (local.y - center.y).abs() < hitRadius) {
            onPawnTap?.call(pawn);
            return;
          }
        }
      }
    }
    
    // PRIORITY 2: Check home area highlighted pawns
    for (int playerId = 0; playerId < gameManager.playerCount; playerId++) {
      final homePawns = gameManager.allPawns
          .where((p) => p.playerId == playerId && p.isHome)
          .toList();

      if (homePawns.isEmpty) continue;

      final areaRect = _getPlayerHomeRect(playerId);
      if (areaRect.contains(Offset(local.x, local.y))) {
        for (final pawn in homePawns) {
          if (_highlightedPawns.contains(pawn.id)) {
            onPawnTap?.call(pawn);
            return;
          }
        }
      }
    }
    
    // PRIORITY 3: Any board pawn
    for (final pawn in gameManager.allPawns) {
      if (pawn.isActive) {
        final pos = gameManager.getPawnPosition(pawn);
        if (pos != null) {
          final center = _getSquareCenter(pos.row, pos.col);
          final hitRadius = squareSize * 0.6;
          if ((local.x - center.x).abs() < hitRadius && 
              (local.y - center.y).abs() < hitRadius) {
            onPawnTap?.call(pawn);
            return;
          }
        }
      }
    }
  }

  Rect _getPlayerHomeRect(int playerId) {
    final areaHeight = squareSize * 0.8;
    final areaWidth = squareSize * 2.2;
    final offset = 8.0;
    
    switch (playerId) {
      case 0: // Bottom
        return Rect.fromLTWH(
          (totalSize - areaWidth) / 2,
          totalSize + offset,
          areaWidth,
          areaHeight,
        );
      case 1: // Top
        return Rect.fromLTWH(
          (totalSize - areaWidth) / 2,
          -areaHeight - offset,
          areaWidth,
          areaHeight,
        );
      case 2: // Left
        return Rect.fromLTWH(
          -areaHeight - offset,
          (totalSize - areaWidth) / 2,
          areaHeight,
          areaWidth,
        );
      case 3: // Right
        return Rect.fromLTWH(
          totalSize + offset,
          (totalSize - areaWidth) / 2,
          areaHeight,
          areaWidth,
        );
      default:
        return Rect.zero;
    }
  }

  void highlightValidPawns(List<Pawn> pawns) {
    _highlightedPawns.clear();
    for (final pawn in pawns) {
      _highlightedPawns.add(pawn.id);
    }
  }

  void clearHighlights() {
    _highlightedPawns.clear();
  }

  void updateDisplay() {
    // Trigger re-render by marking dirty
  }
  
  bool get isAnimating => _isAnimating;
}
