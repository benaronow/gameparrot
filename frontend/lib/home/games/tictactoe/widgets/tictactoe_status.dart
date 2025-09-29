import 'package:flutter/material.dart';
import 'package:gameparrot/models/turn_game.dart';
import 'package:gameparrot/theme.dart';

/// Compact status chip to embed in the game header.
class TicTacToeStatusChip extends StatelessWidget {
  final TurnGame game;
  final String? viewerUid;
  const TicTacToeStatusChip({
    super.key,
    required this.game,
    required this.viewerUid,
  });

  @override
  Widget build(BuildContext context) {
    final isTurn = game.currentPlayer == viewerUid && game.winner.isEmpty;
    final waiting = game.currentPlayer != viewerUid && game.winner.isEmpty;
    final finished = game.winner.isNotEmpty;

    late String label;
    late IconData icon;
    Color base;

    if (finished) {
      label = 'Winner: ${game.winner.substring(0, 6)}';
      icon = Icons.emoji_events;
      base = AppTheme.successColor;
    } else if (isTurn) {
      label = 'Your Turn';
      icon = Icons.flash_on;
      base = AppTheme.tertiaryColor;
    } else if (waiting) {
      label = "Opponent's Turn";
      icon = Icons.schedule;
      base = AppTheme.primaryColor;
    } else {
      label = '—';
      icon = Icons.help_outline;
      base = AppTheme.primaryColor;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          colors: [base.withValues(alpha: 0.95), base.withValues(alpha: 0.60)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: base.withValues(alpha: 0.45),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
        border: Border.all(color: Colors.white.withValues(alpha: 0.28), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: Colors.white),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              fontSize: 14,
              letterSpacing: .5,
            ),
          ),
        ],
      ),
    );
  }
}
