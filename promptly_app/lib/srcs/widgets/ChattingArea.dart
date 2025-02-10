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
      return Center(
        child: Text(
          'No chats yet. Start a new conversation!',
          style: TextStyle(
            color: Colors.grey,
            fontSize: metadata.fontSize,
            fontFamily: metadata.fontFamily,
          ),
        ),
      );
    }

    if (metadata.selectedChatIndex < 0 || 
        metadata.selectedChatIndex >= metadata.chatList.length) {
      return Center(
        child: Text(
          'Please select a chat to start messaging',
          style: TextStyle(
            color: Colors.grey,
            fontSize: metadata.fontSize,
            fontFamily: metadata.fontFamily,
          ),
        ),
      );
    }

    final messages = metadata.chatList[metadata.selectedChatIndex].messages;
    if (messages.isEmpty) {
      return Center(
        child: Text(
          'No messages yet. Start the conversation!',
          style: TextStyle(
            color: Colors.grey,
            fontSize: metadata.fontSize,
            fontFamily: metadata.fontFamily,
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

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        constraints: const BoxConstraints(
          maxHeight: 500,
        ),
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24), // More rounded corners
                border: Border.all(
                  color: Colors.grey.withOpacity(0.3),
                ),
              ),
              child: TextFormField(
                controller: _textController,
                enabled: isInputEnabled,
                maxLines: 30,
                minLines: 1,
                keyboardType: TextInputType.multiline,
                style: TextStyle(
                  fontFamily: metadata.fontFamily,
                  fontSize: metadata.fontSize,
                ),
                scrollPhysics: const BouncingScrollPhysics(),
                decoration: InputDecoration(
                  hintText: isInputEnabled ? 'Type a message...' : 'Select a chat to start messaging',
                  border: InputBorder.none, // Remove default border
                  contentPadding: const EdgeInsets.only(
                    left: 24,
                    right: 64, // Make space for the send button
                    top: 20,
                    bottom: 20,
                  ),
                  isCollapsed: false,
                ),
                onFieldSubmitted: isInputEnabled ? (_) => _sendMessage : null,
              ),
            ),
            Positioned(
              bottom: 16,
              right: 16,
              child: IconButton(
                icon: const Icon(Icons.send),
                onPressed: isInputEnabled ? _sendMessage : null,
                constraints: const BoxConstraints(
                  minWidth: 40.0,
                  minHeight: 40.0,
                ),
                iconSize: 24,
              ),
            ),
          ],
        ),
      ),
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
