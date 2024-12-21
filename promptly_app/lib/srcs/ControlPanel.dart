import 'package:flutter/material.dart';
import 'Chat.dart';
import 'Settings.dart';
import 'ModelService.dart';

class ControlPanel extends StatefulWidget {
  final List<Chat> chats;
  final VoidCallback onAddChat;
  final int selectedChatIndex;
  final Function(int) onSelectChat;

  const ControlPanel({
    super.key,
    required this.chats,
    required this.selectedChatIndex,
    required this.onAddChat,
    required this.onSelectChat,
  });

  @override
  State<ControlPanel> createState() => _ControlPanelState();
}

class _ControlPanelState extends State<ControlPanel> with SingleTickerProviderStateMixin {
  bool _isExpanded = true;
  late AnimationController _animationController;
  late Animation<double> _widthAnimation;

  Widget _getProviderIcon(String provider) {
    switch (provider.toLowerCase()) {
      case 'anthropic':
        return Image.asset(
          'assets/anthropic.png',
          width: 24,
          height: 24,
        );
      case 'openai':
        return Image.asset(
          'assets/openai.png',
          width: 24,
          height: 24,
        );
      case 'ollama':
        return Image.asset(
          'assets/ollama.png',
          width: 24,
          height: 24,
        );
      default:
        return const Icon(Icons.smart_toy, size: 24);
    }
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _widthAnimation = Tween<double>(
      begin: 300,
      end: 70,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    _animationController.value = 0;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _togglePanel() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.reverse();
      } else {
        _animationController.forward();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // Get the selected chat's provider if a chat is selected
    String? selectedProvider;
    if (widget.selectedChatIndex >= 0 && widget.selectedChatIndex < widget.chats.length) {
      final modelParts = widget.chats[widget.selectedChatIndex].title.split(':');
      selectedProvider = modelParts[0];
    }

    return AnimatedBuilder(
      animation: _widthAnimation,
      builder: (context, child) {
        return Container(
          width: _widthAnimation.value,
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: Column(
            children: [
              const SizedBox(height: 20),
              if (_isExpanded) ...[
                Stack(
                  alignment: Alignment.center,
                  children: [
                    // Centered Add button
                    Center(
                      child: ElevatedButton(
                        onPressed: widget.onAddChat,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                        ),
                        child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
                      ),
                    ),
                    // Toggle button on the right
                    Positioned(
                      right: 10,
                      child: ElevatedButton(
                        onPressed: _togglePanel,
                        style: ElevatedButton.styleFrom(
                          shape: const CircleBorder(),
                          padding: const EdgeInsets.all(20),
                          backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                        ),
                        child: Icon(
                          Icons.chevron_left,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Flexible(
                  child: ListView.builder(
                    itemCount: widget.chats.length,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 4,
                          horizontal: 10,
                        ),
                        child: ChatList(
                          chat: widget.chats[index],
                          isSelected: widget.selectedChatIndex == index,
                          onTap: () => widget.onSelectChat(index),
                        ),
                      );
                    },
                  ),
                ),
                ElevatedButton(
                  onPressed: () => SettingsDialog.show(context),
                  style: ElevatedButton.styleFrom(
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(20),
                    backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                  ),
                  child: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 20),
              ] else ...[
                // Collapsed state with centered buttons and selected model icon
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: _togglePanel,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                    child: Icon(
                      Icons.chevron_right,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: ElevatedButton(
                    onPressed: widget.onAddChat,
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                    ),
                    child: Icon(
                      Icons.add,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                if (selectedProvider != null) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      ),
                      child: _getProviderIcon(selectedProvider),
                    ),
                  ),
                ],
                const Spacer(),
                Center(
                  child: ElevatedButton(
                    onPressed: () => SettingsDialog.show(context),
                    style: ElevatedButton.styleFrom(
                      shape: const CircleBorder(),
                      padding: const EdgeInsets.all(20),
                      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                    ),
                    child: Icon(
                      Icons.settings,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ],
          ),
        );
      },
    );
  }
}

class ModelInfoDialog extends StatefulWidget {
  final String modelTitle;

  const ModelInfoDialog({
    super.key,
    required this.modelTitle,
  });

  static void show(BuildContext context, String modelTitle) {
    showDialog(
      context: context,
      builder: (context) => ModelInfoDialog(modelTitle: modelTitle),
    );
  }

  @override
  State<ModelInfoDialog> createState() => _ModelInfoDialogState();
}

class _ModelInfoDialogState extends State<ModelInfoDialog> {
  @override
  Widget build(BuildContext context) {
    final modelParts = widget.modelTitle.split(':');
    final modelType = modelParts[0];
    final modelName = modelParts[1];

    return AlertDialog(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Model Information'),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _InfoSection(
              children: [
                _InfoRow(label: 'Provider', value: modelType),
                _InfoRow(label: 'Model', value: modelName),
                _InfoRow(label: 'Context window', value: getContextWindow(modelName)),
                _InfoRow(label: 'Temperature', value: getTemp(modelName)),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final List<Widget> children;

  const _InfoSection({
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 12),
        ...children,
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class ChatList extends StatelessWidget {
  final Chat chat;
  final bool isSelected;
  final VoidCallback onTap;

  const ChatList({
    super.key,
    required this.chat,
    required this.isSelected,
    required this.onTap,
  });

  Widget _getProviderIcon(String provider) {
    switch (provider.toLowerCase()) {
      case 'anthropic':
        return Image.asset(
          'assets/anthropic.png',
          width: 24,
          height: 24,
        );
      case 'openai':
        return Image.asset(
          'assets/openai.png',
          width: 24,
          height: 24,
        );
      case 'ollama':
        return Image.asset(
          'assets/ollama.png',
          width: 24,
          height: 24,
        );
      default:
        return const Icon(Icons.smart_toy, size: 24);
    }
  }

  @override
  Widget build(BuildContext context) {
    final modelParts = chat.title.split(':');
    final provider = modelParts[0];
    final modelName = modelParts[1];

    return Material(
      color: isSelected
          ? Theme.of(context).colorScheme.surfaceContainerHighest
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _getProviderIcon(provider),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  modelName,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurface,
                    fontWeight: isSelected ? FontWeight.bold : null,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.info, size: 20),
                onPressed: () => ModelInfoDialog.show(context, chat.title),
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
