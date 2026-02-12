import 'package:flutter/material.dart';

import '../config/design_system.dart';

/// Premium splash screen with animated logo and loading
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;

  const SplashScreen({super.key, required this.onComplete});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoCtrl;
  late AnimationController _textCtrl;
  late AnimationController _loadingCtrl;
  late AnimationController _exitCtrl;

  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _textOpacity;
  late Animation<Offset> _textSlide;
  late Animation<double> _loadingProgress;

  @override
  void initState() {
    super.initState();

    // Logo entrance
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut),
    );
    _logoOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeOut),
    );

    // Title text
    _textCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _textOpacity = Tween<double>(begin: 0, end: 1).animate(_textCtrl);
    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _textCtrl, curve: Curves.easeOut));

    // Loading
    _loadingCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _loadingProgress = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _loadingCtrl, curve: Curves.easeInOut),
    );

    // Exit
    _exitCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _startSequence();
  }

  void _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _logoCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    _textCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    _loadingCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 1500));
    _exitCtrl.forward();
    await Future.delayed(const Duration(milliseconds: 400));
    widget.onComplete();
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _textCtrl.dispose();
    _loadingCtrl.dispose();
    _exitCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GameAnimatedBuilder(
      animation: _exitCtrl,
      builder: (context, child) {
        return Opacity(
          opacity: 1 - _exitCtrl.value,
          child: child,
        );
      },
      child: Container(
        decoration: const BoxDecoration(gradient: DesignSystem.bgGradient),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated logo
              GameAnimatedBuilder(
                animation: _logoCtrl,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _logoScale.value,
                    child: Opacity(
                      opacity: _logoOpacity.value,
                      child: child,
                    ),
                  );
                },
                child: _buildLogo(),
              ),
              const SizedBox(height: 32),
              // Title
              SlideTransition(
                position: _textSlide,
                child: FadeTransition(
                  opacity: _textOpacity,
                  child: _buildTitle(),
                ),
              ),
              const SizedBox(height: 48),
              // Loading bar
              GameAnimatedBuilder(
                animation: _loadingProgress,
                builder: (context, child) {
                  return _buildLoadingBar(_loadingProgress.value);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: DesignSystem.goldGradient,
        boxShadow: [
          BoxShadow(
            color: DesignSystem.accent.withValues(alpha: 0.5),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'I',
          style: TextStyle(
            fontSize: 52,
            fontWeight: FontWeight.w900,
            color: Color(0xFF1A0E04),
            fontFamily: 'Inter',
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'ISTO',
          style: DesignSystem.displayLarge.copyWith(
            letterSpacing: 12,
            fontSize: 52,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'ಚೌಕಾಬಾರ',
          style: DesignSystem.bodyMedium.copyWith(
            color: DesignSystem.accent.withValues(alpha: 0.6),
            fontSize: 16,
            letterSpacing: 4,
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingBar(double progress) {
    return SizedBox(
      width: 120,
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: SizedBox(
              height: 2,
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: DesignSystem.textMuted.withValues(alpha: 0.2),
                valueColor:
                    AlwaysStoppedAnimation(DesignSystem.accent.withValues(alpha: 0.8)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
