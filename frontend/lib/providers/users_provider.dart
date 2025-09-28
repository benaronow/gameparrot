import 'package:flutter/material.dart';
import 'package:gameparrot/models/update.dart';
import 'package:gameparrot/models/user.dart';
import 'package:gameparrot/models/tictactoe.dart';
import 'dart:convert';
import 'package:gameparrot/services/services.dart';

enum MessageType { send, receive }

class UsersProvider extends ChangeNotifier {
  final WebSocketService _wsService = WebSocketService();
  User? _currentUser;
  List<User>? _users;
  String? _selectedId;

  User? get currentUser => _currentUser;
  List<User>? get users => _users ?? [];
  String? get selectedId => _selectedId;
  List<User>? get friends =>
      _users
          ?.where(
            (u) =>
                _currentUser?.interactions?.any((i) => i.uid == u.uid) ?? false,
          )
          .toList() ??
      [];
  User? get selectedFriend => _users?.firstWhere(
    (u) => u.uid == _selectedId,
    orElse: () => User(uid: '', email: 'Unknown User', online: false),
  );

  void setSelectedId(String? id) {
    _selectedId = id;
    notifyListeners();
  }

  Future<void> getCurrentUser(String? uid) async {
    _currentUser = await UserDataService.getCurrentUser(uid);
    notifyListeners();
  }

  Future<void> startWsChannel(String? uid) async {
    await _wsService.startWsChannel(uid);
  }

  void listenToWS() {
    _wsService.listenToWS(_handleUpdate);
  }

  void _handleUpdate(Update update) {
    switch (update.type) {
      case "message":
        handleMessage(
          Message(
            message: update.message ?? '',
            from: update.from ?? '',
            to: update.to ?? '',
          ),
          MessageType.receive,
        );
        break;
      case "friend_request":
        handleFriendRequest(
          FriendRequest(from: update.from ?? '', to: update.to ?? ''),
        );
        break;
      case "friend_accept":
        handleFriendAccept(
          FriendRequest(from: update.from ?? '', to: update.to ?? ''),
        );
        break;
      case "status":
        handleStatus(update.status ?? []);
        break;
      default:
        break;
    }
  }

  void closeWsChannel() {
    _wsService.closeWsChannel();
  }

  void handleStatus(List<User> status) {
    UserDataService.handleStatus(status, (users) {
      _users = users;
      notifyListeners();
    });
  }

  void handleMessage(Message message, MessageType type) {
    MessageService.handleMessage(_currentUser, message, type, (updatedUser) {
      _currentUser = updatedUser;
      notifyListeners();
    });
  }

  void handleFriendRequest(FriendRequest request) {
    FriendService.handleFriendRequest(_currentUser, request, (updatedUser) {
      _currentUser = updatedUser;
      notifyListeners();
    });
  }

  void handleFriendAccept(FriendRequest request) {
    FriendService.handleFriendAccept(_currentUser, request, (updatedUser) {
      _currentUser = updatedUser;
      notifyListeners();
    });
  }

  void sendMessage(String messageText, String from, String? to) {
    if (_currentUser == null || to == null) return;

    final message = MessageService.createMessage(messageText, from, to);

    _wsService.sendMessage(messageText, from, to);
    handleMessage(message, MessageType.send);
    notifyListeners();
  }

  void sendFriendRequest(String from, String to) {
    if (_currentUser == null) return;

    final request = FriendService.createFriendRequest(from, to);

    _wsService.sendFriendRequest(from, to);
    handleFriendRequest(request);
  }

  void sendFriendAccept(String from, String to) {
    if (_currentUser == null) return;

    final request = FriendService.createFriendRequest(from, to);

    _wsService.sendFriendAccept(from, to);
    handleFriendAccept(request);
  }

  void sendTicTacToeMove(TicTacToeGame game, String from, String to) {
    final msgJson = {
      "type": "tictactoe",
      "from": from,
      "to": to,
      "tictactoe": game.toJson(),
    };
    _wsService.sendRaw(jsonEncode(msgJson));
    // Optionally update local state here if needed
    notifyListeners();
  }
}
