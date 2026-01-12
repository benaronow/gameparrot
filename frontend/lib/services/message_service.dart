import 'package:gameparrot/models/friend.dart';
import 'package:gameparrot/models/message.dart';
import 'package:gameparrot/models/user.dart';
import 'package:gameparrot/providers/users_provider.dart';

class MessageService {
  static void handleMessage(
    User? currentUser,
    Message message,
    MessageType type,
    Function(User) updateUser,
  ) {
    if (currentUser == null) return;

    final List<Friend>? newFriends = currentUser.friends?.map((
      f,
    ) {
      if (f.uid == (type == MessageType.receive ? message.from : message.to)) {
        final updatedMessages = List<Message>.from(f.messages);
        updatedMessages.add(message);
        return Friend(uid: f.uid, messages: updatedMessages, games: f.games);
      } else {
        return f;
      }
    }).toList();

    final updatedUser = User(
      uid: currentUser.uid,
      email: currentUser.email,
      online: currentUser.online,
      friends: newFriends ?? [],
      friendRequests: currentUser.friendRequests,
    );

    updateUser(updatedUser);
  }

  static Message createMessage(String messageText, String from, String to) {
    return Message(message: messageText, from: from, to: to);
  }
}
