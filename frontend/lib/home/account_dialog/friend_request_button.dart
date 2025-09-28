import 'package:flutter/material.dart';
import 'package:gameparrot/theme.dart';

enum FriendRequestState {
  none, // User is not in friend requests at all
  pending, // Current user sent a friend request to this user
  received, // This user sent a friend request to current user
}

class FriendRequestButton extends StatelessWidget {
  final FriendRequestState state;
  final VoidCallback? onRequestFriend;
  final VoidCallback? onAcceptRequest;

  const FriendRequestButton({
    super.key,
    required this.state,
    this.onRequestFriend,
    this.onAcceptRequest,
  });

  @override
  Widget build(BuildContext context) {
    switch (state) {
      case FriendRequestState.none:
        return _buildButton(
          icon: Icons.person_add,
          text: 'Add',
          color: AppTheme.secondaryColor,
          onPressed: onRequestFriend,
        );

      case FriendRequestState.pending:
        return _buildButton(
          icon: Icons.hourglass_empty,
          text: 'Pending',
          color: Colors.orange,
          onPressed: null, // Disabled
        );

      case FriendRequestState.received:
        return _buildButton(
          icon: Icons.check,
          text: 'Accept',
          color: Colors.green,
          onPressed: onAcceptRequest,
        );
    }
  }

  Widget _buildButton({
    required IconData icon,
    required String text,
    required Color color,
    VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isEnabled
              ? [color, color.withValues(alpha: 0.8)]
              : [Colors.grey.withValues(alpha: 0.6), Colors.grey.withValues(alpha: 0.4)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: Colors.white, size: 16),
                const SizedBox(width: 4),
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    shadows: [
                      Shadow(
                        color: Colors.black.withValues(alpha: 0.3),
                        offset: const Offset(0, 1),
                        blurRadius: 1,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
