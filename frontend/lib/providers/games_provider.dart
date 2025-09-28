import 'package:flutter/material.dart';
import 'package:gameparrot/models/turn_game.dart';
import 'package:gameparrot/services/services.dart';
import 'package:gameparrot/services/turn_game_service.dart';
import 'package:uuid/uuid.dart';

class GamesProvider extends ChangeNotifier {
  var uuid = Uuid();
  final WebSocketService _wsService = WebSocketService();
  String? _currentGameId;
  List<TurnGame>? _games;

  String? get currentGameId => _currentGameId;
  List<TurnGame>? get games => _games ?? [];

  void setCurrentGameId(String? id) {
    _currentGameId = id;
    notifyListeners();
  }

  Future<void> getGames(List<String> gids) async {
    _games = await TurnGameService.getGames(gids);
    notifyListeners();
  }

  // void handleTurnGame(TurnGame turnGame) {
  //   TurnGameService.handleTurnGame(_currentUser, turnGame, (updatedUser) {
  //     _currentUser = updatedUser;
  //     notifyListeners();
  //   });
  // }

  // void sendStartGame(String gameType, String from, String to) {
  //   _wsService.sendStartGame(uuid.v1().toString(), gameType, from, to);
  // }

  // void sendGameTurn(String gameId, List<String> turns, String from, String to) {
  //   _wsService.sendGameTurn(gameId, turns.last, from, to);
  //   final turnGame = TurnGameService().createTurnGame(gameId, turns, from, to);
  // }
  
}