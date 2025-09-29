import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gameparrot/providers/games_provider.dart';
import 'package:gameparrot/providers/users_provider.dart';
import 'package:gameparrot/models/turn_game.dart';
import 'package:gameparrot/theme.dart';

class TicTacToeGameScreen extends StatelessWidget {
  final String gameId;
  const TicTacToeGameScreen({super.key, required this.gameId});

  @override
  Widget build(BuildContext context) {
    final gamesProvider = Provider.of<GamesProvider>(context);
    final userProvider = Provider.of<UsersProvider>(context, listen: false);
    final viewerUid = userProvider.currentUser?.uid;
    final opponentUid = userProvider.selectedId; // friend you are playing with
    final games = gamesProvider.games; // getter already ensures non-null list
    final game = games.firstWhere(
      (g) => g.gameId == gameId,
      orElse: () => TurnGame(
        gameId: gameId,
        gameType: GameType.ticTacToe,
        turns: const [],
        currentPlayer: 'Unknown',
        winner: '',
      ),
    );

    // Build occupancy map: key like 'ax1'
    final Map<String, Turn> board = {};
    for (final t in game.turns) {
      board[t.turnInfo] = t; // last move wins if duplicates (shouldn't happen)
    }

    // Maintain consistent player symbol assignment based on first appearance order
    final List<String> playerOrder = [];
    for (final t in game.turns) {
      if (!playerOrder.contains(t.player)) playerOrder.add(t.player);
    }

    String symbolForTurn(Turn? turn) {
      if (turn == null) return '';
      final idx = playerOrder.indexOf(turn.player);
      if (idx == -1) return '';
      return idx == 0 ? 'X' : 'O';
    }

    String symbolForCellIndex(int index) {
      final coord = _coordFromIndex(index); // e.g., 'ax1'
      return symbolForTurn(board[coord]);
    }

    void handleTapCell(int index) {
      if (viewerUid == null || opponentUid == null) return;
      if (game.winner.isNotEmpty) return; // game finished
      if (game.currentPlayer != viewerUid) return; // not your turn
      final coord = _coordFromIndex(index);
      if (board.containsKey(coord)) return; // already occupied
      // Send move
      gamesProvider.sendGameTurn(game.gameId, coord, viewerUid, opponentUid);
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF0F2027), Color(0xFF203A43), Color(0xFF2C5364)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Top bar
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                child: Row(
                  children: [
                    IconButton(
                      tooltip: 'Close',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withOpacity(0.08),
                        highlightColor: Colors.white24,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, size: 22),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Tic Tac Toe',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                          Text(
                            '#${game.gameId.substring(0, 6)}',
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  color: Colors.white70,
                                  letterSpacing: 1.1,
                                ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              // Board container with fancy glow
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withOpacity(0.35),
                                blurRadius: 35,
                                spreadRadius: 2,
                                offset: const Offset(0, 8),
                              ),
                            ],
                            gradient: LinearGradient(
                              colors: [
                                AppTheme.primaryDark.withOpacity(0.85),
                                AppTheme.primaryColor.withOpacity(0.75),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          padding: const EdgeInsets.all(18),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.black.withOpacity(0.2),
                                    Colors.black.withOpacity(0.05),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                              child: Stack(
                                children: [
                                  // Cells (for future interactivity)
                                  GridView.builder(
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                        ),
                                    itemCount: 9,
                                    itemBuilder: (ctx, index) {
                                      final coord = _coordFromIndex(index);
                                      final occupied = board.containsKey(coord);
                                      final isPlayable =
                                          !occupied &&
                                          viewerUid == game.currentPlayer &&
                                          game.winner.isEmpty;
                                      return _TicTacToeCell(
                                        index: index,
                                        symbol: symbolForCellIndex(index),
                                        onTap: () => handleTapCell(index),
                                        isPlayable: isPlayable,
                                      );
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              _BottomStatusBar(game: game, viewerUid: viewerUid),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // Convert 0..8 index to tic tac toe coordinate string column(a-c)xrow(1-3)
  String _coordFromIndex(int index) {
    final col = index % 3; // 0,1,2
    final row = index ~/ 3; // 0,1,2
    const cols = ['a', 'b', 'c'];
    final letter = cols[col];
    final number = row + 1; // 1-based
    return '${letter}x$number';
  }
}

class _TicTacToeCell extends StatelessWidget {
  final int index;
  final String symbol;
  final VoidCallback onTap;
  final bool isPlayable;
  const _TicTacToeCell({
    required this.index,
    required this.symbol,
    required this.onTap,
    required this.isPlayable,
  });

  @override
  Widget build(BuildContext context) {
    final enabled = symbol.isEmpty && isPlayable;
    return MouseRegion(
      onEnter: (_) => {},
      child: InkWell(
        onTap: enabled ? onTap : null,
        splashColor: Colors.white10,
        highlightColor: Colors.white10,
        hoverColor: Colors.transparent,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: enabled
                  ? Colors.white.withOpacity(0.25)
                  : Colors.white.withOpacity(0.05),
              width: 1.4,
            ),
            gradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(enabled ? 0.10 : 0.02),
                Colors.white.withOpacity(enabled ? 0.18 : 0.04),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            boxShadow: [
              if (enabled)
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.30),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                  spreadRadius: 1,
                ),
            ],
          ),
          child: Center(
            child: AnimatedScale(
              duration: const Duration(milliseconds: 220),
              scale: symbol.isEmpty ? 0.0 : 1.0,
              curve: Curves.easeOutBack,
              child: Text(
                symbol,
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  foreground: Paint()
                    ..shader = const LinearGradient(
                      colors: [AppTheme.tertiaryColor, AppTheme.secondaryColor],
                    ).createShader(const Rect.fromLTWH(0, 0, 200, 70)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomStatusBar extends StatelessWidget {
  final TurnGame game;
  final String? viewerUid;
  const _BottomStatusBar({required this.game, required this.viewerUid});

  @override
  Widget build(BuildContext context) {
    final isTurn = game.currentPlayer == viewerUid && game.winner.isEmpty;
    final waiting = game.currentPlayer != viewerUid && game.winner.isEmpty;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 26, vertical: 22),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: Colors.white.withOpacity(0.12), width: 1.2),
          gradient: LinearGradient(
            colors: [
              Colors.white.withOpacity(0.07),
              Colors.white.withOpacity(0.03),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.35),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Center(
          child: _GameStatusChip(
            game: game,
            isTurn: isTurn,
            waiting: waiting,
            viewerUid: viewerUid,
          ),
        ),
      ),
    );
  }
}

class _GameStatusChip extends StatelessWidget {
  final TurnGame game;
  final bool isTurn;
  final bool waiting;
  final String? viewerUid;
  const _GameStatusChip({
    required this.game,
    required this.isTurn,
    required this.waiting,
    required this.viewerUid,
  });

  @override
  Widget build(BuildContext context) {
    final bool finished = game.winner.isNotEmpty;
    late String label;
    late IconData icon;
    Color base;

    if (finished) {
      label = 'Winner: ${game.winner.substring(0, 6)}';
      icon = Icons.emoji_events;
      base = AppTheme.successColor;
    } else if (isTurn) {
      label = 'Your Turn';
      icon = Icons.flash_on;
      base = AppTheme.tertiaryColor;
    } else if (waiting) {
      label = "Opponent's Turn";
      icon = Icons.schedule;
      base = AppTheme.primaryColor;
    } else {
      // Fallback (shouldn't normally happen)
      label = '—';
      icon = Icons.help_outline;
      base = AppTheme.primaryColor;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        gradient: LinearGradient(
          colors: [base.withOpacity(.95), base.withOpacity(.65)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: base.withOpacity(.45),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(.25), width: 1.2),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 26, color: Colors.white),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
              fontSize: 18,
              letterSpacing: 1,
            ),
          ),
        ],
      ),
    );
  }
}
