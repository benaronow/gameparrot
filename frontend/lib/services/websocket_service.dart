import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:gameparrot/config.dart';
import 'package:gameparrot/models/turn_game.dart';
import 'package:gameparrot/models/update.dart';
import 'package:gameparrot/providers/auth_provider.dart';
import 'package:gameparrot/providers/users_provider.dart';
import 'package:provider/provider.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef UpdateCallback = void Function(Update update);

class WebSocketService {
  WebSocketChannel? _wsChannel;
  UpdateCallback? _onUpdate;
  static UsersProvider? _usersProvider;
  static FirebaseAuthProvider? _authProvider;

  bool get isConnected => _wsChannel != null;

  static Future<void> initialize(BuildContext context) async {
    _usersProvider = Provider.of<UsersProvider>(context, listen: false);
    _authProvider = Provider.of<FirebaseAuthProvider>(context, listen: false);

    final uid = _authProvider?.uid;
    if (uid != null) {
      await _usersProvider?.getCurrentUser(uid);
      _initWebSocketsSync(_usersProvider!, uid);
    }
  }

  static void _initWebSocketsSync(UsersProvider p, String uid) {
    p.startWsChannel(uid);
    p.listenToWS();
  }

  Future<void> startWsChannel(String? uid) async {
    final WebSocketChannel channel = WebSocketChannel.connect(
      Uri.parse('${Config.wsUrl}?uid=$uid'),
    );
    _wsChannel = channel;
    await channel.ready;

    if (uid != null) _wsChannel?.sink.add(uid);
  }

  void listenToWS(UpdateCallback onUpdate) {
    _onUpdate = onUpdate;
    _wsChannel?.stream.listen((message) {
      final Update update = Update.fromJson(jsonDecode(message));
      _onUpdate?.call(update);
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

  void sendRaw(String json) {
    _wsChannel?.sink.add(json);
  }

  void closeWsChannel() {
    _wsChannel?.sink.close();
    _wsChannel = null;
    _onUpdate = null;
  }

  static void dispose() {
    _usersProvider?.closeWsChannel();
    _usersProvider = null;
    _authProvider = null;
  }
}
