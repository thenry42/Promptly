import 'package:flutter/material.dart';
import 'package:promptly_app/widgets/colors.dart';
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
                ? AppColors.secondarylight
                : widget.isSelected
                    ? AppColors.secondarylight
                    : Colors.transparent,
            border: Border.all(
              color: widget.isSelected || _isHovered
                  ? AppColors.secondarylight
                  : AppColors.secondary,
              width: 1.5,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            widget.conversation.title,
            style: TextStyle(
              color: widget.isSelected ? AppColors.primary : Colors.white,
              fontWeight: widget.isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}
