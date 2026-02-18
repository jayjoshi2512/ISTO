import 'dart:math';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/design_system.dart';
import '../game/isto_game.dart';
import '../theme/isto_tokens.dart';

/// Gold gradient roll button with breathing pulse and press feedback.
/// Terracotta Dusk styled — warm gold gradient, mini cowry shell icons.
class RollButtonOverlay extends StatefulWidget {
  final ISTOGame game;

  const RollButtonOverlay({super.key, required this.game});

  @override
  State<RollButtonOverlay> createState() => _RollButtonOverlayState();
}

class _RollButtonOverlayState extends State<RollButtonOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseCtrl;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  void _onTap() {
    widget.game.rollCowries();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 28,
      left: 0,
      right: 0,
      child: Center(
        child: GameAnimatedBuilder(
          animation: _pulseCtrl,
          builder: (context, child) {
            final pulse = 1.0 + sin(_pulseCtrl.value * pi) * 0.03;
            return Transform.scale(
              scale: _isPressed ? 0.95 : pulse,
              child: child,
            );
          },
          child: GestureDetector(
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) {
              setState(() => _isPressed = false);
              _onTap();
            },
            onTapCancel: () => setState(() => _isPressed = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 100),
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
              decoration: DesignSystem.goldButton(pressed: _isPressed),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Mini cowry shell dots
                  ...List.generate(4, (i) {
                    return Container(
                      width: 10,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: IstoColorsDark.bgPrimary.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(3),
                      ),
                    );
                  }),
                  const SizedBox(width: 12),
                  Text(
                    'ROLL',
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: IstoColorsDark.bgPrimary,
                      letterSpacing: 3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
