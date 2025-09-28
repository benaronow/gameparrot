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
  final List<Turn> turns;
  final String currentPlayer;
  final bool finished;
  final String winner;

  TurnGame({
    required this.turns,
    required this.currentPlayer,
    required this.finished,
    required this.winner,
  });

  factory TurnGame.fromJson(Map<String, dynamic> json) {
    return TurnGame(
      turns: (json['turns'] as List<dynamic>)
          .map((turn) => Turn.fromJson(turn))
          .toList(),
      currentPlayer: json['currentPlayer'] ?? '',
      finished: json['finished'] ?? false,
      winner: json['winner'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'turns': turns.map((turn) => turn.toJson()).toList(),
    'currentPlayer': currentPlayer,
    'finished': finished,
    'winner': winner,
  };
}
