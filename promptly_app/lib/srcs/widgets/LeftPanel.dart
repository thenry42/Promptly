import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/backend/Singleton.dart';
import 'package:promptly_app/srcs/backend/Chat.dart';
import 'package:promptly_app/srcs/widgets/NewChatDialog.dart';
import 'package:promptly_app/srcs/widgets/SettingsDialog.dart';

class LeftPanel extends StatefulWidget {
  final Function(Chat) onChatSelected;

  const LeftPanel({
    super.key,
    required this.onChatSelected,
  });

  @override
  State<LeftPanel> createState() => _LeftPanelState();
}

class _LeftPanelState extends State<LeftPanel> {
  
  void _switchChat(Chat chat) {
    final metadata = Singleton();
    setState(() {
      for (var existingChat in metadata.chatList) {
        existingChat.isSelected = existingChat.id == chat.id;
      }
    });
    widget.onChatSelected(chat); // Notify parent about the selection
    debugPrint("Switched to chat: ${chat.modelName}");
  }

  void _showNewChatDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => NewChatDialog(
        onChatCreated: () => setState(() {}),
      ),
    );
  }

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => SettingsDialog(
        onSettingsChanged: () => setState(() {}),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            // New Chat button at top center
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: IconButton(
                onPressed: _showNewChatDialog,
                icon: const Icon(Icons.add),
                tooltip: 'New Chat',
                constraints: const BoxConstraints(
                  minWidth: 48.0,
                  minHeight: 48.0,
                ),
              ),
            ),
            // Main content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildChatList(context),
                    ],
                  ),
                ),
              ),
            ),
            // Settings button at bottom center
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: IconButton(
                onPressed: _showSettingsDialog,
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
                constraints: const BoxConstraints(
                  minWidth: 48.0,
                  minHeight: 48.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(BuildContext context) {
    final metadata = Singleton();
    
    try {
      if (metadata.chatList.isEmpty) {
        return const SizedBox(
          height: 100,
          child: Center(
            child: Text(
              'No chats available',
              style: TextStyle(fontSize: 16),
            ),
          ),
        );
      }

      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: metadata.chatList.length,
        itemBuilder: (context, index) {
          final chat = metadata.chatList[index];
          return _buildChatListItem(context, chat);
        },
      );
    } catch (e) {
      return Center(
        child: Text(
          'Error loading chats: ${e.toString()}',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }
  }

  Widget _buildChatListItem(BuildContext context, Chat chat) {
    return StatefulBuilder(
      builder: (context, setState) => MouseRegion(
        onEnter: (_) => setState(() => chat.isHovered = true),
        onExit: (_) => setState(() => chat.isHovered = false),
        child: Material(
          color: Colors.transparent,
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 8.0,
              vertical: 4.0,
            ),
            title: Text(
              chat.modelName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: chat.isSelected || chat.isHovered
                    ? Theme.of(context).colorScheme.onSurface
                    : Theme.of(context).colorScheme.onSurface,
              ),
            ),
            onTap: () => _switchChat(chat),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            tileColor: chat.isSelected
                ? Theme.of(context).colorScheme.surfaceContainerHighest
                : chat.isHovered
                    ? Theme.of(context).colorScheme.surfaceContainerHigh
                    : Theme.of(context).colorScheme.surfaceContainer,
          ),
        ),
      ),
    );
  }
}
