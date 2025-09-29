import 'dart:convert';

import 'package:gameparrot/config.dart';
import 'package:gameparrot/home/games/tictactoe/tictactoe_utils.dart';
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
    String from,
    String to,
  ) {
    return TurnGame(
      gameId: gameId,
      gameType: gameType,
      turns: [],
      initiator: from,
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

    final updatedWinner = getWinner(currentGame, updatedTurns);

    final nextPlayer = updatedWinner.isNotEmpty
        ? currentGame.currentPlayer
        : to;

    return TurnGame(
      gameId: currentGame.gameId,
      gameType: currentGame.gameType,
      turns: updatedTurns,
      initiator: currentGame.initiator,
      currentPlayer: nextPlayer,
      winner: updatedWinner,
    );
  }
}
