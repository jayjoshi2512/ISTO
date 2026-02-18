import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/isto_tokens.dart';

/// Splash screen — "The Cloth Mat Unrolls"
///
/// Enhanced sequence:
/// 0ms:   Faint grid fades in
/// 400ms: Center cell golden bloom radiates
/// 600ms: Grid lines draw from center outward
/// 900ms: Safe squares pulse with player color hints
/// 1800ms: "ISTO" title fades in + slide up
/// 2200ms: "Chowka Bara" subtitle
/// 2600ms: Tagline appears letter-by-letter
/// 3200ms: 4 cowry shells scatter from center with tumble + bounce
/// 3800ms: Golden particle burst from center
/// 4500ms: Floating golden dust sparkles
/// 5500ms: Hold
/// 6500ms: Fade out
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _masterCtrl;
  late AnimationController _exitCtrl;
  late AnimationController _sparkleCtrl;

  // Phase animations derived from master timeline
  late Animation<double> _gridPatternOpacity;
  late Animation<double> _centerBloom;
  late Animation<double> _gridLinesDraw;
  late Animation<double> _safeSquarePulse;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _taglineProgress; // 0→1 for letter-by-letter
  late Animation<double> _cowryScatterProgress; // 0→1 for 4 shells scatter
  late Animation<double> _particleBurst; // 0→1 for golden particles
  late Animation<double> _dustFloat; // 0→1 for floating sparkles

  // Pre-computed random data for 4 scattered cowries
  final _rng = Random(42);
  late final List<_CowryScatterData> _cowryData;
  // Pre-computed sparkle positions (golden dust)
  late final List<_SparkleData> _sparkles;

  @override
  void initState() {
    super.initState();

    // Generate scatter data for 4 cowry shells
    _cowryData = List.generate(4, (i) {
      final angle = (i * pi / 2) + _rng.nextDouble() * 0.5 - 0.25;
      final dist = 30.0 + _rng.nextDouble() * 50.0;
      return _CowryScatterData(
        targetX: cos(angle) * dist,
        targetY: sin(angle) * dist - 10,
        rotation: (_rng.nextDouble() - 0.5) * 1.2,
        delay: i * 0.08,
        isUp: i < 2, // 2 up, 2 down
      );
    });

    // Golden sparkle particles
    _sparkles = List.generate(20, (i) {
      return _SparkleData(
        startX: (_rng.nextDouble() - 0.5) * 200,
        startY: (_rng.nextDouble() - 0.5) * 300,
        drift: (_rng.nextDouble() - 0.5) * 40,
        speed: 0.3 + _rng.nextDouble() * 0.7,
        size: 1.5 + _rng.nextDouble() * 2.5,
        phaseOffset: _rng.nextDouble() * 2 * pi,
      );
    });

    // Master timeline: 0 → 6500ms
    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6500),
    );

    // Exit fade: 500ms
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // Continuous sparkle loop
    _sparkleCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();

    // Phase 1: Grid pattern fades in immediately
    _gridPatternOpacity = Tween<double>(begin: 0, end: 0.06).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.0, 0.09, curve: Curves.easeOut),
      ),
    );

    // Phase 2: Center bloom (0.09–0.18)
    _centerBloom = Tween<double>(begin: 0, end: 40).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.09, 0.18, curve: Curves.easeOut),
      ),
    );

    // Phase 3: Grid lines draw (0.14–0.27)
    _gridLinesDraw = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.14, 0.27, curve: Curves.decelerate),
      ),
    );

    // Phase 4: Safe square pulse (0.27–0.36)
    _safeSquarePulse = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.27, 0.36, curve: Curves.easeOut),
      ),
    );

    // Phase 5: Title (0.28–0.42)
    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.28, 0.42, curve: Curves.easeOutCubic),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.28, 0.42, curve: Curves.easeOutCubic),
      ),
    );

    // Phase 6: Subtitle (0.36–0.48)
    _subtitleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.36, 0.48, curve: Curves.easeOut),
      ),
    );

    // Phase 7: Tagline letter-by-letter (0.40–0.60)
    _taglineProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.40, 0.60, curve: Curves.linear),
      ),
    );

    // Phase 8: 4 cowry shells scatter from center (0.50–0.68)
    _cowryScatterProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.50, 0.68, curve: Curves.easeOut),
      ),
    );

    // Phase 9: Golden particle burst (0.58–0.78)
    _particleBurst = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.58, 0.78, curve: Curves.easeOut),
      ),
    );

    // Phase 10: Floating golden dust (0.55–1.0)
    _dustFloat = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.55, 1.0, curve: Curves.easeIn),
      ),
    );

    _startSequence();
  }

  void _startSequence() async {
    _masterCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 7200));
    if (!mounted) return;
    _exitCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 500));
    if (!mounted) return;
    widget.onComplete();
  }

  @override
  void dispose() {
    _masterCtrl.dispose();
    _exitCtrl.dispose();
    _sparkleCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_masterCtrl, _exitCtrl, _sparkleCtrl]),
      builder: (context, _) {
        return Opacity(
          opacity: 1.0 - _exitCtrl.value,
          child: Container(
            color: IstoColorsDark.bgPrimary,
            child: Stack(
              children: [
                // Floating golden dust sparkles (background layer)
                if (_dustFloat.value > 0)
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _SparklesPainter(
                        sparkles: _sparkles,
                        progress: _dustFloat.value,
                        time: _sparkleCtrl.value,
                      ),
                    ),
                  ),
                // Main content column
                Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Board animation
                      SizedBox(
                        width: 160,
                        height: 160,
                        child: CustomPaint(
                          painter: _SplashBoardPainter(
                            gridPatternOpacity: _gridPatternOpacity.value,
                            centerBloom: _centerBloom.value,
                            gridLinesDraw: _gridLinesDraw.value,
                            safeSquarePulse: _safeSquarePulse.value,
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Title: "ISTO"
                      Transform.translate(
                        offset: _titleSlide.value,
                        child: Opacity(
                          opacity: _titleOpacity.value,
                          child: Text(
                            'ISTO',
                            style: GoogleFonts.lora(
                              textStyle: IstoTypography.appTitle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Subtitle: "Chowka Bara"
                      Opacity(
                        opacity: _subtitleOpacity.value,
                        child: Text(
                          'Chowka Bara',
                          style: GoogleFonts.poppins(
                            textStyle: IstoTypography.subtitle,
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Tagline with letter-by-letter reveal
                      _buildTagline(),

                      const SizedBox(height: 24),

                      // 4 Cowry shells scatter animation
                      SizedBox(
                        width: 200,
                        height: 70,
                        child: CustomPaint(
                          painter: _CowryScatterPainter(
                            cowryData: _cowryData,
                            progress: _cowryScatterProgress.value,
                            particleBurst: _particleBurst.value,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTagline() {
    const tagline = 'Traditional Indian Board Game';
    final visibleChars = (_taglineProgress.value * tagline.length).floor();
    if (visibleChars == 0) return const SizedBox(height: 18);

    final visibleText = tagline.substring(0, visibleChars);
    // Cursor blink when still typing
    final showCursor = _taglineProgress.value < 1.0;
    return SizedBox(
      height: 18,
      child: Text(
        '$visibleText${showCursor ? '|' : ''}',
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: IstoColorsDark.textMuted.withValues(alpha: 0.7),
          letterSpacing: 2.0,
        ),
      ),
    );
  }
}

// Data classes for pre-computed random scatter
class _CowryScatterData {
  final double targetX, targetY, rotation, delay;
  final bool isUp;
  _CowryScatterData({
    required this.targetX,
    required this.targetY,
    required this.rotation,
    required this.delay,
    required this.isUp,
  });
}

class _SparkleData {
  final double startX, startY, drift, speed, size, phaseOffset;
  _SparkleData({
    required this.startX,
    required this.startY,
    required this.drift,
    required this.speed,
    required this.size,
    required this.phaseOffset,
  });
}

/// Paints the mini 5×5 board for the splash animation
class _SplashBoardPainter extends CustomPainter {
  final double gridPatternOpacity;
  final double centerBloom;
  final double gridLinesDraw;
  final double safeSquarePulse;

  _SplashBoardPainter({
    required this.gridPatternOpacity,
    required this.centerBloom,
    required this.gridLinesDraw,
    required this.safeSquarePulse,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellSize = size.width / 5;
    final center = Offset(size.width / 2, size.height / 2);

    // Phase 1: Faint grid texture pattern
    if (gridPatternOpacity > 0) {
      final patternPaint =
          Paint()
            ..color = IstoColorsDark.boardLine.withValues(
              alpha: gridPatternOpacity,
            )
            ..strokeWidth = 0.5;
      for (int i = 0; i <= 5; i++) {
        final pos = i * cellSize;
        canvas.drawLine(Offset(pos, 0), Offset(pos, size.height), patternPaint);
        canvas.drawLine(Offset(0, pos), Offset(size.width, pos), patternPaint);
      }
    }

    // Phase 2: Center cell golden bloom
    if (centerBloom > 0) {
      final bloomPaint =
          Paint()
            ..shader = RadialGradient(
              colors: [
                IstoColorsDark.accentGlow.withValues(alpha: 0.6),
                IstoColorsDark.accentGlow.withValues(alpha: 0),
              ],
            ).createShader(
              Rect.fromCircle(center: center, radius: centerBloom),
            );
      canvas.drawCircle(center, centerBloom, bloomPaint);
    }

    // Phase 3: Grid lines draw from center outward
    if (gridLinesDraw > 0) {
      final linePaint =
          Paint()
            ..color = IstoColorsDark.boardLine
            ..strokeWidth = 1.0
            ..strokeCap = StrokeCap.round;

      // Fill cells with alternating colors first
      for (int r = 0; r < 5; r++) {
        for (int c = 0; c < 5; c++) {
          final rect = Rect.fromLTWH(
            c * cellSize + 0.5,
            r * cellSize + 0.5,
            cellSize - 1,
            cellSize - 1,
          );
          final isAlt = (r + c) % 2 == 0;
          final alpha = gridLinesDraw * 0.7;
          final cellColor =
              isAlt
                  ? IstoColorsDark.boardCell.withValues(alpha: alpha)
                  : IstoColorsDark.boardCellAlt.withValues(alpha: alpha);
          canvas.drawRect(rect, Paint()..color = cellColor);
        }
      }

      for (int i = 0; i <= 5; i++) {
        final pos = i * cellSize;
        final expand = gridLinesDraw * size.width / 2;

        // Horizontal lines from center
        canvas.drawLine(
          Offset(center.dx - expand, pos),
          Offset(center.dx + expand, pos),
          linePaint,
        );
        // Vertical lines from center
        canvas.drawLine(
          Offset(pos, center.dy - expand),
          Offset(pos, center.dy + expand),
          linePaint,
        );
      }
    }

    // Phase 4: Safe squares pulse
    if (safeSquarePulse > 0) {
      final safeCells = [
        [0, 2],
        [2, 4],
        [4, 2],
        [2, 0],
      ];
      for (final cell in safeCells) {
        final cx = cell[1] * cellSize + cellSize / 2;
        final cy = cell[0] * cellSize + cellSize / 2;
        final ringRadius = cellSize * 0.35 * safeSquarePulse;
        canvas.drawCircle(
          Offset(cx, cy),
          ringRadius,
          Paint()
            ..color = IstoColorsDark.safeSquareBorder.withValues(
              alpha: (1 - safeSquarePulse) * 0.8,
            )
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5,
        );
      }

      // Center square asterisk hint
      final asteriskPaint =
          Paint()
            ..color = IstoColorsDark.accentGlow.withValues(
              alpha: safeSquarePulse * 0.6,
            )
            ..strokeWidth = 1.5
            ..strokeCap = StrokeCap.round;
      final r = cellSize * 0.25;
      for (int i = 0; i < 4; i++) {
        final angle = i * pi / 2;
        canvas.drawLine(
          center,
          Offset(center.dx + cos(angle) * r, center.dy + sin(angle) * r),
          asteriskPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SplashBoardPainter old) => true;
}

/// Paints 4 cowry shells scattering from center + golden particle burst
class _CowryScatterPainter extends CustomPainter {
  final List<_CowryScatterData> cowryData;
  final double progress; // 0→1 scatter
  final double particleBurst; // 0→1 particles

  _CowryScatterPainter({
    required this.cowryData,
    required this.progress,
    required this.particleBurst,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // Golden particle burst behind shells
    if (particleBurst > 0) {
      _drawParticleBurst(canvas, cx, cy);
    }

    // Draw 4 cowry shells scattering
    if (progress > 0) {
      for (int i = 0; i < cowryData.length; i++) {
        final data = cowryData[i];
        // Stagger each shell
        final shellT = ((progress - data.delay) / (1.0 - data.delay)).clamp(
          0.0,
          1.0,
        );
        if (shellT <= 0) continue;

        // Bounce easing
        final t = _bounceOut(shellT);
        final x = cx + data.targetX * t;
        final y = cy + data.targetY * t;
        final rot = data.rotation * t;

        canvas.save();
        canvas.translate(x, y);
        canvas.rotate(rot);

        // Scale: start small (gathering), grow as scattered
        final scale = 0.4 + 0.6 * shellT;
        canvas.scale(scale, scale);

        _drawMiniCowry(canvas, 32, 20, data.isUp);
        canvas.restore();
      }
    }
  }

  void _drawParticleBurst(Canvas canvas, double cx, double cy) {
    final rng = Random(12);
    final particleCount = 16;
    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * pi + rng.nextDouble() * 0.3;
      final maxR = 40.0 + rng.nextDouble() * 50.0;
      final r = maxR * particleBurst;
      final pSize =
          (1.5 + rng.nextDouble() * 2.0) * (1.0 - particleBurst * 0.5);
      final alpha = (1.0 - particleBurst) * 0.7;

      canvas.drawCircle(
        Offset(cx + cos(angle) * r, cy + sin(angle) * r),
        pSize,
        Paint()
          ..color = const Color(0xFFD4A843).withValues(alpha: alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
      );
    }

    // Central glow
    final glowAlpha = (1.0 - particleBurst) * 0.3;
    canvas.drawCircle(
      Offset(cx, cy),
      20 * particleBurst,
      Paint()
        ..color = const Color(0xFFD4A843).withValues(alpha: glowAlpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
  }

  void _drawMiniCowry(Canvas canvas, double w, double h, bool isUp) {
    final cx = 0.0;
    final cy = 0.0;
    final halfW = w / 2;
    final halfH = h / 2;

    final shellPath = Path();
    shellPath.moveTo(-halfW + w * 0.03, cy);
    shellPath.cubicTo(
      -halfW + w * 0.08,
      -halfH + h * 0.06,
      -halfW + w * 0.30,
      -halfH - h * 0.02,
      cx,
      -halfH,
    );
    shellPath.cubicTo(
      -halfW + w * 0.70,
      -halfH - h * 0.02,
      -halfW + w * 0.92,
      -halfH + h * 0.06,
      -halfW + w * 0.97,
      cy,
    );
    shellPath.cubicTo(
      -halfW + w * 0.92,
      -halfH + h * 0.94,
      -halfW + w * 0.70,
      -halfH + h * 1.02,
      cx,
      halfH,
    );
    shellPath.cubicTo(
      -halfW + w * 0.30,
      -halfH + h * 1.02,
      -halfW + w * 0.08,
      -halfH + h * 0.94,
      -halfW + w * 0.03,
      cy,
    );
    shellPath.close();

    // Shadow
    canvas.drawPath(
      shellPath.shift(const Offset(0.8, 2)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.5),
    );

    if (isUp) {
      // Ivory gradient
      final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          const Color(0xFFFFFBF0),
          const Color(0xFFF5ECD6),
          const Color(0xFFEADFC2),
        ],
      ).createShader(Rect.fromCenter(center: Offset.zero, width: w, height: h));
      canvas.drawPath(shellPath, Paint()..shader = gradient);

      // Slit
      final slitPath = Path();
      slitPath.moveTo(-halfW + w * 0.25, cy);
      slitPath.cubicTo(
        -halfW + w * 0.35,
        cy + h * 0.12,
        -halfW + w * 0.65,
        cy + h * 0.12,
        -halfW + w * 0.75,
        cy,
      );
      canvas.drawPath(
        slitPath,
        Paint()
          ..color = const Color(0xFFA08050)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8
          ..strokeCap = StrokeCap.round,
      );
    } else {
      // Brown convex side
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFFD4B896),
          const Color(0xFFB89470),
          const Color(0xFF9C7A56),
        ],
      ).createShader(Rect.fromCenter(center: Offset.zero, width: w, height: h));
      canvas.drawPath(shellPath, Paint()..shader = gradient);

      // Ridge line
      canvas.drawLine(
        Offset(-halfW + w * 0.2, cy),
        Offset(-halfW + w * 0.8, cy),
        Paint()
          ..color = const Color(0xFF8B6E4E).withValues(alpha: 0.5)
          ..strokeWidth = 0.6
          ..strokeCap = StrokeCap.round,
      );
    }

    // Border
    canvas.drawPath(
      shellPath,
      Paint()
        ..color = const Color(0xFFB8A88C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  static double _bounceOut(double t) {
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

  @override
  bool shouldRepaint(covariant _CowryScatterPainter old) =>
      old.progress != progress || old.particleBurst != particleBurst;
}

/// Floating golden dust sparkles across screen
class _SparklesPainter extends CustomPainter {
  final List<_SparkleData> sparkles;
  final double progress; // 0→1 fade in
  final double time; // 0→1 looping

  _SparklesPainter({
    required this.sparkles,
    required this.progress,
    required this.time,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    for (final s in sparkles) {
      final phase = (time * s.speed + s.phaseOffset) % 1.0;
      // Twinkle: alpha oscillates
      final twinkle = (sin(phase * 2 * pi) + 1) / 2; // 0→1→0
      final alpha = progress * twinkle * 0.4;
      if (alpha < 0.02) continue;

      final x = cx + s.startX + s.drift * sin(phase * 2 * pi);
      final y = cy + s.startY - 20 * phase; // Gentle upward drift

      // Sparkle cross shape
      final sparkleSize = s.size * (0.5 + twinkle * 0.5);
      final paint =
          Paint()..color = const Color(0xFFD4A843).withValues(alpha: alpha);

      canvas.drawCircle(Offset(x, y), sparkleSize * 0.5, paint);
      // Cross arms for sparkle effect
      canvas.drawLine(
        Offset(x - sparkleSize, y),
        Offset(x + sparkleSize, y),
        paint..strokeWidth = 0.5,
      );
      canvas.drawLine(
        Offset(x, y - sparkleSize),
        Offset(x, y + sparkleSize),
        paint..strokeWidth = 0.5,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SparklesPainter old) => true;
}
