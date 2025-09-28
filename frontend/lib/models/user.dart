import 'package:gameparrot/models/friend.dart';

class User {
  final String uid;
  final String email;
  final bool online;
  final List<Friend>? friends;
  final List<FriendRequest>? friendRequests;

  User({
    required this.uid,
    required this.email,
    required this.online,
    this.friends,
    this.friendRequests,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      online: json['online'] ?? false,
      friends: (json['friends'] as List<dynamic>?)
          ?.map((f) => Friend.fromJson(f))
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
    'friends': friends?.map((i) => i.toJson()).toList(),
    'friend_requests': friendRequests?.map((fr) => fr.toJson()).toList(),
  };
}
