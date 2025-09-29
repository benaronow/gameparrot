import 'dart:convert';

import 'package:gameparrot/config.dart';
import 'package:gameparrot/models/turn_game.dart';
import 'package:http/http.dart' as http;

class TurnGameService {
  static Future<List<TurnGame>> getGames(String uid, String fid) async {
    final uri = Uri.parse('${Config.httpUrl}/games?uid=$uid&fid=$fid');

    final gamesResponse = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    final decoded = jsonDecode(gamesResponse.body);
    return (decoded['games'] as List)
        .map((game) => TurnGame.fromJson(game))
        .toList();
  }

  static void handleStartGame(
    List<TurnGame>? games,
    TurnGame turnGame,
    Function(List<TurnGame>) updateGames,
  ) {
    final List<TurnGame> newGames =
        games!.any((g) => g.gameId == turnGame.gameId)
        ? games
        : [...games, turnGame];
    updateGames(newGames);
  }

  static void handleGameTurn(
    List<TurnGame>? games,
    TurnGame turnGame,
    Function(List<TurnGame>) updateGames,
  ) {
    final List<TurnGame> newGames = games!.map((g) {
      if (g.gameId == turnGame.gameId) {
        return turnGame;
      } else {
        return g;
      }
    }).toList();
    updateGames(newGames);
  }

  static TurnGame createNewTurnGame(
    String gameId,
    GameType gameType,
    String to,
  ) {
    return TurnGame(
      gameId: gameId,
      gameType: gameType,
      turns: [],
      currentPlayer: to,
      winner: '',
    );
  }

  static TurnGame updateExistingTurnGame(
    TurnGame currentGame,
    String turnInfo,
    String from,
    String to,
  ) {
    final updatedTurns = [
      ...currentGame.turns,
      Turn(player: from, turnInfo: turnInfo),
    ];

    String winner = currentGame.winner;

    if (winner.isEmpty && currentGame.gameType == GameType.ticTacToe) {
      // Build board mapping player -> set of coords
      final Map<String, Set<String>> playerMoves = {};
      for (final t in updatedTurns) {
        playerMoves.putIfAbsent(t.player, () => <String>{}).add(t.turnInfo);
      }
      // All winning lines in our coordinate system (columns a-c, rows 1-3)
      const winningLines = [
        // Rows
        ['ax1', 'bx1', 'cx1'],
        ['ax2', 'bx2', 'cx2'],
        ['ax3', 'bx3', 'cx3'],
        // Columns
        ['ax1', 'ax2', 'ax3'],
        ['bx1', 'bx2', 'bx3'],
        ['cx1', 'cx2', 'cx3'],
        // Diagonals
        ['ax1', 'bx2', 'cx3'],
        ['cx1', 'bx2', 'ax3'],
      ];
      for (final entry in playerMoves.entries) {
        for (final line in winningLines) {
          if (line.every(entry.value.contains)) {
            winner = entry.key;
            break;
          }
        }
        if (winner.isNotEmpty) break;
      }
    }

    // If winner determined, do not change currentPlayer anymore.
    final nextPlayer = winner.isNotEmpty ? currentGame.currentPlayer : to;

    return TurnGame(
      gameId: currentGame.gameId,
      gameType: currentGame.gameType,
      turns: updatedTurns,
      currentPlayer: nextPlayer,
      winner: winner,
    );
  }
}
