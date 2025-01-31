import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/backend/Singleton.dart';
import 'package:promptly_app/srcs/backend/Chat.dart';

class NewChatDialog extends StatefulWidget {
  final VoidCallback onChatCreated;
  
  const NewChatDialog({super.key, required this.onChatCreated});

  @override
  State<NewChatDialog> createState() => _NewChatDialogState();
}

class _NewChatDialogState extends State<NewChatDialog> {
  String? selectedModelType;
  String? selectedModel;

  @override
  Widget build(BuildContext context) {
    final metadata = Singleton();

    return AlertDialog(
      title: const Text('Create New Chat'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Model Type Selection
          DropdownButtonFormField<String>(
            value: selectedModelType,
            decoration: const InputDecoration(
              labelText: 'Model Type',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Anthropic', child: Text('Anthropic')),
              DropdownMenuItem(value: 'Ollama', child: Text('Ollama')),
              DropdownMenuItem(value: 'OpenAI', child: Text('OpenAI')),
            ],
            onChanged: (value) {
              setState(() {
                selectedModelType = value;
                selectedModel = null; // Reset model selection when type changes
              });
            },
          ),
          const SizedBox(height: 16),
          // Model Selection
          if (selectedModelType != null)
            DropdownButtonFormField<String>(
              value: selectedModel,
              decoration: const InputDecoration(
                labelText: 'Model',
                border: OutlineInputBorder(),
              ),
              items: _getModelItems(selectedModelType!, metadata),
              onChanged: (value) {
                setState(() {
                  selectedModel = value;
                });
              },
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: selectedModel != null
              ? () {
                  final metadata = Singleton();
                  final newChatId = metadata.chatList.isEmpty ? 0 : metadata.chatList.last.id + 1;
                  final isFirstChat = metadata.chatList.isEmpty ? true : false;
                  
                  final newChat = Chat(
                    id: newChatId,
                    modelName: selectedModel!,
                    type: selectedModelType!,
                    isSelected: isFirstChat,
                  );
                  
                  metadata.chatList.add(newChat);
                  widget.onChatCreated();
                  Navigator.of(context).pop();
                }
              : null,
          child: const Text('Create'),
        ),
      ],
    );
  }

  List<DropdownMenuItem<String>> _getModelItems(String type, Singleton metadata) {
    switch (type) {
      case 'Anthropic':
        return metadata.anthropic_models
            .map((model) => DropdownMenuItem(
                  value: model.value.toString(),
                  child: Text(model.value.toString()),
                ))
            .toList();
      case 'Ollama':
        return metadata.ollama_models
            .map((model) => DropdownMenuItem(
                  value: model.model!,
                  child: Text(model.model!),
                ))
            .toList();
      case 'OpenAI':
        return metadata.openai_models
            .map((model) => DropdownMenuItem(
                  value: model.id,
                  child: Text(model.id),
                ))
            .toList();
      default:
        return [];
    }
  }
}
