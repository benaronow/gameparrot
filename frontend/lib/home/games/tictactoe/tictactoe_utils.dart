import 'package:gameparrot/models/turn_game.dart';

String symbolForCell(int index, List<Turn> turns, String initiator) {
  Turn? turn =
      turns.where((turn) => turn.turnInfo == index.toString()).isNotEmpty
      ? turns.firstWhere((turn) => turn.turnInfo == index.toString())
      : null;
  if (turn == null) return '';
  return turn.player == initiator ? 'O' : 'X';
}

String getWinner(TurnGame game, List<Turn> updatedTurns) {
  String updatedWinner = game.winner;

  if (game.winner.isEmpty && game.gameType == GameType.ticTacToe) {
    final Map<String, Set<String>> playerMoves = {};
    for (final t in updatedTurns) {
      playerMoves.putIfAbsent(t.player, () => <String>{}).add(t.turnInfo);
    }

    const winningLines = [
      ['0', '1', '2'],
      ['3', '4', '5'],
      ['6', '7', '8'],
      ['0', '3', '6'],
      ['1', '4', '7'],
      ['2', '5', '8'],
      ['0', '4', '8'],
      ['2', '4', '6'],
    ];

    for (final entry in playerMoves.entries) {
      for (final line in winningLines) {
        if (line.every(entry.value.contains)) {
          updatedWinner = entry.key;
          break;
        }
      }
      if (updatedWinner.isNotEmpty) break;
    }
  }

  return updatedWinner;
}
