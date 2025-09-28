import 'package:flutter/material.dart';
import 'package:gameparrot/providers/users_provider.dart';
import 'package:gameparrot/models/user.dart';
import 'package:provider/provider.dart';
import 'friend_request_list_item.dart';
import 'friend_request_button.dart';

class NonFriendsList extends StatelessWidget {
  const NonFriendsList({super.key});

  // Helper method to determine friend request state
  FriendRequestState _getFriendRequestState(
    String userUid,
    String? currentUserId,
    List<FriendRequest>? friendRequests,
  ) {
    if (friendRequests == null || currentUserId == null) {
      return FriendRequestState.none;
    }

    for (final request in friendRequests) {
      if (request.to == userUid && request.from == currentUserId) {
        return FriendRequestState.pending;
      }
      if (request.from == userUid && request.to == currentUserId) {
        return FriendRequestState.received;
      }
    }

    return FriendRequestState.none;
  }

  @override
  Widget build(BuildContext context) {
    final usersProvider = Provider.of<UsersProvider>(context);
    final currentUser = usersProvider.currentUser;
    final allUsers = usersProvider.users ?? [];

    // Get friend UIDs for filtering
    final friendIds =
        currentUser?.interactions?.map((f) => f.uid).toSet() ?? <String>{};
    final currentUserId = currentUser?.uid;

    // Filter out friends and current user
    final nonFriends = allUsers
        .where(
          (user) => user.uid != currentUserId && !friendIds.contains(user.uid),
        )
        .toList();

    if (nonFriends.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Icon(
              Icons.person_search,
              size: 48,
              color: Colors.white.withValues(alpha: 0.6),
            ),
            const SizedBox(height: 12),
            Text(
              'No users to add',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'All available users are already friends',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      height: 200, // Fixed height for the dialog
      child: ListView.builder(
        itemCount: nonFriends.length,
        itemBuilder: (context, index) {
          final user = nonFriends[index];
          final friendRequestState = _getFriendRequestState(
            user.uid,
            currentUserId,
            currentUser?.friendRequests,
          );

          return FriendRequestListItem(
            user: user,
            friendRequestState: friendRequestState,
            onRequestFriend: () {
              if (currentUserId != null) {
                usersProvider.sendFriendRequest(currentUserId, user.uid);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sending friend request to ${user.email}'),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
            onAcceptRequest: () {
              if (currentUserId != null) {
                usersProvider.sendFriendAccept(user.uid, currentUserId);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Accepting friend request from ${user.email}',
                    ),
                    duration: const Duration(seconds: 2),
                  ),
                );
              }
            },
          );
        },
      ),
    );
  }
}
