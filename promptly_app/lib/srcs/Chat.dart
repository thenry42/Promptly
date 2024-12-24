import 'package:flutter/material.dart';
import 'MarkDown.dart';

class Chat {
  String title;
  List<ChatMessage> messages = [];
  bool isHovered = false;
  bool isOnline;
  bool isSending;
  Object modelType;
  String? modelName;
  bool useMarkdown;

  Chat({
    required this.title,
    required this.modelType,
    this.isOnline = false,
    this.isSending = false,
    this.useMarkdown = true,
  });
}

class ChatMessage {
  final String sender;
  final String message;
  bool useMarkdown;

  ChatMessage({
    required this.sender, 
    required this.message,
    this.useMarkdown = true,
  });
}

class ChatMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final bool chatUseMarkdown;
  final VoidCallback? onToggleFormat;

  const ChatMessageWidget({
    super.key,
    required this.message,
    required this.chatUseMarkdown,
    this.onToggleFormat,
  });

  @override
  Widget build(BuildContext context) {
    final isUserMessage = message.sender == 'User';
    final useMarkdown = message.useMarkdown && chatUseMarkdown;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Column(
        crossAxisAlignment:
            isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.8,
            ),
            child: Column(
              crossAxisAlignment:
                  isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (onToggleFormat != null)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4.0, left: 16.0, right: 16.0),
                    child: TextButton(
                      onPressed: onToggleFormat,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        minimumSize: const Size(0, 24),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            useMarkdown ? Icons.code : Icons.text_fields,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            useMarkdown ? 'Plain Text' : 'Markdown',
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ),
                useMarkdown
                    ? MarkdownMessage(
                        message: message.message,
                        isUserMessage: isUserMessage,
                      )
                    : PlainTextMessage(
                        message: message.message,
                        isUserMessage: isUserMessage,
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlainTextMessage extends StatelessWidget {
  final String message;
  final bool isUserMessage;

  const PlainTextMessage({
    super.key,
    required this.message,
    required this.isUserMessage,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16.0),
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: SelectableText(
        message,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }
}
