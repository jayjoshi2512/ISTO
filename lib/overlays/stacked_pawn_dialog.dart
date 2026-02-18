import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../config/design_system.dart';
import '../config/theme_config.dart';
import '../game/isto_game.dart';
import '../models/models.dart';
import '../theme/isto_tokens.dart';

/// Dialog for choosing how many stacked pawns to move together.
/// Slate & Persimmon palette, GoogleFonts Poppins.
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
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fade;
  late Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _scale = Tween<double>(
      begin: 0.85,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  List<int> get _validCounts {
    final roll = widget.rollValue;
    final stackCount = widget.stackedPawns.length;
    final counts = <int>[];

    // Can always move 1
    counts.add(1);

    // Check divisors of roll value that we have enough pawns for
    for (int i = 2; i <= stackCount; i++) {
      if (roll % i == 0) {
        counts.add(i);
      }
    }

    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final counts = _validCounts;
    final playerId =
        widget.stackedPawns.isNotEmpty ? widget.stackedPawns.first.playerId : 0;
    final playerColor = ThemeConfig.getPlayerColor(playerId);

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          // Backdrop
          GestureDetector(
            onTap: () {}, // block taps
            child: FadeTransition(
              opacity: _fade,
              child: Container(color: Colors.black.withValues(alpha: 0.5)),
            ),
          ),

          // Dialog
          Center(
            child: FadeTransition(
              opacity: _fade,
              child: ScaleTransition(
                scale: _scale,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 40),
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
                      color: playerColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.35),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_alt_rounded,
                            color: playerColor,
                            size: 24,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Stacked Pawns',
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: IstoColorsDark.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      Text(
                        '${widget.stackedPawns.length} pawns on this square\nRoll: ${widget.rollValue}',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: IstoColorsDark.textSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      const SizedBox(height: 20),
                      const MinimalDivider(),
                      const SizedBox(height: 16),

                      Text(
                        'How many pawns to move?',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: IstoColorsDark.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Choice buttons
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: WrapAlignment.center,
                        children:
                            counts.map((count) {
                              final stepsEach = widget.rollValue ~/ count;
                              return GestureDetector(
                                onTap: () => widget.onChoice(count),
                                child: Container(
                                  width: 90,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        playerColor.withValues(alpha: 0.15),
                                        playerColor.withValues(alpha: 0.08),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      IstoRadius.md,
                                    ),
                                    border: Border.all(
                                      color: playerColor.withValues(alpha: 0.3),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      // Pawn dots
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: List.generate(count, (_) {
                                          return Container(
                                            width: 10,
                                            height: 10,
                                            margin: const EdgeInsets.symmetric(
                                              horizontal: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: playerColor,
                                              shape: BoxShape.circle,
                                              boxShadow: [
                                                BoxShadow(
                                                  color: playerColor.withValues(
                                                    alpha: 0.5,
                                                  ),
                                                  blurRadius: 4,
                                                ),
                                              ],
                                            ),
                                          );
                                        }),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        '$count pawn${count > 1 ? 's' : ''}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: IstoColorsDark.textPrimary,
                                        ),
                                      ),
                                      Text(
                                        '$stepsEach step${stepsEach > 1 ? 's' : ''} each',
                                        style: GoogleFonts.poppins(
                                          fontSize: 10,
                                          color: IstoColorsDark.textMuted,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
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
