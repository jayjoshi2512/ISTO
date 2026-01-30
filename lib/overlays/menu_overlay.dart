import 'dart:math';
import 'package:flutter/material.dart';

import '../config/design_system.dart';
import '../config/player_colors.dart';
import '../game/isto_game.dart';
import '../services/feedback_service.dart';
import '../components/animated_background.dart';

/// Premium game-like menu overlay for ISTO
/// Features: Animated background, glassmorphism cards, hover effects, premium buttons
class MenuOverlay extends StatefulWidget {
  final ISTOGame game;

  const MenuOverlay({super.key, required this.game});

  @override
  State<MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<MenuOverlay>
    with TickerProviderStateMixin {
  // Entrance animations  
  late AnimationController _entranceController;
  late AnimationController _cardController;
  late AnimationController _buttonController;
  late AnimationController _pulseController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _cardScale;
  late Animation<double> _cardSlide;
  late Animation<double> _buttonScale;
  late Animation<double> _pulseAnimation;
  
  int _selectedPlayerCount = 2;
  int? _hoveredPlayerCount;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimations();
  }

  void _setupAnimations() {
    // Main entrance
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    
    // Card entrance with bounce
    _cardController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    
    _cardScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: Curves.easeOutBack,
      ),
    );
    
    _cardSlide = Tween<double>(begin: 50.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _cardController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    // Button entrance
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _buttonScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _buttonController,
        curve: Curves.elasticOut,
      ),
    );
    
    // Idle pulse for selected player
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _startAnimations() {
    _entranceController.forward();
    
    // Stagger card entrance
    _entranceController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _cardController.forward();
      }
    });
    
    // Stagger button entrance
    _cardController.addStatusListener((status) {
      if (status == AnimationStatus.completed && mounted) {
        _buttonController.forward();
        _pulseController.repeat(reverse: true);
      }
    });
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _cardController.dispose();
    _buttonController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _startGame() {
    feedbackService.mediumTap();
    widget.game.startNewGame(_selectedPlayerCount);
  }

  void _close() {
    feedbackService.lightTap();
    _buttonController.reverse();
    _cardController.reverse();
    _entranceController.reverse().then((_) {
      widget.game.overlays.remove(ISTOGame.menuOverlay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([
        _entranceController,
        _cardController,
        _buttonController,
        _pulseController,
      ]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: AnimatedBackground(
            showParticles: true,
            showGradientAnimation: true,
            showAmbientGlow: true,
            accentColor: DesignSystem.accent,
            particleDensity: 0.8,
            child: SafeArea(
              child: _buildContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    final screenHeight = MediaQuery.of(context).size.height;
    final isCompact = screenHeight < 700;
    
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isCompact ? 16 : 32,
      ),
      child: Column(
        children: [
          // Header with logo
          _buildHeader(),
          
          SizedBox(height: isCompact ? 24 : 40),
          
          // Main card
          Expanded(
            child: Transform.translate(
              offset: Offset(0, _cardSlide.value),
              child: Transform.scale(
                scale: _cardScale.value,
                child: Opacity(
                  opacity: _cardController.value.clamp(0.0, 1.0),
                  child: _buildMainCard(isCompact),
                ),
              ),
            ),
          ),
          
          SizedBox(height: isCompact ? 16 : 24),
          
          // Footer
          _buildFooter(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Animated logo
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: DesignSystem.goldGradient,
            boxShadow: [
              BoxShadow(
                color: DesignSystem.accentGold.withAlpha(100),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DesignSystem.bgDark,
              ),
              child: Center(
                child: _buildMiniCowryIcon(),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Title with gradient
        ShaderMask(
          shaderCallback: (bounds) => LinearGradient(
            colors: [
              DesignSystem.textPrimary,
              DesignSystem.accentGold,
            ],
          ).createShader(bounds),
          child: Text(
            'ISTO',
            style: DesignSystem.headingMedium.copyWith(
              letterSpacing: 8,
              fontSize: 28,
            ),
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
    );
  }

  Widget _buildMiniCowryIcon() {
    return SizedBox(
      width: 24,
      height: 24,
      child: Stack(
        alignment: Alignment.center,
        children: List.generate(4, (index) {
          final angle = (index * 90) * pi / 180;
          final radius = 8.0;
          return Transform.translate(
            offset: Offset(radius * cos(angle), radius * sin(angle)),
            child: Container(
              width: 6,
              height: 4,
              decoration: BoxDecoration(
                color: DesignSystem.accentGold,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildMainCard(bool isCompact) {
    return GlassContainer(
      borderRadius: DesignSystem.radiusXL,
      borderColor: DesignSystem.accent.withAlpha(30),
      padding: EdgeInsets.all(isCompact ? 20 : 28),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Section title with decoration
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 1,
                  color: DesignSystem.border,
                ),
                const SizedBox(width: 12),
                Text(
                  'NEW GAME',
                  style: DesignSystem.caption.copyWith(
                    color: DesignSystem.textMuted,
                    letterSpacing: 3,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 20,
                  height: 1,
                  color: DesignSystem.border,
                ),
              ],
            ),
            
            SizedBox(height: isCompact ? 20 : 28),
            
            // Player selection
            _buildPlayerSelection(),
            
            SizedBox(height: isCompact ? 20 : 28),
            
            // Board preview
            _buildBoardPreview(),
            
            SizedBox(height: isCompact ? 24 : 32),
            
            // Start button with animation
            Transform.scale(
              scale: _buttonScale.value,
              child: _buildStartButton(),
            ),
            
            const SizedBox(height: 16),
            
            // Cancel link
            _buildCancelLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildPlayerSelection() {
    return Column(
      children: [
        Text(
          'Select Players',
          style: DesignSystem.bodyMedium.copyWith(
            color: DesignSystem.textSecondary,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Player count chips with animation
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildPlayerChip(2),
            const SizedBox(width: 12),
            _buildPlayerChip(3),
            const SizedBox(width: 12),
            _buildPlayerChip(4),
          ],
        ),
      ],
    );
  }

  Widget _buildPlayerChip(int count) {
    final isSelected = _selectedPlayerCount == count;
    final isHovered = _hoveredPlayerCount == count;
    final pulseValue = isSelected ? _pulseAnimation.value : 0.0;
    
    return GestureDetector(
      onTap: () {
        feedbackService.lightTap();
        setState(() => _selectedPlayerCount = count);
      },
      onTapDown: (_) => setState(() => _hoveredPlayerCount = count),
      onTapUp: (_) => setState(() => _hoveredPlayerCount = null),
      onTapCancel: () => setState(() => _hoveredPlayerCount = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          gradient: isSelected
              ? LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    DesignSystem.accent.withAlpha(40 + (pulseValue * 20).toInt()),
                    DesignSystem.accent.withAlpha(20 + (pulseValue * 10).toInt()),
                  ],
                )
              : null,
          color: isSelected ? null : DesignSystem.surface,
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          border: Border.all(
            color: isSelected 
                ? DesignSystem.accent
                : isHovered 
                    ? DesignSystem.accent.withAlpha(100)
                    : DesignSystem.border,
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: DesignSystem.accent.withAlpha((40 + pulseValue * 30).toInt()),
                    blurRadius: 12 + (pulseValue * 8),
                    spreadRadius: pulseValue * 2,
                  ),
                ]
              : null,
        ),
        transform: Matrix4.identity()..scale(isHovered ? 0.95 : 1.0),
        child: Column(
          children: [
            // Player dots with stagger
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(count, (i) {
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 200 + i * 50),
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Container(
                        width: 14,
                        height: 14,
                        margin: EdgeInsets.only(left: i > 0 ? 4 : 0),
                        decoration: BoxDecoration(
                          color: PlayerColors.getColor(i),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withAlpha(isSelected ? 150 : 80),
                            width: 1.5,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: PlayerColors.getColor(i).withAlpha(100),
                                    blurRadius: 6,
                                  ),
                                ]
                              : null,
                        ),
                      ),
                    );
                  },
                );
              }),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              '$count Players',
              style: TextStyle(
                color: isSelected 
                    ? DesignSystem.accent 
                    : DesignSystem.textSecondary,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardPreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.bgDark.withAlpha(150),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(color: DesignSystem.border.withAlpha(80)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.grid_view_rounded,
                size: 14,
                color: DesignSystem.textMuted.withAlpha(150),
              ),
              const SizedBox(width: 6),
              Text(
                'PLAYER POSITIONS',
                style: DesignSystem.caption.copyWith(
                  fontSize: 10,
                  color: DesignSystem.textMuted,
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Mini board with player indicators
          SizedBox(
            width: 140,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Mini board grid
                _buildMiniBoard(),
                
                // Player position indicators
                ..._buildPlayerIndicators(),
              ],
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Layout description
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: DesignSystem.surface.withAlpha(100),
              borderRadius: BorderRadius.circular(DesignSystem.radiusS),
            ),
            child: Text(
              _getLayoutDescription(),
              style: DesignSystem.caption.copyWith(
                fontSize: 11,
                color: DesignSystem.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniBoard() {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: DesignSystem.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: DesignSystem.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(40),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GridView.count(
        crossAxisCount: 5,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(3),
        mainAxisSpacing: 1,
        crossAxisSpacing: 1,
        children: List.generate(25, (i) {
          final row = i ~/ 5;
          final col = i % 5;
          final isCenter = row == 2 && col == 2;
          return Container(
            decoration: BoxDecoration(
              gradient: isCenter
                  ? DesignSystem.goldGradient
                  : null,
              color: isCenter ? null : DesignSystem.bgLight,
              borderRadius: BorderRadius.circular(1),
            ),
          );
        }),
      ),
    );
  }

  List<Widget> _buildPlayerIndicators() {
    final positions = _getPlayerPositions();
    final indicators = <Widget>[];
    
    for (int i = 0; i < _selectedPlayerCount && i < positions.length; i++) {
      indicators.add(
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + i * 100),
          curve: Curves.elasticOut,
          builder: (context, value, child) {
            return Positioned(
              left: positions[i].dx,
              top: positions[i].dy,
              child: Transform.scale(
                scale: value,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: PlayerColors.getColor(i),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: PlayerColors.getColor(i).withAlpha(150),
                        blurRadius: 8,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      'P${i + 1}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      );
    }
    
    return indicators;
  }

  List<Offset> _getPlayerPositions() {
    switch (_selectedPlayerCount) {
      case 2:
        return [
          const Offset(15, 75),
          const Offset(105, 75),
        ];
      case 3:
        return [
          const Offset(15, 75),
          const Offset(105, 75),
          const Offset(60, 0),
        ];
      case 4:
      default:
        return [
          const Offset(15, 75),
          const Offset(105, 75),
          const Offset(15, 0),
          const Offset(105, 0),
        ];
    }
  }

  String _getLayoutDescription() {
    switch (_selectedPlayerCount) {
      case 2:
        return 'Both players on bottom side';
      case 3:
        return '2 on bottom, 1 on top';
      case 4:
        return '2 on bottom, 2 on top';
      default:
        return '';
    }
  }

  Widget _buildStartButton() {
    return GestureDetector(
      onTap: _startGame,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          gradient: DesignSystem.accentGradient,
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          boxShadow: [
            BoxShadow(
              color: DesignSystem.accent.withAlpha(100),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_arrow_rounded,
              color: DesignSystem.bgDark,
              size: 24,
            ),
            const SizedBox(width: 8),
            Text(
              'START GAME',
              style: DesignSystem.button.copyWith(
                color: DesignSystem.bgDark,
                letterSpacing: 2,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCancelLink() {
    return GestureDetector(
      onTap: _close,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.arrow_back_ios_rounded,
              size: 14,
              color: DesignSystem.textMuted,
            ),
            const SizedBox(width: 4),
            Text(
              'Cancel',
              style: DesignSystem.bodyMedium.copyWith(
                color: DesignSystem.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Opacity(
      opacity: _cardController.value.clamp(0.0, 0.6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.touch_app_outlined,
            size: 14,
            color: DesignSystem.textMuted.withAlpha(100),
          ),
          const SizedBox(width: 6),
          Text(
            'Tap to select, then start',
            style: DesignSystem.caption.copyWith(
              color: DesignSystem.textMuted.withAlpha(100),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

/// Glassmorphism container widget
class GlassContainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double borderRadius;
  final Color? borderColor;
  
  const GlassContainer({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius = 16,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: margin,
      constraints: const BoxConstraints(maxWidth: 360),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withAlpha(12),
            Colors.white.withAlpha(5),
          ],
        ),
        border: Border.all(
          color: borderColor ?? Colors.white.withAlpha(20),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(60),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                DesignSystem.surface.withAlpha(220),
                DesignSystem.surface.withAlpha(250),
              ],
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}
