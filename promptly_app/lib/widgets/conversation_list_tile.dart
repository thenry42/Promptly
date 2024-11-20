import 'package:flutter/material.dart';
import '../models/conversation.dart';

class ConversationListTile extends StatefulWidget {
  final Conversation conversation;
  final bool isSelected;
  final VoidCallback onTap;

  const ConversationListTile({
    super.key,
    required this.conversation,
    required this.isSelected,
    required this.onTap,
  });

  @override
  _ConversationListTileState createState() => _ConversationListTileState();
}

class _ConversationListTileState extends State<ConversationListTile> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: InkWell(
        onTap: widget.onTap,
        child: Container(
          padding: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: _isHovered
                ? Colors.blueGrey[100]
                : widget.isSelected
                    ? Colors.blue[100]
                    : Colors.transparent,
            border: Border.all(
              color: widget.isSelected || _isHovered
                  ? Colors.blueAccent
                  : Colors.transparent,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            widget.conversation.title,
            style: TextStyle(
              color: widget.isSelected ? Colors.blueAccent : Colors.black87,
              fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
