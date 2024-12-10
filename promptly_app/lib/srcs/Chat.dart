import 'MarkDown.dart';
import 'package:flutter/material.dart';

class Chat {

  String title;
  List<ChatMessage> messages = []; // Default value inline
  bool isHovered = false; // Default value inline
  bool isOnline;
  bool isSending;
  Object? modelType;
  String? modelName;

  // Constructor required inside the class in dart (different from cpp)
  Chat({
    required this.title,
    this.isOnline = false,
    this.isSending = false,
  });
}

class ChatMessage {

  final String sender;
  final String message;

  ChatMessage({required this.sender, required this.message});
}

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  
  const ChatMessageWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MarkdownMessage(
      message: message.message,
      isUserMessage: message.sender == 'User',
    );
  }
}
