class Message {
  final String message;
  final String from;
  final String to;

  Message({
    required this.message,
    required this.from,
    required this.to,
  });

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      message: json['message'] ?? '',
      from: json['from'] ?? '',
      to: json['to'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'from': from,
    'to': to,
  };
}
