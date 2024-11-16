import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../models/chat_message.dart';
import 'conversation_panel.dart';
import 'chat_area.dart';

class LLMInteractionPage extends StatefulWidget {
  const LLMInteractionPage({super.key});

  @override
  _LLMInteractionPageState createState() => _LLMInteractionPageState();
}

class _LLMInteractionPageState extends State<LLMInteractionPage> {
  final TextEditingController _controller = TextEditingController();
  bool _isSending = false;
  int _selectedConversationIndex = 0;

  final List<Conversation> _conversations = [];

  Future<void> _sendRequest() async {
    final messageText = _controller.text.trim(); // Trim whitespace from the message

    // Check if message is empty after trimming
    if (messageText.isEmpty) {
      // If message is empty or only whitespace, clear the input and return without sending
      _controller.clear();
      return;
    }

    setState(() {
      _isSending = true;

      // Add the user's message to the conversation history using trimmed text
      _conversations[_selectedConversationIndex].messages.add(
        ChatMessage(sender: 'User', message: messageText),
      );
    });

    _controller.clear(); // Clear the text area after sending a valid message

    // Simulate a delay to mimic the bot thinking (for development)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      // Automated response from bot for development purposes
      final response = 'Automated Bot Response: Your message was "$messageText".';
      _conversations[_selectedConversationIndex].messages.add(
        ChatMessage(sender: 'Bot', message: response),
      );
      _isSending = false;
    });
  }

  void _addNewConversation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String chatName = '';
        bool isOnline = false;
        String apiKey = '';

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('New Chat'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Chat Name Input
                  TextField(
                    decoration: const InputDecoration(
                      labelText: 'Chat Name',
                      hintText: 'Enter a name for the chat',
                    ),
                    onChanged: (value) {
                      chatName = value;
                    },
                  ),
                  const SizedBox(height: 10),
                  // Local or Online Toggle
                  Row(
                    children: [
                      const Text('Local'),
                      Switch(
                        value: isOnline,
                        onChanged: (value) {
                          setDialogState(() {
                            isOnline = value;
                          });
                        },
                      ),
                      const Text('Online'),
                    ],
                  ),
                  if (isOnline) ...[
                    const SizedBox(height: 10),
                    // API Key Input
                    TextField(
                      decoration: const InputDecoration(
                        labelText: 'API Key',
                        hintText: 'Enter the API key',
                      ),
                      onChanged: (value) {
                        apiKey = value;
                      },
                    ),
                  ],
                ],
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
                    if (chatName.isEmpty) {
                      // Validate that chat name is not empty
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Chat name cannot be empty')),
                      );
                      return;
                    }

                    setState(() {
                      _conversations.add(
                        Conversation(
                          title: chatName,
                          isOnline: isOnline,
                          apiKey: isOnline ? apiKey : null, // Include API key if online
                        ),
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

  void _selectConversation(int index) {
    setState(() {
      _selectedConversationIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LLM Interaction')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Row(
            children: [
              // Left conversation panel with fixed width
              SizedBox(
                width: 200,
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
