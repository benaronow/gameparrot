class TicTacToeGame {
  final String gameId;
  final String playerX;
  final String playerO;
  final List<String> board; // 9 elements: "", "X", or "O"
  final String currentTurn; // uid of current player
  final String winner; // "X", "O", "draw", or ""
  final bool isFinished;

  TicTacToeGame({
    required this.gameId,
    required this.playerX,
    required this.playerO,
    required this.board,
    required this.currentTurn,
    required this.winner,
    required this.isFinished,
  });

  TicTacToeGame copyWith({
    List<String>? board,
    String? currentTurn,
    String? winner,
    bool? isFinished,
  }) {
    return TicTacToeGame(
      gameId: gameId,
      playerX: playerX,
      playerO: playerO,
      board: board ?? this.board,
      currentTurn: currentTurn ?? this.currentTurn,
      winner: winner ?? this.winner,
      isFinished: isFinished ?? this.isFinished,
    );
  }

  Map<String, dynamic> toJson() => {
    'gameId': gameId,
    'playerX': playerX,
    'playerO': playerO,
    'board': board,
    'currentTurn': currentTurn,
    'winner': winner,
    'isFinished': isFinished,
  };

  factory TicTacToeGame.fromJson(Map<String, dynamic> json) {
    return TicTacToeGame(
      gameId: json['gameId'],
      playerX: json['playerX'],
      playerO: json['playerO'],
      board: List<String>.from(json['board']),
      currentTurn: json['currentTurn'],
      winner: json['winner'],
      isFinished: json['isFinished'],
    );
  }
}
