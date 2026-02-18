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
import '../services/audio_service.dart';
import '../theme/isto_tokens.dart';

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

  // Pawn move animations — now supports multi-step hop-by-hop
  final Map<String, _PawnHopChainAnim> _moveAnims = {};

  // Retreat animations — killed pawns walking backwards to home
  final Map<String, _PawnRetreatAnim> _retreatAnims = {};

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

    // Update move animations (hop-by-hop chain)
    _moveAnims.removeWhere((_, a) => a.isComplete);
    for (final anim in _moveAnims.values) {
      anim.update(dt);
    }

    // Update retreat animations (captured pawns going backwards)
    _retreatAnims.removeWhere((_, a) => a.isComplete);
    for (final anim in _retreatAnims.values) {
      anim.update(dt);
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
    _drawInnerEntryArrows(canvas); // Colored arrows showing inner ring entry
    _drawPathGlow(canvas); // Full path glow rendered before pawns
    _drawHomeAreas(canvas);
    _drawPawns(canvas);
    _drawRetreatPawns(
      canvas,
    ); // Captured pawns retreating home — on top of everything
    _drawCenterDecoration(canvas);
  }

  // ========== BOARD BACKGROUND ==========

  void _drawBoardBackground(Canvas canvas) {
    final rect = Rect.fromLTWH(
      -10,
      -10,
      _boardTotalSize + 20,
      _boardTotalSize + 20,
    );

    // Floating shadow beneath board per spec §6 — Board Elevation & Depth
    final shadowRect = rect.inflate(2);
    // Primary drop shadow: offset (0,8), blur 24, black 50%
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        shadowRect.shift(const Offset(0, 8)),
        const Radius.circular(16),
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 24),
    );
    // Ambient shadow: offset (0,2), blur 6
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        shadowRect.shift(const Offset(0, 2)),
        const Radius.circular(15),
      ),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
    );

    // Outer carved wood frame — uses token colors
    final framePaint =
        Paint()
          ..shader = ui.Gradient.linear(
            const Offset(0, 0),
            Offset(_boardTotalSize, _boardTotalSize),
            [
              IstoColorsDark.bgElevated,
              IstoColorsDark.boardOuterBorder,
              IstoColorsDark.boardCell,
              IstoColorsDark.bgElevated,
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
    final boardRect = Rect.fromLTWH(
      -4,
      -4,
      _boardTotalSize + 8,
      _boardTotalSize + 8,
    );
    final boardPaint = Paint()..color = ThemeConfig.boardBackground;
    canvas.drawRRect(
      RRect.fromRectAndRadius(boardRect, const Radius.circular(8)),
      boardPaint,
    );

    // Explicit outer border 2.5dp per spec §6 — 20% brighter (#8A6035)
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(14)),
      Paint()
        ..color = IstoColorsDark.boardOuterBorder
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5,
    );

    // Subtle wood grain texture lines
    final grainPaint =
        Paint()
          ..color = IstoColorsDark.bgPrimary.withValues(alpha: 0.15)
          ..strokeWidth = 0.5;
    for (int i = 0; i < 8; i++) {
      final y = -4.0 + (_boardTotalSize + 8) * (i / 8.0 + sin(i * 0.7) * 0.02);
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

    // Safe/X-mark cells → owning player mapping (start positions)
    final homePlayerId = _getHomeCellPlayer(r, c);

    // Square base color with checkerboard alternation per spec §6
    Color baseColor;
    if (isCenter) {
      baseColor = IstoColorsDark.centerHome;
    } else if (homePlayerId != null) {
      // Safe square with X mark — full player background color
      baseColor = PlayerColors.getColor(homePlayerId);
    } else if (isInner) {
      // Checkerboard alternation for inner cells
      baseColor =
          (r + c) % 2 == 0
              ? ThemeConfig.innerSquare
              : Color.lerp(
                ThemeConfig.innerSquare,
                IstoColorsDark.boardCell,
                0.3,
              )!;
    } else {
      // Checkerboard alternation for outer cells per spec §6
      baseColor =
          (r + c) % 2 == 0
              ? IstoColorsDark.boardCell
              : IstoColorsDark.boardCellAlt;
    }

    // Draw square background with subtle gradient
    final squareGradient = ui.Gradient.linear(
      Offset(x, y),
      Offset(x + squareSize, y + squareSize),
      [_lighten(baseColor, 8), baseColor, _darken(baseColor, 5)],
      [0, 0.5, 1],
    );
    final rrect = RRect.fromRectAndRadius(rect, const Radius.circular(5));
    canvas.drawRRect(rrect, Paint()..shader = squareGradient);

    // Square border
    final borderColor =
        isCenter
            ? IstoColorsDark.boardOuterBorder
            : isInner
            ? ThemeConfig.innerSquareBorder
            : ThemeConfig.outerSquareBorder;
    final borderPaint =
        Paint()
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
    // Determine if this cell belongs to a player (for colored X)
    final cellR = (rect.top / (squareSize + _gap)).round();
    final cellC = (rect.left / (squareSize + _gap)).round();
    final ownerPlayerId = _getHomeCellPlayer(cellR, cellC);

    // X color: high-contrast white on player cells, otherwise default safe-square border
    final xColor =
        ownerPlayerId != null
            ? const Color(
              0xDDFFFAF0,
            ) // Cream-white, high contrast on any player color
            : IstoColorsDark.safeSquareBorder;

    // Faint inner glow
    final glowPaint =
        Paint()
          ..shader = ui.Gradient.radial(rect.center, squareSize * 0.45, [
            xColor.withValues(alpha: 0.15),
            Colors.transparent,
          ]);
    canvas.drawRect(rect, glowPaint);

    // "X" cross mark — FULL SIZE corner-to-corner per spec §6
    // "drawn on top, suggesting engraving"
    final paint =
        Paint()
          ..color = xColor
          ..strokeWidth = ownerPlayerId != null ? 2.5 : 2.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    final inset = squareSize * 0.04; // Minimal inset — X fills the full box

    // Draw X corner-to-corner
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

    // Small diamond at center of X (engraved feel)
    final cx = rect.center.dx;
    final cy = rect.center.dy;
    final d = squareSize * 0.08;
    final diamondPath =
        Path()
          ..moveTo(cx, cy - d)
          ..lineTo(cx + d, cy)
          ..lineTo(cx, cy + d)
          ..lineTo(cx - d, cy)
          ..close();
    canvas.drawPath(
      diamondPath,
      Paint()..color = xColor.withValues(alpha: 0.45),
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
    final color =
        isKillTarget
            ? ThemeConfig.dangerRed.withValues(alpha: 0.35 * pulse)
            : ThemeConfig.successGreen.withValues(alpha: 0.3 * pulse);

    final highlightPaint = Paint()..color = color;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(5)),
      highlightPaint,
    );

    // Pulsing border
    final borderColor =
        isKillTarget
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
        ..color = (isKillTarget
                ? ThemeConfig.dangerRed
                : ThemeConfig.successGreen)
            .withValues(alpha: 0.15 * pulse)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }

  void _drawCenterSquare(Canvas canvas, Rect rect) {
    final center = rect.center;
    final radius = squareSize * 0.35;

    // Pulsing outer glow (spec: opacity 0.6→1.0→0.6 over 3s)
    final glowPulse = sin(_animTime * 2.09) * 0.2 + 0.35;
    canvas.drawCircle(
      Offset(center.dx, center.dy),
      radius * 1.4,
      Paint()
        ..color = IstoColorsDark.centerHomeGlow.withValues(
          alpha: glowPulse * 0.5,
        )
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );

    // Golden gradient circle base
    final gradient = ui.Gradient.radial(
      Offset(center.dx, center.dy),
      radius,
      [
        IstoColorsDark.accentGlow,
        IstoColorsDark.accentGlow.withValues(alpha: 0.6),
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
        ..color = IstoColorsDark.accentGlow.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // 4-pointed asterisk / Chowka mark (spec §6 & §11)
    // "A 4-pointed star/asterisk drawn at center. Stroke 2.5dp. Color: accent-glow"
    final starPulse = sin(_animTime * 2.09) * 0.2 + 0.8; // 0.6→1.0 over ~3s
    final starPaint =
        Paint()
          ..color = IstoColorsDark.accentGlow.withValues(alpha: starPulse)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
    final cx = center.dx;
    final cy = center.dy;
    final arm = squareSize * 0.22;

    // Vertical line
    canvas.drawLine(Offset(cx, cy - arm), Offset(cx, cy + arm), starPaint);
    // Horizontal line
    canvas.drawLine(Offset(cx - arm, cy), Offset(cx + arm, cy), starPaint);
    // Diagonal lines (45°)
    final diag = arm * 0.7;
    canvas.drawLine(
      Offset(cx - diag, cy - diag),
      Offset(cx + diag, cy + diag),
      starPaint,
    );
    canvas.drawLine(
      Offset(cx + diag, cy - diag),
      Offset(cx - diag, cy + diag),
      starPaint,
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

  // ========== INNER RING ENTRY ARROWS ==========

  /// Inner ring entry points per player: [outerCell, innerCell]
  /// Derived from paths — index 15 (last outer) → index 16 (first inner)
  static const Map<int, List<List<int>>> _innerEntryPoints = {
    0: [
      [4, 1],
      [3, 1],
    ], // P0: bottom-left outer → inner
    1: [
      [0, 3],
      [1, 3],
    ], // P1: top-right outer → inner
    2: [
      [1, 0],
      [1, 1],
    ], // P2: top-left outer → inner
    3: [
      [3, 4],
      [3, 3],
    ], // P3: bottom-right outer → inner
  };

  void _drawInnerEntryArrows(Canvas canvas) {
    final playerCount = gameManager.playerCount;
    for (int p = 0; p < playerCount; p++) {
      final entry = _innerEntryPoints[p]!;
      final outerCell = entry[0];
      final innerCell = entry[1];
      final color = PlayerColors.getColor(p);

      // Get pixel centers of the two cells
      final fromX = outerCell[1] * (squareSize + _gap) + squareSize / 2;
      final fromY = outerCell[0] * (squareSize + _gap) + squareSize / 2;
      final toX = innerCell[1] * (squareSize + _gap) + squareSize / 2;
      final toY = innerCell[0] * (squareSize + _gap) + squareSize / 2;

      // Direction vector
      final dx = toX - fromX;
      final dy = toY - fromY;
      final len = sqrt(dx * dx + dy * dy);
      if (len == 0) continue;
      final nx = dx / len;
      final ny = dy / len;

      // Shorten arrow: start/end inset from cell centers
      final inset = squareSize * 0.28;
      final startX = fromX + nx * inset;
      final startY = fromY + ny * inset;
      final endX = toX - nx * inset;
      final endY = toY - ny * inset;

      // Pulsing alpha for subtle animation
      final pulse = (sin(_animTime * 2.0 + p * 0.8) * 0.15 + 0.55).clamp(
        0.3,
        0.8,
      );

      // Arrow shaft (dashed effect with 3 segments)
      final shaftPaint =
          Paint()
            ..color = color.withValues(alpha: pulse * 0.7)
            ..strokeWidth = 2.0
            ..strokeCap = StrokeCap.round;

      // Draw arrow line
      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), shaftPaint);

      // Arrowhead
      final headLen = squareSize * 0.18;
      final headAngle = 0.5; // ~28 degrees
      final arrowPaint =
          Paint()
            ..color = color.withValues(alpha: pulse * 0.85)
            ..strokeWidth = 2.2
            ..strokeCap = StrokeCap.round
            ..style = PaintingStyle.stroke;

      // Left wing
      canvas.drawLine(
        Offset(endX, endY),
        Offset(
          endX - headLen * (nx * cos(headAngle) - ny * sin(headAngle)),
          endY - headLen * (ny * cos(headAngle) + nx * sin(headAngle)),
        ),
        arrowPaint,
      );
      // Right wing
      canvas.drawLine(
        Offset(endX, endY),
        Offset(
          endX - headLen * (nx * cos(headAngle) + ny * sin(headAngle)),
          endY - headLen * (ny * cos(headAngle) - nx * sin(headAngle)),
        ),
        arrowPaint,
      );

      // Subtle glow behind arrow
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        Paint()
          ..color = color.withValues(alpha: pulse * 0.15)
          ..strokeWidth = 6.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
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
      10.0,
    );

    final rect = homeConfig.rect.translate(0, 0);
    final color = PlayerColors.getColor(playerId);
    final isCurrentPlayer =
        gameManager.turnStateMachine.currentPlayerId == playerId;

    // Home area background — distinctly player-colored
    final bgAlpha = isCurrentPlayer ? 0.40 : 0.25;
    final bgPaint = Paint()..color = color.withValues(alpha: bgAlpha);
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      bgPaint,
    );

    // Inner gradient for depth
    final innerGrad = ui.Gradient.linear(
      Offset(rect.left, rect.top),
      Offset(rect.left, rect.bottom),
      [
        color.withValues(alpha: bgAlpha * 0.5),
        color.withValues(alpha: bgAlpha * 1.3),
      ],
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      Paint()..shader = innerGrad,
    );

    // Dark base behind for contrast
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(9)),
      Paint()..color = IstoColorsDark.bgPrimary.withValues(alpha: 0.35),
    );
    // Re-apply player color over the dark base
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect.deflate(1), const Radius.circular(9)),
      Paint()..color = color.withValues(alpha: bgAlpha),
    );

    // Border — strong player color
    final borderPaint =
        Paint()
          ..color = color.withValues(alpha: isCurrentPlayer ? 0.75 : 0.45)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isCurrentPlayer ? 2.0 : 1.5;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(10)),
      borderPaint,
    );

    // Active player glow
    if (isCurrentPlayer) {
      final glowPulse = sin(_animTime * 3) * 0.12 + 0.22;
      canvas.drawRRect(
        RRect.fromRectAndRadius(rect.inflate(3), const Radius.circular(12)),
        Paint()
          ..color = color.withValues(alpha: glowPulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6),
      );
    }

    // Draw home pawns
    final homePawns = gameManager.pawnController.getHomePawnsForPlayer(
      playerId,
    );
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
    Canvas canvas,
    double x,
    double y,
    Pawn pawn,
    bool isHighlighted,
  ) {
    final baseColor = PlayerColors.getColor(pawn.playerId);
    final radius = pawnSize * 0.4;

    // Spec §7: At-home desaturation — muted color when not highlighted
    final color =
        isHighlighted ? baseColor : IstoPlayerColors.muted(pawn.playerId);

    if (isHighlighted) {
      final pulse = sin(_animTime * 5) * 0.3 + 0.7;
      // Glow ring
      canvas.drawCircle(
        Offset(x, y),
        radius + 5,
        Paint()
          ..color = IstoColorsDark.accentGlow.withValues(alpha: 0.45 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5),
      );
      // Animated dashed selection ring
      final dashCount = 8;
      final dashArc = (2 * pi / dashCount) * 0.6;
      final gapArc = (2 * pi / dashCount) * 0.4;
      final rotation = _animTime * 2.0;
      final ringRadius = radius + 3;
      final ringPaint =
          Paint()
            ..color = IstoColorsDark.accentGlow.withValues(alpha: 0.7 * pulse)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.8
            ..strokeCap = StrokeCap.round;

      for (int i = 0; i < dashCount; i++) {
        final startAngle = rotation + i * (dashArc + gapArc);
        canvas.drawArc(
          Rect.fromCircle(center: Offset(x, y), radius: ringRadius),
          startAngle,
          dashArc,
          false,
          ringPaint,
        );
      }
    }

    _drawPremiumPawn(canvas, x, y, radius, color, playerId: pawn.playerId);
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
    Canvas canvas,
    double x,
    double y,
    double r,
    int points,
    Paint paint,
  ) {
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
    Canvas canvas,
    Rect homeRect,
    int playerId,
    bool isActive,
  ) {
    final color = PlayerColors.getColor(playerId);
    final name =
        gameManager.players.length > playerId
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
    // For top home areas (negative Y = above board), paint label ABOVE the rect
    // For bottom home areas, paint label BELOW the rect
    final isTopHome = homeRect.top < 0;
    final labelY =
        isTopHome ? homeRect.top - textPainter.height - 3 : homeRect.bottom + 4;
    textPainter.paint(
      canvas,
      Offset(homeRect.center.dx - textPainter.width / 2, labelY),
    );
  }

  // ========== PREMIUM PAWN RENDERING ==========

  /// Draw a designed pawn disc — soft radial gradient, inner ring accent,
  /// and subtle centre highlight. Refined but not overly 3D.
  void _drawPremiumPawn(
    Canvas canvas,
    double x,
    double y,
    double radius,
    Color color, {
    int? playerId,
  }) {
    // Soft drop shadow for grounding
    canvas.drawCircle(
      Offset(x, y + 1.5),
      radius + 0.5,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    // Soft radial gradient body — lighter centre fading to slightly
    // darker edge. Gives depth without the harsh 3D look.
    final bodyGradient = ui.Gradient.radial(
      Offset(x - radius * 0.2, y - radius * 0.2), // offset for light angle
      radius * 1.2,
      [
        _lighten(color, 22), // warm highlight centre
        color, // true colour mid-zone
        _darken(color, 18), // subtle shadow rim
      ],
      [0.0, 0.55, 1.0],
    );
    canvas.drawCircle(Offset(x, y), radius, Paint()..shader = bodyGradient);

    // Inner ring detail — subtle carved accent
    canvas.drawCircle(
      Offset(x, y),
      radius * 0.62,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.14)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3,
    );

    // Outer border ring — clean edge definition
    canvas.drawCircle(
      Offset(x, y),
      radius,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.32)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // Small centre highlight dot — subtle sparkle
    canvas.drawCircle(
      Offset(x - radius * 0.13, y - radius * 0.13),
      radius * 0.09,
      Paint()..color = Colors.white.withValues(alpha: 0.40),
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
            _drawHopChainPawn(canvas, pawn, _moveAnims[pawn.id]!);
          } else {
            final isHighlighted = _highlightedPawns.any((p) => p.id == pawn.id);
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
            final isHighlighted = _highlightedPawns.any((p) => p.id == pawn.id);
            _drawBoardPawn(
              canvas,
              offsetX,
              offsetY,
              pawn,
              isHighlighted,
              false,
            );
          }
        }
      }
    }
  }

  void _drawBoardPawn(
    Canvas canvas,
    double x,
    double y,
    Pawn pawn,
    bool isHighlighted,
    bool isFlashing,
  ) {
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

    // Highlight glow for valid moves — spec §7: animated dashed ring
    if (isHighlighted) {
      final pulse = sin(_animTime * 4.5) * 0.3 + 0.7;
      // Outer glow ring (softer, larger)
      canvas.drawCircle(
        Offset(x, y),
        radius + 7,
        Paint()
          ..color = IstoColorsDark.accentGlow.withValues(alpha: 0.35 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7),
      );

      // Animated rotating dashed ring — spec §7: selectable state
      final dashCount = 10;
      final dashArc = (2 * pi / dashCount) * 0.6;
      final gapArc = (2 * pi / dashCount) * 0.4;
      final rotation = _animTime * 2.0; // Rotate at ~2 rad/s
      final ringRadius = radius + 4;
      final ringPaint =
          Paint()
            ..color = IstoColorsDark.accentGlow.withValues(alpha: 0.75 * pulse)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0
            ..strokeCap = StrokeCap.round;

      for (int i = 0; i < dashCount; i++) {
        final startAngle = rotation + i * (dashArc + gapArc);
        canvas.drawArc(
          Rect.fromCircle(center: Offset(x, y), radius: ringRadius),
          startAngle,
          dashArc,
          false,
          ringPaint,
        );
      }

      // Subtle scale pulse effect via slightly larger pawn draw
      // (handled by scaling radius in _drawPremiumPawn would be ideal,
      //  but we'll hint it with a brighter inner glow)
      canvas.drawCircle(
        Offset(x, y),
        radius + 1,
        Paint()
          ..color = IstoColorsDark.accentGlow.withValues(alpha: 0.15 * pulse)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }

    _drawPremiumPawn(canvas, x, y, radius, color, playerId: pawn.playerId);
  }

  /// Draw a pawn that is hopping along a chain of cells
  void _drawHopChainPawn(Canvas canvas, Pawn pawn, _PawnHopChainAnim anim) {
    final pos = anim.getCurrentPosition(squareSize, _gap);
    final hop = anim.getCurrentHop(squareSize);
    _drawBoardPawn(canvas, pos.dx, pos.dy - hop, pawn, false, false);
  }

  /// Draw retreat-ing (captured) pawns — ghost-like, going backwards
  void _drawRetreatPawns(Canvas canvas) {
    for (final entry in _retreatAnims.entries) {
      final anim = entry.value;
      if (anim.isComplete) continue;
      final pos = anim.getCurrentPosition(squareSize, _gap);
      final hop = anim.getCurrentHop(squareSize);
      final color = PlayerColors.getColor(anim.playerId);
      final radius = pawnSize * 0.45;
      // Fade out as retreat progresses
      final alpha = (1.0 - anim.overallProgress * 0.6).clamp(0.3, 1.0);

      canvas.save();
      canvas.translate(pos.dx, pos.dy - hop);

      // Ghost shadow
      canvas.drawCircle(
        const Offset(0, 1.5),
        radius + 0.5,
        Paint()
          ..color = Colors.black.withValues(alpha: 0.15 * alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );

      // Translucent body
      final bodyGradient = ui.Gradient.radial(
        Offset(-radius * 0.2, -radius * 0.2),
        radius * 1.2,
        [
          _lighten(color, 22).withValues(alpha: alpha),
          color.withValues(alpha: alpha),
          _darken(color, 18).withValues(alpha: alpha),
        ],
        [0.0, 0.55, 1.0],
      );
      canvas.drawCircle(Offset.zero, radius, Paint()..shader = bodyGradient);

      // Border
      canvas.drawCircle(
        Offset.zero,
        radius,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.25 * alpha)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2,
      );

      canvas.restore();
    }
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

  /// Map corner cells to player home colors
  /// Corners are the home bases for each player
  /// Map safe-square cells (the ones with X marks) to their owning player.
  /// These are the start positions — the cells marked with X on the board.
  /// Only the 4 edge-midpoint safe squares get player coloring (not center).
  int? _getHomeCellPlayer(int r, int c) {
    // Safe squares = start positions: P0=Bottom, P1=Top, P2=Left, P3=Right
    final playerCount = gameManager.playerCount;
    if (r == 4 && c == 2) return 0; // P0 start — Bottom (always active)
    if (r == 0 && c == 2) {
      return (playerCount >= 2) ? 1 : null; // P1 start — Top
    }
    if (r == 2 && c == 0) {
      return (playerCount >= 3) ? 2 : null; // P2 start — Left
    }
    if (r == 2 && c == 4) {
      return (playerCount >= 4) ? 3 : null; // P3 start — Right
    }
    return null;
  }

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
        final homePawns = gameManager.pawnController.getHomePawnsForPlayer(
          pawn.playerId,
        );
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
      // Build list of all cells from source to destination for hop-by-hop
      final List<List<int>> hopCells = [];
      final start = fromIndex < toIndex ? fromIndex : toIndex;
      final end = fromIndex < toIndex ? toIndex : fromIndex;
      for (int i = start; i <= end; i++) {
        if (i < path.length) {
          hopCells.add(path[i]);
        }
      }
      if (hopCells.length >= 2) {
        _moveAnims[pawn.id] = _PawnHopChainAnim(
          cells: hopCells,
          onHopSound: () {
            audioService.playPawnMove();
          },
        );
      }
    }
  }

  void animatePawnSentHome(Pawn victim, int victimPathIndex) {
    _shakeIntensity = 8.0;
    _shakeTime = 0;

    // Build the reverse path — from the kill cell back to cell 0
    final path = gameManager.boardController.playerPaths[victim.playerId];
    if (path == null || victimPathIndex <= 0) return;

    final List<List<int>> retreatCells = [];
    // Walk backwards: from kill index down to 0
    for (int i = victimPathIndex; i >= 0; i--) {
      if (i < path.length) {
        retreatCells.add(path[i]);
      }
    }

    if (retreatCells.length >= 2) {
      _retreatAnims[victim.id] = _PawnRetreatAnim(
        cells: retreatCells,
        playerId: victim.playerId,
      );
    }
  }

  /// Whether any retreat animations are still playing
  bool get hasActiveRetreatAnims => _retreatAnims.isNotEmpty;

  void flashPawn(Pawn pawn) {
    _flashPawnId = pawn.id;
    _flashTime = 0;
  }
}

