import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/services/ChatMessage.dart';
import 'package:promptly_app/srcs/services/Singleton.dart';
import 'package:promptly_app/srcs/widgets/CustomMarkdownMessageWidget.dart';

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
    // Ensure message has the correct format set
    if (!widget.message.useRaw && !widget.message.usePlainText && !widget.message.useCustomMarkdown) {
      widget.message.useCustomMarkdown = true;
    }
    
    if (widget.message.useRaw) {
      return RawMessageWidget(message: widget.message, onFormatChange: _handleFormatChange);
    } else if (widget.message.usePlainText) {
      return PlainTextMessageWidget(message: widget.message, onFormatChange: _handleFormatChange);
    } else {
      // Default to custom markdown for all markdown content
      return CustomMarkdownMessageWidget(message: widget.message, onFormatChange: _handleFormatChange);
    }
  }

  void _handleFormatChange(String format) {
    setState(() {
      widget.message.setFormat(format);
      
      // Save the updated chat settings
      final metadata = Singleton();
      metadata.saveChats();
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
    final metadata = Singleton();
    return _buildMessageContainer(context, SelectableText(message.message, style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily)));
  }

  Widget _buildMessageContainer(BuildContext context, Widget content) {
    final isUser = message.sender == "User";
    final metadata = Singleton();
    
    return Container(
      padding: const EdgeInsets.all(18.0),
      margin: EdgeInsets.only(
        left: isUser ? 150.0 : 18.0,
        right: isUser ? 18.0 : 150.0,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                message.sender,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: metadata.fontSize,
                  color: Theme.of(context).colorScheme.primary,
                  fontFamily: metadata.fontFamily,
                ),
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                _formatTimestamp(message.timestamp),
                style: TextStyle(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: metadata.fontSize,
                  fontFamily: metadata.fontFamily,
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
          _FormatButton(label: 'Code', isActive: message.useCustomMarkdown, onPressed: () => onFormatChange('custom')),
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

class RawMessageWidget extends PlainTextMessageWidget {
  const RawMessageWidget({
    Key? key,
    required ChatMessage message,
    required Function(String) onFormatChange,
  }) : super(key: key, message: message, onFormatChange: onFormatChange);

  @override
  Widget build(BuildContext context) {
    final metadata = Singleton();
    
    return _buildMessageContainer(
      context,
      SelectableText(
        message.rawMessage.toString(),
        style: TextStyle(fontFamily: metadata.fontFamily, fontSize: metadata.fontSize),
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
    final metadata = Singleton();
    
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
          fontSize: metadata.fontSize,
          color: isActive
            ? Theme.of(context).colorScheme.onPrimaryContainer
            : Theme.of(context).colorScheme.primary,
          fontFamily: metadata.fontFamily,
        ),
      ),
    );
  }
}
