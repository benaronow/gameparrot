import 'package:flutter/material.dart';
import 'package:gameparrot/models/turn_game.dart';
import 'package:gameparrot/models/update.dart';
import 'package:gameparrot/services/services.dart';
import 'package:gameparrot/services/turn_game_service.dart';
import 'package:uuid/uuid.dart';

class GamesProvider extends ChangeNotifier {
  var uuid = Uuid();
  final WebSocketService _wsService;
  GamesProvider(this._wsService);
  String? _currentGameId;
  List<TurnGame>? _games;
  bool _listening = false;

  String? get currentGameId => _currentGameId;
  List<TurnGame> get games => _games ?? [];

  void setCurrentGameId(String? id) {
    _currentGameId = id;
    notifyListeners();
  }

  Future<void> setGames(String uid, String fid) async {
    _games = await TurnGameService.getGames(uid, fid);
    notifyListeners();
  }

  void listenToWS() {
    if (_listening) return;
    _wsService.registerListener(_handleUpdate);
    _listening = true;
  }

  void _handleUpdate(Update update) {
    switch (update.type) {
      case "start_game":
        handleStartGame(
          TurnGameService.createNewTurnGame(
            update.gameId ?? '',
            GameType.values.firstWhere(
              (e) => e.toString().split('.').last == (update.message ?? ''),
              orElse: () => GameType.values.first,
            ),
            update.to ?? '',
          ),
        );
        break;
      case "game_turn":
        handleGameTurn(
          TurnGameService.updateExistingTurnGame(
            _games!.firstWhere((g) => g.gameId == update.gameId),
            update.message ?? '',
            update.from ?? '',
            update.to ?? '',
          ),
        );
        break;
      default:
        break;
    }
  }

  void handleStartGame(TurnGame turnGame) {
    TurnGameService.handleStartGame(_games, turnGame, (updatedGames) {
      _games = updatedGames;
      notifyListeners();
    });
    debugPrint(_games.toString());
  }

  void handleGameTurn(TurnGame turnGame) {
    TurnGameService.handleGameTurn(_games, turnGame, (updatedGames) {
      _games = updatedGames;
      notifyListeners();
    });
  }

  void sendStartGame(GameType gameType, String from, String to) {
    var gameId = uuid.v1().toString();
    _wsService.sendStartGame(gameId, gameType, from, to);
    final turnGame = TurnGameService.createNewTurnGame(gameId, gameType, to);
    handleStartGame(turnGame);
  }

  void sendGameTurn(String gameId, String turnInfo, String from, String to) {
    _wsService.sendGameTurn(gameId, turnInfo, from, to);
    final turnGame = TurnGameService.updateExistingTurnGame(
      games.firstWhere((g) => g.gameId == gameId),
      turnInfo,
      from,
      to,
    );
    handleGameTurn(turnGame);
  }
}
