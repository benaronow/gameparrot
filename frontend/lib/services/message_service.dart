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

    final List<Interaction>? newInteractions = currentUser.interactions?.map((
      f,
    ) {
      if (f.uid == (type == MessageType.receive ? message.from : message.to)) {
        final updatedMessages = List<Message>.from(f.messages);
        updatedMessages.add(message);
        return Interaction(uid: f.uid, messages: updatedMessages);
      } else {
        return f;
      }
    }).toList();

    final updatedUser = User(
      uid: currentUser.uid,
      email: currentUser.email,
      online: currentUser.online,
      interactions: newInteractions ?? [],
      friendRequests: currentUser.friendRequests,
    );

    updateUser(updatedUser);
  }

  static Message createMessage(String messageText, String from, String to) {
    return Message(message: messageText, from: from, to: to);
  }
}
