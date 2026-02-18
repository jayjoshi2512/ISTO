import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/design_system.dart';
import '../game/isto_game.dart';
import '../theme/isto_tokens.dart';

/// Victory overlay — celebration effects, rankings, Lora title.
class WinOverlay extends StatefulWidget {
  final ISTOGame game;

  const WinOverlay({super.key, required this.game});

  @override
  State<WinOverlay> createState() => _WinOverlayState();
}

class _WinOverlayState extends State<WinOverlay> with TickerProviderStateMixin {
  late AnimationController _entranceCtrl;
  late AnimationController _confettiCtrl;
  late Animation<double> _fadeIn;
  late Animation<double> _scaleIn;
  late List<_ConfettiParticle> _confetti;

  @override
  void initState() {
    super.initState();

    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeIn = CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut);
    _scaleIn = Tween<double>(
      begin: 0.7,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.elasticOut));

    _confettiCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();

    // Confetti particles in player palette + gold
    final rng = Random();
    _confetti = List.generate(50, (_) {
      return _ConfettiParticle(
        x: rng.nextDouble(),
        speed: 0.2 + rng.nextDouble() * 0.6,
        size: 4 + rng.nextDouble() * 8,
        color:
            [
              IstoColorsDark.accentPrimary,
              IstoPlayerColors.base(0), // Crimson
              IstoPlayerColors.base(1), // Cobalt
              IstoPlayerColors.base(2), // Forest
              IstoColorsDark.accentGlow,
              IstoColorsDark.accentWarm,
            ][rng.nextInt(6)],
        wobble: rng.nextDouble() * pi * 2,
        wobbleSpeed: 1 + rng.nextDouble() * 3,
      );
    });

    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    _confettiCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final rankings = widget.game.gameManager.rankings;
    final winner = rankings.isNotEmpty ? rankings.first : null;
    final screen = MediaQuery.of(context).size;

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dark backdrop
          FadeTransition(
            opacity: _fadeIn,
            child: Container(color: Colors.black.withValues(alpha: 0.75)),
          ),

          // Confetti layer
          GameAnimatedBuilder(
            animation: _confettiCtrl,
            builder: (context, _) {
              return CustomPaint(
                size: screen,
                painter: _ConfettiPainter(
                  particles: _confetti,
                  progress: _confettiCtrl.value,
                ),
              );
            },
          ),

          // Content card
          Center(
            child: FadeTransition(
              opacity: _fadeIn,
              child: ScaleTransition(
                scale: _scaleIn,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        IstoColorsDark.bgElevated.withValues(alpha: 0.95),
                        IstoColorsDark.bgSurface.withValues(alpha: 0.95),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(IstoRadius.lg),
                    border: Border.all(
                      color:
                          winner != null
                              ? winner.color.withValues(alpha: 0.3)
                              : IstoColorsDark.accentPrimary.withValues(
                                alpha: 0.3,
                              ),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.4),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Trophy icon
                      Container(
                        width: 64,
                        height: 64,
                        decoration: BoxDecoration(
                          gradient: IstoGradients.accentGold,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: IstoColorsDark.accentPrimary.withValues(
                                alpha: 0.4,
                              ),
                              blurRadius: 20,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: Icon(
                          Icons.emoji_events_rounded,
                          color: IstoColorsDark.bgPrimary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // "VICTORY!" in Lora with gold gradient
                      ShaderMask(
                        shaderCallback:
                            (bounds) =>
                                IstoGradients.accentGold.createShader(bounds),
                        child: Text(
                          'VICTORY!',
                          style: GoogleFonts.lora(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: 4,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      if (winner != null) ...[
                        Text(
                          '${winner.name} wins!',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: winner.color,
                          ),
                        ),
                      ],

                      const SizedBox(height: 24),
                      const MinimalDivider(),
                      const SizedBox(height: 20),

                      // Rankings
                      ...rankings.asMap().entries.map((entry) {
                        final index = entry.key;
                        final player = entry.value;
                        final medals = ['🥇', '🥈', '🥉', '4th'];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              SizedBox(
                                width: 32,
                                child: Text(
                                  index < 3 ? medals[index] : medals[3],
                                  style: const TextStyle(fontSize: 16),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                width: 10,
                                height: 10,
                                decoration: BoxDecoration(
                                  color: player.color,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text(
                                  player.name,
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color:
                                        index == 0
                                            ? IstoColorsDark.textPrimary
                                            : IstoColorsDark.textSecondary,
                                    fontWeight:
                                        index == 0
                                            ? FontWeight.w700
                                            : FontWeight.w400,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 28),

                      // Buttons
                      Row(
                        children: [
                          Expanded(
                            child: PremiumButton(
                              label: 'PLAY AGAIN',
                              onTap: () {
                                widget.game.gameManager.reset();
                                widget.game.overlays.remove(
                                  ISTOGame.winOverlay,
                                );
                                widget.game.overlays.add(
                                  ISTOGame.turnIndicatorOverlay,
                                );
                                if (!widget
                                    .game
                                    .gameManager
                                    .isCurrentPlayerAI) {
                                  widget.game.overlays.add(
                                    ISTOGame.rollButtonOverlay,
                                  );
                                }
                              },
                              icon: Icons.replay_rounded,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: PremiumButton(
                              label: 'MENU',
                              onTap: () {
                                widget.game.overlays.remove(
                                  ISTOGame.winOverlay,
                                );
                                widget.game.overlays.remove(
                                  ISTOGame.turnIndicatorOverlay,
                                );
                                widget.game.overlays.remove(
                                  ISTOGame.rollButtonOverlay,
                                );
                                widget.game.showMenu();
                              },
                              isPrimary: false,
                              icon: Icons.home_rounded,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfettiParticle {
  final double x;
  final double speed;
  final double size;
  final Color color;
  final double wobble;
  final double wobbleSpeed;

  _ConfettiParticle({
    required this.x,
    required this.speed,
    required this.size,
    required this.color,
    required this.wobble,
    required this.wobbleSpeed,
  });
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  final double progress;

  _ConfettiPainter({required this.particles, required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final y = (progress * p.speed * 2) % 1.2;
      if (y > 1.0) continue;
      final x = p.x + sin(progress * p.wobbleSpeed * pi * 2 + p.wobble) * 0.05;
      final rect = Rect.fromCenter(
        center: Offset(x * size.width, y * size.height),
        width: p.size,
        height: p.size * 0.6,
      );
      canvas.save();
      canvas.translate(rect.center.dx, rect.center.dy);
      canvas.rotate(progress * p.wobbleSpeed * 2);
      canvas.translate(-rect.center.dx, -rect.center.dy);
      canvas.drawRect(
        rect,
        Paint()..color = p.color.withValues(alpha: (1.0 - y) * 0.8),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter old) => true;
}
