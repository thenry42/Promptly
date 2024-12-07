import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../widgets/chat_message_widget.dart';
import '../widgets/loading_indicator_widget.dart';
//import '../widgets/colors.dart';

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

    return Container(
      color: Theme.of(context).colorScheme.surface,
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
            Expanded(
              child: Center(
                child: Text(
                  'No conversation selected. Please create or select a conversation.',
                  style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurface),
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
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    labelText: 'Enter your message',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.onSurface),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: OutlineInputBorder(),
                    // Optional: Change the input field background to a lighter color
                    fillColor: Theme.of(context).colorScheme.surface,
                    filled: true,
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
                icon: Icon(Icons.send, color: Theme.of(context).colorScheme.onSurface),
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
