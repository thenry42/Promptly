import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/backend/Singleton.dart';
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
                    tooltip: widget.isPanelVisible ? 'Hide Panel' : 'Show Panel',
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        widget.chatName,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            const Expanded(
              child: Padding(
                padding: EdgeInsets.all(12),
                child: ChattingArea(),
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
