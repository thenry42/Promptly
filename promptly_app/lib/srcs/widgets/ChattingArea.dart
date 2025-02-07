import 'package:flutter/material.dart';
import 'package:promptly_app/srcs/backend/ChatMessage.dart';
import 'package:promptly_app/srcs/backend/Singleton.dart';
import 'package:promptly_app/srcs/backend/Chat.dart';
import 'package:promptly_app/srcs/widgets/ChatMessageWidget.dart';

class ChattingArea extends StatefulWidget {
  const ChattingArea({Key? key}) : super(key: key);

  @override
  _ChattingAreaState createState() => _ChattingAreaState();
}

class _ChattingAreaState extends State<ChattingArea> {
  final metadata = Singleton();
  late String message;
  final TextEditingController _textController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Listen for changes in selectedChatIndex
    metadata.addChatSelectionListener(_onChatSelected);
  }

  @override
  void dispose() {
    // Remove listener when widget is disposed
    metadata.removeChatSelectionListener(_onChatSelected);
    _textController.dispose();
    super.dispose();
  }

  // Callback for chat selection changes
  void _onChatSelected() {
    setState(() {
      // Force widget rebuild when chat is selected
    });
  }

  void _sendMessage() async {
    if (_textController.text.isNotEmpty) {
      setState(() {
        ChatMessage message = ChatMessage(
          sender: "User",
          message: _textController.text,
          timestamp: DateTime.now(),
          rawMessage: _textController.text,
        );
        metadata.chatList[metadata.selectedChatIndex].addChatMessage(message);
        _textController.clear();
        _isLoading = true;  // Set loading state to true before generating response
      });

      try {
        await metadata.chatList[metadata.selectedChatIndex].generateMessageRequest(metadata: metadata);
      } finally {
        if (mounted) {  // Check if widget is still mounted
          setState(() {
            _isLoading = false;  // Set loading state to false after response
          });
        }
      }
    }
  }

  Widget _buildMessagesList() {
    if (metadata.chatList.isEmpty) {
      return const Center(
        child: Text(
          'No chats yet. Start a new conversation!',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    if (metadata.selectedChatIndex < 0 || 
        metadata.selectedChatIndex >= metadata.chatList.length) {
      return const Center(
        child: Text(
          'Please select a chat to start messaging',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    final messages = metadata.chatList[metadata.selectedChatIndex].messages;
    if (messages.isEmpty) {
      return const Center(
        child: Text(
          'No messages yet. Start the conversation!',
          style: TextStyle(
            color: Colors.grey,
            fontSize: 16,
          ),
        ),
      );
    }

    return Stack(
      children: [
        ListView.builder(
          itemCount: messages.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ChatMessageWidget(message: messages[index]),
            );
          },
        ),
        if (_isLoading)
          Positioned(
            left: 0,
            right: 0,
            bottom: 50,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildInputArea() {
    bool isInputEnabled = metadata.chatList.isNotEmpty && 
        metadata.selectedChatIndex >= 0 &&
        metadata.selectedChatIndex < metadata.chatList.length;

    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: _textController,
            enabled: isInputEnabled,
            decoration: InputDecoration(
              hintText: isInputEnabled 
                ? 'Type a message...' 
                : 'Select a chat to start messaging',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12, 
                vertical: 8,
              ),
            ),
            onSubmitted: isInputEnabled ? (_) => _sendMessage() : null,
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          icon: const Icon(Icons.send),
          onPressed: isInputEnabled ? _sendMessage : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: _buildMessagesList(),
        ),
        _buildInputArea(),
      ],
    );
  }
}
