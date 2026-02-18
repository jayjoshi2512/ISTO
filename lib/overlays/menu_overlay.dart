import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/design_system.dart';
import '../config/player_colors.dart';
import '../game/isto_game.dart';
import '../models/game_mode.dart';
import '../theme/isto_tokens.dart';
import '../components/animated_background.dart';
import 'how_to_play_overlay.dart';

/// Home / Menu screen — clean vertical stack, board-centric.
/// Terracotta Dusk palette, GoogleFonts Poppins + Lora.
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
    _fadeIn = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOut));
    _slideUp = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _entranceCtrl, curve: Curves.easeOutCubic),
    );
    _entranceCtrl.forward();
  }

  @override
  void dispose() {
    _entranceCtrl.dispose();
    super.dispose();
  }

  // ── Business logic untouched ──
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
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 44),
                    _buildTitle(),
                    const SizedBox(height: 36),
                    // Mini board preview at 45° tilt
                    _buildBoardPreview(),
                    const SizedBox(height: 36),
                    _buildModeSelection(),
                    const SizedBox(height: 20),
                    _buildPlayerCount(),
                    const SizedBox(height: 20),
                    if (_selectedMode == GameMode.vsAI) ...[
                      _buildAIDifficulty(),
                      const SizedBox(height: 20),
                    ],
                    const SizedBox(height: 8),
                    _buildStartButton(),
                    const SizedBox(height: 16),
                    _buildHowToPlay(),
                    const SizedBox(height: 36),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Title block ──
  Widget _buildTitle() {
    return Column(
      children: [
        Text(
          'ISTO',
          style: GoogleFonts.lora(textStyle: IstoTypography.appTitle),
        ),
        const SizedBox(height: 4),
        Text(
          'Chowka Bara',
          style: GoogleFonts.poppins(textStyle: IstoTypography.subtitle),
        ),
      ],
    );
  }

  // ── Mode selection ──
  Widget _buildModeSelection() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GAME MODE',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: IstoColorsDark.accentPrimary,
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
                  onTap:
                      () => setState(() {
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
                  onTap:
                      () => setState(() {
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

  // ── Player count selector ──
  Widget _buildPlayerCount() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'PLAYERS',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: IstoColorsDark.accentPrimary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children:
                [2, 3, 4].map((count) {
                  final isSelected = _playerCount == count;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _playerCount = count),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        decoration: BoxDecoration(
                          color:
                              isSelected
                                  ? IstoColorsDark.accentPrimary.withValues(
                                    alpha: 0.15,
                                  )
                                  : Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(IstoRadius.md),
                          border: Border.all(
                            color:
                                isSelected
                                    ? IstoColorsDark.accentPrimary.withValues(
                                      alpha: 0.5,
                                    )
                                    : Colors.white.withValues(alpha: 0.06),
                            width: isSelected ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            Text(
                              '$count',
                              style: GoogleFonts.poppins(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color:
                                    isSelected
                                        ? IstoColorsDark.accentPrimary
                                        : IstoColorsDark.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(count, (i) {
                                return Container(
                                  width: 8,
                                  height: 8,
                                  margin: const EdgeInsets.symmetric(
                                    horizontal: 2,
                                  ),
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

  // ── AI difficulty ──
  Widget _buildAIDifficulty() {
    return GlassContainer(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI DIFFICULTY',
            style: GoogleFonts.poppins(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: IstoColorsDark.accentPrimary,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children:
                AIDifficulty.values.map((diff) {
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
                          color:
                              isSelected
                                  ? IstoColorsDark.accentPrimary.withValues(
                                    alpha: 0.15,
                                  )
                                  : Colors.white.withValues(alpha: 0.03),
                          borderRadius: BorderRadius.circular(IstoRadius.md),
                          border: Border.all(
                            color:
                                isSelected
                                    ? IstoColorsDark.accentPrimary.withValues(
                                      alpha: 0.5,
                                    )
                                    : Colors.white.withValues(alpha: 0.06),
                          ),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              icon,
                              size: 22,
                              color:
                                  isSelected
                                      ? IstoColorsDark.accentPrimary
                                      : IstoColorsDark.textMuted,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              label,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                fontWeight:
                                    isSelected
                                        ? FontWeight.w700
                                        : FontWeight.w400,
                                color:
                                    isSelected
                                        ? IstoColorsDark.accentPrimary
                                        : IstoColorsDark.textSecondary,
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

  // ── Board preview with 45° decorative tilt ──
  Widget _buildBoardPreview() {
    return Transform(
      alignment: Alignment.center,
      transform:
          Matrix4.identity()
            ..setEntry(3, 2, 0.001) // perspective
            ..rotateX(0.18)
            ..rotateZ(-0.05),
      child: SizedBox(
        height: 100,
        child: CustomPaint(
          painter: _MiniBoardPreview(playerCount: _playerCount),
          size: const Size(100, 100),
        ),
      ),
    );
  }

  // ── Start button ──
  Widget _buildStartButton() {
    return PremiumButton(
      label: _selectedMode == GameMode.vsAI ? 'PLAY VS AI' : 'PLAY',
      icon: Icons.play_arrow_rounded,
      onTap: _startGame,
      width: 200,
    );
  }

  // ── How to Play link ──
  Widget _buildHowToPlay() {
    return GestureDetector(
      onTap: () {
        showDialog(
          context: context,
          barrierColor: Colors.transparent,
          builder:
              (_) =>
                  HowToPlayOverlay(onClose: () => Navigator.of(context).pop()),
        );
      },
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_rounded,
            size: 16,
            color: IstoColorsDark.accentPrimary.withValues(alpha: 0.7),
          ),
          const SizedBox(width: 6),
          Text(
            'How to Play',
            style: GoogleFonts.poppins(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: IstoColorsDark.accentPrimary.withValues(alpha: 0.7),
              decoration: TextDecoration.underline,
              decorationColor: IstoColorsDark.accentPrimary.withValues(
                alpha: 0.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Mode button (Local / vs AI) ──
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
          color:
              isSelected
                  ? IstoColorsDark.accentPrimary.withValues(alpha: 0.12)
                  : Colors.white.withValues(alpha: 0.03),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color:
                isSelected
                    ? IstoColorsDark.accentPrimary.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.06),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color:
                  isSelected
                      ? IstoColorsDark.accentPrimary
                      : IstoColorsDark.textMuted,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color:
                    isSelected
                        ? IstoColorsDark.textPrimary
                        : IstoColorsDark.textSecondary,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color:
                    isSelected
                        ? IstoColorsDark.accentPrimary.withValues(alpha: 0.7)
                        : IstoColorsDark.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Mini board for the menu ──
class _MiniBoardPreview extends CustomPainter {
  final int playerCount;

  _MiniBoardPreview({required this.playerCount});

  @override
  void paint(Canvas canvas, Size size) {
    final squareSize = size.width / 5.5;
    final offset = (size.width - squareSize * 5) / 2;

    for (int r = 0; r < 5; r++) {
      for (int c = 0; c < 5; c++) {
        final x = offset + c * squareSize;
        final y = r * squareSize;
        final rect = Rect.fromLTWH(x, y, squareSize - 1, squareSize - 1);

        Color color;
        if (r == 2 && c == 2) {
          color = IstoColorsDark.accentGlow.withValues(alpha: 0.55);
        } else if ((r + c) % 2 == 0) {
          color = IstoColorsDark.boardCell.withValues(alpha: 0.85);
        } else {
          color = IstoColorsDark.boardCellAlt.withValues(alpha: 0.85);
        }

        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, const Radius.circular(2)),
          Paint()..color = color,
        );
      }
    }

    // Grid lines
    final linePaint =
        Paint()
          ..color = IstoColorsDark.boardLine.withValues(alpha: 0.4)
          ..strokeWidth = 0.5;
    for (int i = 0; i <= 5; i++) {
      final p = offset + i * squareSize;
      canvas.drawLine(Offset(p, 0), Offset(p, 5 * squareSize), linePaint);
      canvas.drawLine(
        Offset(offset, i * squareSize),
        Offset(offset + 5 * squareSize, i * squareSize),
        linePaint,
      );
    }

    // Player position dots — match startPositions per player count
    // 2p: bottom+top, 3p: bottom+top+left, 4p: all sides
    final positions = [
      [4, 2], // P0: Bottom
      [0, 2], // P1: Top
      [2, 0], // P2: Left
      [2, 4], // P3: Right
    ];
    for (int i = 0; i < playerCount; i++) {
      final pos = positions[i];
      final x = offset + pos[1] * squareSize + squareSize / 2;
      final y = pos[0] * squareSize + squareSize / 2;
      canvas.drawCircle(
        Offset(x, y),
        squareSize * 0.28,
        Paint()..color = PlayerColors.getColor(i),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _MiniBoardPreview oldDelegate) =>
      oldDelegate.playerCount != playerCount;
}
