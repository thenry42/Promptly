import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:promptly_app/services/Anthropic.dart';
import 'package:promptly_app/services/ChatCompletion.dart';
import 'package:promptly_app/services/Ollama.dart';
import 'package:promptly_app/services/OpenAI.dart';
import 'ChatArea.dart';
import 'ControlPanel.dart';
import '../models/Chat.dart';
import '../services/ModelService.dart';
import '../models/ChatMessage.dart';
import 'package:ollama_dart/ollama_dart.dart' as ollama;
import 'package:dart_openai/dart_openai.dart' as openai;
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropic;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final TextEditingController _controller = TextEditingController();
  int _selectedChatIndex = -1; // Start with no chat selected
  final List<Chat> _chats = [];
  final ModelService _modelService = ModelService();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _initializeModels();
  }

  Future<void> _initializeModels() async {
    try {
      await _modelService.initializeOllamaModels();
      await _modelService.initializeOpenAiModels();
      await _modelService.initializeAnthropicModels();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing models: $e');
      }
    }
  }

  Future<void> _sendMessage(String message) async {
    if (_selectedChatIndex < 0 || message.isEmpty) return;

    setState(() {
      _isSending = true;
      _chats[_selectedChatIndex].messages.add(
        ChatMessage(sender: 'User', message: message),
      );
    });

    try {
      final selectedLLM = _chats[_selectedChatIndex].title;
      final parts = selectedLLM.split(':');
      final modelType = parts[0];
      Object type;

      switch (modelType) {
        case 'ollama':
          type = ollama.Model;
          break;
        case 'openai':
          type = openai.OpenAIModelModel;
          break;
        case 'anthropic':
          type = anthropic.Model;
          break;
        default:
          throw Exception('Unknown model type');
      }

      final result = await generateChatCompletion(
        model: selectedLLM,
        prompt: message,
        type: type,
      );

      setState(() {
        _isSending = false;
        _chats[_selectedChatIndex].messages.add(
          ChatMessage(sender: 'Bot', message: result),
        );
      });
    } catch (e) {
      setState(() {
        _isSending = false;
        _chats[_selectedChatIndex].messages.add(
          ChatMessage(sender: 'Bot', message: 'Error: $e'),
        );
      });
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }

  void _addNewChat() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedLLM;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final allModels = [
              ...ollamaModels.map((model) => 
                  {'type': 'ollama', 'model': model.model}),
              ...openAIModels.map((model) => 
                  {'type': 'openai', 'model': model.id}),
              ...anthropicModels.map((model) => 
                  {'type': 'anthropic', 'model': model.value}),
            ];

            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              title: const Center(child: Text('New Chat')),
              content: SizedBox(
                height: 120,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // Action for the first button
                            print('Ollama selected');
                          },
                          child: Text('Ollama'),
                        ),
                        SizedBox(width: 20), // Space between buttons
                        ElevatedButton(
                          onPressed: () {
                            // Action for the second button
                            print('Anthropic selected');
                          },
                          child: Text('Anthropic'),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {
                            // Action for the third button
                            print('Open AI selected');
                          },
                          child: Text('Open AI'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedLLM,
                      hint: const Text('Choose LLM'),
                      items: allModels
                          .map((llm) => DropdownMenuItem<String>(
                                value: '${llm['type']}:${llm['model']}',
                                child: Text('${llm['type']}: ${llm['model']}'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setDialogState(() {
                          selectedLLM = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedLLM != null) {
                      setState(() {
                        _chats.add(Chat(title: selectedLLM!));
                        _selectedChatIndex = _chats.length - 1;
                      });
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
      body: Row(
        children: [
          ControlPanel(
            chats: _chats,
            selectedChatIndex: _selectedChatIndex,
            onAddChat: _addNewChat,
            onSelectChat: (index) => setState(() => _selectedChatIndex = index),
          ),
          Expanded(
            child: ChattingArea(
              chats: _chats,
              selectedChatIndex: _selectedChatIndex,
              onSendMessage: _sendMessage,
              controller: _controller,
              isSending: _isSending,
            ),
          ),
        ],
      ),
    );
  }
}