import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/backend/Singleton.dart';
import 'package:promptly_app/srcs/backend/Chat.dart';
import 'package:promptly_app/srcs/widgets/NewChatDialog.dart';

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
      // Find the index of the chat in the list
      int chatIndex = metadata.chatList.indexWhere((c) => c.id == chat.id);
      
      // Update selection state for all chats
      for (var existingChat in metadata.chatList) {
        existingChat.isSelected = existingChat.id == chat.id;
      }
      
      // Use setSelectedChatIndex to trigger listeners
      if (chatIndex != -1) {
        metadata.setSelectedChatIndex(chatIndex);
      }
    });
    
    widget.onChatSelected(chat); // Notify parent about the selection
    debugPrint("Switched to chat: ${chat.modelName} at index ${metadata.selectedChatIndex}");
  }

  void _showNewChatDialog() {
    final metadata = Singleton();
    showDialog(
      context: context,
      builder: (BuildContext context) => NewChatDialog(
        onChatCreated: () => setState(() {_switchChat(metadata.chatList.last);}),
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
                  minWidth: 60.0,
                  minHeight: 60.0,
                ),
                iconSize: 40,
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
          ],
        ),
      ),
    );
  }

  Widget _buildChatList(BuildContext context) {
    final metadata = Singleton();
    
    try {
      if (metadata.chatList.isEmpty) {
        return SizedBox(
          height: 100,
          child: Center(
            child: Text(
              'No chats available',
              style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily),
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
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: _buildChatListItem(context, chat),
          );
        },
      );
    } catch (e) {
      return Center(
        child: Text(
          'Error loading chats: ${e.toString()}',
          style: TextStyle(
            fontSize: 18,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      );
    }
  }

  Widget _buildChatListItem(BuildContext context, Chat chat) {
    final metadata = Singleton();
    return StatefulBuilder(
      builder: (context, setState) => MouseRegion(
        onEnter: (_) => setState(() => chat.isHovered = true),
        onExit: (_) => setState(() => chat.isHovered = false),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => _switchChat(chat),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              decoration: BoxDecoration(
                color: chat.isSelected
                    ? Theme.of(context).colorScheme.surfaceContainerHighest
                    : chat.isHovered
                        ? Theme.of(context).colorScheme.surfaceContainerHigh
                        : Theme.of(context).colorScheme.surfaceContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon
                  Flexible(
                    flex: 1,
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: Image(
                        image: chat.icon,
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Title
                  Expanded(
                    flex: 4,
                    child: Text(
                      chat.modelName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface,
                        fontFamily: metadata.fontFamily,
                        fontSize: metadata.fontSize,
                      ),
                    ),
                  ),
                  // Menu
                  Flexible(
                    flex: 1,
                    child: PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      onSelected: (value) {
                        switch (value) {
                          case 'details':
                            _showChatDetails(context, chat);
                            break;
                          case 'delete':
                            _showDeleteConfirmation(context, chat);
                            break;
                        }
                      },
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                        PopupMenuItem<String>(
                          value: 'details',
                          child: Text(
                            'Details',
                            style: TextStyle(
                              fontSize: metadata.fontSize,
                              fontFamily: metadata.fontFamily,
                            ),
                          ),
                        ),
                        PopupMenuItem<String>(
                          value: 'delete',
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              fontSize: metadata.fontSize,
                              fontFamily: metadata.fontFamily,
                              color: Theme.of(context).colorScheme.error,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showChatDetails(BuildContext context, Chat chat) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final metadata = Singleton();
        return AlertDialog(
          title: Text(
            'Chat Details',
            style: TextStyle(
              fontSize: metadata.fontSize,
              fontFamily: metadata.fontFamily,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Model Name: ${chat.modelName}',
                style: TextStyle(
                  fontSize: metadata.fontSize,
                  fontFamily: metadata.fontFamily,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Model Type: ${chat.type}',
                style: TextStyle(
                  fontSize: metadata.fontSize,
                  fontFamily: metadata.fontFamily,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Messages: ${chat.messages.length}',
                style: TextStyle(
                  fontSize: metadata.fontSize,
                  fontFamily: metadata.fontFamily,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(
                  fontSize: metadata.fontSize,
                  fontFamily: metadata.fontFamily,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteConfirmation(BuildContext context, Chat chat) {
    final metadata = Singleton();
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Delete Chat',
          style: TextStyle(
            fontSize: metadata.fontSize,
            fontFamily: metadata.fontFamily,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this chat?',
          style: TextStyle(
            fontSize: metadata.fontSize,
            fontFamily: metadata.fontFamily,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                fontSize: metadata.fontSize,
                fontFamily: metadata.fontFamily,
              ),
            ),
          ),
          FilledButton(
            onPressed: () {
              setState(() {
                metadata.chatList.removeWhere((c) => c.id == chat.id);
                if (metadata.chatList.isNotEmpty) {
                  _switchChat(metadata.chatList.first);
                } else {
                  metadata.setSelectedChatIndex(-1);
                }
              });
              Navigator.of(context).pop();
            },
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: metadata.fontSize,
                fontFamily: metadata.fontFamily,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
