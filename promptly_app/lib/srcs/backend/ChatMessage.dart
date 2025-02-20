class ChatMessage
{
  // ATTRIBUTES -------------------------------------------

  final String sender;
  final String message;
  final DateTime timestamp;
  final Object rawMessage;
  
  bool useMarkdown = true;
  bool useRaw = false;
  bool usePlainText = false;

  // CONSTRUCTOR ------------------------------------------

  ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.rawMessage
  }) {
    // Set default formatting based on sender
    if (sender.toLowerCase() == 'user') {
      useMarkdown = false;
      usePlainText = true;
    } else if (sender.toLowerCase() == 'assistant') {
      useMarkdown = true;
      usePlainText = false;
    }
  }

  // METHODS ----------------------------------------------

  Map<String, dynamic> toJson() {
    return {
      'sender': sender,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'rawMessage': rawMessage.toString(),
      'useMarkdown': useMarkdown,
      'useRaw': useRaw,
      'usePlainText': usePlainText,
    };
  }

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    return ChatMessage(
      sender: json['sender'],
      message: json['message'],
      timestamp: DateTime.parse(json['timestamp']),
      rawMessage: json['rawMessage'],
    )
    ..useMarkdown = json['useMarkdown'] ?? true
    ..useRaw = json['useRaw'] ?? false
    ..usePlainText = json['usePlainText'] ?? false;
  }
}