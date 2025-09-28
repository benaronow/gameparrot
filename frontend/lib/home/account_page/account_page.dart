import 'package:flutter/material.dart';
import 'package:gameparrot/home/messages/messages.dart';
import 'package:gameparrot/home/messages/select_conversation.dart';
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
    final selectedId = Provider.of<UsersProvider>(context).selectedId;

    if (_prevSelectedId != selectedId) {
      setState(() {
        showMessages = false;
        _prevSelectedId = selectedId;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersProvider = Provider.of<UsersProvider>(context);
    final friend = usersProvider.selectedFriend;
    final gamesProvider = Provider.of<GamesProvider>(context);
    gamesProvider.setGames(
      usersProvider.currentUser?.uid ?? '',
      usersProvider.selectedId ?? '',
    );

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

    return Stack(
      children: [
        // Back button positioned at top-left like mobile header
        Positioned(
          top: 15,
          left: 16,
          child: StyledIconButton(
            icon: Icons.close,
            backgroundColor: AppTheme.secondaryColor,
            iconColor: Colors.white,
            size: 40,
            onPressed: () {
              Provider.of<UsersProvider>(
                context,
                listen: false,
              ).setSelectedId(null);
            },
          ),
        ),
        // Main content centered
        Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 40,
                backgroundColor: friend!.online ? Colors.green : Colors.grey,
                child: Text(
                  friend.email[0].toUpperCase(),
                  style: const TextStyle(fontSize: 32, color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                friend.email,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(friend.online ? 'Online' : 'Offline'),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                icon: const Icon(Icons.message),
                label: const Text('View Messages'),
                onPressed: () => setState(() => showMessages = true),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
