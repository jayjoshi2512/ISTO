import 'dart:math';
import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../config/board_config.dart';

/// Player colors matching the board
class PawnColors {
  static const Color player0 = Color(0xFFE57373); // Red (Bottom)
  static const Color player1 = Color(0xFF81C784); // Green (Top)
  static const Color player2 = Color(0xFFFFD54F); // Yellow (Left)
  static const Color player3 = Color(0xFF64B5F6); // Blue (Right)
  
  static Color getColor(int playerId) {
    switch (playerId) {
      case 0: return player0;
      case 1: return player1;
      case 2: return player2;
      case 3: return player3;
      default: return player0;
    }
  }
}

/// Animated pawn that moves smoothly between squares
class AnimatedPawnComponent extends PositionComponent {
  final Pawn pawn;
  final double pawnSize;
  final Function(Vector2)? getSquareCenter;
  
  bool isHighlighted = false;
  bool isAnimating = false;
  double _pulsePhase = 0;
  double _bounceOffset = 0;
  
  // Animation state
  double _killScale = 1.0;
  bool _isEnterAnimation = false;
  double _enterScale = 0.0;

  AnimatedPawnComponent({
    required this.pawn,
    required this.pawnSize,
    required Vector2 position,
    this.getSquareCenter,
  }) : super(position: position, size: Vector2.all(pawnSize));

  @override
  void update(double dt) {
    super.update(dt);
    
    // Pulse animation for highlighted pawns
    if (isHighlighted && !isAnimating) {
      _pulsePhase += dt * 4;
      _bounceOffset = sin(_pulsePhase) * 3;
    } else {
      _bounceOffset = 0;
    }
  }

  /// Animate pawn moving through path squares
  Future<void> animateMove({
    required List<Vector2> pathPositions,
    required Duration stepDuration,
    VoidCallback? onComplete,
  }) async {
    if (pathPositions.isEmpty) {
      onComplete?.call();
      return;
    }
    
    isAnimating = true;
    
    for (int i = 0; i < pathPositions.length; i++) {
      final target = pathPositions[i];
      
      // Move to this position
      add(MoveEffect.to(
        target,
        EffectController(duration: stepDuration.inMilliseconds / 1000),
      ));
      
      await Future.delayed(stepDuration);
    }
    
    isAnimating = false;
    onComplete?.call();
  }

  /// Animate pawn entering the board
  Future<void> animateEnter({
    required Vector2 targetPosition,
    VoidCallback? onComplete,
  }) async {
    _isEnterAnimation = true;
    _enterScale = 0.0;
    
    // Move to target
    position = targetPosition;
    
    // Scale up animation
    for (int i = 0; i <= 10; i++) {
      _enterScale = i / 10;
      await Future.delayed(const Duration(milliseconds: 30));
    }
    
    _isEnterAnimation = false;
    _enterScale = 1.0;
    onComplete?.call();
  }

  /// Animate pawn being captured (killed)
  Future<void> animateKill({
    required Vector2 homePosition,
    VoidCallback? onComplete,
  }) async {
    isAnimating = true;
    
    // Flash and shrink
    for (int i = 0; i < 3; i++) {
      _killScale = 0.8;
      await Future.delayed(const Duration(milliseconds: 80));
      _killScale = 1.2;
      await Future.delayed(const Duration(milliseconds: 80));
    }
    
    // Move to home
    add(MoveEffect.to(
      homePosition,
      EffectController(duration: 0.3),
    ));
    
    await Future.delayed(const Duration(milliseconds: 300));
    
    isAnimating = false;
    _killScale = 1.0;
    onComplete?.call();
  }

  /// Animate reaching center (victory for this pawn)
  Future<void> animateFinish({VoidCallback? onComplete}) async {
    // Spin and scale up
    for (int i = 0; i < 8; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
    }
    onComplete?.call();
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);
    
    final color = PawnColors.getColor(pawn.playerId);
    final centerX = size.x / 2;
    final centerY = size.y / 2 - _bounceOffset;
    final radius = (size.x / 2) * (_isEnterAnimation ? _enterScale : _killScale);
    
    if (radius <= 0) return;
    
    // Highlight glow
    if (isHighlighted && !isAnimating) {
      final glowPaint = Paint()
        ..color = Colors.yellow.withAlpha(150)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
      canvas.drawCircle(Offset(centerX, centerY), radius + 6, glowPaint);
      
      canvas.drawCircle(
        Offset(centerX, centerY),
        radius + 3,
        Paint()
          ..color = Colors.yellow
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2,
      );
    }
    
