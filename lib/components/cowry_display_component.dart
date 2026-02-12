import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';

/// Displays 4 cowry shells with authentic design, roll animation, and result
/// 
/// Cowry shells are the traditional dice used in ISTO (Chowka Bhara).
/// - Mouth-up (flat side up): Ivory shell with natural opening/slit
/// - Mouth-down (dome side up): Brown textured shell with ridge line & spots
class CowryDisplayComponent extends PositionComponent {
  CowryRoll? _currentRoll;
  double _rollAnimTime = 0;
  bool _isRolling = false;
  bool _showResult = false;
  double _resultShowTime = 0;
  bool _notifiedAnimComplete = false;

  /// Callback when roll animation finishes
  final VoidCallback? onAnimationComplete;

  // Shell animation states (random per shell for organic feel)
  final List<double> _shellPhases = List.generate(4, (i) => i * 0.7 + Random().nextDouble() * 0.5);
  final List<double> _shellBounce = List.generate(4, (_) => 0.0);

  CowryDisplayComponent({
    required Vector2 position,
    this.onAnimationComplete,
  }) : super(
          position: position,
          size: Vector2(220, 60),
          anchor: Anchor.center,
        );

  void showRoll(CowryRoll roll) {
    _currentRoll = roll;
    _isRolling = true;
    _showResult = false;
    _rollAnimTime = 0;
    _resultShowTime = 0;
    _notifiedAnimComplete = false;
    // Randomize phases for each new roll
    for (int i = 0; i < 4; i++) {
      _shellPhases[i] = i * 0.6 + Random().nextDouble() * 0.8;
      _shellBounce[i] = 0.0;
    }
  }

