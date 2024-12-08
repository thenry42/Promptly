import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropic;
import 'package:dart_openai/dart_openai.dart' as openai;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:ollama_dart/ollama_dart.dart' as ollama;
import 'package:promptly_app/models/anthropic_list.dart';
import 'package:promptly_app/models/open_ai_list.dart';
import '../models/conversation.dart';
import '../models/chat_message.dart';
import 'conversation_panel.dart';
import 'chat_area.dart';
import '../models/ollama_list.dart'; // Import the LLM list
import '../services/chat_completion.dart';

class LLMInteractionPage extends StatefulWidget {
  const LLMInteractionPage({super.key});

  @override
  _LLMInteractionPageState createState() => _LLMInteractionPageState();
}

class _LLMInteractionPageState extends State<LLMInteractionPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;
  int _selectedConversationIndex = 0;
  bool _isLoadingModels = true;

  final List<Conversation> _conversations = [];

  @override
  void initState() {
    super.initState();
    _initializeOllamaModels();
    _initializeOpenAiModels();
    _initializeAnthropicModels();
  }

  Future<void> _initializeOllamaModels() async {
    setState(() {
      _isLoadingModels = true;
    });

    try {
      await getOllamaModels();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing ollama models: $e');
      }
    } finally {
      setState(() {
        _isLoadingModels = false;
      });
    }
  }

  Future<void> _initializeOpenAiModels() async {
    setState(() {
      _isLoadingModels = true;
    });

    try {
      await getOpenAIModels();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing OpenAI models: $e');
      }
    } finally {
      setState(() {
        _isLoadingModels = false;
      });
    }
  }
  
  Future<void> _initializeAnthropicModels() async {
    setState(() {
      _isLoadingModels = true;
    });

    try {
      await getAnthropicModels();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Anthropic models: $e');
      }
    } finally {
      setState(() {
        _isLoadingModels = false;
      });
    }
  }
  
  Future<void> _sendRequest() async {
    final messageText = _controller.text.trim();

    // Check if no conversations exist
    if (_conversations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No conversation selected. Please create a conversation first.')),
      );
      return;
    }

    // Check if message is empty after trimming
    if (messageText.isEmpty) {
      _controller.clear(); // Clear the input field if the message is empty
      return;
    }

    setState(() {
      _isSending = true;

      // Add the user's message to the conversation history
      _conversations[_selectedConversationIndex].messages.add(
        ChatMessage(sender: 'User', message: messageText),
      );
    });

    _controller.clear(); // Clear the text area after sending a valid message

    try {

      Object type = [];

      final selectedLLM = _conversations[_selectedConversationIndex].title;
      final parts = selectedLLM.split(':');
      final modelType = parts[0]; // "ollama" or "openai"

      if (modelType == 'ollama') {
        type = ollama.Model; // Ollama model
      } else if (modelType == 'openai') {
        type = openai.OpenAIModelModel; // OpenAI model
      } else if (modelType == 'anthropic') {
        type = anthropic.Model;
      }

      final result = await generateChatCompletion(
        model: _conversations[_selectedConversationIndex].title, 
        prompt: messageText,
        type: type,
      );
      setState(() {
        // Add Model's response to the conversation
        _conversations[_selectedConversationIndex].messages.add(
          ChatMessage(sender: 'Bot', message: result),
        );
        _isSending = false;
      });
    } catch (e) {
      setState(() {
        _isSending = false;
        _conversations[_selectedConversationIndex].messages.add(
          ChatMessage(sender: 'Bot', message: 'Error: $e'),
        );
      });
      if (kDebugMode) {
        print('Error: $e');
      }
    }
  }
  
  void _addNewConversation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String? selectedLLM;

        // spread operator
        final allModels = [
          ...ollamaModels.map((model) => {'type': 'ollama', 'model': model.model}),
          ...openAIModels.map((model) => {'type': 'openai', 'model': model.id}),
          ...anthropicModels.map((model) => {'type': 'anthropic', 'model': model.value}),
        ];

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New Chat'),
              content: SizedBox(
                width: MediaQuery.of(context).size.width * 0.5,
                height: MediaQuery.of(context).size.height * 0.4,
                child: Column(
                  children: [
                    const Text('Select a Language Model:'),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedLLM,
                      hint: const Text('Choose LLM'),
                      items: allModels.map((llm) => getDropdownItem(llm)).toList(),
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
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog without action
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (selectedLLM == null) {
                      // Ensure an LLM is selected before proceeding
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please select an LLM')),
                      );
                      return;
                    }

                    setState(() {
                      // Add the new conversation with the selected LLM
                      _conversations.add(
                        Conversation(title: selectedLLM!)
                      );
                      _selectedConversationIndex = _conversations.length - 1;
                    });

                    Navigator.pop(context); // Close the dialog
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

  DropdownMenuItem<String> getDropdownItem(Map<String, Object?> llm) {
    String label;
    switch (llm['type']) {
      case 'ollama':
        label = 'Ollama: ${llm['model']}';
        break;
      case 'openai':
        label = 'OpenAI: ${llm['model']}';
        break;
      case 'anthropic':
        label = 'Anthropic: ${llm['model']}';
        break;
      default:
        label = 'Unknown: ${llm['model']}';
    }
    return DropdownMenuItem<String>(
      value: '${llm['type']}:${llm['model']}',
      child: Text(label),
    );
  }

  void _selectConversation(int index) {
    setState(() {
      _selectedConversationIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              // Left conversation panel with fixed width
              SizedBox(
                width: 300,
                child: ConversationPanel(
                  conversations: _conversations,
                  selectedConversationIndex: _selectedConversationIndex,
                  onAddConversation: _addNewConversation,
                  onSelectConversation: _selectConversation,
                ),
              ),
              // Main chat area expands to take remaining width
              Expanded(
                child: ChatArea(
                  conversations: _conversations,
                  selectedConversationIndex: _selectedConversationIndex,
                  controller: _controller,
                  isSending: _isSending,
                  onSendMessage: _sendRequest,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
