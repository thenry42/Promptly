import 'package:flutter/material.dart';

class ChattingArea extends StatefulWidget {
  const ChattingArea({Key? key}) : super(key: key);

  @override
  _ChattingAreaState createState() => _ChattingAreaState();
}

class _ChattingAreaState extends State<ChattingArea> {
  final List<String> messages = [];
  final TextEditingController _textController = TextEditingController();

  void _sendMessage() {
    if (_textController.text.isNotEmpty) {
      setState(() {
        messages.add(_textController.text);
        _textController.clear();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Title
        Text(
          'Chat',
          style: Theme.of(context).textTheme.titleMedium,
          textAlign: TextAlign.left,
        ),

        // Messages List
        Expanded(
          child: ListView.separated(
            itemCount: messages.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  messages[index],
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              );
            },
          ),
        ),

        // Text Input Area
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _textController,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ],
    );
  }
}
