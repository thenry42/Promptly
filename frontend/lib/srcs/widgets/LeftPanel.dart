import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/services/Singleton.dart';
import 'package:promptly_app/srcs/services/Chat.dart';
import 'package:promptly_app/srcs/widgets/NewChatDialog.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter/foundation.dart';

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
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            borderRadius: BorderRadius.circular(8),
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
                        ? Theme.of(context).colorScheme.surfaceContainerHigh.withOpacity(0.8)
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
                        image: chat.icon ?? const AssetImage('assets/images/ollama.png'),
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  // Spacing
                  const Flexible(
                    flex: 1,
                    child: SizedBox(width: 16),
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
                    child: Center(
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
                            case 'deleteAll':
                              _showDeleteAllConfirmation(context);
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
                          PopupMenuItem<String>(
                            value: 'deleteAll',
                            child: Text(
                              'Delete All Chats',
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
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showChatDetails(BuildContext context, Chat chat) async {
    // Load and decode the JSON file
    final String jsonString = await rootBundle.loadString('assets/json/models.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    
    // Find the model details from JSON
    Map<String, dynamic>? modelDetails;
    if (chat.type == 'anthropic') {
      modelDetails = (jsonData['anthropic_models'] as List)
          .firstWhere((model) => model['id'] == chat.modelName, orElse: () => null);
    } else if (chat.type == 'openai') {
      modelDetails = (jsonData['openai_models'] as List)
          .firstWhere((model) => model['id'] == chat.modelName, orElse: () => null);
    }

    final metadata = Singleton();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Chat Details',
            style: TextStyle(
              fontSize: metadata.fontSize,
              fontFamily: metadata.fontFamily,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Model Name: ${modelDetails?['name'] ?? chat.modelName}',
                  style: TextStyle(
                    fontSize: metadata.fontSize,
                    fontFamily: metadata.fontFamily,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Description: ${modelDetails?['description'] ?? 'No description available'}',
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
                  'Vision Capable: ${modelDetails?['vision'] ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: metadata.fontSize,
                    fontFamily: metadata.fontFamily,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Audio Input: ${modelDetails?['audio_input'] ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: metadata.fontSize,
                    fontFamily: metadata.fontFamily,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Input Price: ${modelDetails?['price_per_million_tokens']['input']} ${modelDetails?['price_per_million_tokens']['currency']}/M tokens',
                  style: TextStyle(
                    fontSize: metadata.fontSize,
                    fontFamily: metadata.fontFamily,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Output Price: ${modelDetails?['price_per_million_tokens']['output']} ${modelDetails?['price_per_million_tokens']['currency']}/M tokens',
                  style: TextStyle(
                    fontSize: metadata.fontSize,
                    fontFamily: metadata.fontFamily,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Max Output Tokens: ${modelDetails?['max_output_tokens'] ?? 'Unknown'}',
                  style: TextStyle(
                    fontSize: metadata.fontSize,
                    fontFamily: metadata.fontFamily,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Context Window: ${modelDetails?['context_window'] ?? 'Unknown'}',
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
            onPressed: () async {
              try {
                // Find the index of the chat to remove
                final chatIndex = metadata.chatList.indexWhere((c) => c.id == chat.id);
                if (chatIndex != -1) {
                  await metadata.removeChat(chatIndex);
                  setState(() {}); // Refresh the UI
                }
                if (!context.mounted) return;
                Navigator.of(context).pop();
              } catch (e) {
                if (kDebugMode) {
                  print('Error deleting chat: $e');
                }
                // Show error to user if deletion fails
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete chat: $e')),
                );
              }
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

  void _showDeleteAllConfirmation(BuildContext context) {
    final metadata = Singleton();
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text(
          'Delete All Chats',
          style: TextStyle(
            fontSize: metadata.fontSize,
            fontFamily: metadata.fontFamily,
          ),
        ),
        content: Text(
          'Are you sure you want to delete all chats? This action cannot be undone.',
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
            onPressed: () async {
              try {
                // Delete all chats one by one
                while (metadata.chatList.isNotEmpty) {
                  await metadata.removeChat(0);
                }
                setState(() {}); // Refresh the UI
                if (!context.mounted) return;
                Navigator.of(context).pop();
              } catch (e) {
                if (kDebugMode) {
                  print('Error deleting all chats: $e');
                }
                // Show error to user if deletion fails
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Failed to delete all chats: $e')),
                );
              }
            },
            child: Text(
              'Delete All',
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
