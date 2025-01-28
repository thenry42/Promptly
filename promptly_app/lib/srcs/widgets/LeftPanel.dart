// LeftPanel.dart
import 'package:flutter/material.dart';

class LeftPanel extends StatelessWidget {
  final VoidCallback onNewChat;
  final VoidCallback onSettings;

  const LeftPanel({
    super.key,
    required this.onNewChat,
    required this.onSettings,
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
          children: [
            // New Chat button at top center
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: IconButton(
                onPressed: onNewChat,
                icon: const Icon(Icons.add),
                tooltip: 'New Chat',
              ),
            ),
            // Main content area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Available chats',
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
            // Settings button at bottom center
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: IconButton(
                onPressed: onSettings,
                icon: const Icon(Icons.settings),
                tooltip: 'Settings',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
