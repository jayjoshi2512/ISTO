import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../config/board_config.dart';
import '../config/design_system.dart';
import '../config/player_colors.dart';
import '../config/layout_config.dart';
import '../models/models.dart';
import '../game/game_manager.dart';

/// Board colors - unified with design system
class IstoColors {
  // Board colors - clean minimal dark theme
  static const Color boardBackground = DesignSystem.bgMedium;
  static const Color squareNormal = DesignSystem.surface;
  static const Color squareBorder = DesignSystem.border;
  static const Color squareInner = DesignSystem.surfaceLight;
  
  // Player colors - delegate to PlayerColors for consistency
  static Color get player0 => PlayerColors.player0;
  static Color get player1 => PlayerColors.player1;
  static Color get player2 => PlayerColors.player2;
  static Color get player3 => PlayerColors.player3;
  
  static const Color highlight = DesignSystem.accentGold;
  static const Color centerColor = Color(0xFFD4AF37);  // Gold center
  
  static Color getPlayerColor(int playerId) => PlayerColors.getColor(playerId);
  
  /// Get safe square color based on which player's start it is
  static Color getSafeSquareColor(int row, int col) {
    final playerId = BoardConfig.getPlayerAtStart([row, col]);
    if (playerId != null) {
      return getPlayerColor(playerId).withAlpha(180);
    }
    // Center square
    if (row == 2 && col == 2) {
      return centerColor;
    }
    return squareNormal;
  }
}

/// Animation types for different pawn movements
enum PawnAnimationType {
  move,      // Normal movement - hopping
  enter,     // Entering board - slide with bounce
  captured,  // Being captured - spin and shrink
  finish,    // Reaching center - celebration
}

/// Main board component - renders 5x5 ISTO board
class BoardComponent extends PositionComponent with TapCallbacks {
  final GameManager gameManager;
  final double squareSize;
  final double pawnSize;
  final Function(Pawn)? onPawnTap;
  
  // Animation state
  final Map<String, Vector2> _pawnPositions = {};
  final Map<String, List<Vector2>> _pawnPaths = {};
  final Map<String, int> _pawnPathIndex = {};
  final Map<String, PawnAnimationType> _pawnAnimationType = {};
  final Map<String, double> _pawnAnimationPhase = {};  // 0-1 for hop/bounce
  final Map<String, double> _pawnScale = {};  // For capture animation
  final Map<String, double> _pawnRotation = {};  // For capture spin
  bool _isAnimating = false;

  final Set<String> _highlightedPawns = {};

  BoardComponent({
    required Vector2 position,
    required this.gameManager,
    required this.squareSize,
    required this.pawnSize,
    this.onPawnTap,
  }) : super(position: position);

  double get gap => 2.0;
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
    // Faster base speed for snappier feel
    final baseSpeed = squareSize * 4.0;
    
