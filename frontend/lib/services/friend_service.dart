import 'package:gameparrot/models/friend.dart';
import 'package:gameparrot/models/user.dart';

class FriendService {
  static void handleFriendRequest(
    User? currentUser,
    FriendRequest request,
    Function(User) updateUser,
  ) {
    if (currentUser == null) return;

    final List<FriendRequest> newRequests = currentUser.friendRequests ?? [];
    newRequests.add(request);

    final updatedUser = User(
      uid: currentUser.uid,
      email: currentUser.email,
      online: currentUser.online,
      friends: currentUser.friends,
      friendRequests: newRequests,
    );

    updateUser(updatedUser);
  }

  static void handleFriendAccept(
    User? currentUser,
    FriendRequest request,
    Function(User) updateUser,
  ) {
    if (currentUser == null) return;

    final List<FriendRequest> newRequests = currentUser.friendRequests ?? [];
    newRequests.removeWhere(
      (r) => r.from == request.from && r.to == request.to,
    );

    final Friend newFriend = Friend(
      uid: request.from == currentUser.uid ? request.to : request.from,
      messages: [],
      games: [],
    );
    final List<Friend> newFriends = List.from(
      currentUser.friends ?? [],
    );
    newFriends.add(newFriend);

    final updatedUser = User(
      uid: currentUser.uid,
      email: currentUser.email,
      online: currentUser.online,
      friends: newFriends,
      friendRequests: newRequests,
    );

    updateUser(updatedUser);
  }

  static FriendRequest createFriendRequest(String from, String to) {
    return FriendRequest(from: from, to: to);
  }
}
