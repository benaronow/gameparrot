import 'package:flutter/material.dart';
import 'package:gameparrot/models/turn_game.dart';
import 'package:gameparrot/theme.dart';

class StartGameSheet extends StatelessWidget {
  final GameType selected;
  final bool starting;
  final ValueChanged<GameType> onSelect;
  final VoidCallback onConfirm;

  const StartGameSheet({
    super.key,
    required this.selected,
    required this.starting,
    required this.onSelect,
    required this.onConfirm,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Start New Game',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children: GameType.values.map((gt) {
              final isSelected = gt == selected;
              return ChoiceChip(
                label: Text(gt.name),
                selected: isSelected,
                onSelected: (_) => onSelect(gt),
              );
            }).toList(),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              icon: starting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.play_arrow),
              label: Text(starting ? 'Starting...' : 'Start Game'),
              onPressed: starting ? null : onConfirm,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
