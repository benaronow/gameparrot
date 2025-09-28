import 'user.dart'; // make sure you import the User class

class Update {
  final String type;
  final String? from;
  final String? to;
  final String? message;
  final List<User>? status;
  final String? gameId;

  Update({
    required this.type,
    this.from,
    this.to,
    this.message,
    this.status,
    this.gameId,
  });

  factory Update.fromJson(Map<String, dynamic> json) {
    return Update(
      type: json['type'] ?? '',
      from: json['from'],
      to: json['to'],
      message: json['message'],
      status: json['status'] != null
          ? (json['status'] as List)
                .map((userJson) => User.fromJson(userJson))
                .toList()
          : null,
      gameId: json['gameId'],
    );
  }
}
