import 'dart:convert';

import 'package:gameparrot/config.dart';
import 'package:gameparrot/models/turn_game.dart';
import 'package:http/http.dart' as http;

class TurnGameService {
  static Future<List<TurnGame>> getGames(List<String> gids) async {
    final uri = Uri.parse('${Config.httpUrl}/games?gids=${gids.join("s")}');

    final gamesResponse = await http.get(
      uri,
      headers: {'Content-Type': 'application/json'},
    );

    final decoded = jsonDecode(gamesResponse.body);
    return (decoded['games'] as List)
      .map((game) => TurnGame.fromJson(game))
      .toList();
  }
}
