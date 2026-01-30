import 'dart:math';
import 'package:flutter/material.dart';
import '../config/design_system.dart';
import '../config/game_feel_config.dart';
import '../components/animated_background.dart';

/// Premium, game-like splash screen for ISTO
/// Features: Dramatic reveal, floating particles, animated logo, shimmer effects
class SplashScreen extends StatefulWidget {
  final VoidCallback onComplete;
  final Duration duration;

  const SplashScreen({
    super.key,
    required this.onComplete,
    this.duration = const Duration(milliseconds: 3500),
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  // Main sequence controller
  late AnimationController _sequenceController;
  
  // Logo animations
  late AnimationController _logoController;
  late AnimationController _logoGlowController;
  late AnimationController _logoRotateController;
  
  // Title animations
  late AnimationController _titleController;
  
  // Exit animation
  late AnimationController _exitController;
  
  // Animations
  late Animation<double> _logoScale;
  late Animation<double> _logoOpacity;
  late Animation<double> _logoGlow;
  late Animation<double> _logoRotation;
  late Animation<double> _titleOpacity;
  late Animation<double> _titleSlide;
  late Animation<double> _subtitleOpacity;
  late Animation<double> _loadingProgress;
  late Animation<double> _exitOpacity;
  late Animation<double> _exitScale;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimationSequence();
  }

  void _setupAnimations() {
    // Sequence controller for timing
    _sequenceController = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    // Logo entrance with bounce
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.0, end: 1.15)
            .chain(CurveTween(curve: Curves.easeOutCubic)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.15, end: 0.95)
            .chain(CurveTween(curve: Curves.easeInOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.95, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
    ]).animate(_logoController);
    
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );
    
