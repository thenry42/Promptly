import 'package:flutter/material.dart';
import '../models/ChatMessage.dart';
import '../models/Chat.dart';
import '../widgets/ChatMessageWidget.dart';
import '../widgets/LoadingIndicator.dart';

class ChattingArea extends StatelessWidget {
  final List<Chat> chats;
  final int selectedChatIndex;
  final TextEditingController controller;
  final bool isSending;
  final Function(String) onSendMessage;

  const ChattingArea({
    super.key,
    required this.chats,
    required this.selectedChatIndex,
    required this.controller,
    required this.isSending,
    required this.onSendMessage,
  });

  @override
  Widget build(BuildContext context) {
    final bool hasChat = chats.isNotEmpty && selectedChatIndex < chats.length;

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainer,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chat messages or "No chat selected" message
          Expanded(
            child: hasChat
                ? ListView.builder(
                    itemCount: chats[selectedChatIndex].messages.length + (isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (isSending && index == chats[selectedChatIndex].messages.length) {
                        return const LoadingIndicator();
                      }
                      return ChatMessageWidget(
                        message: chats[selectedChatIndex].messages[index],
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'No chat selected. Please create or select a chat.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
          const SizedBox(height: 8),

          // Message input and send button
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  enabled: hasChat && !isSending,
                  maxLines: null,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 20,
                    ),
                    labelText: 'Enter your message',
                    labelStyle: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    floatingLabelBehavior: FloatingLabelBehavior.never,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(30)),
                    ),
                    fillColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                    filled: true,
                    suffixIcon: Padding(
                      padding: EdgeInsets.only(right: 10),
                      child: IconButton(
                        icon: Icon(
                          Icons.send_rounded,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        onPressed: () {
                          if (controller.text.trim().isNotEmpty) {
                            onSendMessage(controller.text);
                            controller.clear();
                          }
                        },
                      ),
                    ),
                  ),
                  textInputAction: TextInputAction.send,
                  onFieldSubmitted: (value) {
                    if (value.trim().isNotEmpty) {
                      onSendMessage(value);
                      controller.clear();
                    }
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}