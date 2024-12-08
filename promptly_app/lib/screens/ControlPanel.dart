import 'package:flutter/material.dart';
import '../models/Chat.dart';
import '../widgets/Settings.dart';
import '../widgets/ChatList.dart';

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
          Expanded(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 8.0,
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