import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';
import '../models/conversation.dart';

class ConversationListTile extends StatelessWidget {
  final Conversation conversation;
  final bool isSelected;
  final VoidCallback onTap;

  const ConversationListTile({
    Key? key,
    required this.conversation,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        conversation.isHovered = true;
      },
      onExit: (_) {
        conversation.isHovered = false;
      },
      child: ListTile(
        leading: GFAvatar(
          backgroundColor: Colors.blue,
          shape: GFAvatarShape.circle,
          size: 40,
          child: Text(
            conversation.title[0], // Show the first letter as avatar
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(
          conversation.title,
          style: TextStyle(
            color: conversation.isHovered ? Colors.blueAccent : Colors.black,
          ),
        ),
        selected: isSelected,
        onTap: onTap,
      ),
    );
  }
}