    for (final pawnId in _pawnPaths.keys.toList()) {
      final path = _pawnPaths[pawnId]!;
      var pathIndex = _pawnPathIndex[pawnId] ?? 0;
      final animType = _pawnAnimationType[pawnId] ?? PawnAnimationType.move;
      
      if (pathIndex >= path.length) {
        // Animation complete - add landing settle effect
        _pawnAnimationPhase[pawnId] = 1.0;  // Mark as landed for squash
        
        // Quick cleanup after settle
        Future.delayed(const Duration(milliseconds: 100), () {
          _pawnPaths.remove(pawnId);
          _pawnPathIndex.remove(pawnId);
          _pawnAnimationType.remove(pawnId);
          _pawnAnimationPhase.remove(pawnId);
          _pawnScale.remove(pawnId);
          _pawnRotation.remove(pawnId);
          _pawnPositions.remove(pawnId);
        });
        continue;
      }
      
      final startPos = pathIndex == 0 
          ? (_pawnPositions[pawnId] ?? path[0])
          : path[pathIndex - 1];
      final targetPos = path[pathIndex];
      final currentPos = _pawnPositions[pawnId] ?? startPos;
      
      final totalDist = (targetPos - startPos).length;
      final currentDist = (currentPos - startPos).length;
      
      // Calculate progress within this square (0.0 to 1.0)
      final progress = totalDist > 0 ? (currentDist / totalDist).clamp(0.0, 1.0) : 0.0;
      
      // Phase is tied to progress - one complete hop per square
      _pawnAnimationPhase[pawnId] = progress;
      
      // Speed varies by animation type - eased for natural feel
      double speed;
      if (animType == PawnAnimationType.captured) {
        speed = baseSpeed * 1.8;
      } else {
        // Ease out - starts fast, slows at end
        final easeProgress = 1 - pow(1 - progress, 2).toDouble();
        speed = baseSpeed * (0.8 + easeProgress * 0.4);
      }
      
      // Handle capture animation (faster spin + more dramatic shrink)
      if (animType == PawnAnimationType.captured) {
        var rotation = _pawnRotation[pawnId] ?? 0.0;
        rotation += dt * 18.0;  // Faster spin
        _pawnRotation[pawnId] = rotation;
        
        final overallProgress = pathIndex / path.length.toDouble();
        // More dramatic shrink with bounce
        final shrinkProgress = pow(overallProgress, 0.7).toDouble();
        _pawnScale[pawnId] = 1.0 - (shrinkProgress * 0.6);
      }
      
      final diff = targetPos - currentPos;
      final dist = diff.length;
      
      if (dist < speed * dt) {
        // Reached this waypoint
        _pawnPositions[pawnId] = targetPos.clone();
        _pawnPathIndex[pawnId] = pathIndex + 1;
        _pawnAnimationPhase[pawnId] = 0.0;
        stillAnimating = true;
      } else {
        // Move towards target with easing
        final move = diff.normalized() * speed * dt;
        _pawnPositions[pawnId] = currentPos + move;
        stillAnimating = true;
      }
    }
    
