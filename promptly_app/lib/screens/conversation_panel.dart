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
            child: conversations.isEmpty
                ? Center(
                    child: Text(
                      'No conversations yet.\nClick "+" to add a new chat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey[600],
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
          const Divider(), // Adds a visual separator before the settings button
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                _showSettingsDialog(context);
              },
              style: ElevatedButton.styleFrom(
                shape: const CircleBorder(),
                padding: const EdgeInsets.all(16.0),
              ),
              child: const Icon(Icons.settings),
            ),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Settings'),
          content: const SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.color_lens),
                  title: Text('Theme'),
                ),
                ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('Notifications'),
                ),
                ListTile(
                  leading: Icon(Icons.info),
                  title: Text('About'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
