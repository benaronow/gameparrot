import 'package:gameparrot/models/message.dart';

class Friend {
  final String uid;
  final List<Message> messages;
  final List<String> games;

  Friend({required this.uid, required this.messages, required this.games});

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      uid: json['uid'] ?? '',
      messages:
          (json['messages'] as List<dynamic>?)
              ?.map((msg) => Message.fromJson(msg))
              .toList() ??
          [],
      games: (json['games'] is List)
          ? (json['games'] as List)
                .where((e) => e != null)
                .map((e) => e.toString())
                .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
    'uid': uid,
    'messages': messages.map((m) => m.toJson()).toList(),
    'games': games.toList(),
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
