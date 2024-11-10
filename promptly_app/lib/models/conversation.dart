import 'chat_message.dart';

class Conversation {
  String title;
  List<ChatMessage> messages;
  bool isHovered; // Track hover state for hover effect

  Conversation({required this.title}) : messages = [], isHovered = false;
}