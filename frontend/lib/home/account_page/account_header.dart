import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:gameparrot/providers/users_provider.dart';
import 'package:gameparrot/theme.dart';
import 'package:gameparrot/widgets/widgets.dart';

class AccountHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onNewGame;
  final VoidCallback onShowMessages;

  const AccountHeader({
    super.key,
    required this.onBack,
    required this.onNewGame,
    required this.onShowMessages,
  });

  @override
  Widget build(BuildContext context) {
    final usersProvider = Provider.of<UsersProvider>(context, listen: false);
    final friend = usersProvider.selectedFriend!;

    final width = MediaQuery.of(context).size.width;
    final isNarrow = width < 600;

    final avatar = CircleAvatar(
      radius: 28,
      backgroundColor: friend.online ? Colors.green : Colors.grey,
      child: Text(
        friend.email[0].toUpperCase(),
        style: const TextStyle(fontSize: 22, color: Colors.white),
      ),
    );

    final nameStatus = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          friend.email,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          friend.online ? 'Online' : 'Offline',
          style: TextStyle(color: friend.online ? Colors.green : Colors.grey),
        ),
      ],
    );

    final actions = Wrap(
      spacing: 8,
      runSpacing: 8,
      alignment: isNarrow ? WrapAlignment.start : WrapAlignment.end,
      children: [
        ElevatedButton.icon(
          icon: const Icon(Icons.play_arrow, size: 20),
          label: const Text('New Game'),
          onPressed: onNewGame,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            textStyle: const TextStyle(fontSize: 14),
            minimumSize: const Size(0, 40),
          ),
        ),
        OutlinedButton.icon(
          icon: const Icon(Icons.message, size: 20),
          label: const Text('Messages'),
          onPressed: onShowMessages,
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            textStyle: const TextStyle(fontSize: 14),
            minimumSize: const Size(0, 40),
          ),
        ),
      ],
    );

    if (isNarrow) {
      // Narrow layout: back button + avatar + name on one row; buttons on next row.
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StyledIconButton(
                icon: Icons.arrow_back,
                backgroundColor: AppTheme.secondaryColor,
                iconColor: Colors.white,
                size: 40,
                onPressed: onBack,
              ),
              const SizedBox(width: 12),
              avatar,
              const SizedBox(width: 12),
              Expanded(child: nameStatus),
            ],
          ),
          const SizedBox(height: 12),
          actions,
        ],
      );
    }

    return Row(
      children: [
        StyledIconButton(
          icon: Icons.arrow_back,
          backgroundColor: AppTheme.secondaryColor,
          iconColor: Colors.white,
          size: 40,
          onPressed: onBack,
        ),
        const SizedBox(width: 12),
        avatar,
        const SizedBox(width: 12),
        Expanded(
          child: Row(
            children: [
              Expanded(child: nameStatus),
              const SizedBox(width: 8),
              Flexible(child: actions),
            ],
          ),
        ),
      ],
    );
  }
}
