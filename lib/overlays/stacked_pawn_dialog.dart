import 'package:flutter/material.dart';

import '../config/design_system.dart';
import '../game/isto_game.dart';
import '../models/models.dart';
import '../services/feedback_service.dart';

/// Premium dialog for choosing how many stacked pawns to move
/// Features: Entrance animation, glassmorphism, interactive pawn preview
class StackedPawnDialog extends StatefulWidget {
  final ISTOGame game;
  final List<Pawn> stackedPawns;
  final int rollValue;
  final Function(int pawnCount) onChoice;

  const StackedPawnDialog({
    super.key,
    required this.game,
    required this.stackedPawns,
    required this.rollValue,
    required this.onChoice,
  });

  @override
  State<StackedPawnDialog> createState() => _StackedPawnDialogState();
}

class _StackedPawnDialogState extends State<StackedPawnDialog>
    with TickerProviderStateMixin {
  late AnimationController _entranceController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _pulseAnimation;
  
  int? _hoveredOption;

  @override
  void initState() {
    super.initState();
    
    _entranceController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );
    
    _fadeAnimation = CurvedAnimation(
      parent: _entranceController,
      curve: Curves.easeOut,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutBack,
      ),
    );
    
    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _entranceController,
        curve: Curves.easeOutCubic,
      ),
    );
    
    _pulseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );
    
    _entranceController.forward();
    _pulseController.repeat(reverse: true);
    
    // Haptic feedback when dialog appears
    feedbackService.lightTap();
  }

  @override
  void dispose() {
    _entranceController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  void _selectOption(int count) {
    feedbackService.mediumTap();
    
    // Exit animation before callback
    _entranceController.reverse().then((_) {
      widget.onChoice(count);
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([_entranceController, _pulseController]),
      builder: (context, child) {
        return Opacity(
          opacity: _fadeAnimation.value,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withAlpha((180 * _fadeAnimation.value).toInt()),
                  DesignSystem.bgDark.withAlpha((200 * _fadeAnimation.value).toInt()),
                ],
              ),
            ),
            child: Center(
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: child,
                ),
              ),
            ),
          ),
        );
      },
      child: _buildDialogContent(),
    );
  }

  Widget _buildDialogContent() {
    final pawnColor = widget.game.gameManager.players[widget.stackedPawns.first.playerId].color;
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      constraints: const BoxConstraints(maxWidth: 360),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            DesignSystem.surfaceLight,
            DesignSystem.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusXL),
        border: Border.all(
          color: pawnColor.withAlpha(60),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(100),
            blurRadius: 32,
            offset: const Offset(0, 12),
          ),
          BoxShadow(
            color: pawnColor.withAlpha(40),
            blurRadius: 40,
            spreadRadius: -10,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with glow
          _buildHeader(pawnColor),
          
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
            child: Column(
              children: [
                // Pawn preview with animation
                _buildPawnPreview(pawnColor),
                
                const SizedBox(height: 24),
                
                // Roll info
                _buildRollInfo(),
                
                const SizedBox(height: 24),
                
                // Option buttons
                _buildOptionButtons(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(Color pawnColor) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            pawnColor.withAlpha(30),
            Colors.transparent,
          ],
        ),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(22),
        ),
      ),
      child: Column(
        children: [
          // Icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: pawnColor.withAlpha(40),
              border: Border.all(color: pawnColor.withAlpha(100), width: 2),
            ),
            child: Icon(
              Icons.layers_rounded,
              color: pawnColor,
              size: 26,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Title
          Text(
            '${widget.stackedPawns.length} Pawns Stacked',
            style: DesignSystem.headingMedium.copyWith(
              color: DesignSystem.textPrimary,
              fontSize: 20,
            ),
          ),
          
          const SizedBox(height: 4),
          
          Text(
            'Choose how many to move together',
            style: DesignSystem.caption.copyWith(
              color: DesignSystem.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPawnPreview(Color pawnColor) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      decoration: BoxDecoration(
        color: DesignSystem.bgDark.withAlpha(150),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(color: DesignSystem.border.withAlpha(80)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(widget.stackedPawns.length, (index) {
          return TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 300 + index * 100),
            curve: Curves.elasticOut,
            builder: (context, value, child) {
              final pulseValue = _pulseAnimation.value;
              return Transform.translate(
                offset: Offset(0, -2 * pulseValue),
                child: Transform.scale(
                  scale: value * (1.0 + pulseValue * 0.05),
                  child: Container(
                    width: 44,
                    height: 44,
                    margin: EdgeInsets.only(left: index > 0 ? 8 : 0),
                    decoration: BoxDecoration(
                      color: pawnColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withAlpha(180),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: pawnColor.withAlpha((150 + pulseValue * 50).toInt()),
                          blurRadius: 12 + (pulseValue * 4),
                          spreadRadius: pulseValue * 2,
                        ),
                      ],
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  Widget _buildRollInfo() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            DesignSystem.accentGold.withAlpha(20),
            DesignSystem.accentGold.withAlpha(10),
          ],
        ),
        borderRadius: BorderRadius.circular(DesignSystem.radiusS),
        border: Border.all(color: DesignSystem.accentGold.withAlpha(40)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.casino_outlined,
            color: DesignSystem.accentGold,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'You rolled ',
            style: DesignSystem.bodyMedium.copyWith(
              color: DesignSystem.textSecondary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: DesignSystem.accentGold.withAlpha(30),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '${widget.rollValue}',
              style: DesignSystem.headingSmall.copyWith(
                color: DesignSystem.accentGold,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButtons() {
    final pawnCount = widget.stackedPawns.length;
    final validOptions = <int>[1];
    
    for (int count = 2; count <= pawnCount; count++) {
      if (widget.rollValue % count == 0) {
        validOptions.add(count);
      }
    }
    
    return Column(
      children: validOptions.asMap().entries.map((entry) {
        final index = entry.key;
        final count = entry.value;
        final stepsPerPawn = widget.rollValue ~/ count;
        final isAll = count == pawnCount;
        
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: Duration(milliseconds: 300 + index * 100),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: EdgeInsets.only(top: index > 0 ? 12 : 0),
            child: _buildOptionButton(count, stepsPerPawn, isAll),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildOptionButton(int count, int stepsPerPawn, bool isAll) {
    final isHovered = _hoveredOption == count;
    
    String title;
    String subtitle;
    IconData icon;
    
    if (count == 1) {
      title = 'Move 1 Pawn';
      subtitle = '$stepsPerPawn steps';
      icon = Icons.person_outline;
    } else if (isAll) {
      title = 'Move All Pawns';
      subtitle = '$count pawns × $stepsPerPawn steps each';
      icon = Icons.groups_outlined;
    } else {
      title = 'Move $count Pawns';
      subtitle = '$count pawns × $stepsPerPawn steps each';
      icon = Icons.people_outline;
    }
    
    return GestureDetector(
      onTap: () => _selectOption(count),
      onTapDown: (_) => setState(() => _hoveredOption = count),
      onTapUp: (_) => setState(() => _hoveredOption = null),
      onTapCancel: () => setState(() => _hoveredOption = null),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          gradient: isAll
              ? LinearGradient(
                  colors: [
                    DesignSystem.accent.withAlpha(isHovered ? 60 : 40),
                    DesignSystem.accent.withAlpha(isHovered ? 40 : 20),
                  ],
                )
              : null,
          color: isAll ? null : (isHovered ? DesignSystem.surfaceLight : DesignSystem.surface),
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          border: Border.all(
            color: isAll 
                ? DesignSystem.accent
                : (isHovered ? DesignSystem.accent.withAlpha(100) : DesignSystem.border),
            width: isAll ? 2 : 1,
          ),
          boxShadow: isAll
              ? [
                  BoxShadow(
                    color: DesignSystem.accent.withAlpha(40),
                    blurRadius: 12,
                  ),
                ]
              : null,
        ),
        transform: Matrix4.identity()..scale(isHovered ? 0.98 : 1.0),
        child: Row(
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isAll 
                    ? DesignSystem.accent.withAlpha(30) 
                    : DesignSystem.bgLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isAll ? DesignSystem.accent : DesignSystem.textSecondary,
                size: 22,
              ),
            ),
            
            const SizedBox(width: 16),
            
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: DesignSystem.bodyMedium.copyWith(
                      color: isAll ? DesignSystem.accent : DesignSystem.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: DesignSystem.caption.copyWith(
                      color: DesignSystem.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.arrow_forward_ios_rounded,
              color: isAll ? DesignSystem.accent : DesignSystem.textMuted,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}
