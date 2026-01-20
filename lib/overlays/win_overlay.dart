import 'package:flutter/material.dart';

import '../config/design_system.dart';
import '../game/isto_game.dart';
import '../services/feedback_service.dart';

/// Clean, celebratory win overlay
class WinOverlay extends StatefulWidget {
  final ISTOGame game;

  const WinOverlay({super.key, required this.game});

  @override
  State<WinOverlay> createState() => _WinOverlayState();
}

class _WinOverlayState extends State<WinOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _trophyAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.1, 0.6, curve: Curves.elasticOut),
      ),
    );

    _trophyAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.8, curve: Curves.easeOutBack),
      ),
    );

    _controller.forward();
    feedbackService.onWin();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final winner = widget.game.gameManager.winner;
    if (winner == null) return const SizedBox.shrink();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha(220),
                  DesignSystem.bgDark.withAlpha(250),
                ],
              ),
            ),
            child: SafeArea(
              child: Center(
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      child: _buildContent(winner),
    );
  }

  Widget _buildContent(dynamic winner) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(32),
      constraints: const BoxConstraints(maxWidth: 340),
      decoration: BoxDecoration(
        gradient: DesignSystem.cardGradient,
        borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
        border: Border.all(
          color: winner.color.withAlpha(150),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: winner.color.withAlpha(60),
            blurRadius: 40,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Trophy
          AnimatedBuilder(
            animation: _trophyAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _trophyAnimation.value,
                child: child,
              );
            },
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: DesignSystem.goldGradient,
                boxShadow: DesignSystem.glowGold,
              ),
              child: Icon(
                Icons.emoji_events,
                size: 42,
                color: DesignSystem.bgDark,
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Winner announcement
          Text(
            'VICTORY',
            style: DesignSystem.caption.copyWith(
              color: DesignSystem.accentGold,
              letterSpacing: 4,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '${winner.name} Wins!',
            style: DesignSystem.headingMedium.copyWith(
              color: winner.color,
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Rankings
          _buildRankings(),
          
          const SizedBox(height: 32),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: _buildButton(
                  'Play Again',
                  DesignSystem.accent,
                  () {
                    feedbackService.mediumTap();
                    widget.game.startNewGame(widget.game.gameManager.playerCount);
                  },
                  isPrimary: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildButton(
                  'Menu',
                  DesignSystem.textMuted,
                  () {
                    feedbackService.lightTap();
                    widget.game.showMenu();
                  },
                  isPrimary: false,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRankings() {
    final rankings = widget.game.gameManager.rankings;
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.bgDark.withAlpha(150),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
      ),
      child: Column(
        children: [
          for (int i = 0; i < rankings.length; i++)
            Padding(
              padding: EdgeInsets.only(top: i > 0 ? 8 : 0),
              child: Row(
                children: [
                  // Rank
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: i == 0 
                          ? DesignSystem.accentGold.withAlpha(40)
                          : DesignSystem.surface,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          color: i == 0 
                              ? DesignSystem.accentGold 
                              : DesignSystem.textMuted,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Player dot
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: rankings[i].color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  
                  const SizedBox(width: 8),
                  
                  // Player name
                  Expanded(
                    child: Text(
                      rankings[i].name,
                      style: DesignSystem.bodyMedium.copyWith(
                        color: i == 0 
                            ? DesignSystem.textPrimary 
                            : DesignSystem.textSecondary,
                        fontWeight: i == 0 ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildButton(
    String text, 
    Color color, 
    VoidCallback onTap, 
    {bool isPrimary = true}
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: isPrimary ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(DesignSystem.radiusFull),
          border: isPrimary ? null : Border.all(color: DesignSystem.border),
          boxShadow: isPrimary ? DesignSystem.glowAccent : null,
        ),
        child: Center(
          child: Text(
            text,
            style: DesignSystem.button.copyWith(
              color: isPrimary 
                  ? DesignSystem.textPrimary 
                  : DesignSystem.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
