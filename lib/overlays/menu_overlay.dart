import 'package:flutter/material.dart';

import '../config/design_system.dart';
import '../config/player_colors.dart';
import '../game/isto_game.dart';
import '../models/game_mode.dart';
import '../components/animated_background.dart';

/// Premium game menu with mode selection, player count, and AI difficulty
class MenuOverlay extends StatefulWidget {
  final ISTOGame game;

  const MenuOverlay({super.key, required this.game});

  @override
  State<MenuOverlay> createState() => _MenuOverlayState();
}

class _MenuOverlayState extends State<MenuOverlay>
    with TickerProviderStateMixin {
  GameMode _selectedMode = GameMode.localMultiplayer;
  int _playerCount = 2;
  AIDifficulty _aiDifficulty = AIDifficulty.medium;

  late AnimationController _entranceCtrl;
  late Animation<double> _fadeIn;
  late Animation<Offset> _slideUp;

  @override
  void initState() {
    super.initState();
    _entranceCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeIn = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut),
    );
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic));
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  void _startGame() {
    GameConfig config;
    if (_selectedMode == GameMode.vsAI) {
      config = GameConfig.vsAI(
        playerCount: _playerCount,
        difficulty: _aiDifficulty,
      );
    } else {
      config = GameConfig.local(_playerCount);
    }
    widget.game.startNewGame(_playerCount, config: config);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBackground(
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeIn,
          child: SlideTransition(
            position: _slideUp,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 40),
                    // Title
                    _buildTitle(),
                    const SizedBox(height: 48),
                    // Game Mode Selection
                    _buildModeSelection(),
                    const SizedBox(height: 28),
                    // Player Count
                    _buildPlayerCount(),
                    const SizedBox(height: 28),
                    // AI Difficulty (only for vs AI mode)
                    if (_selectedMode == GameMode.vsAI) ...[
                      _buildAIDifficulty(),
                      const SizedBox(height: 28),
                    ],
                    // Board Preview
                    _buildBoardPreview(),
                    const SizedBox(height: 36),
                    // Start Button
                    _buildStartButton(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      children: [
        // Game logo
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: DesignSystem.goldGradient,
            boxShadow: [
              BoxShadow(
                color: DesignSystem.accent.withValues(alpha: 0.4),
                blurRadius: 24,
                spreadRadius: 4,
              ),
            ],
          ),
          child: const Center(
            child: Text(
              'I',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: Color(0xFF1A0E04),
                fontFamily: 'Inter',
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Text(
          'ISTO',
          style: DesignSystem.displayLarge.copyWith(letterSpacing: 8),
        ),
        const SizedBox(height: 4),
        Text(
          'Chowka Bhara',
          style: DesignSystem.bodyMedium.copyWith(
            color: DesignSystem.accent.withValues(alpha: 0.7),
            letterSpacing: 3,
            fontSize: 13,
          ),
        ),
      ],
    );
  }

  Widget _buildModeSelection() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GAME MODE',
            style: DesignSystem.caption.copyWith(
              color: DesignSystem.accent,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _ModeButton(
                  icon: Icons.people_outline,
                  label: 'Local',
                  subtitle: 'Pass & Play',
                  isSelected: _selectedMode == GameMode.localMultiplayer,
                  onTap: () => setState(() {
                    _selectedMode = GameMode.localMultiplayer;
                  }),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ModeButton(
                  icon: Icons.smart_toy_outlined,
                  label: 'vs AI',
                  subtitle: 'Play Robot',
                  isSelected: _selectedMode == GameMode.vsAI,
                  onTap: () => setState(() {
                    _selectedMode = GameMode.vsAI;
                  }),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCount() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PLAYERS',
            style: DesignSystem.caption.copyWith(
              color: DesignSystem.accent,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [2, 3, 4].map((count) {
              final isSelected = _playerCount == count;
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _playerCount = count),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? DesignSystem.accent.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? DesignSystem.accent.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.06),
                        width: isSelected ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      children: [
                        Text(
                          '$count',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: isSelected
                                ? DesignSystem.accent
                                : DesignSystem.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Player color dots
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(count, (i) {
                            return Container(
                              width: 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 2),
                              decoration: BoxDecoration(
                                color: PlayerColors.getColor(i),
                                shape: BoxShape.circle,
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildAIDifficulty() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI DIFFICULTY',
            style: DesignSystem.caption.copyWith(
              color: DesignSystem.accent,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: AIDifficulty.values.map((diff) {
              final isSelected = _aiDifficulty == diff;
              final label = switch (diff) {
                AIDifficulty.easy => 'Easy',
                AIDifficulty.medium => 'Medium',
                AIDifficulty.hard => 'Hard',
              };
              final icon = switch (diff) {
                AIDifficulty.easy => Icons.sentiment_satisfied,
                AIDifficulty.medium => Icons.psychology,
                AIDifficulty.hard => Icons.bolt,
              };
              return Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _aiDifficulty = diff),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? DesignSystem.accent.withValues(alpha: 0.15)
                          : Colors.white.withValues(alpha: 0.03),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? DesignSystem.accent.withValues(alpha: 0.5)
                            : Colors.white.withValues(alpha: 0.06),
                      ),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          icon,
                          size: 22,
                          color: isSelected
                              ? DesignSystem.accent
                              : DesignSystem.textMuted,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight:
                                isSelected ? FontWeight.w700 : FontWeight.w400,
                            color: isSelected
                                ? DesignSystem.accent
                                : DesignSystem.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildBoardPreview() {
    return SizedBox(
      height: 80,
      child: CustomPaint(
        painter: _MiniBoardPreview(
          playerCount: _playerCount,
        ),
        size: const Size(80, 80),
      ),
    );
  }

  Widget _buildStartButton() {
    return PremiumButton(
      label: _selectedMode == GameMode.vsAI ? 'PLAY VS AI' : 'START GAME',
      icon: Icons.play_arrow_rounded,
      onTap: _startGame,
      width: 220,
    );
  }
}

class _ModeButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeButton({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? DesignSystem.accent.withValues(alpha: 0.12)
              : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected
                ? DesignSystem.accent.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.06),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected ? DesignSystem.accent : DesignSystem.textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? DesignSystem.textPrimary
                    : DesignSystem.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: isSelected
                    ? DesignSystem.accent.withValues(alpha: 0.7)
                    : DesignSystem.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniBoardPreview extends CustomPainter {
  final int playerCount;

  _MiniBoardPreview({required this.playerCount});

  @override
  void paint(Canvas canvas, Size size) {
    final squareSize = size.width / 7;
    final offset = (size.width - squareSize * 5) / 2;

    // Draw 5x5 grid
    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 5; c++) {
        final x = offset + c * squareSize;
        final y = r * squareSize;
        final rect = Rect.fromLTWH(x, y, squareSize - 1, squareSize - 1);

        Color color;
        if (r == 2 && c == 2) {
          color = const Color(0xFFFFD700).withValues(alpha: 0.6);
        } else {
          color = const Color(0xFF2A1A08).withValues(alpha: 0.8);
        }

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          Paint()..color = color,
        );
      }
    }

    // Draw player position dots
    final positions = [
      [4, 2], // P0 bottom
      [0, 2], // P1 top
      [2, 0], // P2 left
      [2, 4], // P3 right
    ];

    for (int i = 0; i < playerCount; i++) {
      final pos = positions[i];
      final x = offset + pos[1] * squareSize + squareSize / 2;
      final y = pos[0] * squareSize + squareSize / 2;
      canvas.drawCircle(
        Offset(x, y),
        squareSize * 0.3,
        Paint()..color = PlayerColors.getColor(i),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniBoardPreview oldDelegate) =>
      oldDelegate.playerCount != playerCount;
}
