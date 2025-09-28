import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gameparrot/config.dart';
import 'package:gameparrot/models/turn_game.dart';
import 'package:gameparrot/models/update.dart';
import 'package:gameparrot/providers/auth_provider.dart';
import 'package:gameparrot/providers/games_provider.dart';
import 'package:gameparrot/providers/users_provider.dart';
import 'package:gameparrot/providers/ws_provider.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef UpdateCallback = void Function(Update update);

class WebSocketService {
  WebSocketChannel? _wsChannel;
  final List<UpdateCallback> _listeners = [];
  static WebSocketProvider? _wsProvider;
  static UsersProvider? _usersProvider;
  static GamesProvider? _gamesProvider;
  static FirebaseAuthProvider? _authProvider;

  bool get isConnected => _wsChannel != null;

  static Future<void> initialize(BuildContext context) async {
    _wsProvider = Provider.of<WebSocketProvider>(context, listen: false);
    _usersProvider = Provider.of<UsersProvider>(context, listen: false);
    _gamesProvider = Provider.of<GamesProvider>(context, listen: false);
    _authProvider = Provider.of<FirebaseAuthProvider>(context, listen: false);

    final uid = _authProvider?.uid;
    if (uid != null) {
      await _usersProvider?.getCurrentUser(uid);
      _wsProvider?.startWsChannel(uid);
      _usersProvider?.listenToWS();
    }
  }

  static void initGamesListener(BuildContext context) {
    _gamesProvider = Provider.of<GamesProvider>(context, listen: false);
    _gamesProvider?.listenToWS();
  }

  Future<void> startWsChannel(String? uid) async {
    final WebSocketChannel channel = WebSocketChannel.connect(
      Uri.parse('${Config.wsUrl}?uid=$uid'),
    );
    _wsChannel = channel;
    await channel.ready;

    if (uid != null) _wsChannel?.sink.add(uid);
  }

  void registerListener(UpdateCallback listener) {
    if (!_listeners.contains(listener)) {
      _listeners.add(listener);
    }
    // Ensure subscription started
    _ensureListening();
  }

  void unregisterListener(UpdateCallback listener) {
    _listeners.remove(listener);
  }

  void _ensureListening() {
    // If no channel or already has a stream listener attached (web_socket_channel handles multiple
    // listen calls by throwing for single-subscription), just return if we previously attached.
    if (_streamAttached || _wsChannel == null) return;
    _streamAttached = true;
    _wsChannel!.stream.listen((message) {
      try {
        final Update update = Update.fromJson(jsonDecode(message));
        for (final cb in List<UpdateCallback>.from(_listeners)) {
          cb(update);
        }
      } catch (e, st) {
        debugPrint('WebSocket message handling error: $e\n$st');
      }
    });
  }

  void sendMessage(String messageText, String from, String to) {
    final msgJson = {
      "type": "message",
      "message": messageText,
      "from": from,
      "to": to,
    };
    _wsChannel?.sink.add(jsonEncode(msgJson));
  }

  void sendStartGame(String gameId, GameType gameType, String from, String to) {
    final gameJson = {
      "type": "start_game",
      "gameId": gameId,
      "message": gameType.toString(),
      "from": from,
      "to": to,
    };
    _wsChannel?.sink.add(jsonEncode(gameJson));
  }

  void sendGameTurn(String gameId, String turnInfo, String from, String to) {
    final turnJson = {
      "type": "game_turn",
      "gameId": gameId,
      "message": turnInfo,
      "from": from,
      "to": to,
    };
    _wsChannel?.sink.add(jsonEncode(turnJson));
  }

  void sendFriendRequest(String from, String to) {
    final requestJson = {"type": "friend_request", "from": from, "to": to};
    _wsChannel?.sink.add(jsonEncode(requestJson));
  }

  void sendFriendAccept(String from, String to) {
    final requestJson = {"type": "friend_accept", "from": from, "to": to};
    _wsChannel?.sink.add(jsonEncode(requestJson));
  }

  static bool _streamAttached = false;

  void closeWsChannel() {
    _wsChannel?.sink.close();
    _wsChannel = null;
    _listeners.clear();
    _streamAttached = false;
  }

  static void dispose() {
    _wsProvider?.closeWsChannel();
    _wsProvider = null;
    _usersProvider = null;
    _authProvider = null;
  }
}
