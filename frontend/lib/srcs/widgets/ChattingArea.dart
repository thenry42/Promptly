import 'package:flutter/material.dart';
import 'package:flutter/services.dart';  // Add this import for keyboard handling
// Import the necessary classes for keyboard events
import 'package:flutter/services.dart' show KeyEvent, KeyDownEvent, LogicalKeyboardKey, HardwareKeyboard;
import 'package:promptly_app/srcs/services/ChatMessage.dart';
import 'package:promptly_app/srcs/services/Singleton.dart';
import 'package:promptly_app/srcs/services/Chat.dart';
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
  final ScrollController _scrollController = ScrollController(); // Add this line
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
    _scrollController.dispose();
    super.dispose();
  }

  // Callback for chat selection changes
  void _onChatSelected() {
    setState(() {
      // Force widget rebuild when chat is selected
    });
    // Add this line to scroll to bottom after chat selection
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottomInstant());
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToBottomInstant() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
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
    
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

      try {
        await metadata.chatList[metadata.selectedChatIndex].generateMessageRequest(metadata: metadata);
      } finally {
        if (mounted) {  // Check if widget is still mounted
          setState(() {
            _isLoading = false;  // Set loading state to false after response
          });
          WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
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
          controller: _scrollController,
          itemCount: messages.length + (_isLoading ? 1 : 0), // Add 1 to itemCount if loading
          itemBuilder: (context, index) {
            if (index == messages.length && _isLoading) {
              // Return loading indicator as the last item
              return const Padding(
                padding: EdgeInsets.all(16.0),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: ChatMessageWidget(message: messages[index]),
            );
          },
        ),
      ],
    );
  }

  Widget _buildInputArea() {
    bool isInputEnabled = metadata.chatList.isNotEmpty &&
        metadata.selectedChatIndex >= 0 &&
        metadata.selectedChatIndex < metadata.chatList.length;

    return Padding(
      padding: const EdgeInsets.all(8.0), // Reduced padding
      child: LayoutBuilder(
        builder: (context, constraints) {
          return Stack(
            children: [
              Container(
                constraints: BoxConstraints(
                  maxWidth: constraints.maxWidth, // Ensure container respects parent width
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: Colors.grey.withOpacity(0.3),
                  ),
                ),
                child: Focus(
                  onKeyEvent: (FocusNode node, KeyEvent event) {
                    if (isInputEnabled && 
                        event is KeyDownEvent && 
                        event.logicalKey == LogicalKeyboardKey.enter && 
                        !(HardwareKeyboard.instance.isShiftPressed || HardwareKeyboard.instance.isControlPressed)) {
                      _sendMessage();
                      return KeyEventResult.handled;
                    }
                    return KeyEventResult.ignored;
                  },
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
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(
                        left: 16, // Reduced padding
                        right: 48, // Reduced padding, but keep space for send button
                        top: 12, // Reduced padding
                        bottom: 12, // Reduced padding
                      ),
                      isCollapsed: false,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 8, // Reduced positioning
                right: 8, // Reduced positioning
                child: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: isInputEnabled ? _sendMessage : null,
                  constraints: const BoxConstraints(
                    minWidth: 32.0, // Slightly smaller button
                    minHeight: 32.0, // Slightly smaller button
                  ),
                  iconSize: 20, // Slightly smaller icon
                ),
              ),
            ],
          );
        }
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: _buildMessagesList(),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: _buildInputArea(),
          ),
        ],
      ),
    );
  }
}
