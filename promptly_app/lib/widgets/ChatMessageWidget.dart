import '../services/MarkDown.dart';
import '../models/ChatMessage.dart';
import 'package:flutter/material.dart';

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
