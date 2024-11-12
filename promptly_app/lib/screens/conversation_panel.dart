import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../widgets/conversation_list_tile.dart';

class ConversationPanel extends StatelessWidget {
  final List<Conversation> conversations;
  final int selectedConversationIndex;
  final VoidCallback onAddConversation;
  final Function(int) onSelectConversation;

  const ConversationPanel({
    Key? key,
    required this.conversations,
    required this.selectedConversationIndex,
    required this.onAddConversation,
    required this.onSelectConversation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blueGrey[50],
      child: Column(
        children: [
          const SizedBox(height: 16),
          Center(
            child: IconButton(
              icon: const Icon(Icons.add),
              onPressed: onAddConversation,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
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
        ],
      ),
    );
  }
}
