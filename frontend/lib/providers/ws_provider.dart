import 'package:flutter/material.dart';
import 'package:gameparrot/services/services.dart';

class WebSocketProvider extends ChangeNotifier {
  final WebSocketService _wsService = WebSocketService();
  WebSocketService get wsService => _wsService;

  Future<void> startWsChannel(String? uid) async {
    await _wsService.startWsChannel(uid);
    notifyListeners();
  }

  void closeWsChannel() {
    _wsService.closeWsChannel();
    notifyListeners();
  }
}
