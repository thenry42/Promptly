import 'package:flutter/material.dart';
import 'package:promptly_app/widgets/colors.dart';
import '../models/conversation.dart';
import '../widgets/conversation_list_tile.dart';
import '../widgets/settings_widget.dart'; // Import the settings dialog

class ConversationPanel extends StatelessWidget {
  final List<Conversation> conversations;
  final int selectedConversationIndex;
  final VoidCallback onAddConversation;
  final Function(int) onSelectConversation;

  const ConversationPanel({
    super.key,
    required this.conversations,
    required this.selectedConversationIndex,
    required this.onAddConversation,
    required this.onSelectConversation,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primary,
      child: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: IconButton(
              icon: const Icon(
                Icons.add,
                color: Colors.white),
              onPressed: onAddConversation,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: conversations.isEmpty
                ? Center(
                    child: Text(
                      'No conversations yet.\nClick "+" to add a new chat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimary,
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    itemCount: conversations.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                        child: ConversationListTile(
                          conversation: conversations[index],
                          isSelected: selectedConversationIndex == index,
                          onTap: () => onSelectConversation(index),
                        ),
                      );
                    },
                  ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: () {
                SettingsDialog.show(context); // Call the static method
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16.0),
              ),
              child: Icon(Icons.settings, color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}
