import 'package:flutter/material.dart';
import 'package:gameparrot/providers/users_provider.dart';
import 'package:provider/provider.dart';
import 'message_area.dart';
import 'message_input.dart';
import 'mobile_header.dart';

class Messages extends StatelessWidget {
  final VoidCallback close;
  const Messages({super.key, required this.close});

  @override
  Widget build(BuildContext context) {
    final friend = Provider.of<UsersProvider>(context).selectedFriend;

    return Stack(
      children: [
        MessageArea(),
        MobileHeader(close: close),
        if (friend != null)
          Positioned(left: 0, right: 0, bottom: 0, child: MessageInput()),
      ],
    );
  }
}
