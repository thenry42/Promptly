import '../services/MarkDown.dart';
import '../models/ChatMessage.dart';
import 'package:flutter/material.dart';

/*
class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;

  const ChatMessageWidget({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.sender == 'User' ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.tertiary,
          borderRadius: BorderRadius.circular(16),
        ),
        child: SelectableText(
          message.message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onTertiary,
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
*/

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