/// Hop-by-hop chain animation: pawn hops through each intermediate cell
class _PawnHopChainAnim {
  final List<List<int>> cells; // All cells from source to destination
  final VoidCallback? onHopSound;
  int currentHopIndex = 0; // Current hop (0 = first segment)
  double hopProgress = 0; // 0→1 within current hop
  bool _soundPlayed = false;

  // Adaptive speed: short moves play slower (more visible), long moves faster
  late final double _hopSpeed;

  _PawnHopChainAnim({required this.cells, this.onHopSound}) {
    final n = totalHops;
    if (n <= 2) {
      _hopSpeed = 2.8; // ~357ms per hop
    } else if (n <= 4) {
      _hopSpeed = 3.2; // ~312ms per hop
    } else {
      _hopSpeed = 3.8; // ~263ms per hop
    }
  }

  int get totalHops => cells.length - 1;
  bool get isComplete => currentHopIndex >= totalHops;

  void update(double dt) {
    if (isComplete) return;

    hopProgress += dt * _hopSpeed;

    // Play sound at the very start of each hop (threshold near zero)
    if (!_soundPlayed) {
      _soundPlayed = true;
      onHopSound?.call();
    }

    // Advance to next hop when progress >= 1, carrying over overflow.
    // Each traversed hop gets its sound played.
    while (hopProgress >= 1.0 && !isComplete) {
      hopProgress -= 1.0;
      currentHopIndex++;
      _soundPlayed = false;
      // Immediately trigger sound for the new hop
      if (!isComplete && !_soundPlayed) {
        _soundPlayed = true;
        onHopSound?.call();
      }
    }
  }

