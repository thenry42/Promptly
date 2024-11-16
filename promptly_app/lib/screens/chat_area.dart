import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/loading_indicator_widget.dart';

class ChatArea extends StatelessWidget {
  final List<Conversation> conversations;
  final int selectedConversationIndex;
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback onSendMessage;

  const ChatArea({
    super.key,
    required this.conversations,
    required this.selectedConversationIndex,
    required this.controller,
    required this.isSending,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Flexible(
            child: ListView.builder(
              itemCount: (conversations.isNotEmpty && selectedConversationIndex < conversations.length) ? conversations[selectedConversationIndex].messages.length + (isSending ? 1 : 0) : 0,
              itemBuilder: (context, index) {
                if (isSending && index == conversations[selectedConversationIndex].messages.length) {
                  return const LoadingIndicator();
                }
                final message = conversations[selectedConversationIndex].messages[index];
                return ChatMessageWidget(message: message);
              },
            ),
          ),
          const SizedBox(height: 8), // Adds spacing between messages and input row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Enter your message',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.send,
                  onFieldSubmitted: (_) => onSendMessage(),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: Colors.blue),
                onPressed: onSendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
