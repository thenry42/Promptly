import 'package:flutter/material.dart';
import 'Chat.dart';
import 'Settings.dart';

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
          Text('Model Settings'),
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
              title: 'Model Information',
              children: [
                _InfoRow(label: 'Provider', value: modelType),
                _InfoRow(label: 'Model', value: modelName),
              ],
            ),
            const SizedBox(height: 20),
            _InfoSection(
              title: 'Model Settings',
              children: [
                _SliderSetting(
                  label: 'Temperature',
                  value: 0.7,
                  onChanged: (value) {
                    // Handle temperature change
                  },
                ),
                const SizedBox(height: 12),
                _SliderSetting(
                  label: 'Max Tokens',
                  value: 0.8,
                  onChanged: (value) {
                    // Handle max tokens change
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _InfoSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
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

class _SliderSetting extends StatefulWidget {
  final String label;
  final double value;
  final ValueChanged<double> onChanged;

  const _SliderSetting({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  State<_SliderSetting> createState() => _SliderSettingState();
}

class _SliderSettingState extends State<_SliderSetting> {
  late double _value;

  @override
  void initState() {
    super.initState();
    _value = widget.value;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(widget.label),
            Text(_value.toStringAsFixed(1)),
          ],
        ),
        Slider(
          value: _value,
          onChanged: (value) {
            setState(() {
              _value = value;
            });
            widget.onChanged(value);
          },
        ),
      ],
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
                icon: const Icon(Icons.tune, size: 20),
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