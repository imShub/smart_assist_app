enum MessageSender { user, assistant }

class ChatMessage {
  final MessageSender sender;
  final String message;

  ChatMessage({required this.sender, required this.message});

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: json['sender'] == 'user'
          ? MessageSender.user
          : MessageSender.assistant,
      message: json['message'],
    );
  }
}
