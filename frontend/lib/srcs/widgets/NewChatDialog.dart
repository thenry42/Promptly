import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/services/Singleton.dart';
import 'package:promptly_app/srcs/services/Chat.dart';

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
      title: Text('Create New Chat', style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Model Type Selection
          DropdownButtonFormField<String>(
            isExpanded: true,
            style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily),
            value: selectedModelType,
            decoration: const InputDecoration(
              labelText: 'Model Type',
              border: OutlineInputBorder(),
            ),
            items: [
              DropdownMenuItem(value: 'Anthropic', child: Text('Anthropic', style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily))),
              DropdownMenuItem(value: 'Ollama', child: Text('Ollama', style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily))),
              DropdownMenuItem(value: 'OpenAI', child: Text('OpenAI', style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily))),
              DropdownMenuItem(value: 'Mistral', child: Text('Mistral', style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily))),
              DropdownMenuItem(value: 'Gemini', child: Text('Gemini', style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily))),
              DropdownMenuItem(value: 'DeepSeek', child: Text('DeepSeek', style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily))),
            ],
            onChanged: (value) {
              setState(() {
                selectedModelType = value;
                selectedModel = null; // Reset model selection when type changes
              });
            },
          ),
          const SizedBox(height: 16),
          
          // Model Selection - Always displayed, disabled if no model type selected
          DropdownButtonFormField<String>(
            isExpanded: true,
            style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily),
            value: selectedModel,
            decoration: const InputDecoration(
              labelText: 'Model',
              border: OutlineInputBorder(),
            ),
            items: selectedModelType != null 
                ? _getModelItems(selectedModelType!, metadata)
                : [], // Empty list if no model type selected
            onChanged: selectedModelType != null 
                ? (value) {
                    setState(() {
                      selectedModel = value;
                    });
                  }
                : null, // Disabled if no model type selected
            hint: Text(
              selectedModelType == null 
                ? 'Select a model type first' 
                : 'Select a model',
              style: TextStyle(
                fontSize: metadata.fontSize, 
                fontFamily: metadata.fontFamily,
                color: Colors.grey,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel', style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily)),
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
          child: Text('Create', style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily)),
        ),
      ],
    );
  }

  Widget _buildProviderDropdownItem(String providerType, double fontSize, String fontFamily) {
    return Row(
      children: [
        Image(image: _getProviderIcon(providerType), width: 20, height: 20),
        const SizedBox(width: 8),
        Text(providerType, style: TextStyle(fontSize: fontSize, fontFamily: fontFamily))
      ],
    );
  }
  
  AssetImage _getProviderIcon(String type) {
    switch (type) {
      case 'Gemini':
        return const AssetImage('assets/images/gemini.png');
      case 'Mistral':
        return const AssetImage('assets/images/mistral.png');
      case 'DeepSeek':
        return const AssetImage('assets/images/deepseek.png');
      case 'Ollama':
        return const AssetImage('assets/images/ollama.png');
      case 'OpenAI':
        return const AssetImage('assets/images/openai.png');
      case 'Anthropic':
        return const AssetImage('assets/images/anthropic.png');
      default:
        return const AssetImage('assets/images/error.png');
    }
  }

  List<DropdownMenuItem<String>> _getModelItems(String type, Singleton metadata) {
    switch (type) {
      case 'Anthropic':
        return metadata.anthropic_models
            .map((modelId) => DropdownMenuItem<String>(
                  value: modelId,
                  child: Text(modelId, style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily)),
                ))
            .toList();
      case 'Ollama':
        return metadata.ollama_models
            .map((modelName) => DropdownMenuItem<String>(
                  value: modelName,
                  child: Text(modelName, style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily)),
                ))
            .toList();
      case 'OpenAI':
        return metadata.openai_models
            .map((modelId) => DropdownMenuItem<String>(
                  value: modelId,
                  child: Text(modelId, style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily)),
                ))
            .toList();
      case 'Mistral':
        return metadata.mistral_models
            .map((modelId) => DropdownMenuItem<String>(
                  value: modelId,
                  child: Text(modelId, style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily)),
                ))
            .toList();
      case 'Gemini':
        return metadata.gemini_models
            .map((modelId) => DropdownMenuItem<String>(
                  value: modelId,
                  child: Text(modelId, style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily)),
                ))
            .toList();
      case 'DeepSeek':
        return metadata.deepseek_models
            .map((modelId) => DropdownMenuItem<String>(
                  value: modelId,
                  child: Text(modelId, style: TextStyle(fontSize: metadata.fontSize, fontFamily: metadata.fontFamily)),
                ))
            .toList();
      default:
        return [];
    }
  }
}
