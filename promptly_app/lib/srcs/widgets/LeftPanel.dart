import 'package:flutter/material.dart';

class LeftPanel extends StatefulWidget {
  const LeftPanel({super.key});

  @override
  State<LeftPanel> createState() => _LeftPanelState();
}

class _LeftPanelState extends State<LeftPanel> {
  bool _isVisible = true; // Tracks whether the panel is visible or hidden.

  void _togglePanel() {
    setState(() {
      _isVisible = !_isVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isVisible ? _buildExpandedPanel(context) : _buildCollapsedPanel();
  }

  // Builds the expanded panel view
  Widget _buildExpandedPanel(BuildContext context) {
    return SafeArea(
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            _buildTopButtons(),
            _buildMainContent(context),
            _buildBottomSettingsButton(),
          ],
        ),
      ),
    );
  }

  // Builds the collapsed panel view
  Widget _buildCollapsedPanel() {
    return IconButton(
      onPressed: _togglePanel,
      icon: const Icon(Icons.chevron_right),
      tooltip: 'Show Panel',
    );
  }

  // Builds the top row with New Chat and Toggle buttons
  Widget _buildTopButtons() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Flexible(
            child: NewChatButton(
              onPressed: () {
                // Handle New Chat action
              },
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: TogglePanelButton(
              onPressed: _togglePanel,
            ),
          ),
        ],
      ),
    );
  }

  // Builds the main content area
  Widget _buildMainContent(BuildContext context) {
    return Expanded(
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
              // Add more content here as needed.
            ],
          ),
        ),
      ),
    );
  }

  // Builds the bottom settings button
  Widget _buildBottomSettingsButton() {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Align(
        alignment: Alignment.bottomCenter,
        child: SettingsButton(
          onPressed: () {
            // Handle Settings action
          },
        ),
      ),
    );
  }
}

class NewChatButton extends StatelessWidget {
  final VoidCallback onPressed;

  const NewChatButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.add),
      tooltip: 'New Chat',
    );
  }
}

class TogglePanelButton extends StatelessWidget {
  final VoidCallback onPressed;

  const TogglePanelButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.chevron_left),
      tooltip: 'Hide Panel',
    );
  }
}

class SettingsButton extends StatelessWidget {
  final VoidCallback onPressed;

  const SettingsButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.settings),
      tooltip: 'Settings',
    );
  }
}