    // Shadow
    canvas.drawCircle(
      Offset(centerX + 2, centerY + 3),
      radius,
      Paint()
        ..color = Colors.black.withAlpha(60)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );
    
    // Main pawn body
    canvas.drawCircle(
      Offset(centerX, centerY),
      radius,
      Paint()..color = color,
    );
    
    // Inner gradient effect
    final innerColor = Color.lerp(color, Colors.white, 0.3)!;
    canvas.drawCircle(
      Offset(centerX - radius * 0.2, centerY - radius * 0.2),
      radius * 0.3,
      Paint()..color = innerColor.withAlpha(150),
    );
    
    // Star in center
    _drawStar(canvas, Offset(centerX, centerY), radius * 0.4);
    
    // Border
    canvas.drawCircle(
      Offset(centerX, centerY),
      radius - 1,
      Paint()
        ..color = Colors.white.withAlpha(100)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius) {
    final path = Path();
    final paint = Paint()..color = Colors.white.withAlpha(200);
    
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
}

/// Animation controller for managing all pawn animations
class PawnAnimationController {
  final Map<String, AnimatedPawnComponent> _animatedPawns = {};
  
  final double squareSize;
  final double pawnSize;
  final Vector2 Function(int row, int col) getSquareCenter;
  final Vector2 Function(int playerId, int pawnIndex) getHomePawnPosition;

  PawnAnimationController({
    required this.squareSize,
    required this.pawnSize,
    required this.getSquareCenter,
    required this.getHomePawnPosition,
  });

  /// Get or create animated pawn component
  AnimatedPawnComponent getOrCreatePawn(Pawn pawn, Vector2 initialPosition) {
    if (!_animatedPawns.containsKey(pawn.id)) {
      _animatedPawns[pawn.id] = AnimatedPawnComponent(
        pawn: pawn,
        pawnSize: pawnSize,
        position: initialPosition,
      );
    }
    return _animatedPawns[pawn.id]!;
  }

  /// Animate pawn entering the board
  Future<void> animatePawnEnter(Pawn pawn) async {
    final startPos = BoardConfig.startPositions[pawn.playerId]!;
    final targetPos = getSquareCenter(startPos[0], startPos[1]);
    final homePos = getHomePawnPosition(pawn.playerId, pawn.pawnIndex);
    
    final animPawn = getOrCreatePawn(pawn, homePos);
    await animPawn.animateEnter(targetPosition: targetPos);
  }

  /// Animate pawn moving through squares
  Future<void> animatePawnMove(
    Pawn pawn,
    int fromIndex,
    int toIndex,
  ) async {
    final path = BoardConfig.getPlayerPath(pawn.playerId);
    final List<Vector2> positions = [];
    
    // Build path of positions to animate through
    for (int i = fromIndex + 1; i <= toIndex && i < path.length; i++) {
      final pos = path[i];
      positions.add(getSquareCenter(pos[0], pos[1]));
    }
    
    if (positions.isEmpty) return;
    
    final currentPos = getSquareCenter(path[fromIndex][0], path[fromIndex][1]);
    final animPawn = getOrCreatePawn(pawn, currentPos);
    
    await animPawn.animateMove(
      pathPositions: positions,
      stepDuration: const Duration(milliseconds: 150),
    );
  }

  /// Animate pawn being captured
  Future<void> animatePawnKill(Pawn pawn) async {
    final homePos = getHomePawnPosition(pawn.playerId, pawn.pawnIndex);
    
    if (_animatedPawns.containsKey(pawn.id)) {
      await _animatedPawns[pawn.id]!.animateKill(homePosition: homePos);
    }
  }

  /// Set pawn highlight state
  void setHighlighted(String pawnId, bool highlighted) {
    _animatedPawns[pawnId]?.isHighlighted = highlighted;
  }

  /// Clear all highlights
  void clearHighlights() {
    for (final pawn in _animatedPawns.values) {
      pawn.isHighlighted = false;
    }
  }

  /// Remove pawn from animation controller
  void removePawn(String pawnId) {
    _animatedPawns.remove(pawnId);
  }

  /// Clear all pawns
  void clear() {
    _animatedPawns.clear();
  }
}
