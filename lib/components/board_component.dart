import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../config/board_config.dart';
import '../config/layout_config.dart';
import '../config/player_colors.dart';
import '../config/theme_config.dart';
import '../game/game_manager.dart';
import '../models/models.dart';

/// Renders the entire game board — 5×5 grid, premium pawns, home areas,
/// full path glow, and rich visual effects
class BoardComponent extends PositionComponent with TapCallbacks {
  final GameManager gameManager;
  final double squareSize;
  final double pawnSize;
  final Function(Pawn) onPawnTap;

  // Highlighted pawns (valid moves)
  List<Pawn> _highlightedPawns = [];

  // Animation state
  double _animTime = 0;

  // Pawn move animations
  final Map<String, _PawnMoveAnim> _moveAnims = {};

  // Screen shake
  double _shakeIntensity = 0;
  double _shakeTime = 0;

  // Flash effect for pawn
  String? _flashPawnId;
  double _flashTime = 0;

  BoardComponent({
    required Vector2 position,
    required this.gameManager,
    required this.squareSize,
    required this.pawnSize,
    required this.onPawnTap,
  }) : super(position: position);

  double get _boardTotalSize => 5 * squareSize + 4 * 2;
  double get _gap => 2.0;

  @override
  void update(double dt) {
    super.update(dt);
    _animTime += dt;

    // Update screen shake
    if (_shakeIntensity > 0) {
      _shakeTime += dt;
      _shakeIntensity *= 0.88;
      if (_shakeIntensity < 0.3) _shakeIntensity = 0;
    }

    // Update move animations
    _moveAnims.removeWhere((_, a) => a.progress >= 1.0);
    for (final anim in _moveAnims.values) {
      anim.progress += dt * 3.5;
      if (anim.progress > 1.0) anim.progress = 1.0;
    }

    // Update flash
    if (_flashPawnId != null) {
      _flashTime += dt;
      if (_flashTime > 0.5) {
        _flashPawnId = null;
        _flashTime = 0;
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // Apply screen shake
    if (_shakeIntensity > 0) {
      final dx = sin(_shakeTime * 40) * _shakeIntensity;
      final dy = cos(_shakeTime * 30) * _shakeIntensity * 0.7;
      canvas.translate(dx, dy);
    }

    _drawBoardBackground(canvas);
    _drawSquares(canvas);
    _drawPathGlow(canvas); // Full path glow rendered before pawns
    _drawHomeAreas(canvas);
    _drawPawns(canvas);
    _drawCenterDecoration(canvas);
  }

  // ========== BOARD BACKGROUND ==========

  void _drawBoardBackground(Canvas canvas) {
    final rect =
        Rect.fromLTWH(-10, -10, _boardTotalSize + 20, _boardTotalSize + 20);

    // Outer carved wood frame
    final framePaint = Paint()
      ..shader = ui.Gradient.linear(
        const Offset(0, 0),
        Offset(_boardTotalSize, _boardTotalSize),
        [
          const Color(0xFF3D2B18),
          const Color(0xFF5A4530),
          const Color(0xFF4A3320),
          const Color(0xFF3D2B18),
        ],
        [0, 0.3, 0.7, 1],
      );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(14)),
      framePaint,
    );

    // Inner shadow for carved-in effect
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(2), const Radius.circular(12)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );

