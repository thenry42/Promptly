import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../models/chat_message.dart';
import 'conversation_panel.dart';
import 'chat_area.dart';
import '../models/llm_list.dart'; // Import the LLM list

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

    // Check if no conversations exist
    if (_conversations.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No conversation selected. Please create a conversation first.')),
      );
      return; // Exit the function early
    }

    // Check if message is empty after trimming
    if (messageText.isEmpty) {
      _controller.clear(); // Clear the input field if the message is empty
      return; // Exit the function early
    }

    setState(() {
      _isSending = true;

      // Add the user's message to the conversation history
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
        String? selectedLLM;

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
                      items: llmList.map((llm) {
                        return DropdownMenuItem<String>(
                          value: llm['name'],
                          child: Text(llm['name']!),
                        );
                      }).toList(),
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
                        Conversation(
                          title: selectedLLM!,
                          isOnline: llmList.firstWhere(
                                (llm) => llm['name'] == selectedLLM,
                              )['type'] ==
                              'online', // Determine if it's online
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
