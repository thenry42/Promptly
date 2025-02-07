import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:promptly_app/srcs/backend/ChatMessage.dart';
import 'package:promptly_app/srcs/backend/Singleton.dart';

class ChatMessageWidget extends StatefulWidget {
  final ChatMessage message;
  
  const ChatMessageWidget({
    Key? key,
    required this.message,
  }) : super(key: key);

  @override
  State<ChatMessageWidget> createState() => _ChatMessageWidgetState();
}

class _ChatMessageWidgetState extends State<ChatMessageWidget> {
  @override
  Widget build(BuildContext context) {
    if (widget.message.useRaw) {
      return RawMessageWidget(message: widget.message, onFormatChange: _handleFormatChange);
    } else if (widget.message.usePlainText) {
      return PlainTextMessageWidget(message: widget.message, onFormatChange: _handleFormatChange);
    } else {
      return MarkdownMessageWidget(message: widget.message, onFormatChange: _handleFormatChange);
    }
  }

  void _handleFormatChange(String format) {
    setState(() {
      widget.message.useMarkdown = format == 'markdown';
      widget.message.useRaw = format == 'raw';
      widget.message.usePlainText = format == 'plain';
    });
  }
}

class PlainTextMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final Function(String) onFormatChange;
  
  const PlainTextMessageWidget({
    Key? key,
    required this.message,
    required this.onFormatChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return _buildMessageContainer(context, SelectableText(message.message));
  }

  Widget _buildMessageContainer(BuildContext context, Widget content) {
    final isUser = message.sender == "User";
    
    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: EdgeInsets.only(
        left: isUser ? 150.0 : 16.0,
        right: isUser ? 16.0 : 150.0,
      ),
      decoration: BoxDecoration(
        color: isUser 
          ? Theme.of(context).colorScheme.primary.withOpacity(0.1)
          : Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                message.sender,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              Text(
                _formatTimestamp(message.timestamp),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 10,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          content,
          const SizedBox(height: 8),
          _buildFormatButtons(context),
        ],
      ),
    );
  }

  Widget _buildFormatButtons(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _FormatButton(label: 'Markdown', isActive: message.useMarkdown, onPressed: () => onFormatChange('markdown')),
          const SizedBox(width: 8),
          _FormatButton(label: 'Raw', isActive: message.useRaw, onPressed: () => onFormatChange('raw')),
          const SizedBox(width: 8),
          _FormatButton(label: 'Plain', isActive: message.usePlainText, onPressed: () => onFormatChange('plain')),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class MarkdownMessageWidget extends PlainTextMessageWidget {
  const MarkdownMessageWidget({
    Key? key,
    required ChatMessage message,
    required Function(String) onFormatChange,
  }) : super(key: key, message: message, onFormatChange: onFormatChange);

  @override
  Widget build(BuildContext context) {
    return _buildMessageContainer(
      context,
      MarkdownBody(
        data: message.message,
        selectable: true,
        styleSheet: MarkdownStyleSheet(
          p: const TextStyle(fontSize: 14),
          code: TextStyle(
            backgroundColor: Colors.grey[300],
            fontFamily: 'Courier New',
          ),
        ),
      ),
    );
  }
}

class RawMessageWidget extends PlainTextMessageWidget {
  const RawMessageWidget({
    Key? key,
    required ChatMessage message,
    required Function(String) onFormatChange,
  }) : super(key: key, message: message, onFormatChange: onFormatChange);

  @override
  Widget build(BuildContext context) {
    return _buildMessageContainer(
      context,
      SelectableText(
        message.rawMessage.toString(),
        style: const TextStyle(fontFamily: 'Courier New', fontSize: 14),
      ),
    );
  }
}

class _FormatButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const _FormatButton({
    required this.label,
    required this.isActive,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        backgroundColor: isActive 
          ? Theme.of(context).colorScheme.primaryContainer
          : null,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: isActive
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
