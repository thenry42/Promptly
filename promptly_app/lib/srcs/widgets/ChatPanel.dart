// ChatPanel.dart
import 'package:flutter/material.dart';

class ChatPanel extends StatelessWidget {
  final VoidCallback onTogglePanel;
  final bool isPanelVisible;

  const ChatPanel({
    super.key, 
    required this.onTogglePanel,
    required this.isPanelVisible,
  });

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
            // Toggle button at the top
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: IconButton(
                onPressed: onTogglePanel,
                icon: Icon(
                  isPanelVisible ? Icons.chevron_left : Icons.chevron_right,
                ),
                tooltip: isPanelVisible ? 'Hide Panel' : 'Show Panel',
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chat Panel Content',
                        style: TextStyle(
                          fontSize: 16,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
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
}
