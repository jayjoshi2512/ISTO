import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/design_system.dart';
import '../game/isto_game.dart';
import '../services/feedback_service.dart';
import '../theme/isto_tokens.dart';

/// Settings overlay — glass card with toggles and actions.
/// Terracotta Dusk palette, GoogleFonts Poppins.
class SettingsOverlay extends StatefulWidget {
  final ISTOGame game;

  const SettingsOverlay({super.key, required this.game});

  @override
  State<SettingsOverlay> createState() => _SettingsOverlayState();
}

class _SettingsOverlayState extends State<SettingsOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _close() {
    _ctrl.reverse().then((_) {
      if (mounted) {
        widget.game.overlays.remove('settings');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Dark backdrop
          GestureDetector(
            onTap: _close,
            child: FadeTransition(
              opacity: _fade,
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
            ),
          ),

          // Settings panel
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 32),
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        IstoColorsDark.bgElevated.withValues(alpha: 0.96),
                        IstoColorsDark.bgSurface.withValues(alpha: 0.96),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(IstoRadius.lg),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.1),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        blurRadius: 24,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Settings',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w700,
                              color: IstoColorsDark.textPrimary,
                            ),
                          ),
                          GestureDetector(
                            onTap: _close,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.06),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                Icons.close_rounded,
                                color: IstoColorsDark.textMuted,
                                size: 20,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      const MinimalDivider(),
                      const SizedBox(height: 16),

                      // Sound toggle
                      _SettingsTile(
                        icon:
                            feedbackService.soundEnabled
                                ? Icons.volume_up_rounded
                                : Icons.volume_off_rounded,
                        label: 'Sound Effects',
                        value: feedbackService.soundEnabled,
                        onChanged: (v) {
                          setState(() {
                            feedbackService.setSoundEnabled(v);
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      // Haptics toggle
                      _SettingsTile(
                        icon:
                            feedbackService.hapticsEnabled
                                ? Icons.vibration
                                : Icons.do_not_disturb_on_rounded,
                        label: 'Haptic Feedback',
                        value: feedbackService.hapticsEnabled,
                        onChanged: (v) {
                          setState(() {
                            feedbackService.setHapticsEnabled(v);
                          });
                        },
                      ),

                      const SizedBox(height: 24),
                      const MinimalDivider(),
                      const SizedBox(height: 16),

                      // How to Play
                      _ActionTile(
                        icon: Icons.menu_book_rounded,
                        label: 'How to Play',
                        color: IstoColorsDark.accentPrimary,
                        onTap: () {
                          widget.game.overlays.add('howToPlay');
                        },
                      ),
                      const SizedBox(height: 10),

                      // Game actions
                      _ActionTile(
                        icon: Icons.restart_alt_rounded,
                        label: 'Restart Game',
                        color: IstoColorsDark.accentWarm,
                        onTap: () {
                          _close();
                          widget.game.gameManager.reset();
                        },
                      ),
                      const SizedBox(height: 10),
                      _ActionTile(
                        icon: Icons.home_rounded,
                        label: 'Back to Menu',
                        color: IstoColorsDark.textSecondary,
                        onTap: () {
                          _close();
                          widget.game.overlays.remove(
                            ISTOGame.turnIndicatorOverlay,
                          );
                          widget.game.showMenu();
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(IstoRadius.md),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Icon(icon, color: IstoColorsDark.textSecondary, size: 22),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: IstoColorsDark.textPrimary,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 46,
              height: 26,
              decoration: BoxDecoration(
                color:
                    value
                        ? IstoColorsDark.accentPrimary.withValues(alpha: 0.3)
                        : IstoColorsDark.bgSurface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(
                  color:
                      value
                          ? IstoColorsDark.accentPrimary.withValues(alpha: 0.5)
                          : IstoColorsDark.textMuted.withValues(alpha: 0.3),
                ),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 20,
                  height: 20,
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  decoration: BoxDecoration(
                    color:
                        value
                            ? IstoColorsDark.accentPrimary
                            : IstoColorsDark.textMuted,
                    shape: BoxShape.circle,
                    boxShadow:
                        value
                            ? [
                              BoxShadow(
                                color: IstoColorsDark.accentPrimary.withValues(
                                  alpha: 0.4,
                                ),
                                blurRadius: 6,
                              ),
                            ]
                            : null,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(IstoRadius.md),
          border: Border.all(color: color.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(width: 14),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            const Spacer(),
            Icon(Icons.chevron_right_rounded, color: color, size: 20),
          ],
        ),
      ),
    );
  }
}