    // Inner board area
    final boardRect =
        Rect.fromLTWH(-4, -4, _boardTotalSize + 8, _boardTotalSize + 8);
    final boardPaint = Paint()..color = ThemeConfig.boardBackground;
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(8)),
      boardPaint,
    );

    // Subtle wood grain texture lines
    final grainPaint = Paint()
      ..color = const Color(0xFF2A1A0C).withValues(alpha: 0.15)
      ..strokeWidth = 0.5;
    for (int i = 0; i < 8; i++) {
      final y =
          -4.0 + (_boardTotalSize + 8) * (i / 8.0 + sin(i * 0.7) * 0.02);
      canvas.drawLine(
        Offset(-4, y),
        Offset(_boardTotalSize + 4, y + sin(i * 1.3) * 3),
        grainPaint,
      );
    }
  }

  // ========== SQUARES ==========

  void _drawSquares(Canvas canvas) {
    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 5; c++) {
        if (!BoardConfig.isValidSquare(r, c)) continue;
        _drawSquare(canvas, r, c);
      }
    }
  }

  void _drawSquare(Canvas canvas, int r, int c) {
    final x = c * (squareSize + _gap);
    final y = r * (squareSize + _gap);
    final rect = Rect.fromLTWH(x, y, squareSize, squareSize);
    final pos = [r, c];

    final isCenter = BoardConfig.isCenter(pos);
    final isInner = BoardConfig.isInnerPath(pos);
    final isSafe = BoardConfig.isSafeSquare(pos);
    final isHighlighted = _isSquareHighlighted(r, c);
    final isKillTarget = _isKillTarget(r, c);
    final isOnPath = _isSquareOnPath(r, c);

    // Square base color
    Color baseColor;
    if (isCenter) {
      baseColor = const Color(0xFF3D2B18);
    } else if (isInner) {
      baseColor = ThemeConfig.innerSquare;
    } else {
      baseColor = ThemeConfig.outerSquare;
    }

    // Draw square background with subtle gradient
    final squareGradient = ui.Gradient.linear(
      Offset(x, y),
      Offset(x + squareSize, y + squareSize),
      [
        _lighten(baseColor, 8),
        baseColor,
        _darken(baseColor, 5),
      ],
      [0, 0.5, 1],
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));
    canvas.drawRRect(rrect, Paint()..shader = squareGradient);

    // Square border
    final borderColor = isCenter
        ? const Color(0xFF5A4530)
        : isInner
            ? ThemeConfig.innerSquareBorder
            : ThemeConfig.outerSquareBorder;
    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;
    canvas.drawRRect(rrect, borderPaint);

    // Safe square — ornate X marker
    if (isSafe && !isCenter) {
      _drawSafeMarker(canvas, rect);
    }

    // Starting position player indicator
    final startPlayer = BoardConfig.getPlayerAtStart(pos);
    if (startPlayer != null) {
      _drawStartIndicator(canvas, rect, startPlayer);
    }

    // Full path glow for intermediate squares
    if (isOnPath && !isHighlighted) {
      _drawPathSquareGlow(canvas, rect);
    }

    // Highlight for valid move destinations
    if (isHighlighted) {
      _drawHighlight(canvas, rect, isKillTarget);
    }

    // Center decoration (golden circle)
    if (isCenter) {
      _drawCenterSquare(canvas, rect);
    }
  }

  void _drawSafeMarker(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = ThemeConfig.safeSquareMark
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final inset = squareSize * 0.25;

    // Ornate X pattern
    canvas.drawLine(
      Offset(rect.left + inset, rect.top + inset),
      Offset(rect.right - inset, rect.bottom - inset),
      paint,
    );
    canvas.drawLine(
      Offset(rect.right - inset, rect.top + inset),
      Offset(rect.left + inset, rect.bottom - inset),
      paint,
    );

    // Small diamond at center of X
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final d = squareSize * 0.06;
    final diamondPath = Path()
      ..moveTo(cx, cy - d)
      ..lineTo(cx + d, cy)
      ..lineTo(cx, cy + d)
      ..lineTo(cx - d, cy)
      ..close();
    canvas.drawPath(
      diamondPath,
      Paint()..color = ThemeConfig.safeSquareMark.withValues(alpha: 0.5),
    );
  }

  void _drawStartIndicator(Canvas canvas, Rect rect, int playerId) {
    final color = PlayerColors.getColor(playerId);
    final dotSize = squareSize * 0.07;

    // Small colored dot in corner
    canvas.drawCircle(
      Offset(rect.right - dotSize * 2.5, rect.top + dotSize * 2.5),
      dotSize,
      Paint()..color = color.withValues(alpha: 0.6),
    );
    // Tiny glow
    canvas.drawCircle(
      Offset(rect.right - dotSize * 2.5, rect.top + dotSize * 2.5),
      dotSize * 2,
      Paint()
        ..color = color.withValues(alpha: 0.1)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  void _drawPathSquareGlow(Canvas canvas, Rect rect) {
    // Subtle glow for squares on the movement path
    final pulse = (sin(_animTime * 3.5) * 0.15 + 0.2);
    final playerColor = PlayerColors.getColor(
      gameManager.turnStateMachine.currentPlayerId,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(4)),
      Paint()
        ..color = playerColor.withValues(alpha: pulse * 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
  }

  void _drawHighlight(Canvas canvas, Rect rect, bool isKillTarget) {
    final pulse = (sin(_animTime * 4) * 0.3 + 0.7);
    final color = isKillTarget
        ? ThemeConfig.dangerRed.withValues(alpha: 0.35 * pulse)
        : ThemeConfig.successGreen.withValues(alpha: 0.3 * pulse);

    final highlightPaint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(5)),
      highlightPaint,
    );

    // Pulsing border
    final borderColor = isKillTarget
        ? ThemeConfig.dangerRed.withValues(alpha: 0.8 * pulse)
        : ThemeConfig.successGreen.withValues(alpha: 0.7 * pulse);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(5)),
      Paint()
        ..color = borderColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0,
    );

    // Outer glow
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.inflate(2), const Radius.circular(7)),
      Paint()
        ..color = (isKillTarget ? ThemeConfig.dangerRed : ThemeConfig.successGreen)
            .withValues(alpha: 0.15 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  void _drawCenterSquare(Canvas canvas, Rect rect) {
    final center = rect.center;
    final radius = squareSize * 0.35;

    // Golden gradient circle
    final gradient = ui.Gradient.radial(
      Offset(center.dx, center.dy),
      radius,
      [
        ThemeConfig.centerSquare,
        ThemeConfig.centerSquare.withValues(alpha: 0.6),
        Colors.transparent,
      ],
      [0, 0.7, 1],
    );
    canvas.drawCircle(
      Offset(center.dx, center.dy),
      radius,
      Paint()..shader = gradient,
    );

    // Inner ring
    canvas.drawCircle(
      Offset(center.dx, center.dy),
      radius * 0.55,
      Paint()
        ..color = ThemeConfig.centerSquare.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Pulsing glow
    final glowPulse = sin(_animTime * 2) * 0.2 + 0.35;
    canvas.drawCircle(
      Offset(center.dx, center.dy),
      radius * 1.3,
      Paint()
        ..color = ThemeConfig.centerSquareGlow.withValues(alpha: glowPulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10),
    );
  }

  void _drawCenterDecoration(Canvas canvas) {
    // Draw finished pawns in center
    final centerSquare = gameManager.boardController.getSquareAt(2, 2);
    if (centerSquare == null || centerSquare.isEmpty) return;

    final cx = 2 * (squareSize + _gap) + squareSize / 2;
    final cy = 2 * (squareSize + _gap) + squareSize / 2;
    final finishedPawns = centerSquare.pawns;
    final radius = squareSize * 0.25;

    for (int i = 0; i < finishedPawns.length; i++) {
      final angle = (i * 2 * pi / finishedPawns.length) - pi / 2;
      final px = cx + cos(angle) * radius;
      final py = cy + sin(angle) * radius;
      _drawMiniPawn(canvas, px, py, finishedPawns[i]);
    }
  }

  // ========== FULL PATH GLOW ==========

  /// Draw a glowing trail showing the full path for each highlighted pawn
  void _drawPathGlow(Canvas canvas) {
    if (_highlightedPawns.isEmpty) return;

    final roll = gameManager.cowryController.lastRoll;
    if (roll == null) return;

    for (final pawn in _highlightedPawns) {
      _drawPawnPathGlow(canvas, pawn, roll.steps);
    }
  }

  void _drawPawnPathGlow(Canvas canvas, Pawn pawn, int steps) {
    final playerColor = PlayerColors.getColor(pawn.playerId);
    final path = gameManager.boardController.playerPaths[pawn.playerId]!;
    final pulse = sin(_animTime * 3) * 0.15 + 0.5;

    if (pawn.isHome) {
      // Entry — glow the start position
      final startPos = BoardConfig.startPositions[pawn.playerId]!;
      final x = startPos[1] * (squareSize + _gap) + squareSize / 2;
      final y = startPos[0] * (squareSize + _gap) + squareSize / 2;
      canvas.drawCircle(
        Offset(x, y),
        squareSize * 0.4,
        Paint()
          ..color = playerColor.withValues(alpha: 0.2 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      return;
    }

    final startIdx = pawn.pathIndex;
    final endIdx = startIdx + steps;
    if (endIdx >= path.length) return;

    // Draw glowing dots along intermediate path squares
    for (int i = startIdx + 1; i <= endIdx; i++) {
      if (i >= path.length) break;
      final pos = path[i];
      final x = pos[1] * (squareSize + _gap) + squareSize / 2;
      final y = pos[0] * (squareSize + _gap) + squareSize / 2;

      // Intensity increases toward destination
      final progress = (i - startIdx) / (endIdx - startIdx);
      final alpha = (0.08 + progress * 0.25) * pulse;

      // Trail dot
      canvas.drawCircle(
        Offset(x, y),
        squareSize * 0.15 + progress * squareSize * 0.1,
        Paint()
          ..color = playerColor.withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );

      // Connect dots with a thin line
      if (i > startIdx + 1) {
        final prevPos = path[i - 1];
        final px = prevPos[1] * (squareSize + _gap) + squareSize / 2;
        final py = prevPos[0] * (squareSize + _gap) + squareSize / 2;
        canvas.drawLine(
          Offset(px, py),
          Offset(x, y),
          Paint()
            ..color = playerColor.withValues(alpha: alpha * 0.5)
            ..strokeWidth = 1.5
            ..strokeCap = StrokeCap.round,
        );
      }
    }
  }

  // ========== HOME AREAS ==========

  void _drawHomeAreas(Canvas canvas) {
    final playerCount = gameManager.playerCount;
    for (int p = 0; p < playerCount; p++) {
      _drawHomeArea(canvas, p, playerCount);
    }
  }

  void _drawHomeArea(Canvas canvas, int playerId, int playerCount) {
    final homeConfig = LayoutConfig.getHomePosition(
      playerId,
      playerCount,
      _boardTotalSize,
      _boardTotalSize,
    );

    final rect = homeConfig.rect.translate(0, 0);
    final color = PlayerColors.getColor(playerId);
    final isCurrentPlayer =
        gameManager.turnStateMachine.currentPlayerId == playerId;

    // Home area background
    final bgPaint = Paint()
      ..color = color.withValues(alpha: isCurrentPlayer ? 0.15 : 0.07);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      bgPaint,
    );

    // Border
    final borderPaint = Paint()
      ..color = color.withValues(alpha: isCurrentPlayer ? 0.5 : 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isCurrentPlayer ? 2.0 : 1.0;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      borderPaint,
    );

    // Active player glow
    if (isCurrentPlayer) {
      final glowPulse = sin(_animTime * 3) * 0.12 + 0.18;
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          rect.inflate(3),
          const Radius.circular(12),
        ),
        Paint()
          ..color = color.withValues(alpha: glowPulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // Draw home pawns
    final homePawns =
        gameManager.pawnController.getHomePawnsForPlayer(playerId);
    final finishedCount =
        gameManager.pawnController.getFinishedPawnsForPlayer(playerId).length;

    for (int i = 0; i < 4; i++) {
      final offset = LayoutConfig.getPawnHomeOffset(
        playerId,
        i,
        playerCount,
        _boardTotalSize,
        pawnSize,
      );

      if (i < homePawns.length) {
        final pawn = homePawns[i];
        final isHighlighted = _highlightedPawns.any((p) => p.id == pawn.id);
        _drawHomePawn(canvas, offset.dx, offset.dy, pawn, isHighlighted);
      } else if (i >= 4 - finishedCount) {
        _drawFinishedStar(canvas, offset.dx, offset.dy, color);
      } else {
        _drawEmptySlot(canvas, offset.dx, offset.dy, color);
      }
    }

    // Player name label
    _drawPlayerLabel(canvas, rect, playerId, isCurrentPlayer);
  }

  void _drawHomePawn(
      Canvas canvas, double x, double y, Pawn pawn, bool isHighlighted) {
    final color = PlayerColors.getColor(pawn.playerId);
    final radius = pawnSize * 0.4;

    if (isHighlighted) {
      final pulse = sin(_animTime * 5) * 0.3 + 0.7;
      canvas.drawCircle(
        Offset(x, y),
        radius + 5,
        Paint()
          ..color = ThemeConfig.successGreen.withValues(alpha: 0.5 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
    }

    _drawPremiumPawn(canvas, x, y, radius, color);
  }

  void _drawFinishedStar(Canvas canvas, double x, double y, Color color) {
    final paint = Paint()..color = ThemeConfig.goldAccent;
    final radius = pawnSize * 0.25;
    _drawStar(canvas, x, y, radius, 5, paint);
    // Star glow
    canvas.drawCircle(
      Offset(x, y),
      radius * 1.5,
      Paint()
        ..color = ThemeConfig.goldAccent.withValues(alpha: 0.15)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  void _drawStar(
      Canvas canvas, double x, double y, double r, int points, Paint paint) {
    final path = Path();
    for (int i = 0; i < points * 2; i++) {
      final angle = (i * pi / points) - pi / 2;
      final rad = i.isEven ? r : r * 0.45;
      final px = x + cos(angle) * rad;
      final py = y + sin(angle) * rad;
      if (i == 0) {
        path.moveTo(px, py);
      } else {
        path.lineTo(px, py);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  void _drawEmptySlot(Canvas canvas, double x, double y, Color color) {
    canvas.drawCircle(
      Offset(x, y),
      pawnSize * 0.3,
      Paint()
        ..color = color.withValues(alpha: 0.12)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawPlayerLabel(
      Canvas canvas, Rect homeRect, int playerId, bool isActive) {
    final color = PlayerColors.getColor(playerId);
    final name = gameManager.players.length > playerId
        ? gameManager.players[playerId].name
        : PlayerColors.getName(playerId);

    final textPainter = TextPainter(
      text: TextSpan(
        text: name,
        style: TextStyle(
          fontSize: 10,
          fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
          color: isActive ? color : color.withValues(alpha: 0.6),
          letterSpacing: 0.5,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        homeRect.center.dx - textPainter.width / 2,
        homeRect.bottom + 4,
      ),
    );
  }

  // ========== PREMIUM PAWN RENDERING ==========

  /// Draw a premium 3D chess-piece style pawn with depth, shine, and detail
  void _drawPremiumPawn(
      Canvas canvas, double x, double y, double radius, Color color) {
    // Drop shadow — multi-layer for depth
    canvas.drawCircle(
      Offset(x + 1, y + 3),
      radius + 1,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    // Base disc (slightly larger, darker) — chess piece base
    canvas.drawCircle(
      Offset(x, y + 2),
      radius * 1.05,
      Paint()..color = _darken(color, 45),
    );

    // Main body with rich radial gradient
    final bodyGradient = ui.Gradient.radial(
      Offset(x - radius * 0.3, y - radius * 0.3),
      radius * 1.4,
      [
        _lighten(color, 55), // Bright highlight
        _lighten(color, 25), // Light area
        color, // Mid tone
        _darken(color, 35), // Shadow edge
      ],
      [0.0, 0.3, 0.6, 1.0],
    );
    canvas.drawCircle(
      Offset(x, y),
      radius,
      Paint()..shader = bodyGradient,
    );

    // Rim light — thin bright edge for 3D pop
    canvas.drawCircle(
      Offset(x, y),
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2,
    );

    // Inner specular highlight (top-left crescent)
    final highlightPath = Path()
      ..addOval(Rect.fromCenter(
        center: Offset(x - radius * 0.2, y - radius * 0.2),
        width: radius * 0.7,
        height: radius * 0.5,
      ));
    canvas.drawPath(
      highlightPath,
      Paint()..color = Colors.white.withValues(alpha: 0.3),
    );

    // Tiny bright specular dot (the "shine point")
    canvas.drawCircle(
      Offset(x - radius * 0.25, y - radius * 0.25),
      radius * 0.12,
      Paint()..color = Colors.white.withValues(alpha: 0.7),
    );

    // Inner ring for chess-piece identity
    canvas.drawCircle(
      Offset(x, y),
      radius * 0.5,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );

    // Center gem/dot (player identity marker)
    final gemGradient = ui.Gradient.radial(
      Offset(x, y),
      radius * 0.18,
      [
        Colors.white.withValues(alpha: 0.8),
        _lighten(color, 30).withValues(alpha: 0.5),
      ],
    );
    canvas.drawCircle(
      Offset(x, y),
      radius * 0.13,
      Paint()..shader = gemGradient,
    );
  }

  // ========== BOARD PAWNS ==========

  void _drawPawns(Canvas canvas) {
    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 5; c++) {
        if (r == 2 && c == 2) continue; // Center drawn separately
        final square = gameManager.boardController.getSquareAt(r, c);
        if (square == null || square.isEmpty) continue;

        final x = c * (squareSize + _gap) + squareSize / 2;
        final y = r * (squareSize + _gap) + squareSize / 2;

        if (square.pawns.length == 1) {
          final pawn = square.pawns.first;

          // Check for move animation
          if (_moveAnims.containsKey(pawn.id)) {
            _drawAnimatedPawn(canvas, pawn, _moveAnims[pawn.id]!);
          } else {
            final isHighlighted =
                _highlightedPawns.any((p) => p.id == pawn.id);
            final isFlashing = _flashPawnId == pawn.id;
            _drawBoardPawn(canvas, x, y, pawn, isHighlighted, isFlashing);
          }
        } else {
          // Multiple pawns stacked — draw with offset
          for (int i = 0; i < square.pawns.length; i++) {
            final pawn = square.pawns[i];
            final offsetX =
                x + (i - (square.pawns.length - 1) / 2) * (pawnSize * 0.3);
            final offsetY = y - i * 2;
            final isHighlighted =
                _highlightedPawns.any((p) => p.id == pawn.id);
            _drawBoardPawn(
                canvas, offsetX, offsetY, pawn, isHighlighted, false);
          }
        }
      }
    }
  }

  void _drawBoardPawn(Canvas canvas, double x, double y, Pawn pawn,
      bool isHighlighted, bool isFlashing) {
    final color = PlayerColors.getColor(pawn.playerId);
    final radius = pawnSize * 0.45;

    // Flash effect (AI move indicator)
    if (isFlashing) {
      final flash = sin(_flashTime * 20) * 0.5 + 0.5;
      canvas.drawCircle(
        Offset(x, y),
        radius + 7,
        Paint()
          ..color = color.withValues(alpha: 0.5 * flash)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );
    }

    // Highlight glow for valid moves
    if (isHighlighted) {
      final pulse = sin(_animTime * 4.5) * 0.3 + 0.7;
      // Outer glow ring
      canvas.drawCircle(
        Offset(x, y),
        radius + 6,
        Paint()
          ..color = ThemeConfig.successGreen.withValues(alpha: 0.4 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
      // Selection ring
      canvas.drawCircle(
        Offset(x, y),
        radius + 3,
        Paint()
          ..color = ThemeConfig.successGreen.withValues(alpha: 0.6 * pulse)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5,
      );
    }

    _drawPremiumPawn(canvas, x, y, radius, color);
  }

  void _drawAnimatedPawn(Canvas canvas, Pawn pawn, _PawnMoveAnim anim) {
    final t = _easeOutCubic(anim.progress.clamp(0.0, 1.0));

    // Interpolate position
    final fromX = anim.fromCol * (squareSize + _gap) + squareSize / 2;
    final fromY = anim.fromRow * (squareSize + _gap) + squareSize / 2;
    final toX = anim.toCol * (squareSize + _gap) + squareSize / 2;
    final toY = anim.toRow * (squareSize + _gap) + squareSize / 2;

    final x = fromX + (toX - fromX) * t;
    final y = fromY + (toY - fromY) * t;

    // Hop arc effect
    final hop = sin(t * pi) * squareSize * 0.35;

    _drawBoardPawn(canvas, x, y - hop, pawn, false, false);
  }

  void _drawMiniPawn(Canvas canvas, double x, double y, Pawn pawn) {
    final color = PlayerColors.getColor(pawn.playerId);
    final radius = pawnSize * 0.28;

    canvas.drawCircle(Offset(x, y), radius, Paint()..color = color);
    canvas.drawCircle(
      Offset(x, y),
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.4)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0,
    );
  }

  // ========== HELPERS ==========

  /// Check if a square is the DESTINATION for any highlighted pawn
  bool _isSquareHighlighted(int r, int c) {
    for (final pawn in _highlightedPawns) {
      if (pawn.isHome) {
        final startPos = BoardConfig.startPositions[pawn.playerId];
        if (startPos != null && startPos[0] == r && startPos[1] == c) {
          return true;
        }
      } else {
        final roll = gameManager.cowryController.lastRoll;
        if (roll != null) {
          final newIndex = pawn.pathIndex + roll.steps;
          final path = gameManager.boardController.playerPaths[pawn.playerId]!;
          if (newIndex < path.length) {
            final destPos = path[newIndex];
            if (destPos[0] == r && destPos[1] == c) return true;
          }
        }
      }
    }
    return false;
  }

  /// Check if a square is on the INTERMEDIATE PATH for any highlighted pawn
  bool _isSquareOnPath(int r, int c) {
    final roll = gameManager.cowryController.lastRoll;
    if (roll == null) return false;

    for (final pawn in _highlightedPawns) {
      if (pawn.isHome) continue;
      final path = gameManager.boardController.playerPaths[pawn.playerId]!;
      final startIdx = pawn.pathIndex;
      final endIdx = startIdx + roll.steps;

      // Check intermediate squares (not start, not end)
      for (int i = startIdx + 1; i < endIdx && i < path.length; i++) {
        if (path[i][0] == r && path[i][1] == c) return true;
      }
    }
    return false;
  }

  bool _isKillTarget(int r, int c) {
    final square = gameManager.boardController.getSquareAt(r, c);
    if (square == null || square.isEmpty) return false;

    for (final pawn in _highlightedPawns) {
      if (pawn.isActive) {
        final roll = gameManager.cowryController.lastRoll;
        if (roll != null) {
          final newIndex = pawn.pathIndex + roll.steps;
          final path = gameManager.boardController.playerPaths[pawn.playerId]!;
          if (newIndex < path.length) {
            final destPos = path[newIndex];
            if (destPos[0] == r && destPos[1] == c) {
              return square.hasEnemyPawns(pawn.playerId);
            }
          }
        }
      }
    }
    return false;
  }

  Color _lighten(Color color, int amount) {
    return Color.fromARGB(
      color.a.toInt(),
      (color.r.toInt() + amount).clamp(0, 255),
      (color.g.toInt() + amount).clamp(0, 255),
      (color.b.toInt() + amount).clamp(0, 255),
    );
  }

  Color _darken(Color color, int amount) {
    return Color.fromARGB(
      color.a.toInt(),
      (color.r.toInt() - amount).clamp(0, 255),
      (color.g.toInt() - amount).clamp(0, 255),
      (color.b.toInt() - amount).clamp(0, 255),
    );
  }

  double _easeOutCubic(double t) {
    return 1 - pow(1 - t, 3).toDouble();
  }

  // ========== TAP HANDLING ==========

  @override
  bool containsLocalPoint(Vector2 point) {
    return Rect.fromLTWH(
      -20,
      -_boardTotalSize * 0.25,
      _boardTotalSize + 40,
      _boardTotalSize * 1.5,
    ).contains(point.toOffset());
  }

  @override
  void onTapDown(TapDownEvent event) {
    final localPos = event.localPosition;

    // Check if tapping on a highlighted board pawn
    for (final pawn in _highlightedPawns) {
      if (pawn.isActive) {
        final pos = gameManager.getPawnPosition(pawn);
        if (pos != null) {
          final px = pos.col * (squareSize + _gap) + squareSize / 2;
          final py = pos.row * (squareSize + _gap) + squareSize / 2;
          if ((localPos - Vector2(px, py)).length < squareSize * 0.5) {
            onPawnTap(pawn);
            return;
          }
        }
      }
    }

    // Check if tapping on a highlighted home pawn
    for (final pawn in _highlightedPawns) {
      if (pawn.isHome) {
        final homePawns =
            gameManager.pawnController.getHomePawnsForPlayer(pawn.playerId);
        for (int i = 0; i < homePawns.length; i++) {
          if (homePawns[i].id == pawn.id) {
            final offset = LayoutConfig.getPawnHomeOffset(
              pawn.playerId,
              i,
              gameManager.playerCount,
              _boardTotalSize,
              pawnSize,
            );
            if ((localPos - Vector2(offset.dx, offset.dy)).length <
                pawnSize * 0.6) {
              onPawnTap(pawn);
              return;
            }
          }
        }
      }
    }

    // Check any board pawn tap (non-highlighted)
    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 5; c++) {
        final square = gameManager.boardController.getSquareAt(r, c);
        if (square == null || square.isEmpty) continue;
        final px = c * (squareSize + _gap) + squareSize / 2;
        final py = r * (squareSize + _gap) + squareSize / 2;
        if ((localPos - Vector2(px, py)).length < squareSize * 0.5) {
          for (final pawn in square.pawns) {
            if (_highlightedPawns.any((p) => p.id == pawn.id)) {
              onPawnTap(pawn);
              return;
            }
          }
        }
      }
    }
  }

  // ========== PUBLIC API ==========

  void highlightValidPawns(List<Pawn> pawns) {
    _highlightedPawns = List.from(pawns);
  }

  void clearHighlights() {
    _highlightedPawns.clear();
  }

  void updateDisplay() {
    // Called when game state changes — component auto-rerenders
  }

  void animatePawnMove(Pawn pawn, int fromIndex, int toIndex) {
    final path = gameManager.boardController.playerPaths[pawn.playerId]!;
    if (fromIndex >= 0 && fromIndex < path.length && toIndex < path.length) {
      final from = path[fromIndex];
      final to = path[toIndex];
      _moveAnims[pawn.id] = _PawnMoveAnim(
        fromRow: from[0].toDouble(),
        fromCol: from[1].toDouble(),
        toRow: to[0].toDouble(),
        toCol: to[1].toDouble(),
      );
    }
  }

  void animatePawnSentHome(Pawn victim) {
    _shakeIntensity = 8.0;
    _shakeTime = 0;
  }

  void flashPawn(Pawn pawn) {
    _flashPawnId = pawn.id;
    _flashTime = 0;
  }
}

/// Internal animation data for pawn movement
class _PawnMoveAnim {
  final double fromRow, fromCol, toRow, toCol;
  double progress = 0;

  _PawnMoveAnim({
    required this.fromRow,
    required this.fromCol,
    required this.toRow,
    required this.toCol,
  });
}
