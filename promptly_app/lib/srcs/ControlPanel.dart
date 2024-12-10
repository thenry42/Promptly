import 'package:flutter/material.dart';
import 'Chat.dart';
import 'Settings.dart';

class ControlPanel extends StatelessWidget {
  final List<Chat> chats;
  final VoidCallback onAddChat;
  final int selectedChatIndex;
  final Function(int) onSelectChat;

  const ControlPanel({
    super.key,
    required this.chats,
    required this.selectedChatIndex,
    required this.onAddChat,
    required this.onSelectChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      child: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onAddChat,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 10,
                  ),
                  child: ChatList(
                    chat: chats[index],
                    isSelected: selectedChatIndex == index,
                    onTap: () => onSelectChat(index),
                  ),
                );
              },
            ),
          ),
          ElevatedButton(
            onPressed: () => SettingsDialog.show(context),
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
            child: Icon(
              Icons.settings,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

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