  Offset getCurrentPosition(double squareSize, double gap) {
    if (isComplete) {
      final last = cells.last;
      return Offset(
        last[1] * (squareSize + gap) + squareSize / 2,
        last[0] * (squareSize + gap) + squareSize / 2,
      );
    }

    final from = cells[currentHopIndex];
    final to = cells[currentHopIndex + 1];
    final t = _easeInOutCubic(hopProgress.clamp(0.0, 1.0));

    final fromX = from[1] * (squareSize + gap) + squareSize / 2;
    final fromY = from[0] * (squareSize + gap) + squareSize / 2;
    final toX = to[1] * (squareSize + gap) + squareSize / 2;
    final toY = to[0] * (squareSize + gap) + squareSize / 2;

    return Offset(fromX + (toX - fromX) * t, fromY + (toY - fromY) * t);
  }

  double getCurrentHop(double squareSize) {
    if (isComplete) return 0;
    final t = hopProgress.clamp(0.0, 1.0);
    return sin(t * pi) * squareSize * 0.38;
  }

  static double _easeInOutCubic(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3).toDouble() / 2;
  }
}

/// Retreat animation: a captured pawn hops **backwards** along its path to home.
///
/// Faster than normal movement (speed ramps up), with a fading ghost effect.
class _PawnRetreatAnim {
  final List<List<int>>
  cells; // Cells from kill-point → starting cell (reversed)
  final int playerId;
  int currentHopIndex = 0;
  double hopProgress = 0;

