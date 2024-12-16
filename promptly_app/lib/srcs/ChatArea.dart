import 'Chat.dart';
import 'package:flutter/material.dart';
import 'LoadingIndicator.dart';

class ChattingArea extends StatefulWidget {
  final List<Chat> chats;
  final int selectedChatIndex;
  final TextEditingController controller;
  final Function(String) onSendMessage;

  const ChattingArea({
    super.key,
    required this.chats,
    required this.selectedChatIndex,
    required this.controller,
    required this.onSendMessage,
  });

  @override
  _ChattingAreaState createState() => _ChattingAreaState();

}

class _ChattingAreaState extends State<ChattingArea> {
  final ScrollController _scrollController = ScrollController();

  @override
  void didUpdateWidget(ChattingArea oldWidget) {
    super.didUpdateWidget(oldWidget);

    // Check if the selected chat or its messages have changed
    if (widget.selectedChatIndex != oldWidget.selectedChatIndex ||
        widget.chats[widget.selectedChatIndex].messages.length !=
            oldWidget.chats[oldWidget.selectedChatIndex].messages.length) {
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool hasChat = widget.chats.isNotEmpty && widget.selectedChatIndex < widget.chats.length;
    final currentChat = hasChat ? widget.chats[widget.selectedChatIndex] : null;

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHigh,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Chat messages or "No chat selected" message
          Expanded(
            child: hasChat
                ? ListView.builder(
                    controller: _scrollController,
                    itemCount: currentChat!.messages.length + (currentChat.isSending ? 1 : 0),
                    itemBuilder: (context, index) {
                      if (currentChat.isSending && index == currentChat.messages.length) {
                        return const LoadingIndicator();
                      }
                      return ChatMessageWidget(
                        message: currentChat.messages[index],
                      );
                    },
                  )
                : Center(
                    child: Text(
                      'No chat selected. Please create or select a chat.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
          ),
          const SizedBox(height: 8),
          // Message input and send button
          if (hasChat)
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.controller,
                    maxLines: null,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 20,
                      ),
                      labelText: 'Enter your message',
                      labelStyle: TextStyle(
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                      floatingLabelBehavior: FloatingLabelBehavior.never,
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(30)),
                      ),
                      fillColor: Theme.of(context).colorScheme.surfaceContainerHighest,
                      filled: true,
                      suffixIcon: Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: IconButton(
                          icon: Icon(
                            Icons.send_rounded,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          onPressed: () {
                            if (widget.controller.text.trim().isNotEmpty) {
                              widget.onSendMessage(widget.controller.text);
                              widget.controller.clear();
                              _scrollToBottom();
                            }
                          },
                        ),
                      ),
                    ),
                    textInputAction: TextInputAction.send,
                    onFieldSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        widget.onSendMessage(value);
                        widget.controller.clear();
                        _scrollToBottom();
                      }
                    },
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}
