class ChatMessage {
  final String message;
  final bool isUser;
  final DateTime time;
  final String? context;
  final bool showVerifiedBadge;

  ChatMessage({
    required this.message,
    required this.isUser,
    required this.time,
    this.context,
    this.showVerifiedBadge = false,
  });

  Map<String, dynamic> toJson() {
    return {
      "message": message,
      "isUser": isUser,
      "time": time.toIso8601String(),
      "context": context,
      "verified": showVerifiedBadge,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      message: json["message"],
      isUser: json["isUser"],
      time: DateTime.parse(json["time"]),
      context: json["context"],
      showVerifiedBadge: json["verified"] ?? false,
    );
  }
}
