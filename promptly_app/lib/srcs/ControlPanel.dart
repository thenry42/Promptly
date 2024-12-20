import 'package:flutter/material.dart';
import 'Chat.dart';
import 'Settings.dart';
import 'ModelService.dart';

class ControlPanel extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: Theme.of(context).colorScheme.surfaceContainer,
      child: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: onAddChat,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
            ),
            child: Icon(Icons.add, color: Theme.of(context).colorScheme.onSurface),
          ),
          const SizedBox(height: 20),
          Flexible(
            child: ListView.builder(
              itemCount: chats.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4,
                    horizontal: 10,
                  ),
                  child: ChatList(
                    chat: chats[index],
                    isSelected: selectedChatIndex == index,
                    onTap: () => onSelectChat(index),
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
        ],
      ),
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
    // Extract model type and name from the title format "type:model"
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

  @override
  Widget build(BuildContext context) {
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
              Expanded(
                child: Text(
                  chat.title.split(':')[1], // Show only the model name
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
