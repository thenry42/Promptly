import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:promptly_app/srcs/Anthropic.dart';
import 'package:promptly_app/srcs/ChatCompletion.dart';
import 'package:promptly_app/srcs/Ollama.dart';
import 'package:promptly_app/srcs/OpenAI.dart';
import 'ChatArea.dart';
import 'ControlPanel.dart';
import 'Chat.dart';
import 'ModelService.dart';
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

    final int originalChatIndex = _selectedChatIndex;

    setState(() {
      _chats[originalChatIndex].isSending = true;
      _chats[originalChatIndex].messages.add(
        ChatMessage(sender: 'User', message: message),
      );
    });

    try {
      final selectedLLM = _chats[originalChatIndex].title;
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
        messageList: _chats[originalChatIndex].messages,
      );

      setState(() {
        _chats[originalChatIndex].isSending = false;
        _chats[originalChatIndex].messages.add(
          ChatMessage(sender: 'Bot', message: result),
        );
      });
    } catch (e) {
      setState(() {
        _chats[originalChatIndex].isSending = false;
        _chats[originalChatIndex].messages.add(
          ChatMessage(sender: 'Bot', message: 'Error: $e'),
        );
      });
      if (kDebugMode) {
        print('Error: $e');
      } 
    }
  }

  void _showModelSelectionDialog(BuildContext context, List<Map<String, Object?>> models, String provider, Function(String) onSelect) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Select $provider Model'),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          content: SizedBox(
            width: 300,
            height: 400,
            child: ListView.builder(
              itemCount: models.length,
              itemBuilder: (context, index) {
                final model = models[index];
                final modelValue = '${model['type']}:${model['model']}';
                
                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Theme.of(context).colorScheme.surfaceContainerHigh,
                  ),
                  child: ListTile(
                    title: Text(
                      '${model['model']}',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    onTap: () {
                      onSelect(modelValue);
                      Navigator.of(context).pop();
                    },
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  void _addNewChat() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedLLM;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            final List<Map<String, Object?>> allModels = [
              ...ollamaModels.map((model) => 
                  {'type': 'ollama', 'model': model.model}),
              ...openAIModels.map((model) => 
                  {'type': 'openai', 'model': model.id}),
              ...anthropicModels.map((model) => 
                  {'type': 'anthropic', 'model': model.value}),
            ];

            void selectModel(String model) {
              setDialogState(() {
                selectedLLM = model;
              });
            }

            return AlertDialog(
              backgroundColor: Theme.of(context).colorScheme.surfaceContainer,
              title: const Center(child: Text('New Chat')),
              content: SizedBox(
                height: 200,
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Column(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                final ollamaList = allModels.where((model) => model['type'] == 'ollama').toList();
                                _showModelSelectionDialog(context, ollamaList, 'Ollama', selectModel);
                              },
                              child: Image.asset(
                                'assets/ollama.png',
                                height: 64,
                                width: 64,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Ollama',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Column(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                final anthropicList = allModels.where((model) => model['type'] == 'anthropic').toList();
                                _showModelSelectionDialog(context, anthropicList, 'Anthropic', selectModel);
                              },
                              child: Image.asset(
                                'assets/anthropic.png',
                                height: 64,
                                width: 64,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Anthropic',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 20),
                        Column(
                          children: [
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                                padding: const EdgeInsets.all(16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onPressed: () {
                                final openaiList = allModels.where((model) => model['type'] == 'openai').toList();
                                _showModelSelectionDialog(context, openaiList, 'OpenAI', selectModel);
                              },
                              child: Image.asset(
                                'assets/openai.png',
                                height: 64,
                                width: 64,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Open AI',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    if (selectedLLM != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                'Selected: ${selectedLLM!.split(":")[1]}',
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.onSurface,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                setDialogState(() {
                                  selectedLLM = null;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: TextButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                      ),
                      child: Icon(Icons.cancel, color: Theme.of(context).colorScheme.onSurface),
                    ),
                    TextButton(
                      onPressed: selectedLLM == null ? null : () {
                        setState(() {
                          _chats.add(Chat(title: selectedLLM!));
                          _selectedChatIndex = _chats.length - 1;
                        });
                        Navigator.pop(context);
                      },
                      style: TextButton.styleFrom(
                        shape: const CircleBorder(),
                        padding: const EdgeInsets.all(20),
                        backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
                      ),
                      child: Icon(
                        Icons.check,
                        color: selectedLLM == null 
                          ? Theme.of(context).colorScheme.onSurface.withOpacity(0.5)
                          : Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                  ],
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
            ),
          ),
        ],
      ),
    );
  }
}
