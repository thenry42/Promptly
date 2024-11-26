import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../widgets/chatMessageWidget.dart';
import '../widgets/loadingIndicatorWidget.dart';
import '../widgets/colors.dart';

class ChatArea extends StatelessWidget {
  final List<Conversation> conversations;
  final int selectedConversationIndex;
  final TextEditingController controller;
  final bool isSending;
  final VoidCallback? onSendMessage; // Nullable to handle no-action scenario

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
    // Determine if a conversation is active
    final bool hasConversation = conversations.isNotEmpty && selectedConversationIndex < conversations.length;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Message list
          if (hasConversation)
            Flexible(
              child: ListView.builder(
                itemCount: conversations[selectedConversationIndex].messages.length + (isSending ? 1 : 0),
                itemBuilder: (context, index) {
                  if (isSending && index == conversations[selectedConversationIndex].messages.length) {
                    return const LoadingIndicator();
                  }
                  final message = conversations[selectedConversationIndex].messages[index];
                  return ChatMessageWidget(message: message);
                },
              ),
            )
          else
            const Expanded(
              child: Center(
                child: Text(
                  'No conversation selected. Please create or select a conversation.',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          const SizedBox(height: 8), // Adds spacing between messages and input row
          // Input row
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  enabled: hasConversation && !isSending, // Disable when no conversation or sending
                  maxLines: null,
                  decoration: const InputDecoration(
                    labelText: 'Enter your message',
                    border: OutlineInputBorder(),
                  ),
                  textInputAction: TextInputAction.send,
                  onFieldSubmitted: (_) {
                    if (hasConversation && onSendMessage != null) {
                      onSendMessage!();
                    }
                  },
                ),
              ),
              IconButton(
                icon: const Icon(Icons.send, color: AppColors.powderblue),
                onPressed: (hasConversation && !isSending && onSendMessage != null)
                    ? onSendMessage
                    : null, // Disable button when not valid
              ),
            ],
          ),
        ],
      ),
    );
  }
}
