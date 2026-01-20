import 'package:flutter/material.dart';

import '../config/design_system.dart';
import '../config/player_colors.dart';
import '../game/isto_game.dart';
import '../services/feedback_service.dart';

/// Clean, minimal, elegant menu overlay for ISTO game
class MenuOverlay extends StatefulWidget {
  final ISTOGame game;

  const MenuOverlay({super.key, required this.game});

  @override
  State<MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<MenuOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;
  
  int _selectedPlayerCount = 2;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _startGame() {
    feedbackService.mediumTap();
    widget.game.startNewGame(_selectedPlayerCount);
  }

  void _close() {
    feedbackService.lightTap();
    _controller.reverse().then((_) {
      widget.game.overlays.remove(ISTOGame.menuOverlay);
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isCompact = screenSize.height < 700;
    
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
                  DesignSystem.bgDark.withAlpha(250),
                  DesignSystem.bgMedium.withAlpha(250),
                ],
              ),
            ),
            child: SafeArea(
              child: Transform.translate(
                offset: Offset(0, _slideAnimation.value),
                child: child,
              ),
            ),
          ),
        );
      },
      child: _buildContent(isCompact),
    );
  }

  Widget _buildContent(bool isCompact) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 24,
        vertical: isCompact ? 16 : 32,
      ),
      child: Column(
        children: [
          // Header
          _buildHeader(),
          
          SizedBox(height: isCompact ? 24 : 40),
          
          // Main card
          Expanded(
            child: _buildMainCard(isCompact),
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
        // Logo mark
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: DesignSystem.goldGradient,
            boxShadow: DesignSystem.glowGold,
          ),
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: DesignSystem.bgDark.withAlpha(180),
              ),
              child: const Center(
                child: Text(
                  'इ',  // Sanskrit/Hindi stylized letter
                  style: TextStyle(
                    color: Color(0xFFD4AF37),
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Title
        Text(
          'ISTO',
          style: DesignSystem.headingMedium.copyWith(
            letterSpacing: 8,
            color: DesignSystem.textPrimary,
          ),
        ),
        
        const SizedBox(height: 4),
        
        Text(
          'Chowka Bhara',
          style: DesignSystem.caption.copyWith(
            color: DesignSystem.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _buildMainCard(bool isCompact) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      decoration: DesignSystem.cardDecoration,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(isCompact ? 20 : 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Section title
            Text(
              'NEW GAME',
              style: DesignSystem.caption.copyWith(
                color: DesignSystem.textMuted,
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Player selection
            _buildPlayerSelection(),
            
            SizedBox(height: isCompact ? 20 : 32),
            
            // Board preview
            _buildBoardPreview(_selectedPlayerCount),
            
            SizedBox(height: isCompact ? 24 : 32),
            
            // Start button
            _buildStartButton(),
            
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
        
        // Player count chips
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
    
    return GestureDetector(
      onTap: () {
        feedbackService.lightTap();
        setState(() => _selectedPlayerCount = count);
      },
      child: AnimatedContainer(
        duration: DesignSystem.animFast,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected 
              ? DesignSystem.accent.withAlpha(30)
              : DesignSystem.surface,
          borderRadius: BorderRadius.circular(DesignSystem.radiusM),
          border: Border.all(
            color: isSelected 
                ? DesignSystem.accent
                : DesignSystem.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            // Player dots
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(count, (i) {
                return Container(
                  width: 12,
                  height: 12,
                  margin: EdgeInsets.only(left: i > 0 ? 4 : 0),
                  decoration: BoxDecoration(
                    color: PlayerColors.getColor(i),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withAlpha(80),
                      width: 1,
                    ),
                  ),
                );
              }),
            ),
            
            const SizedBox(height: 6),
            
            Text(
              '$count',
              style: TextStyle(
                color: isSelected 
                    ? DesignSystem.accent 
                    : DesignSystem.textSecondary,
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBoardPreview(int playerCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: DesignSystem.bgDark.withAlpha(150),
        borderRadius: BorderRadius.circular(DesignSystem.radiusM),
        border: Border.all(color: DesignSystem.border.withAlpha(100)),
      ),
      child: Column(
        children: [
          Text(
            'PLAYER POSITIONS',
            style: DesignSystem.caption.copyWith(
              fontSize: 10,
              color: DesignSystem.textMuted,
            ),
          ),
          
          const SizedBox(height: 12),
          
          // Visual preview
          SizedBox(
            width: 140,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Mini board
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: DesignSystem.surface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: DesignSystem.border),
                  ),
                  child: GridView.count(
                    crossAxisCount: 5,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(2),
                    mainAxisSpacing: 1,
                    crossAxisSpacing: 1,
                    children: List.generate(25, (i) {
                      final row = i ~/ 5;
                      final col = i % 5;
                      final isCenter = row == 2 && col == 2;
                      return Container(
                        decoration: BoxDecoration(
                          color: isCenter 
                              ? DesignSystem.accentGold.withAlpha(150)
                              : DesignSystem.bgLight,
                          borderRadius: BorderRadius.circular(1),
                        ),
                      );
                    }),
                  ),
                ),
                
                // Player indicators
                ..._buildPlayerIndicators(playerCount),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Layout description
          Text(
            _getLayoutDescription(playerCount),
            style: DesignSystem.caption.copyWith(
              fontSize: 10,
              color: DesignSystem.textMuted.withAlpha(180),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildPlayerIndicators(int playerCount) {
    final indicators = <Widget>[];
    
    // 2 players: both on bottom
    // 3 players: 2 bottom + 1 top center
    // 4 players: 2 bottom + 2 top
    final positions = _getPlayerPositions(playerCount);
    
    for (int i = 0; i < playerCount && i < positions.length; i++) {
      indicators.add(
        Positioned(
          left: positions[i].dx,
          top: positions[i].dy,
          child: Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              color: PlayerColors.getColor(i),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: PlayerColors.getColor(i).withAlpha(100),
                  blurRadius: 6,
                ),
              ],
            ),
            child: Center(
              child: Text(
                'P${i + 1}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 7,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      );
    }
    
    return indicators;
  }

  List<Offset> _getPlayerPositions(int playerCount) {
    switch (playerCount) {
      case 2:
        return [
          const Offset(15, 75),   // P1 - Bottom Left
          const Offset(105, 75),  // P2 - Bottom Right
        ];
      case 3:
        return [
          const Offset(15, 75),   // P1 - Bottom Left
          const Offset(105, 75),  // P2 - Bottom Right
          const Offset(60, 5),    // P3 - Top Center
        ];
      case 4:
      default:
        return [
          const Offset(15, 75),   // P1 - Bottom Left
          const Offset(105, 75),  // P2 - Bottom Right
          const Offset(15, 5),    // P3 - Top Left
          const Offset(105, 5),   // P4 - Top Right
        ];
    }
  }

  String _getLayoutDescription(int playerCount) {
    switch (playerCount) {
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
    return SizedBox(
      width: double.infinity,
      child: GestureDetector(
        onTap: _startGame,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: DesignSystem.accentButtonDecoration,
          child: Center(
            child: Text(
              'START GAME',
              style: DesignSystem.button.copyWith(
                letterSpacing: 2,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCancelLink() {
    return GestureDetector(
      onTap: _close,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Text(
          'Cancel',
          style: DesignSystem.bodyMedium.copyWith(
            color: DesignSystem.textMuted,
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.info_outline,
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
    );
  }
}
