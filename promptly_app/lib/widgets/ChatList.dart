import '../models/Chat.dart';
import 'package:flutter/material.dart';

class ChatList extends StatelessWidget {
  final Chat chat;
  final bool isSelected;
  final VoidCallback onTap;

  const ChatList({
    super.key,
    required this.chat,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap, // Simply triggers the onTap callback passed by parent
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.surfaceContainerHighest // Selected chat background color
              : Theme.of(context).colorScheme.surfaceContainerHigh, // Unselected chat, no background color
          borderRadius: BorderRadius.circular(30),
        ),
        child: Row(
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 0),
              child: Text(
                chat.title,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurface,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal, // Bold when selected
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}