  _PawnRetreatAnim({required this.cells, required this.playerId});

  int get totalHops => cells.length - 1;
  bool get isComplete => currentHopIndex >= totalHops;

  /// 0→1 overall progress (for fade calculation)
  double get overallProgress {
    if (totalHops <= 0) return 1.0;
    return ((currentHopIndex + hopProgress) / totalHops).clamp(0.0, 1.0);
  }

  void update(double dt) {
    if (isComplete) return;

    // Accelerate as the retreat continues — starts visible, ends fast
    final accel = 1.0 + overallProgress * 3.0; // 1x → 4x speed
    final baseSpeed = totalHops <= 4 ? 5.0 : 7.0; // fast base
    hopProgress += dt * baseSpeed * accel;

    while (hopProgress >= 1.0 && !isComplete) {
      hopProgress -= 1.0;
      currentHopIndex++;
    }
  }

  Offset getCurrentPosition(double squareSize, double gap) {
    if (isComplete) {
      final last = cells.last;
      return Offset(
        last[1] * (squareSize + gap) + squareSize / 2,
        last[0] * (squareSize + gap) + squareSize / 2,
      );
    }

    final from = cells[currentHopIndex];
    final to = cells[currentHopIndex + 1];
    final t = _easeInOutCubic(hopProgress.clamp(0.0, 1.0));

    final fromX = from[1] * (squareSize + gap) + squareSize / 2;
    final fromY = from[0] * (squareSize + gap) + squareSize / 2;
    final toX = to[1] * (squareSize + gap) + squareSize / 2;
    final toY = to[0] * (squareSize + gap) + squareSize / 2;

    return Offset(fromX + (toX - fromX) * t, fromY + (toY - fromY) * t);
  }

  double getCurrentHop(double squareSize) {
    if (isComplete) return 0;
    final t = hopProgress.clamp(0.0, 1.0);
    // Smaller hop arc for retreat — snappier feel
    return sin(t * pi) * squareSize * 0.22;
  }

  static double _easeInOutCubic(double t) {
    return t < 0.5 ? 4 * t * t * t : 1 - pow(-2 * t + 2, 3).toDouble() / 2;
  }
}
