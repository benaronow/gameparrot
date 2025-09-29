enum GameType { ticTacToe }

class Turn {
  final String player;
  final String turnInfo;

  Turn({required this.player, required this.turnInfo});

  factory Turn.fromJson(Map<String, dynamic> json) {
    return Turn(player: json['player'] ?? '', turnInfo: json['turnInfo'] ?? '');
  }

  Map<String, dynamic> toJson() => {'player': player, 'turnInfo': turnInfo};
}

class TurnGame {
  final String gameId;
  final GameType gameType;
  final List<Turn> turns;
  final String initiator;
  final String currentPlayer;
  final String winner;

  TurnGame({
    required this.gameId,
    required this.gameType,
    required this.turns,
    required this.initiator,
    required this.currentPlayer,
    required this.winner,
  });

  factory TurnGame.fromJson(Map<String, dynamic> json) {
    return TurnGame(
      gameId: json['gameId'] ?? '',
      gameType: GameType.values.firstWhere(
        (e) => e.toString() == 'GameType.${json['gameType']}',
        orElse: () => GameType.ticTacToe,
      ),
      turns: (json['turns'] as List<dynamic>)
          .map((turn) => Turn.fromJson(turn))
          .toList(),
      initiator: json['initiator'] ?? '',
      currentPlayer: json['currentPlayer'] ?? '',
      winner: json['winner'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'gameId': gameId,
    'gameType': gameType.toString(),
    'turns': turns.map((turn) => turn.toJson()).toList(),
    'initiator': initiator,
    'currentPlayer': currentPlayer,
    'winner': winner,
  };
}