  @override
  void update(double dt) {
    super.update(dt);

    if (_isRolling) {
      _rollAnimTime += dt;

      // Roll animation duration: 0.9 seconds with staggered settle
      if (_rollAnimTime > 0.9) {
        _isRolling = false;
        _showResult = true;
        _resultShowTime = 0;

        // Fire animation complete callback
        if (!_notifiedAnimComplete) {
          _notifiedAnimComplete = true;
          onAnimationComplete?.call();
        }
      }
    }

    if (_showResult) {
      _resultShowTime += dt;
      // Update bounce-in for each shell
      for (int i = 0; i < 4; i++) {
        _shellBounce[i] = ((_resultShowTime * 5 - i * 0.18).clamp(0.0, 1.0));
      }
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    if (_currentRoll == null && !_isRolling) return;

    final shellWidth = 40.0;
    final shellHeight = 26.0;
    final spacing = 14.0;
    final totalWidth = 4 * shellWidth + 3 * spacing;
    final startX = -totalWidth / 2;

    // Subtle ground shadow under shells
    for (int i = 0; i < 4; i++) {
      final x = startX + i * (shellWidth + spacing);
      canvas.drawOval(
        Rect.fromCenter(center: Offset(x + shellWidth / 2, 16), width: shellWidth * 0.7, height: 6),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.2)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }

    for (int i = 0; i < 4; i++) {
      final x = startX + i * (shellWidth + spacing);
      final y = 0.0;

      if (_isRolling) {
        _drawRollingShell(canvas, x, y, shellWidth, shellHeight, i);
      } else if (_currentRoll != null) {
        final isUp = _currentRoll!.cowries[i];
        _drawShell(canvas, x, y, shellWidth, shellHeight, isUp, i);
      }
    }

    // Show result text below shells
    if (_showResult && _currentRoll != null && _resultShowTime < 4.0) {
      _drawResultText(canvas);
    }
  }

  void _drawRollingShell(
      Canvas canvas, double x, double y, double w, double h, int index) {
    // Chaotic tumbling during roll
    final angle = _rollAnimTime * (10 + index * 2.5) + _shellPhases[index];
    final flipProgress = sin(angle);
    
    // Vertical bounce during tumbling
    final bounceY = sin(_rollAnimTime * (6 + index) + _shellPhases[index]) * 8;
    // Horizontal wobble
    final wobbleX = sin(_rollAnimTime * (4 + index) + index) * 3;
    // Rotation
    final rotation = sin(_rollAnimTime * (5 + index * 1.3)) * 0.2;

    canvas.save();
    canvas.translate(x + w / 2 + wobbleX, y + bounceY);
    canvas.rotate(rotation);

    // Scale Y for 3D flip effect
    final scaleY = flipProgress.abs().clamp(0.3, 1.0);
    canvas.scale(1, scaleY);

    // During rolling show random up/down
    final showUp = flipProgress > 0;
    _drawShellBody(canvas, -w / 2, -h / 2, w, h, showUp);

    canvas.restore();
  }

  void _drawShell(Canvas canvas, double x, double y, double w, double h,
      bool isUp, int index) {
    // Bounce-in entrance animation
    final t = _shellBounce[index];
    final bounce = _bounceOut(t);

    canvas.save();
    canvas.translate(x + w / 2, y);
    canvas.scale(bounce.clamp(0.01, 1.2), bounce.clamp(0.01, 1.2));

    _drawShellBody(canvas, -w / 2, -h / 2, w, h, isUp);

    canvas.restore();
  }

  void _drawShellBody(
      Canvas canvas, double x, double y, double w, double h, bool isUp) {
    // Authentic cowry shell shape — more oval/elongated than rounded rect
    final shellPath = Path();
    final cx = x + w / 2;
    final cy = y + h / 2;
    
    // Create elongated oval shape with pointed ends
    shellPath.moveTo(x + w * 0.12, cy);
    shellPath.cubicTo(x + w * 0.12, y + h * 0.15, x + w * 0.35, y, cx, y);
    shellPath.cubicTo(x + w * 0.65, y, x + w * 0.88, y + h * 0.15, x + w * 0.88, cy);
    shellPath.cubicTo(x + w * 0.88, y + h * 0.85, x + w * 0.65, y + h, cx, y + h);
    shellPath.cubicTo(x + w * 0.35, y + h, x + w * 0.12, y + h * 0.85, x + w * 0.12, cy);
    shellPath.close();

    // Drop shadow
    canvas.drawPath(
      shellPath.shift(const Offset(1, 3)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
    );

    if (isUp) {
      // ========== MOUTH UP — Ivory/cream shell with natural opening ==========
      
      // Base gradient: warm ivory → cream
      final gradient = ui.Gradient.linear(
        Offset(x, y),
        Offset(x + w * 0.3, y + h),
        [
          const Color(0xFFFAF3E0),  // Light ivory
          const Color(0xFFF0E6CE),  // Warm cream
          const Color(0xFFE8DCBF),  // Sandy cream
        ],
        [0.0, 0.5, 1.0],
      );
      canvas.drawPath(shellPath, Paint()..shader = gradient);

      // Natural highlight on top-left
      final highlightGrad = ui.Gradient.radial(
        Offset(x + w * 0.35, y + h * 0.3),
        w * 0.3,
        [
          Colors.white.withValues(alpha: 0.4),
          Colors.white.withValues(alpha: 0.0),
        ],
      );
      canvas.drawPath(shellPath, Paint()..shader = highlightGrad);

      // The central slit/opening — the defining feature of mouth-up cowry
      final slitPath = Path()
        ..moveTo(x + w * 0.25, y + h * 0.42)
        ..cubicTo(
          x + w * 0.35, y + h * 0.58,
          x + w * 0.65, y + h * 0.58,
          x + w * 0.75, y + h * 0.42,
        );
      canvas.drawPath(
        slitPath,
        Paint()
          ..color = const Color(0xFFA08050)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.0
          ..strokeCap = StrokeCap.round,
      );
      // Inner slit shadow for depth
      final innerSlitPath = Path()
        ..moveTo(x + w * 0.30, y + h * 0.45)
        ..cubicTo(
          x + w * 0.38, y + h * 0.55,
          x + w * 0.62, y + h * 0.55,
          x + w * 0.70, y + h * 0.45,
        );
      canvas.drawPath(
        innerSlitPath,
        Paint()
          ..color = const Color(0xFF806040).withValues(alpha: 0.5)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.0
          ..strokeCap = StrokeCap.round,
      );

      // Subtle teeth-like ridges along the slit
      for (int i = 0; i < 6; i++) {
        final t = 0.30 + (i * 0.08);
        final tx = x + w * t;
        final ty1 = y + h * (0.43 + sin(i * 0.8) * 0.02);
        final ty2 = ty1 + h * 0.06;
        canvas.drawLine(
          Offset(tx, ty1),
          Offset(tx, ty2),
          Paint()
            ..color = const Color(0xFFC0A070).withValues(alpha: 0.4)
            ..strokeWidth = 0.8,
        );
      }
    } else {
      // ========== MOUTH DOWN — Brown textured dome back ==========
      
      // Base gradient: warm brown tones
      final gradient = ui.Gradient.linear(
        Offset(x, y),
        Offset(x + w * 0.3, y + h),
        [
          const Color(0xFFA08060),  // Light brown
          const Color(0xFF8A6C4A),  // Medium brown
          const Color(0xFF6A5030),  // Dark brown
        ],
        [0.0, 0.5, 1.0],
      );
      canvas.drawPath(shellPath, Paint()..shader = gradient);

      // Natural highlight on top
      final highlightGrad = ui.Gradient.radial(
        Offset(x + w * 0.4, y + h * 0.25),
        w * 0.25,
        [
          Colors.white.withValues(alpha: 0.18),
          Colors.white.withValues(alpha: 0.0),
        ],
      );
      canvas.drawPath(shellPath, Paint()..shader = highlightGrad);

      // Central ridge line (spine of the shell)
      final ridgePath = Path()
        ..moveTo(x + w * 0.18, cy)
        ..cubicTo(
          x + w * 0.35, cy - 1,
          x + w * 0.65, cy - 1,
          x + w * 0.82, cy,
        );
      canvas.drawPath(
        ridgePath,
        Paint()
          ..color = const Color(0xFF5A4028)
          ..strokeWidth = 1.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );

      // Natural texture spots on back
      final spotPaint = Paint()..color = const Color(0xFF4A3520).withValues(alpha: 0.5);
      final rng = Random(42); // fixed seed for consistent look
      for (int i = 0; i < 5; i++) {
        final sx = x + w * (0.25 + rng.nextDouble() * 0.5);
        final sy = y + h * (0.25 + rng.nextDouble() * 0.5);
        final sr = 1.5 + rng.nextDouble() * 1.0;
        canvas.drawCircle(Offset(sx, sy), sr, spotPaint);
      }
      
      // Growth rings (subtle arcs)
      for (int i = 0; i < 2; i++) {
        final arcPath = Path()
          ..addArc(
            Rect.fromCenter(
              center: Offset(cx, cy),
              width: w * (0.45 + i * 0.18),
              height: h * (0.35 + i * 0.15),
            ),
            -0.8 + i * 0.3,
            1.6 - i * 0.3,
          );
        canvas.drawPath(
          arcPath,
          Paint()
            ..color = const Color(0xFF5A4028).withValues(alpha: 0.25)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.7,
        );
      }
    }

    // Shell border — thin and elegant
    canvas.drawPath(
      shellPath,
      Paint()
        ..color = isUp ? const Color(0xFFB8A88C) : const Color(0xFF5A4830)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  void _drawResultText(Canvas canvas) {
    if (_currentRoll == null) return;

    final roll = _currentRoll!;
    final text = roll.displayName;
    final isSpecial = roll.grantsExtraTurn;

    final entrance = (_resultShowTime * 3).clamp(0.0, 1.0);
    final alpha = entrance;
    final scale = 0.5 + entrance * 0.5;

    canvas.save();
    canvas.translate(0, 36);
    canvas.scale(scale, scale);

    final color = isSpecial
        ? Color.fromARGB(
            (255 * alpha).toInt(), 242, 201, 76) // Antique gold for special
        : Color.fromARGB(
            (255 * alpha * 0.85).toInt(), 240, 230, 210); // Parchment for normal

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontSize: isSpecial ? 20 : 15,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: isSpecial ? 4 : 1.5,
          shadows: isSpecial
              ? [
                  Shadow(
                    color: const Color(0x80F2C94C),
                    blurRadius: 10,
                  ),
                  Shadow(
                    color: const Color(0x40F2C94C),
                    blurRadius: 20,
                  ),
                ]
              : null,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));

    // Subtitle for special rolls
    if (isSpecial && _resultShowTime > 0.3) {
      final subAlpha = ((_resultShowTime - 0.3) * 3).clamp(0.0, 0.7);
      final subtitle = roll.isAshta ? '8 Steps + Extra Turn!' : '4 Steps + Extra Turn!';
      final subPainter = TextPainter(
        text: TextSpan(
          text: subtitle,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w500,
            color: Color.fromARGB((255 * subAlpha).toInt(), 196, 174, 146),
            letterSpacing: 1,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      subPainter.layout();
      subPainter.paint(canvas, Offset(-subPainter.width / 2, 24));
    }

    canvas.restore();
  }

  double _bounceOut(double t) {
    if (t < 1 / 2.75) {
      return 7.5625 * t * t;
    } else if (t < 2 / 2.75) {
      t -= 1.5 / 2.75;
      return 7.5625 * t * t + 0.75;
    } else if (t < 2.5 / 2.75) {
      t -= 2.25 / 2.75;
      return 7.5625 * t * t + 0.9375;
    } else {
      t -= 2.625 / 2.75;
      return 7.5625 * t * t + 0.984375;
    }
  }
}
