import 'package:flutter/material.dart';
import 'package:gameparrot/home/messages/messages.dart';
import 'package:gameparrot/home/messages/select_conversation.dart';
import 'package:gameparrot/models/turn_game.dart';
import 'package:gameparrot/providers/games_provider.dart';
import 'package:gameparrot/providers/users_provider.dart';
import 'package:gameparrot/services/services.dart';
import 'package:provider/provider.dart';

import 'account_header.dart';
import 'start_game_sheet.dart';
import 'current_games_list.dart';
import 'package:gameparrot/home/games/tictactoe/tictactoe_game_screen.dart';

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  bool showMessages = false;
  String? _prevSelectedId;
  GameType _selectedGameType = GameType.ticTacToe;
  bool _startingGame = false;

  @override
  void initState() {
    super.initState();
    WebSocketService.initGamesListener(context);
  }

  void setShowMessages(bool value) => setState(() => showMessages = value);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final usersProvider = Provider.of<UsersProvider>(context);
    final gamesProvider = Provider.of<GamesProvider>(context);
    if (_prevSelectedId != usersProvider.selectedId) {
      setState(() {
        showMessages = false;
        _prevSelectedId = usersProvider.selectedId;
      });
      gamesProvider.setGames(
        usersProvider.currentUser?.uid ?? '',
        usersProvider.selectedId ?? '',
      );
    }
  }

  void _handleStartGame() {
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);
    final gamesProvider = Provider.of<GamesProvider>(context, listen: false);
    if (_startingGame) return;
    setState(() => _startingGame = true);
    gamesProvider.sendStartGame(
      _selectedGameType,
      usersProvider.currentUser!.uid,
      usersProvider.selectedId!,
    );
    Future.delayed(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _startingGame = false);
    });
  }

  void _openStartGameSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => StartGameSheet(
        selected: _selectedGameType,
        starting: _startingGame,
        onSelect: (gt) => setState(() => _selectedGameType = gt),
        onConfirm: () {
          Navigator.of(context).pop();
          _handleStartGame();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersProvider = Provider.of<UsersProvider>(context);
    if (usersProvider.selectedId == null) {
      return const SelectConversation();
    }
    if (showMessages) {
      return Messages(close: () => setShowMessages(false));
    }
    final gamesProvider = Provider.of<GamesProvider>(context);
    final games = gamesProvider.games;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AccountHeader(
            onBack: () => context.read<UsersProvider>().setSelectedId(null),
            onNewGame: _openStartGameSheet,
            onShowMessages: () => setState(() => showMessages = true),
          ),
          const SizedBox(height: 20),
          const Text(
            'Current Games',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          CurrentGamesList(
            games: games,
            onOpenGame: (id) {
              gamesProvider.setCurrentGameId(id);
              final current = gamesProvider.games.firstWhere(
                (g) => g.gameId == id,
              );
              if (current.gameType == GameType.ticTacToe) {
                Navigator.of(context).push(
                  PageRouteBuilder(
                    pageBuilder: (_, __, ___) =>
                        TicTacToeGameScreen(gameId: id),
                    transitionsBuilder: (_, animation, __, child) {
                      final curved = CurvedAnimation(
                        parent: animation,
                        curve: Curves.easeInOutCubic,
                      );
                      return FadeTransition(
                        opacity: curved,
                        child: ScaleTransition(
                          scale: Tween<double>(
                            begin: .94,
                            end: 1,
                          ).animate(curved),
                          child: child,
                        ),
                      );
                    },
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
