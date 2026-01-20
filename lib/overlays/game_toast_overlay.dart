import 'package:flutter/material.dart';

import '../config/design_system.dart';
import '../game/isto_game.dart';

/// Clean, minimal toast notifications for game events
class GameToastOverlay extends StatefulWidget {
  final ISTOGame game;
  final String message;
  final Color color;
  final IconData? icon;
  final Duration duration;
  final VoidCallback? onDismiss;

  const GameToastOverlay({
    super.key,
    required this.game,
    required this.message,
    this.color = DesignSystem.accent,
    this.icon,
    this.duration = const Duration(seconds: 2),
    this.onDismiss,
  });

  @override
  State<GameToastOverlay> createState() => _GameToastOverlayState();
}

class _GameToastOverlayState extends State<GameToastOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _controller.forward();

    Future.delayed(widget.duration, () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.onDismiss?.call();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 80,
          left: 32,
          right: 32,
          child: SlideTransition(
            position: _slideAnimation,
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Center(child: child),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
          border: Border.all(
            color: widget.color.withAlpha(100),
          ),
          boxShadow: [
            BoxShadow(
              color: widget.color.withAlpha(40),
              blurRadius: 16,
            ),
            BoxShadow(
              color: Colors.black.withAlpha(60),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (widget.icon != null) ...[
              Icon(
                widget.icon,
                color: widget.color,
                size: 18,
              ),
              const SizedBox(width: 10),
            ],
            Text(
              widget.message,
              style: DesignSystem.bodyMedium.copyWith(
                color: DesignSystem.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Extra turn notification overlay
class ExtraTurnOverlay extends StatefulWidget {
  final ISTOGame game;

  const ExtraTurnOverlay({super.key, required this.game});

  @override
  State<ExtraTurnOverlay> createState() => _ExtraTurnOverlayState();
}

class _ExtraTurnOverlayState extends State<ExtraTurnOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.game.overlays.remove('extraTurn');
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 80,
          left: 32,
          right: 32,
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _controller.value,
                child: child,
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          gradient: DesignSystem.goldGradient,
          borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
          boxShadow: DesignSystem.glowGold,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.auto_awesome,
              color: Color(0xFF1A1025),
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'EXTRA TURN!',
              style: DesignSystem.button.copyWith(
                color: DesignSystem.bgDark,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Capture notification overlay
class CaptureOverlay extends StatefulWidget {
  final ISTOGame game;

  const CaptureOverlay({super.key, required this.game});

  @override
  State<CaptureOverlay> createState() => _CaptureOverlayState();
}

class _CaptureOverlayState extends State<CaptureOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.game.overlays.remove('capture');
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 80,
          left: 32,
          right: 32,
          child: Center(
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Opacity(
                opacity: _controller.value,
                child: child,
              ),
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFE53935),
          borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFE53935).withAlpha(80),
              blurRadius: 16,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.flash_on,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 10),
            Text(
              'CAPTURED!',
              style: DesignSystem.button.copyWith(
                color: Colors.white,
                letterSpacing: 2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// No valid moves notification overlay
class NoMovesOverlay extends StatefulWidget {
  final ISTOGame game;

  const NoMovesOverlay({super.key, required this.game});

  @override
  State<NoMovesOverlay> createState() => _NoMovesOverlayState();
}

class _NoMovesOverlayState extends State<NoMovesOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    )..forward();

    Future.delayed(const Duration(milliseconds: 1500), () {
      if (mounted) {
        _controller.reverse().then((_) {
          widget.game.overlays.remove('noMoves');
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Positioned(
          top: MediaQuery.of(context).padding.top + 80,
          left: 32,
          right: 32,
          child: Center(
            child: Opacity(
              opacity: _controller.value,
              child: child,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        decoration: BoxDecoration(
          color: DesignSystem.surface,
          borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
          border: Border.all(color: Colors.orange.withAlpha(150)),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.withAlpha(40),
              blurRadius: 12,
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.block,
              color: Colors.orange,
              size: 18,
            ),
            const SizedBox(width: 10),
            Text(
              'No valid moves',
              style: DesignSystem.bodyMedium.copyWith(
                color: DesignSystem.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
