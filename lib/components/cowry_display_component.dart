import 'dart:math';
import 'dart:ui' as ui;

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../theme/isto_tokens.dart';

/// Displays 4 cowry shells with authentic design, roll animation, and result.
///
/// Implements the full UIX spec §8 animation phases:
///   Phase 1 — Gather   (0–150ms)   : Shells pull toward center
///   Phase 2 — Shake    (150–650ms) : Cupped-hands shake/vibrate
///   Phase 3 — Scatter  (650–1050ms) : Shells fly out with bounceOut easing
///   Phase 4 — Settle   (1050–1300ms): Tiny rocking ±3° as shells land
///   Phase 5 — Result   (1300ms+)   : Face reveal + count badge
///
/// Idle state: 4 shells in casual arrangement with gentle breathing animation.
/// Tap on this component triggers a roll (replaces the old ROLL button).
class CowryDisplayComponent extends PositionComponent with TapCallbacks {
  CowryRoll? _currentRoll;
  double _animTime = 0;
  double _idleTime = 0;
  bool _notifiedAnimComplete = false;

  // Animation phase enum
  _CowryPhase _phase = _CowryPhase.idle;

  /// Callback when roll animation finishes
  final VoidCallback? onAnimationComplete;

  /// Callback when user taps the cowry zone to roll
  final VoidCallback? onTap;

  // Per-shell random state for organic feel
  final Random _rng = Random();
  final List<_ShellState> _shells = List.generate(4, (i) => _ShellState(i));

  // Pre-computed scatter targets (randomised per throw)
  final List<Offset> _scatterTargets = List.filled(4, Offset.zero);
  final List<double> _scatterAngles = List.filled(4, 0);
  final List<double> _landDelays = [0, 0.06, 0.12, 0.18]; // Stagger

  CowryDisplayComponent({
    required Vector2 position,
    required Vector2 componentSize,
    this.onAnimationComplete,
    this.onTap,
  }) : super(position: position, size: componentSize, anchor: Anchor.center);

  @override
  void onTapUp(TapUpEvent event) {
    onTap?.call();
  }

  void showRoll(CowryRoll roll) {
    _currentRoll = roll;
    _animTime = 0;
    _phase = _CowryPhase.gather;
    _notifiedAnimComplete = false;

    // Pre-compute random scatter destinations with guaranteed non-overlap
    final halfW = size.x * 0.42; // use ~84% of width
    final halfH = size.y * 0.30; // use ~60% of height
    final shellW = (size.x * 0.14).clamp(40.0, 70.0);
    final minDist = shellW * 1.1; // Minimum distance between shell centers
    for (int i = 0; i < 4; i++) {
      Offset candidate;
      int attempts = 0;
      do {
        candidate = Offset(
          -halfW + _rng.nextDouble() * halfW * 2,
          -halfH + _rng.nextDouble() * halfH * 1.5,
        );
        attempts++;
      } while (attempts < 50 && _hasOverlap(candidate, i, minDist));
      _scatterTargets[i] = candidate;
      _scatterAngles[i] = (_rng.nextDouble() - 0.5) * 0.6; // ±0.3 rad
      _shells[i].phase = 0;
      _shells[i].settled = false;
    }

    // Randomise land stagger order
    _landDelays.shuffle(_rng);
  }

  /// Returns true if [candidate] is too close to any already-placed shell.
  bool _hasOverlap(Offset candidate, int currentIndex, double minDist) {
    for (int j = 0; j < currentIndex; j++) {
      if ((candidate - _scatterTargets[j]).distance < minDist) return true;
    }
    return false;
  }

  // Shell idle positions — scaled dynamically in _getIdlePosition()
  static const List<double> _idleXFractions = [-0.25, -0.088, 0.088, 0.25];
  static const List<double> _idleYOffsets = [-2, 3, -3, 2];
  static const List<double> _idleAngles = [-0.12, 0.08, -0.06, 0.15];

  Offset _getIdlePosition(int index) {
    return Offset(size.x * _idleXFractions[index], _idleYOffsets[index]);
  }

