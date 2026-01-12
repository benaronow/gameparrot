import 'package:flutter/material.dart';
import 'package:gameparrot/home/games/tictactoe/tictactoe_utils.dart';
import 'package:provider/provider.dart';
import 'package:gameparrot/providers/games_provider.dart';
import 'package:gameparrot/providers/users_provider.dart';
import 'package:gameparrot/models/turn_game.dart';
import 'package:gameparrot/theme.dart';
import 'widgets/tictactoe_cell.dart';
import 'widgets/tictactoe_status.dart';

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
        initiator: 'Unknown',
        currentPlayer: 'Unknown',
        winner: '',
      ),
    );

    void handleTapCell(int index) {
      if (viewerUid == null || opponentUid == null) return;
      if (game.winner.isNotEmpty) return;
      if (game.currentPlayer != viewerUid) return;
      if (game.turns.any((turn) => turn.turnInfo == index.toString())) return;
      gamesProvider.sendGameTurn(
        game.gameId,
        index.toString(),
        viewerUid,
        opponentUid,
      );
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                children: [
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
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Tic Tac Toe',
                                    style: Theme.of(context)
                                        .textTheme
                                        .headlineSmall
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                  Text(
                                    '#${game.gameId.substring(0, 6)}',
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelMedium
                                        ?.copyWith(
                                          color: Colors.white70,
                                          letterSpacing: 1.1,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 12),
                              TicTacToeStatusChip(
                                game: game,
                                viewerUid: viewerUid,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Board centered: use Expanded with Center
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primaryColor.withOpacity(
                                    0.35,
                                  ),
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
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 3,
                                      ),
                                  itemCount: 9,
                                  itemBuilder: (ctx, index) {
                                    final occupied = game.turns.any(
                                      (turn) =>
                                          turn.turnInfo == index.toString(),
                                    );
                                    final isPlayable =
                                        !occupied &&
                                        viewerUid == game.currentPlayer &&
                                        game.winner.isEmpty;
                                    return TicTacToeCell(
                                      index: index,
                                      symbol: symbolForCell(index, game.turns, game.initiator),
                                      onTap: () => handleTapCell(index),
                                      isPlayable: isPlayable,
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
