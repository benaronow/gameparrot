import 'package:flutter/material.dart';
import 'package:gameparrot/models/turn_game.dart';

class CurrentGamesList extends StatelessWidget {
  final List<TurnGame> games;
  final ValueChanged<String> onOpenGame;

  const CurrentGamesList({
    super.key,
    required this.games,
    required this.onOpenGame,
  });

  @override
  Widget build(BuildContext context) {
    if (games.isEmpty) {
      return const Text(
        'No active games yet.',
        style: TextStyle(color: Colors.grey),
      );
    }
    return Expanded(
      child: ListView.separated(
        itemCount: games.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (ctx, i) {
          final g = games[i];
          return ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.grid_3x3, color: Colors.white70),
            title: Text(
              'Game ${g.gameId.substring(0, 6)}',
              style: const TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'Type: ${g.gameType.name}  Turns: ${g.turns.length}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => onOpenGame(g.gameId),
          );
        },
      ),
    );
  }
}
