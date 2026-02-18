import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/isto_tokens.dart';

/// Splash screen — "The Cloth Mat Unrolls"
///
/// Sequence (per design spec Section 4):
/// 0ms:   Black screen
/// 200ms: Faint grid pattern fades in
/// 400ms: Center cell golden bloom radiates outward
/// 600ms: Grid lines draw from center outward
/// 900ms: Safe squares pulse
/// 1100ms: "ISTO" title fades in + slide up
/// 1600ms: Cowry shell icon drops and bounces
/// 2200ms: Fade to Home Screen
///
/// UI only. No business logic touched.
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

  // Phase animations derived from master timeline
  late Animation<double> _gridPatternOpacity;
  late Animation<double> _centerBloom;
  late Animation<double> _gridLinesDraw;
  late Animation<double> _safeSquarePulse;
  late Animation<double> _titleOpacity;
  late Animation<Offset> _titleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _cowryDrop;
  late Animation<double> _cowryBounce;

  @override
  void initState() {
    super.initState();

    // Master timeline: 0 → 2200ms
    _masterCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Exit fade: 300ms
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    // Phase 1: Grid pattern fades in (200ms–400ms → 0.09–0.18 of 2200)
    _gridPatternOpacity = Tween<double>(begin: 0, end: 0.06).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.09, 0.18, curve: Curves.easeOut),
      ),
    );

    // Phase 2: Center bloom (400ms–800ms → 0.18–0.36)
    _centerBloom = Tween<double>(begin: 0, end: 40).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.18, 0.36, curve: Curves.easeOut),
      ),
    );

    // Phase 3: Grid lines draw (600ms–900ms → 0.27–0.41)
    _gridLinesDraw = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.27, 0.41, curve: Curves.decelerate),
      ),
    );

    // Phase 4: Safe square pulse (900ms–1050ms → 0.41–0.48)
    _safeSquarePulse = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.41, 0.48, curve: Curves.easeOut),
      ),
    );

    // Phase 5: Title fade + slide (1100ms–1500ms → 0.5–0.68)
    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.5, 0.68, curve: Curves.easeOutCubic),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.5, 0.68, curve: Curves.easeOutCubic),
      ),
    );

    // Subtitle delayed slightly (1300ms → 0.59)
    _subtitleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.59, 0.73, curve: Curves.easeOut),
      ),
    );

    // Phase 6: Cowry drop + bounce (1600ms–2000ms → 0.73–0.91)
    _cowryDrop = Tween<double>(begin: -30, end: 0).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.73, 0.82, curve: Curves.easeIn),
      ),
    );
    _cowryBounce = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _masterCtrl,
        curve: const Interval(0.82, 0.91, curve: Curves.bounceOut),
      ),
    );

    _startSequence();
  }

  void _startSequence() async {
    _masterCtrl.forward();
    // Wait for full animation + brief hold
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    _exitCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    widget.onComplete();
  }

  @override
  void dispose() {
    _masterCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_masterCtrl, _exitCtrl]),
      builder: (context, _) {
        return Opacity(
          opacity: 1.0 - _exitCtrl.value,
          child: Container(
            color: IstoColorsDark.bgPrimary,
            child: Center(
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
                  const SizedBox(height: 32),

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
                  const SizedBox(height: 6),

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
                  const SizedBox(height: 20),

                  // Cowry shell icon (drops and bounces)
                  Transform.translate(
                    offset: Offset(
                      0,
                      _cowryDrop.value * (1 - _cowryBounce.value),
                    ),
                    child: Opacity(
                      opacity: _cowryDrop.value > -25 ? 1.0 : 0.0,
                      child: CustomPaint(
                        size: const Size(28, 18),
                        painter: _MiniCowryPainter(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
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

/// Paints a tiny cowry shell icon for the splash
class _MiniCowryPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final cx = w / 2;
    final cy = h / 2;

    // Shell shape — oval
    final shellPath =
        Path()
          ..moveTo(w * 0.12, cy)
          ..cubicTo(w * 0.12, h * 0.15, w * 0.35, 0, cx, 0)
          ..cubicTo(w * 0.65, 0, w * 0.88, h * 0.15, w * 0.88, cy)
          ..cubicTo(w * 0.88, h * 0.85, w * 0.65, h, cx, h)
          ..cubicTo(w * 0.35, h, w * 0.12, h * 0.85, w * 0.12, cy)
          ..close();

    // Shadow
    canvas.drawPath(
      shellPath.shift(const Offset(0.5, 1.5)),
      Paint()
        ..color = Colors.black.withValues(alpha: 0.3)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );

    // Fill: ivory
    canvas.drawPath(shellPath, Paint()..color = const Color(0xFFF5F0E0));

    // Slit line
    final slitPath =
        Path()
          ..moveTo(w * 0.3, cy * 0.95)
          ..cubicTo(w * 0.4, cy * 1.2, w * 0.6, cy * 1.2, w * 0.7, cy * 0.95);
    canvas.drawPath(
      slitPath,
      Paint()
        ..color = const Color(0xFFA08050)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round,
    );

    // Border
    canvas.drawPath(
      shellPath,
      Paint()
        ..color = const Color(0xFFB8A88C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.5,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
