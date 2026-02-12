import 'dart:async';

import 'package:flutter/material.dart';

import '../config/design_system.dart';
import '../game/isto_game.dart';

/// Toast overlay for extra turns
class ExtraTurnOverlay extends StatefulWidget {
  final ISTOGame game;

  const ExtraTurnOverlay({super.key, required this.game});

  @override
  State<ExtraTurnOverlay> createState() => _ExtraTurnOverlayState();
}

class _ExtraTurnOverlayState extends State<ExtraTurnOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));

    _ctrl.forward();

    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        _ctrl.reverse().then((_) {
          if (mounted) {
            widget.game.overlays.remove('extraTurn');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DesignSystem.accent.withValues(alpha: 0.2),
                    DesignSystem.accentDark.withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
                border: Border.all(
                  color: DesignSystem.accent.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: DesignSystem.accent.withValues(alpha: 0.2),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.stars_rounded,
                      color: DesignSystem.accent, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'EXTRA TURN!',
                    style: DesignSystem.bodyLarge.copyWith(
                      color: DesignSystem.accent,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
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

/// Toast overlay for capturing opponent's pawn
class CaptureOverlay extends StatefulWidget {
  final ISTOGame game;

  const CaptureOverlay({super.key, required this.game});

  @override
  State<CaptureOverlay> createState() => _CaptureOverlayState();
}

class _CaptureOverlayState extends State<CaptureOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );

    _ctrl.forward();

    Timer(const Duration(milliseconds: 2000), () {
      if (mounted) {
        _ctrl.reverse().then((_) {
          if (mounted) {
            widget.game.overlays.remove('capture');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fade,
        child: ScaleTransition(
          scale: _scale,
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    DesignSystem.danger.withValues(alpha: 0.2),
                    const Color(0xFFFF1744).withValues(alpha: 0.15),
                  ],
                ),
                borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
                border: Border.all(
                  color: DesignSystem.danger.withValues(alpha: 0.4),
                ),
                boxShadow: [
                  BoxShadow(
                    color: DesignSystem.danger.withValues(alpha: 0.2),
                    blurRadius: 16,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.gps_fixed_rounded,
                      color: DesignSystem.danger, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'CAPTURED!',
                    style: DesignSystem.bodyLarge.copyWith(
                      color: DesignSystem.danger,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
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

/// Toast overlay for no valid moves
class NoMovesOverlay extends StatefulWidget {
  final ISTOGame game;

  const NoMovesOverlay({super.key, required this.game});

  @override
  State<NoMovesOverlay> createState() => _NoMovesOverlayState();
}

class _NoMovesOverlayState extends State<NoMovesOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.forward();

    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _ctrl.reverse().then((_) {
          if (mounted) {
            widget.game.overlays.remove('noMoves');
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 80,
      left: 0,
      right: 0,
      child: FadeTransition(
        opacity: _fade,
        child: Center(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: DesignSystem.surface.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
              border: Border.all(
                color: DesignSystem.textMuted.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.block_rounded,
                    color: DesignSystem.textMuted, size: 18),
                const SizedBox(width: 8),
                Text(
                  'No valid moves',
                  style: DesignSystem.bodyMedium.copyWith(
                    color: DesignSystem.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