    _isAnimating = stillAnimating;
  }
  
  /// Enhanced hop offset with squash and stretch feel
  double _getHopOffset(double phase, PawnAnimationType type) {
    if (type == PawnAnimationType.captured) return 0;
    
    // Increased hop height for more visible bounce
    final hopHeight = squareSize * 0.18;  // Relative to square for consistency
    
    // Asymmetric hop - faster up, slower down (more satisfying)
    // Peak at 0.4 instead of 0.5 for snappier feel
    final adjustedPhase = phase < 0.4 
        ? phase / 0.4  // Fast rise to peak
        : 1 - ((phase - 0.4) / 0.6);  // Slower fall
    
    return -hopHeight * sin(adjustedPhase * pi);
  }
  
  /// Get scale factor for squash-and-stretch during hop
  double _getHopScale(double phase, PawnAnimationType type) {
    if (type == PawnAnimationType.captured) return 1.0;
    if (type == PawnAnimationType.finish) return 1.0;
    
    // Subtle squash and stretch
    if (phase < 0.15) {
      // Launch - slight squash before jump
      return 0.92 + (phase / 0.15) * 0.08;
    } else if (phase < 0.4) {
      // Rising - stretch vertically
      return 1.0 + (sin((phase - 0.15) / 0.25 * pi / 2)) * 0.08;
    } else if (phase > 0.85) {
      // Landing - squash on impact
      final landPhase = (phase - 0.85) / 0.15;
      return 1.0 - sin(landPhase * pi) * 0.12;
    }
    return 1.0;
  }

  /// Start pawn movement animation through path with hopping
  void animatePawnMove(Pawn pawn, int fromIndex, int toIndex) {
    final path = BoardConfig.getPlayerPath(pawn.playerId);
    final positions = <Vector2>[];
    
    // Current position
    if (fromIndex >= 0 && fromIndex < path.length) {
      _pawnPositions[pawn.id] = _getSquareCenter(path[fromIndex][0], path[fromIndex][1]);
    }
    
    // Build path through each intermediate square for smooth animation
    for (int i = fromIndex + 1; i <= toIndex && i < path.length; i++) {
      positions.add(_getSquareCenter(path[i][0], path[i][1]));
    }
    
    if (positions.isNotEmpty) {
      _pawnPaths[pawn.id] = positions;
      _pawnPathIndex[pawn.id] = 0;
      _pawnAnimationType[pawn.id] = PawnAnimationType.move;
      _pawnAnimationPhase[pawn.id] = 0.0;
      _isAnimating = true;
    }
  }

  /// Animate pawn entering board from home with bounce
  void animatePawnEnter(Pawn pawn) {
    final startPos = BoardConfig.startPositions[pawn.playerId]!;
    final target = _getSquareCenter(startPos[0], startPos[1]);
    
    // Start from home area (using new 2-sided layout)
    final homePos = _getHomePawnPosition(pawn.playerId, pawn.pawnIndex);
    _pawnPositions[pawn.id] = homePos;
    _pawnPaths[pawn.id] = [target];
    _pawnPathIndex[pawn.id] = 0;
    _pawnAnimationType[pawn.id] = PawnAnimationType.enter;
    _pawnAnimationPhase[pawn.id] = 0.0;
    _isAnimating = true;
  }

  /// Animate pawn being sent back to home (when captured) with spin
  void animatePawnSentHome(Pawn pawn) {
    // Get the pawn's last known position or current animated position
    Vector2 currentPos;
    if (_pawnPositions.containsKey(pawn.id)) {
      currentPos = _pawnPositions[pawn.id]!;
    } else {
      // Try to get current board position
      final pos = gameManager.getPawnPosition(pawn);
      if (pos != null) {
        currentPos = _getSquareCenter(pos.row, pos.col);
      } else {
        currentPos = _getHomePawnPosition(pawn.playerId, pawn.pawnIndex);
      }
    }
    
    // Target is home area (using new 2-sided layout)
    final homePos = _getHomePawnPosition(pawn.playerId, pawn.pawnIndex);
    
    _pawnPositions[pawn.id] = currentPos;
    _pawnPaths[pawn.id] = [homePos];
    _pawnPathIndex[pawn.id] = 0;
    _pawnAnimationType[pawn.id] = PawnAnimationType.captured;
    _pawnRotation[pawn.id] = 0.0;
    _pawnScale[pawn.id] = 1.0;
    _isAnimating = true;
  }

  /// Get home pawn position using new 2-sided layout (bottom/top only)
  Vector2 _getHomePawnPosition(int playerId, int pawnIndex) {
    final playerCount = gameManager.playerCount;
    final offset = LayoutConfig.getPawnHomeOffset(
      playerId, 
      pawnIndex, 
      playerCount, 
      totalSize, 
      pawnSize,
    );
    return Vector2(offset.dx, offset.dy);
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
    
    // Draw current player turn indicator arrow
    _drawTurnIndicatorArrow(canvas);

    // Draw pawns on board (with animation positions)
    _drawBoardPawns(canvas);
    
    // Draw center pawns (finished pawns visible)
    _drawCenterPawns(canvas);
  }
  
  /// Draw turn indicator pointing to current player's home area
  void _drawTurnIndicatorArrow(Canvas canvas) {
    final playerId = gameManager.currentPlayer.id;
    final playerCount = gameManager.playerCount;
    final color = IstoColors.getPlayerColor(playerId);
    
    // Get player's home position using new layout
    final homePos = LayoutConfig.getHomePosition(playerId, playerCount, totalSize, 10.0);
    final homeRect = homePos.rect;
    
    final arrowSize = 8.0;
    
    Path arrowPath;
    Offset arrowTip;
    
    // Determine if player is on bottom or top based on home rect position
    final isBottom = homeRect.top > totalSize / 2;
    
    if (isBottom) {
      // Arrow points down toward bottom home area
      arrowTip = Offset(homeRect.center.dx, homeRect.top - 5);
      arrowPath = Path()
        ..moveTo(arrowTip.dx, arrowTip.dy)
        ..lineTo(arrowTip.dx - arrowSize, arrowTip.dy - arrowSize * 1.5)
        ..lineTo(arrowTip.dx + arrowSize, arrowTip.dy - arrowSize * 1.5)
        ..close();
    } else {
      // Arrow points up toward top home area  
      arrowTip = Offset(homeRect.center.dx, homeRect.bottom + 5);
      arrowPath = Path()
        ..moveTo(arrowTip.dx, arrowTip.dy)
        ..lineTo(arrowTip.dx - arrowSize, arrowTip.dy + arrowSize * 1.5)
        ..lineTo(arrowTip.dx + arrowSize, arrowTip.dy + arrowSize * 1.5)
        ..close();
    }
    
    // Draw glow
    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = color.withAlpha(100)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );
    
    // Draw arrow
    canvas.drawPath(arrowPath, Paint()..color = color);
    
    // Draw border
    canvas.drawPath(
      arrowPath,
      Paint()
        ..color = Colors.white.withAlpha(150)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );
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

  /// Draw player home areas using new 2-sided layout (bottom/top only)
  void _drawPlayerHomeAreas(Canvas canvas) {
    final playerCount = gameManager.playerCount;
    
    for (int playerId = 0; playerId < playerCount; playerId++) {
      final position = LayoutConfig.getHomePosition(playerId, playerCount, totalSize, 10.0);
      _drawPlayerHomeArea(canvas, position.rect, playerId);
    }
  }

  void _drawPlayerHomeArea(Canvas canvas, Rect rect, int playerId) {
    final color = IstoColors.getPlayerColor(playerId);
    final isCurrentPlayer = gameManager.currentPlayer.id == playerId;
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(10));
    
    // Glow effect for current player
    if (isCurrentPlayer) {
      canvas.drawRRect(
        rrect.inflate(3),
        Paint()
          ..color = color.withAlpha(120)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8),
      );
    }
    
    // Shadow
    canvas.drawRRect(
      rrect.shift(const Offset(2, 2)),
      Paint()..color = Colors.black.withAlpha(60),
    );
    
    // Background with gradient effect
    canvas.drawRRect(rrect, Paint()..color = color);
    
    // Inner highlight
    final innerRRect = RRect.fromRectAndRadius(
      rect.deflate(3), 
      const Radius.circular(7),
    );
    canvas.drawRRect(
      innerRRect,
      Paint()..color = Colors.white.withAlpha(25),
    );
    
    // Border - thicker for current player
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = isCurrentPlayer ? Colors.white : Colors.white.withAlpha(60)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isCurrentPlayer ? 2.5 : 1.5,
    );

    // Draw player number label
    _drawPlayerLabel(canvas, rect, playerId);

    // Draw home pawns
    final homePawns = gameManager.allPawns
        .where((p) => p.playerId == playerId && p.isHome)
        .toList();

    if (homePawns.isEmpty) return;

    final pawnDrawSize = pawnSize * 0.55;
    final innerRect = rect.deflate(6);
    
    // All home areas are now horizontal (bottom/top sides)
    for (int i = 0; i < homePawns.length && i < 4; i++) {
      final pawn = homePawns[i];
      final cellW = innerRect.width / 4;
      final px = innerRect.left + cellW * i + cellW / 2 - pawnDrawSize / 2;
      final py = innerRect.center.dy - pawnDrawSize / 2;
      
      final isHighlighted = _highlightedPawns.contains(pawn.id);
      _drawPawn(canvas, Offset(px, py), pawn, pawnDrawSize, isHighlighted, 1.0, 0.0);
    }
  }
  
  void _drawPlayerLabel(Canvas canvas, Rect rect, int playerId) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: 'P${playerId + 1}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black54,
              blurRadius: 2,
              offset: Offset(1, 1),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    
    // All home areas are now horizontal - label at top-left corner
    final labelX = rect.left + 4;
    final labelY = rect.top + 2;
    
    textPainter.paint(canvas, Offset(labelX, labelY));
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
      
      final drawSize = pawnSize * 0.7;
      
      if (pawns.length == 1) {
        final pawn = pawns[0];
        final isHighlighted = _highlightedPawns.contains(pawn.id);
        
        // Get animated position with hop offset and squash-stretch
        Vector2 baseCenter;
        double hopOffset = 0.0;
        double scale = 1.0;
        double rotation = 0.0;
        double hopScale = 1.0;  // For squash-stretch effect
        
        if (_pawnPositions.containsKey(pawn.id)) {
          baseCenter = _pawnPositions[pawn.id]!;
          final animType = _pawnAnimationType[pawn.id] ?? PawnAnimationType.move;
          final phase = _pawnAnimationPhase[pawn.id] ?? 0.0;
          hopOffset = _getHopOffset(phase, animType);
          hopScale = _getHopScale(phase, animType);
          scale = (_pawnScale[pawn.id] ?? 1.0) * hopScale;
          rotation = _pawnRotation[pawn.id] ?? 0.0;
        } else {
          baseCenter = _getSquareCenter(row, col);
        }
        
        _drawPawn(
          canvas,
          Offset(baseCenter.x - drawSize / 2, baseCenter.y - drawSize / 2 + hopOffset),
          pawn,
          drawSize,
          isHighlighted,
          scale,
          rotation,
        );
      } else {
        // Stack multiple pawns in 2x2 grid (no animation for stacked)
        final center = _getSquareCenter(row, col);
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
            1.0,
            0.0,
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
      
      _drawPawn(canvas, Offset(px, py), pawn, drawSize, false, 1.0, 0.0);
    }
  }

  /// Draw a pawn with optional scale and rotation for animations
  void _drawPawn(Canvas canvas, Offset topLeft, Pawn pawn, double size, bool isHighlighted, [double scale = 1.0, double rotation = 0.0]) {
    final color = IstoColors.getPlayerColor(pawn.playerId);
    final scaledSize = size * scale;
    final center = Offset(topLeft.dx + size / 2, topLeft.dy + size / 2);
    final radius = scaledSize / 2;
    
    canvas.save();
    
    // Apply rotation for capture animation
    if (rotation != 0) {
      canvas.translate(center.dx, center.dy);
      canvas.rotate(rotation);
      canvas.translate(-center.dx, -center.dy);
    }
    
    // Highlight glow (pulsing effect)
    if (isHighlighted) {
      canvas.drawCircle(
        center,
        radius + 5,
        Paint()
          ..color = IstoColors.highlight.withAlpha(180)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      canvas.drawCircle(
        center,
        radius + 2,
        Paint()
          ..color = IstoColors.highlight
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
    
    canvas.restore();
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
    // Expand bounds to include home areas above and below the board
    // Home areas can be at y = -boardSize*0.16 - 10 (approximately -100)
    // and below at y = boardSize + 10 + boardSize*0.16
    final expandX = squareSize * 2;
    final expandY = totalSize * 0.25; // 25% of board size for home areas
    return point.x >= -expandX &&
           point.x <= totalSize + expandX &&
           point.y >= -expandY &&
           point.y <= totalSize + expandY;
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

  /// Get home area rect using LayoutConfig for correct 2-sided positioning
  Rect _getPlayerHomeRect(int playerId) {
    final playerCount = gameManager.playerCount;
    final position = LayoutConfig.getHomePosition(playerId, playerCount, totalSize, 10.0);
    return position.rect;
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
