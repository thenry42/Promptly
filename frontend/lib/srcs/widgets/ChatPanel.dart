import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/services/Singleton.dart';
import 'package:promptly_app/srcs/widgets/ChattingArea.dart';

class ChatPanel extends StatefulWidget {
  final VoidCallback onTogglePanel;
  final bool isPanelVisible;
  final String chatName;

  const ChatPanel({
    super.key,
    required this.onTogglePanel,
    required this.isPanelVisible,
    required this.chatName,
  });

  @override
  _ChatPanelState createState() => _ChatPanelState();
}

class _ChatPanelState extends State<ChatPanel> {
  late Singleton metadata;

  @override
  void initState() {
    super.initState();
    metadata = Singleton();
    // Listen for changes in the chat list or selection
    metadata.addChatSelectionListener(_onChatChanged);
  }

  @override
  void dispose() {
    metadata.removeChatSelectionListener(_onChatChanged);
    super.dispose();
  }

  void _onChatChanged() {
    setState(() {
      // Update the panel when chat changes
    });
  }

  String get _currentChatName {
    if (metadata.chatList.isEmpty || 
        metadata.selectedChatIndex < 0 || 
        metadata.selectedChatIndex >= metadata.chatList.length) {
      return widget.chatName;
    }
    return metadata.chatList[metadata.selectedChatIndex].modelName;
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: widget.onTogglePanel,
                    icon: Icon(
                      widget.isPanelVisible
                          ? Icons.chevron_left
                          : Icons.chevron_right,
                    ),
                    iconSize: 40,
                    tooltip: widget.isPanelVisible ? 'Hide Panel' : 'Show Panel',
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        _currentChatName,
                        style: TextStyle(
                          fontSize: metadata.fontSize,
                          fontWeight: FontWeight.bold,
                          fontFamily: metadata.fontFamily,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                child: const ChattingArea(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void updateChatPanel() {
    setState(() {});
  }
}
