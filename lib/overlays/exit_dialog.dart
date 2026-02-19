import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../theme/isto_tokens.dart';
import '../game/isto_game.dart';

/// Exit confirmation dialog shown when user presses back during gameplay.
/// Three options: Exit Game, Back to Home (menu), Continue.
class ExitDialog extends StatelessWidget {
  final ISTOGame game;

  const ExitDialog({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 32),
          padding: const EdgeInsets.all(24),
          constraints: const BoxConstraints(maxWidth: 340),
          decoration: BoxDecoration(
            color: IstoColorsDark.bgSurface,
            borderRadius: BorderRadius.circular(IstoRadius.lg),
            border: Border.all(
              color: IstoColorsDark.boardLine.withValues(alpha: 0.4),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.5),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.pause_circle_outline,
                color: IstoColorsDark.accentGlow,
                size: 40,
              ),
              const SizedBox(height: 16),
              Text(
                'Game Paused',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: IstoColorsDark.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'What would you like to do?',
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: IstoColorsDark.textMuted,
                ),
              ),
              const SizedBox(height: 24),

              // Continue to Game
              _buildOption(
                label: 'Continue Game',
                icon: Icons.play_arrow_rounded,
                color: IstoColorsDark.success,
                onTap: () => game.overlays.remove('exitDialog'),
              ),
              const SizedBox(height: 10),

              // Back to Home (menu)
              _buildOption(
                label: 'Back to Home',
                icon: Icons.home_outlined,
                color: IstoColorsDark.accentPrimary,
                onTap: () {
                  game.overlays.remove('exitDialog');
                  game.showMenu();
                },
              ),
              const SizedBox(height: 10),

              // Exit Game
              _buildOption(
                label: 'Exit Game',
                icon: Icons.exit_to_app_rounded,
                color: IstoColorsDark.danger,
                onTap: () {
                  SystemNavigator.pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(IstoRadius.sm),
          border: Border.all(
            color: color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 12),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