  @override
  void update(double dt) {
    super.update(dt);
    _idleTime += dt;

    if (_phase == _CowryPhase.idle) return;

    _animTime += dt;

    switch (_phase) {
      case _CowryPhase.gather:
        if (_animTime > 0.15) {
          _phase = _CowryPhase.shake;
          _animTime = 0;
        }
        break;

      case _CowryPhase.shake:
        if (_animTime > 0.50) {
          _phase = _CowryPhase.scatter;
          _animTime = 0;
        }
        break;

      case _CowryPhase.scatter:
        if (_animTime > 0.40) {
          _phase = _CowryPhase.settle;
          _animTime = 0;
        }
        break;

      case _CowryPhase.settle:
        if (_animTime > 0.25) {
          _phase = _CowryPhase.result;
          _animTime = 0;
          // Fire animation complete callback
          if (!_notifiedAnimComplete) {
            _notifiedAnimComplete = true;
            onAnimationComplete?.call();
          }
        }
        break;

      case _CowryPhase.result:
        // Result display persists
        break;

      case _CowryPhase.idle:
        break;
    }
  }

  @override
  void render(Canvas canvas) {
    super.render(canvas);

    // CRITICAL: Flame's canvas origin is at TOP-LEFT of component.
    // All our drawing code uses Offset.zero as center.
    // Translate canvas so (0,0) = component center.
    canvas.save();
    canvas.translate(size.x / 2, size.y / 2);

    // Draw throw zone background — spec §8: bg-elevated fill, rounded 20dp
    _drawThrowZone(canvas);

    if (_currentRoll == null && _phase == _CowryPhase.idle) {
      // Draw idle shells with breathing animation
      _drawIdleShells(canvas);
      canvas.restore();
      return;
    }

    // Scale shell size proportionally to component
    final shellW = (size.x * 0.14).clamp(40.0, 70.0);
    final shellH = shellW * 0.625;

    // Draw shadows first (under all shells)
    for (int i = 0; i < 4; i++) {
      final pos = _getShellPosition(i, shellW, shellH);
      final shellScale = _getShellScale(i);
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(pos.dx, pos.dy + shellH * 0.6),
          width: shellW * 0.6 * shellScale,
          height: 5 * shellScale,
        ),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.2 * shellScale)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3),
      );
    }

    // Draw shells
    for (int i = 0; i < 4; i++) {
      _drawAnimatedShell(canvas, i, shellW, shellH);
    }

    // Special roll glow effect (ISTO/Chom)
    if (_phase == _CowryPhase.result && _currentRoll != null) {
      if (_currentRoll!.grantsExtraTurn && _animTime < 0.6) {
        final glowAlpha = (1.0 - _animTime / 0.6) * 0.25;
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: size.x * 0.7,
            height: size.y * 0.65,
          ),
          Paint()
            ..color = IstoColorsDark.accentGlow.withValues(alpha: glowAlpha)
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 20),
        );
      }
    }

    // Result text
    if (_phase == _CowryPhase.result &&
        _currentRoll != null &&
        _animTime < 4.0) {
      _drawResultText(canvas);
    }

    canvas.restore();
  }

  void _drawThrowZone(Canvas canvas) {
    final zoneRect = Rect.fromCenter(
      center: Offset.zero,
      width: size.x - 10,
      height: size.y - 10,
    );
    final rrect = RRect.fromRectAndRadius(zoneRect, const Radius.circular(20));

    // Background
    canvas.drawRRect(
      rrect,
      Paint()..color = IstoColorsDark.bgElevated.withValues(alpha: 0.5),
    );

    // Inset shadow for depth
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.15)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5,
    );

    // "TAP TO THROW" label above zone — spec §8: Poppins 10sp, letter-spacing 2.0
    // Visible only during idle, hidden during animation
    if (_phase == _CowryPhase.idle || _phase == _CowryPhase.result) {
      final showLabel =
          _phase == _CowryPhase.idle ||
          (_phase == _CowryPhase.result && _animTime > 3.0);
      if (showLabel) {
        final labelAlpha =
            _phase == _CowryPhase.result
                ? ((_animTime - 3.0) * 2.0).clamp(0.0, 0.5)
                : 0.5;
        final labelPainter = TextPainter(
          text: TextSpan(
            text: 'TAP TO THROW',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: IstoColorsDark.textMuted.withValues(alpha: labelAlpha),
              letterSpacing: 2.0,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        labelPainter.layout();
        labelPainter.paint(canvas, Offset(-labelPainter.width / 2, -48));
      }
    }
  }

  void _drawIdleShells(Canvas canvas) {
    // Scale idle shell size proportionally
    final shellW = (size.x * 0.13).clamp(36.0, 60.0);
    final shellH = shellW * 0.636;

    // Breathing animation — spec §8: scale 1.0→1.02→1.0 over 2s
    final breathe = 1.0 + sin(_idleTime * pi) * 0.02;

    canvas.save();
    canvas.scale(breathe, breathe);

    for (int i = 0; i < 4; i++) {
      final pos = _getIdlePosition(i);
      final angle = _idleAngles[i] + sin(_idleTime * 0.5 + i) * 0.03;

      // Shadow
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(pos.dx, pos.dy + shellH * 0.5),
          width: shellW * 0.6,
          height: 5,
        ),
        Paint()
          ..color = Colors.black.withValues(alpha: 0.18)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
      );

      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(angle);
      // Idle shells show alternating up/down for visual variety
      _drawShellBody(
        canvas,
        -shellW / 2,
        -shellH / 2,
        shellW,
        shellH,
        i.isEven,
      );
      canvas.restore();
    }

    canvas.restore();
  }

  Offset _getShellPosition(int index, double shellW, double shellH) {
    switch (_phase) {
      case _CowryPhase.gather:
        // Animate from idle positions toward center
        final t = (_animTime / 0.15).clamp(0.0, 1.0);
        final easeT = _easeIn(t);
        final from = _getIdlePosition(index);
        return Offset.lerp(from, Offset.zero, easeT)!;

      case _CowryPhase.shake:
        // Vibrate around center — rapid random jitter
        final jitterX = sin(_animTime * 80 + index * 2.5) * 4;
        final jitterY = cos(_animTime * 60 + index * 3.2) * 4;
        return Offset(jitterX, jitterY);

      case _CowryPhase.scatter:
        // Fly out to random positions with bounceOut
        final rawT = (_animTime / 0.40 - _landDelays[index]).clamp(0.0, 1.0);
        final t = _bounceOut(rawT);
        return Offset.lerp(Offset.zero, _scatterTargets[index], t)!;

      case _CowryPhase.settle:
        // Stay at scatter target with tiny rocking
        final rockPhase = _animTime * 30 + index * 2;
        final rockAmount = (1.0 - (_animTime / 0.25).clamp(0.0, 1.0)) * 2;
        return _scatterTargets[index] +
            Offset(
              sin(rockPhase) * rockAmount,
              cos(rockPhase) * rockAmount * 0.5,
            );

      case _CowryPhase.result:
      case _CowryPhase.idle:
        return _scatterTargets[index];
    }
  }

  double _getShellScale(int index) {
    switch (_phase) {
      case _CowryPhase.gather:
        final t = (_animTime / 0.15).clamp(0.0, 1.0);
        return 1.0 - t * 0.3; // Scale down to 0.7x
      case _CowryPhase.shake:
        return 0.7;
      case _CowryPhase.scatter:
        final rawT = (_animTime / 0.40 - _landDelays[index]).clamp(0.0, 1.0);
        return 0.7 + rawT * 0.3; // Scale back to 1.0
      case _CowryPhase.settle:
      case _CowryPhase.result:
      case _CowryPhase.idle:
        return 1.0;
    }
  }

  double _getShellRotation(int index) {
    switch (_phase) {
      case _CowryPhase.gather:
        final t = (_animTime / 0.15).clamp(0.0, 1.0);
        return _idleAngles[index] * (1.0 - t);
      case _CowryPhase.shake:
        return sin(_animTime * 40 + index * 1.7) * 0.15;
      case _CowryPhase.scatter:
        final rawT = (_animTime / 0.40 - _landDelays[index]).clamp(0.0, 1.0);
        return _scatterAngles[index] * rawT;
      case _CowryPhase.settle:
        // Rocking settle ±3° → 0
        final decay = 1.0 - (_animTime / 0.25).clamp(0.0, 1.0);
        return sin(_animTime * 30 + index * 2) * 0.05 * decay +
            _scatterAngles[index];
      case _CowryPhase.result:
      case _CowryPhase.idle:
        return _scatterAngles[index];
    }
  }

  void _drawAnimatedShell(
    Canvas canvas,
    int index,
    double shellW,
    double shellH,
  ) {
    final pos = _getShellPosition(index, shellW, shellH);
    final scale = _getShellScale(index);
    final rotation = _getShellRotation(index);

    canvas.save();
    canvas.translate(pos.dx, pos.dy);
    canvas.rotate(rotation);
    canvas.scale(scale, scale);

    // During gather/shake, show random flipping
    if (_phase == _CowryPhase.gather || _phase == _CowryPhase.shake) {
      final flipAngle = _animTime * (10 + index * 2.5) + index * 0.7;
      final flipProgress = sin(flipAngle);
      final scaleY = flipProgress.abs().clamp(0.3, 1.0);
      canvas.scale(1, scaleY);
      final showUp = flipProgress > 0;
      _drawShellBody(canvas, -shellW / 2, -shellH / 2, shellW, shellH, showUp);
    } else {
      // After scatter, show actual result face
      final isUp = _currentRoll?.cowries[index] ?? true;
      _drawShellBody(canvas, -shellW / 2, -shellH / 2, shellW, shellH, isUp);

      // Golden outline for special rolls (ISTO/Chom) per spec §8
      if (_phase == _CowryPhase.result &&
          _currentRoll != null &&
          _currentRoll!.grantsExtraTurn &&
          _animTime < 0.6) {
        final outlineAlpha = (1.0 - _animTime / 0.6) * 0.6;
        final outlinePath = _makeShellPath(
          -shellW / 2,
          -shellH / 2,
          shellW,
          shellH,
        );
        canvas.drawPath(
          outlinePath,
          Paint()
            ..color = IstoColorsDark.accentGlow.withValues(alpha: outlineAlpha)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0,
        );
      }
    }

    canvas.restore();
  }

  Path _makeShellPath(double x, double y, double w, double h) {
    final cx = x + w / 2;
    final cy = y + h / 2;
    final path = Path();
    // Elongated cowry shape — tapered tips, convex curves
    path.moveTo(x + w * 0.03, cy);
    path.cubicTo(x + w * 0.08, y + h * 0.06, x + w * 0.30, y - h * 0.02, cx, y);
    path.cubicTo(
      x + w * 0.70,
      y - h * 0.02,
      x + w * 0.92,
      y + h * 0.06,
      x + w * 0.97,
      cy,
    );
    path.cubicTo(
      x + w * 0.92,
      y + h * 0.94,
      x + w * 0.70,
      y + h * 1.02,
      cx,
      y + h,
    );
    path.cubicTo(
      x + w * 0.30,
      y + h * 1.02,
      x + w * 0.08,
      y + h * 0.94,
      x + w * 0.03,
      cy,
    );
    path.close();
    return path;
  }

  void _drawShellBody(
    Canvas canvas,
    double x,
    double y,
    double w,
    double h,
    bool isUp,
  ) {
    final cx = x + w / 2;
    final cy = y + h / 2;
    final shellPath = _makeShellPath(x, y, w, h);

    // Soft drop shadow
    canvas.drawPath(
      shellPath.shift(const Offset(1.5, 3.5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );

    if (isUp) {
      // ========== MOUTH UP — Ivory/cream shell §8 ==========
      // Base fill — warm ivory gradient
      final gradient = ui.Gradient.linear(
        Offset(x, y),
        Offset(x + w * 0.25, y + h),
        [
          const Color(0xFFFFFBF0), // Warm white
          const Color(0xFFF5ECD6), // Ivory
          const Color(0xFFEADFC2), // Cream/tan at bottom
        ],
        [0.0, 0.45, 1.0],
      );
      canvas.drawPath(shellPath, Paint()..shader = gradient);

      // Pearly luster sheen — radial highlight
      final sheen = ui.Gradient.radial(
        Offset(x + w * 0.38, y + h * 0.25),
        w * 0.35,
        [
          Colors.white.withValues(alpha: 0.55),
          Colors.white.withValues(alpha: 0.0),
        ],
      );
      canvas.drawPath(shellPath, Paint()..shader = sheen);

      // Secondary specular highlight (smaller, sharper)
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + w * 0.32, y + h * 0.22),
          width: w * 0.18,
          height: h * 0.12,
        ),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );

      // Central slit / lip opening — prominent, runs most of width
      final slitPath =
          Path()
            ..moveTo(x + w * 0.15, y + h * 0.48)
            ..cubicTo(
              x + w * 0.30,
              y + h * 0.62,
              x + w * 0.70,
              y + h * 0.62,
              x + w * 0.85,
              y + h * 0.48,
            );
      canvas.drawPath(
        slitPath,
        Paint()
          ..color = const Color(0xFF8A6840)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );

      // Inner slit depth shadow
      final innerSlitPath =
          Path()
            ..moveTo(x + w * 0.20, y + h * 0.50)
            ..cubicTo(
              x + w * 0.33,
              y + h * 0.59,
              x + w * 0.67,
              y + h * 0.59,
              x + w * 0.80,
              y + h * 0.50,
            );
      canvas.drawPath(
        innerSlitPath,
        Paint()
          ..color = const Color(0xFF6B4E2C).withValues(alpha: 0.6)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..strokeCap = StrokeCap.round,
      );

      // Teeth-like ridges along slit opening
      for (int i = 0; i < 9; i++) {
        final t = 0.20 + (i * 0.075);
        final tx = x + w * t;
        // Top teeth (above slit)
        canvas.drawLine(
          Offset(tx, y + h * 0.44),
          Offset(tx, y + h * 0.50),
          Paint()
            ..color = const Color(0xFFCBB08A).withValues(alpha: 0.5)
            ..strokeWidth = 0.7,
        );
        // Bottom teeth (below slit)
        canvas.drawLine(
          Offset(tx, y + h * 0.54),
          Offset(tx, y + h * 0.60),
          Paint()
            ..color = const Color(0xFFC0A070).withValues(alpha: 0.35)
            ..strokeWidth = 0.7,
        );
      }

      // Subtle lateral banding (growth lines)
      for (int i = 0; i < 3; i++) {
        final bandY = y + h * (0.20 + i * 0.08);
        final bandPath =
            Path()
              ..moveTo(x + w * 0.18, bandY)
              ..cubicTo(
                x + w * 0.35,
                bandY - h * 0.02,
                x + w * 0.65,
                bandY - h * 0.02,
                x + w * 0.82,
                bandY,
              );
        canvas.drawPath(
          bandPath,
          Paint()
            ..color = const Color(0xFFD0BFA0).withValues(alpha: 0.18)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5,
        );
      }

      // Rim edge highlight (top lip of shell)
      final rimPath =
          Path()
            ..moveTo(x + w * 0.10, cy)
            ..cubicTo(
              x + w * 0.20,
              y + h * 0.10,
              x + w * 0.40,
              y + h * 0.02,
              cx,
              y + h * 0.02,
            )
            ..cubicTo(
              x + w * 0.60,
              y + h * 0.02,
              x + w * 0.80,
              y + h * 0.10,
              x + w * 0.90,
              cy,
            );
      canvas.drawPath(
        rimPath,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.20)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8,
      );
    } else {
      // ========== MOUTH DOWN — Brown dome back §8 ==========
      // Rich brown gradient with warm tones
      final gradient = ui.Gradient.linear(
        Offset(x, y),
        Offset(x + w * 0.25, y + h),
        [
          const Color(0xFFB89468), // Light golden-brown
          const Color(0xFF9A7850), // Medium brown
          const Color(0xFF725838), // Dark brown
        ],
        [0.0, 0.45, 1.0],
      );
      canvas.drawPath(shellPath, Paint()..shader = gradient);

      // Glossy dome highlight — strong specular
      final highlight = ui.Gradient.radial(
        Offset(x + w * 0.40, y + h * 0.22),
        w * 0.30,
        [
          Colors.white.withValues(alpha: 0.32),
          Colors.white.withValues(alpha: 0.0),
        ],
      );
      canvas.drawPath(shellPath, Paint()..shader = highlight);

      // Secondary warm highlight
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(x + w * 0.35, y + h * 0.20),
          width: w * 0.15,
          height: h * 0.10,
        ),
        Paint()
          ..color = const Color(0xFFDFC090).withValues(alpha: 0.25)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );

      // Dorsal spine/ridge — prominent line running the full length
      final ridgePath =
          Path()
            ..moveTo(x + w * 0.08, cy + h * 0.02)
            ..cubicTo(
              x + w * 0.30,
              cy - h * 0.06,
              x + w * 0.70,
              cy - h * 0.06,
              x + w * 0.92,
              cy + h * 0.02,
            );
      canvas.drawPath(
        ridgePath,
        Paint()
          ..color = const Color(0xFF5A4028)
          ..strokeWidth = 1.8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
      // Ridge highlight (above the ridge)
      final ridgeHighlight =
          Path()
            ..moveTo(x + w * 0.12, cy - h * 0.02)
            ..cubicTo(
              x + w * 0.33,
              cy - h * 0.10,
              x + w * 0.67,
              cy - h * 0.10,
              x + w * 0.88,
              cy - h * 0.02,
            );
      canvas.drawPath(
        ridgeHighlight,
        Paint()
          ..color = const Color(0xFFCCA870).withValues(alpha: 0.20)
          ..strokeWidth = 0.8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );

      // Concentric growth rings
      for (int i = 0; i < 4; i++) {
        final ringW = w * (0.25 + i * 0.14);
        final ringH = h * (0.22 + i * 0.10);
        final arcPath =
            Path()..addArc(
              Rect.fromCenter(
                center: Offset(cx, cy - h * 0.04),
                width: ringW,
                height: ringH,
              ),
              -0.9 + i * 0.15,
              1.8 - i * 0.15,
            );
        canvas.drawPath(
          arcPath,
          Paint()
            ..color = const Color(0xFF5A4028).withValues(alpha: 0.15 + i * 0.03)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 0.5,
        );
      }

      // Subtle texture mottling
      final rng = Random(42);
      for (int i = 0; i < 5; i++) {
        final sx = x + w * (0.20 + rng.nextDouble() * 0.60);
        final sy = y + h * (0.15 + rng.nextDouble() * 0.70);
        final sr = 0.8 + rng.nextDouble() * 1.0;
        canvas.drawCircle(
          Offset(sx, sy),
          sr,
          Paint()..color = const Color(0xFF4A3520).withValues(alpha: 0.25),
        );
      }

      // Bottom edge shadow (subtle 3D depth)
      final bottomShadow =
          Path()
            ..moveTo(x + w * 0.15, y + h * 0.85)
            ..cubicTo(
              x + w * 0.35,
              y + h * 0.95,
              x + w * 0.65,
              y + h * 0.95,
              x + w * 0.85,
              y + h * 0.85,
            );
      canvas.drawPath(
        bottomShadow,
        Paint()
          ..color = const Color(0xFF3A2818).withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.2
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5),
      );
    }

    // Shell border — refined thin line
    canvas.drawPath(
      shellPath,
      Paint()
        ..color = isUp ? const Color(0xFFC0B090) : const Color(0xFF5A4830)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.7,
    );
  }

  void _drawResultText(Canvas canvas) {
    if (_currentRoll == null) return;

    final roll = _currentRoll!;
    final text = roll.displayName;
    final isSpecial = roll.grantsExtraTurn;

    // Pop-in scale: 0.5→1.2→1.0 over 300ms per spec §8
    final t = (_animTime * 3.3).clamp(0.0, 1.0);
    double scale;
    if (t < 0.6) {
      scale = 0.5 + t * 1.167; // 0.5 → 1.2
    } else {
      scale = 1.2 - (t - 0.6) * 0.5; // 1.2 → 1.0
    }
    final alpha = t.clamp(0.0, 1.0);

    canvas.save();
    canvas.translate(0, 44);
    canvas.scale(scale, scale);

    final color =
        isSpecial
            ? Color.fromARGB(
              (255 * alpha).toInt(),
              255,
              217,
              138,
            ) // accent-glow
            : Color.fromARGB((255 * alpha * 0.85).toInt(), 245, 230, 200);

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: isSpecial ? 22 : 16,
          fontWeight: FontWeight.w800,
          color: color,
          letterSpacing: isSpecial ? 4 : 1.5,
          shadows:
              isSpecial
                  ? [
                    Shadow(color: const Color(0x80FFD98A), blurRadius: 12),
                    Shadow(color: const Color(0x40FFD98A), blurRadius: 24),
                  ]
                  : null,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(-textPainter.width / 2, 0));

    // "BONUS TURN" subtitle for special rolls — slides up per spec §8
    if (isSpecial && _animTime > 0.3) {
      final subT = ((_animTime - 0.3) * 3).clamp(0.0, 1.0);
      final slideUp = 8 * (1.0 - subT);
      final subAlpha = subT * 0.8;
      final subtitle =
          roll.isAshta ? 'BONUS TURN — 8 Steps!' : 'BONUS TURN — 4 Steps!';
      final subPainter = TextPainter(
        text: TextSpan(
          text: subtitle,
          style: TextStyle(
            fontFamily: 'Poppins',
            fontSize: 10,
            fontWeight: FontWeight.w600,
            color: IstoColorsDark.accentPrimary.withValues(alpha: subAlpha),
            letterSpacing: 1.5,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      subPainter.layout();
      subPainter.paint(canvas, Offset(-subPainter.width / 2, 26 + slideUp));
    }

    canvas.restore();
  }

  // ========== EASING FUNCTIONS ==========

  double _easeIn(double t) => t * t;

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

/// Internal per-shell animation state
class _ShellState {
  final int index;
  double phase = 0;
  bool settled = false;

  _ShellState(this.index);
}

/// Animation phases for the cowry throw
enum _CowryPhase { idle, gather, shake, scatter, settle, result }
