import 'package:flutter/material.dart';
import '../models/conversation.dart';
import '../models/chat_message.dart';
import '../widgets/conversation_list_tile.dart';
import '../widgets/chat_message_widget.dart';
import '../services/api_service.dart';

class LLMInteractionPage extends StatefulWidget {
  const LLMInteractionPage({super.key});

  @override
  _LLMInteractionPageState createState() => _LLMInteractionPageState();
}

class _LLMInteractionPageState extends State<LLMInteractionPage> {
  final TextEditingController _controller = TextEditingController();
  String _response = '';
  String _sendingMessage = '';
  bool _isSending = false;
  int _selectedConversationIndex = 0;

  List<Conversation> _conversations = [Conversation(title: 'Chat 1')];

  Future<void> _sendRequest() async {
    setState(() {
      _sendingMessage = _controller.text;
      _isSending = true;

      // Add the user's message to the conversation history immediately
      _conversations[_selectedConversationIndex].messages.add(
        ChatMessage(sender: 'User', message: _sendingMessage),
      );
    });

    _controller.clear(); // Clear the text area after sending

    // Simulate a delay to mimic the bot thinking (for development)
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      // Automated response from bot for development purposes
      _response = 'Automated Bot Response: Your message was "$_sendingMessage".';

      // Add the bot's response to the conversation history
      _conversations[_selectedConversationIndex].messages.add(
        ChatMessage(sender: 'Bot', message: _response),
      );

      _isSending = false;
    });
  }

  void _addNewConversation() {
    setState(() {
      _conversations.add(Conversation(title: 'Chat ${_conversations.length + 1}'));
      _selectedConversationIndex = _conversations.length - 1;
    });
  }

  void _selectConversation(int index) {
    setState(() {
      _selectedConversationIndex = index;
      _response = '';
      _sendingMessage = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('LLM Interaction')),
      body: Row(
        children: [
          // Left panel for conversation management
          Container(
            width: 200,
            color: Colors.blueGrey[50],
            child: Column(
              children: [
                const SizedBox(height: 16),
                Center(
                  child: IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: _addNewConversation,
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: _conversations.length,
                    itemBuilder: (context, index) {
                      return ConversationListTile(
                        conversation: _conversations[index],
                        isSelected: _selectedConversationIndex == index,
                        onTap: () => _selectConversation(index),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          // Main chat area
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_isSending)
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Sending: $_sendingMessage',
                            style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                          ),
                        ),
                        const SizedBox(width: 8),
                        const CircularProgressIndicator(),
                      ],
                    ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _conversations[_selectedConversationIndex].messages.length,
                      itemBuilder: (context, index) {
                        final message = _conversations[_selectedConversationIndex].messages[index];
                        return ChatMessageWidget(message: message);
                      },
                    ),
                  ),
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _controller,
                          maxLines: null,
                          decoration: const InputDecoration(
                            labelText: 'Enter your message',
                            border: OutlineInputBorder(),
                          ),
                          textInputAction: TextInputAction.send,
                          onFieldSubmitted: (_) => _sendRequest(), // Trigger send on Enter
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.send, color: Colors.blue),
                        onPressed: _sendRequest,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
