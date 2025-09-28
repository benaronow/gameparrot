import 'package:flutter/material.dart';
import 'package:gameparrot/home/messages/messages.dart';
import 'package:gameparrot/home/messages/select_conversation.dart';
import 'package:gameparrot/models/turn_game.dart';
import 'package:gameparrot/providers/games_provider.dart';
import 'package:gameparrot/providers/users_provider.dart';
import 'package:gameparrot/services/services.dart';
import 'package:gameparrot/theme.dart';
import 'package:gameparrot/widgets/widgets.dart';
import 'package:provider/provider.dart';

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

  void setShowMessages(bool value) {
    setState(() {
      showMessages = value;
    });
  }

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
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Start New Game',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: GameType.values.map((gt) {
                      final isSelected = gt == _selectedGameType;
                      return ChoiceChip(
                        label: Text(gt.name),
                        selected: isSelected,
                        onSelected: (_) {
                          setSheetState(() => _selectedGameType = gt);
                          setState(() => _selectedGameType = gt);
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      icon: _startingGame
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.play_arrow),
                      label: Text(_startingGame ? 'Starting...' : 'Start Game'),
                      onPressed: _startingGame
                          ? null
                          : () {
                              Navigator.of(context).pop();
                              _handleStartGame();
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        textStyle: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final usersProvider = Provider.of<UsersProvider>(context);
    final friend = usersProvider.selectedFriend;

    if (usersProvider.selectedId == null) {
      return const SelectConversation();
    }

    if (showMessages) {
      return Messages(
        close: () {
          setShowMessages(false);
        },
      );
    }

    final gamesProvider = Provider.of<GamesProvider>(context);
    final games = gamesProvider.games ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StyledIconButton(
                icon: Icons.arrow_back,
                backgroundColor: AppTheme.secondaryColor,
                iconColor: Colors.white,
                size: 40,
                onPressed: () =>
                    context.read<UsersProvider>().setSelectedId(null),
              ),
              const SizedBox(width: 12),
              CircleAvatar(
                radius: 28,
                backgroundColor: friend!.online ? Colors.green : Colors.grey,
                child: Text(
                  friend.email[0].toUpperCase(),
                  style: const TextStyle(fontSize: 22, color: Colors.white),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            friend.email,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            friend.online ? 'Online' : 'Offline',
                            style: TextStyle(
                              color: friend.online ? Colors.green : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        alignment: WrapAlignment.end,
                        children: [
                          ElevatedButton.icon(
                            icon: const Icon(Icons.play_arrow, size: 20),
                            label: const Text('New Game'),
                            onPressed: _openStartGameSheet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              textStyle: const TextStyle(fontSize: 14),
                              minimumSize: const Size(0, 40),
                            ),
                          ),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.message, size: 20),
                            label: const Text('Messages'),
                            onPressed: () =>
                                setState(() => showMessages = true),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              textStyle: const TextStyle(fontSize: 14),
                              minimumSize: const Size(0, 40),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Text(
            'Current Games',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 8),
          if (games.isEmpty)
            const Text(
              'No active games yet.',
              style: TextStyle(color: Colors.grey),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: games.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (ctx, i) {
                  final g = games[i];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.grid_3x3, color: Colors.white70),
                    title: Text(
                      'Game ${g.gameId.substring(0, 6)}',
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Type: ${g.gameType.name}  Turns: ${g.turns.length}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      gamesProvider.setCurrentGameId(g.gameId);
                      // TODO: Navigate to dedicated game screen.
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
