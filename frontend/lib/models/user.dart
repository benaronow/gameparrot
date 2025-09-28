class Message {
  final String message;
  final String from;
  final String to;
  final Map<String, dynamic>? tictactoe;

  Message({
    required this.message,
    required this.from,
    required this.to,
    this.tictactoe,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      message: json['message'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
      tictactoe: json['tictactoe'],
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'from': from,
    'to': to,
    if (tictactoe != null) 'tictactoe': tictactoe,
  };
}

class Interaction {
  final String uid;
  final List<Message> messages;

  Interaction({required this.uid, required this.messages});

  factory Interaction.fromJson(Map<String, dynamic> json) {
    return Interaction(
      uid: json['uid'] ?? '',
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((msg) => Message.fromJson(msg))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'messages': messages.map((m) => m.toJson()).toList(),
  };
}

class FriendRequest {
  final String from;
  final String to;

  FriendRequest({required this.from, required this.to});

  factory FriendRequest.fromJson(Map<String, dynamic> json) {
    return FriendRequest(from: json['from'] ?? '', to: json['to'] ?? '');
  }

  Map<String, dynamic> toJson() => {'from': from, 'to': to};
}

class User {
  final String uid;
  final String email;
  final bool online;
  final List<Interaction>? interactions;
  final List<FriendRequest>? friendRequests;

  User({
    required this.uid,
    required this.email,
    required this.online,
    this.interactions,
    this.friendRequests,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      online: json['online'] ?? false,
      interactions: (json['interactions'] as List<dynamic>?)
          ?.map((f) => Interaction.fromJson(f))
          .toList(),
      friendRequests: (json['friend_requests'] as List<dynamic>?)
          ?.map((fr) => FriendRequest.fromJson(fr))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'email': email,
    'online': online,
    'interactions': interactions?.map((i) => i.toJson()).toList(),
    'friend_requests': friendRequests?.map((fr) => fr.toJson()).toList(),
  };
}
