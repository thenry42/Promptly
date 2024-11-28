import 'package:flutter/material.dart';
import 'package:promptly_app/widgets/colors.dart';
import '../models/chat_message.dart';

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
          color: message.sender == 'User' ? AppColors.primary : AppColors.primary,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          message.message,
          style: const TextStyle(color: Colors.white), // Set the text color to white 
          ),
      ),
    );
  }
}
