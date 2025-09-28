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
      interactions: currentUser.interactions,
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

    final Interaction newInteraction = Interaction(
      uid: request.from == currentUser.uid ? request.to : request.from,
      messages: [],
    );
    final List<Interaction> newInteractions = List.from(
      currentUser.interactions ?? [],
    );
    newInteractions.add(newInteraction);

    final updatedUser = User(
      uid: currentUser.uid,
      email: currentUser.email,
      online: currentUser.online,
      interactions: newInteractions,
      friendRequests: newRequests,
    );

    updateUser(updatedUser);
  }

  static FriendRequest createFriendRequest(String from, String to) {
    return FriendRequest(from: from, to: to);
  }
}
