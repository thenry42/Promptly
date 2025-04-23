import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/services/ChatMessage.dart';
import 'package:promptly_app/srcs/services/Singleton.dart';
import 'package:promptly_app/srcs/widgets/CustomMarkdown.dart';

class CustomMarkdownMessageWidget extends StatelessWidget {
  final ChatMessage message;
  final Function(String) onFormatChange;

  const CustomMarkdownMessageWidget({
    Key? key,
    required this.message,
    required this.onFormatChange,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return buildMessageContainer(context);
  }

  Widget buildMessageContainer(BuildContext context) {
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
          CustomMarkdownMessage(message: message.message),
          const SizedBox(height: 8),
          buildFormatButtons(context),
        ],
      ),
    );
  }

  Widget buildFormatButtons(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FormatButton(label: 'Code', isActive: message.useCustomMarkdown, onPressed: () => onFormatChange('custom')),
          const SizedBox(width: 8),
          FormatButton(label: 'Raw', isActive: message.useRaw, onPressed: () => onFormatChange('raw')),
          const SizedBox(width: 8),
          FormatButton(label: 'Plain', isActive: message.usePlainText, onPressed: () => onFormatChange('plain')),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}

class FormatButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onPressed;

  const FormatButton({
    Key? key,
    required this.label,
    required this.isActive,
    required this.onPressed,
  }) : super(key: key);

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