    // Logo glow pulsing
    _logoGlowController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _logoGlow = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoGlowController, curve: Curves.easeInOut),
    );
    
    // Subtle logo rotation
    _logoRotateController = AnimationController(
      duration: const Duration(milliseconds: 20000),
      vsync: this,
    );
    
    _logoRotation = Tween<double>(begin: 0.0, end: 2 * pi).animate(
      _logoRotateController,
    );
    
    // Title entrance
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );
    
    _titleSlide = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
      ),
    );
    
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _titleController,
        curve: const Interval(0.4, 1.0, curve: Curves.easeOut),
      ),
    );
    
    // Loading progress
    _loadingProgress = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _sequenceController,
        curve: const Interval(0.2, 0.85, curve: Curves.easeInOut),
      ),
    );
    
    // Exit animation
    _exitController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    
    _exitOpacity = Tween<double>(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );
    
    _exitScale = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _exitController, curve: Curves.easeIn),
    );
  }

  void _startAnimationSequence() {
    // Start sequence controller
    _sequenceController.forward();
    
    // Logo entrance (immediate)
    _logoController.forward();
    
    // Start logo glow after entrance
    _logoController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _logoGlowController.repeat(reverse: true);
        _logoRotateController.repeat();
      }
    });
    
    // Title entrance after logo
    Future.delayed(const Duration(milliseconds: 600), () {
      if (mounted) _titleController.forward();
    });
    
    // Exit and complete
    _sequenceController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _exitController.forward().then((_) {
          if (mounted) widget.onComplete();
        });
      }
    });
  }

  @override
  void dispose() {
    _sequenceController.dispose();
    _logoController.dispose();
    _logoGlowController.dispose();
    _logoRotateController.dispose();
    _titleController.dispose();
    _exitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _sequenceController,
        _logoController,
        _logoGlowController,
        _logoRotateController,
        _titleController,
        _exitController,
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: _exitOpacity.value,
          child: Transform.scale(
            scale: _exitScale.value,
            child: AnimatedBackground(
              showParticles: true,
              showGradientAnimation: true,
              showAmbientGlow: true,
              accentColor: DesignSystem.accentGold,
              particleDensity: 1.5,
              child: SafeArea(
                child: Column(
                  children: [
                    const Spacer(flex: 2),
                    
                    // Logo with glow
                    _buildAnimatedLogo(),
                    
                    const SizedBox(height: 48),
                    
                    // Title with slide-up
                    _buildAnimatedTitle(),
                    
                    const SizedBox(height: 12),
                    
                    // Subtitle
                    _buildSubtitle(),
                    
                    const Spacer(flex: 2),
                    
                    // Loading bar
                    _buildLoadingBar(),
                    
                    const SizedBox(height: 48),
                    
                    // Footer
                    _buildFooter(),
                    
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedLogo() {
    final glowIntensity = _logoGlow.value * GameFeelConfig.glowIntensity;
    
    return Opacity(
      opacity: _logoOpacity.value,
      child: Transform.scale(
        scale: _logoScale.value,
        child: Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: DesignSystem.goldGradient,
            boxShadow: [
              // Outer glow
              BoxShadow(
                color: DesignSystem.accentGold.withAlpha((80 * glowIntensity).toInt()),
                blurRadius: 40 + (20 * glowIntensity),
                spreadRadius: 10 * glowIntensity,
              ),
              // Inner glow
              BoxShadow(
                color: DesignSystem.accentGold.withAlpha((60 * glowIntensity).toInt()),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DesignSystem.bgDark,
                border: Border.all(
                  color: DesignSystem.accentGold.withAlpha(100),
                  width: 2,
                ),
              ),
              child: Center(
                child: Transform.rotate(
                  angle: _logoRotation.value * 0.05, // Very subtle rotation
                  child: _buildCowryMandala(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCowryMandala() {
    return SizedBox(
      width: 90,
      height: 90,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Center ornament
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: DesignSystem.goldGradient,
              boxShadow: [
                BoxShadow(
                  color: DesignSystem.accentGold.withAlpha(100),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
          
          // Cowry shells in mandala pattern
          ...List.generate(4, (index) {
            final angle = (index * 90) * pi / 180;
            final radius = 30.0;
            return Transform.translate(
              offset: Offset(radius * cos(angle), radius * sin(angle)),
              child: Transform.rotate(
                angle: angle + pi / 2,
                child: _buildPremiumCowry(),
              ),
            );
          }),
          
          // Decorative dots
          ...List.generate(8, (index) {
            final angle = (index * 45 + 22.5) * pi / 180;
            final radius = 38.0;
            return Transform.translate(
              offset: Offset(radius * cos(angle), radius * sin(angle)),
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignSystem.accentGold.withAlpha(180),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildPremiumCowry() {
    return Container(
      width: 22,
      height: 14,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFFFAF0),
            Color(0xFFF5E6D3),
            Color(0xFFE8D5C4),
          ],
        ),
        borderRadius: BorderRadius.circular(7),
        border: Border.all(
          color: const Color(0xFFD4C4B0),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 12,
          height: 2,
          decoration: BoxDecoration(
            color: const Color(0xFF5D4E37),
            borderRadius: BorderRadius.circular(1),
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedTitle() {
    return Opacity(
      opacity: _titleOpacity.value,
      child: Transform.translate(
        offset: Offset(0, _titleSlide.value),
        child: ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              DesignSystem.textPrimary,
              DesignSystem.accentGold,
              DesignSystem.textPrimary,
            ],
            stops: const [0.0, 0.5, 1.0],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ).createShader(bounds),
          child: Text(
            'ISTO',
            style: DesignSystem.headingLarge.copyWith(
              fontSize: 72,
              letterSpacing: 16,
              shadows: [
                Shadow(
                  color: DesignSystem.accentGold.withAlpha(100),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubtitle() {
    return Opacity(
      opacity: _subtitleOpacity.value,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildDecorativeLine(),
          const SizedBox(width: 16),
          Column(
            children: [
              Text(
                'ಚೌಕಾಬಾರ',
                style: DesignSystem.bodyMedium.copyWith(
                  color: DesignSystem.accentGold.withAlpha(200),
                  letterSpacing: 4,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Chowka Bhara',
                style: DesignSystem.caption.copyWith(
                  color: DesignSystem.textMuted,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          const SizedBox(width: 16),
          _buildDecorativeLine(),
        ],
      ),
    );
  }

  Widget _buildDecorativeLine() {
    return Container(
      width: 40,
      height: 2,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            DesignSystem.accentGold.withAlpha(150),
          ],
        ),
        borderRadius: BorderRadius.circular(1),
      ),
    );
  }

  Widget _buildLoadingBar() {
    final progress = _loadingProgress.value;
    
    return Column(
      children: [
        // Progress bar container
        Container(
          width: 160,
          height: 4,
          decoration: BoxDecoration(
            color: DesignSystem.border.withAlpha(100),
            borderRadius: BorderRadius.circular(2),
          ),
          child: Stack(
            children: [
              // Progress fill
              FractionallySizedBox(
                alignment: Alignment.centerLeft,
                widthFactor: progress,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: DesignSystem.goldGradient,
                    borderRadius: BorderRadius.circular(2),
                    boxShadow: [
                      BoxShadow(
                        color: DesignSystem.accentGold.withAlpha(150),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
              // Shimmer effect on progress bar
              if (progress > 0 && progress < 1)
                Positioned(
                  left: (progress * 160) - 30,
                  top: 0,
                  bottom: 0,
                  width: 30,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          Colors.white.withAlpha(80),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Loading text with dots animation
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'LOADING',
              style: DesignSystem.caption.copyWith(
                color: DesignSystem.textMuted,
                letterSpacing: 3,
              ),
            ),
            SizedBox(
              width: 20,
              child: Text(
                '.' * ((progress * 10).toInt() % 4),
                style: DesignSystem.caption.copyWith(
                  color: DesignSystem.textMuted,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFooter() {
    final opacity = (_loadingProgress.value * 2).clamp(0.0, 1.0);
    
    return Opacity(
      opacity: opacity * 0.7,
      child: Column(
        children: [
          Text(
            'Traditional Indian Board Game',
            style: DesignSystem.caption.copyWith(
              color: DesignSystem.textMuted.withAlpha(150),
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignSystem.accent.withAlpha(100),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Made with ♥',
                style: DesignSystem.caption.copyWith(
                  color: DesignSystem.textMuted.withAlpha(100),
                  fontSize: 10,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: DesignSystem.accent.withAlpha(100),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
