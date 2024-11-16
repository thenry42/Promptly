import 'chat_message.dart';

class Conversation {
  String title;
  List<ChatMessage> messages;
  bool isHovered; // Track hover state for hover effect
  bool isOnline; // Indicates if the chat is online or local
  String? apiKey; // Stores the API key if the chat is online

  Conversation({
    required this.title,
    this.isOnline = false, // Default to local chat
    this.apiKey, // Optional API key, only needed for online chats
  }) : messages = [], isHovered = false;
}
