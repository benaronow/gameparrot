import 'package:flutter/material.dart';
import 'message_bubble.dart';
import 'package:gameparrot/providers/users_provider.dart';
import 'package:provider/provider.dart';

class MessageArea extends StatefulWidget {
  const MessageArea({super.key});

  @override
  State<MessageArea> createState() => _MessageAreaState();
}

class _MessageAreaState extends State<MessageArea> {
  final _scrollController = ScrollController();
  int _previousMessageCount = 0;

  String _getMessageKey(dynamic msg) {
    return '${msg.from}_${msg.to}_${msg.message}';
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;

    if (_scrollController.position.pixels == 0) {
      _scrollController.jumpTo(50);
    }

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _unfocusKeyboard() {
    FocusScope.of(context).unfocus();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final usersProvider = Provider.of<UsersProvider>(context);
    final selectedId = usersProvider.selectedId;
    final interactions = usersProvider.currentUser?.interactions ?? [];
    final interaction = interactions
        .where((f) => f.uid == selectedId)
        .firstOrNull;
    final currentMessageCount = interaction?.messages.length ?? 0;

    if (currentMessageCount > _previousMessageCount) {
      _previousMessageCount = currentMessageCount;
      _scrollToBottom();
    }
  }

  @override
  Widget build(BuildContext context) {
    final usersProvider = Provider.of<UsersProvider>(context);
    final messages =
        usersProvider.currentUser?.interactions
            ?.where(
              (interaction) => interaction.uid == usersProvider.selectedId,
            )
            .map((interaction) => interaction.messages)
            .expand((msgList) => msgList)
            .toList() ??
        [];

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: _unfocusKeyboard,
      child: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                controller: _scrollController,
                reverse: true,
                itemCount: messages.length + 1,
                padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
                itemBuilder: (ctx, idx) {
                  if (idx == 0) {
                    return const SizedBox(height: 90);
                  }
                  final msgIdx = messages.length - idx;
                  final msg = messages[msgIdx];
                  final isMe = msg.from == usersProvider.currentUser?.uid;
                  final messageKey = _getMessageKey(msg);

                  return MessageBubble(
                    key: ValueKey(messageKey),
                    message: msg.message,
                    isMe: isMe,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
