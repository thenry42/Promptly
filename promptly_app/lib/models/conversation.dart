import 'chat_message.dart';

/* Conversation class that represents a chat conversation. 
It contains properties related to the conversation's details such as:
  - [title]: The name or title of the conversation.
  - [messages]: A list of [ChatMessage] objects representing all the messages in the conversation.
  - [isHovered]: A boolean to track whether the conversation is currently being hovered over, useful for UI effects.
  - [isOnline]: A boolean indicating whether the conversation is online (uses an API key) or local.
  - [apiKey]: The API key used for online conversations, optional for local ones. */

class Conversation {
  String title;
  List<ChatMessage> messages;
  bool isHovered;
  bool isOnline;
  String? apiKey;

  Conversation({
    required this.title,
    this.isOnline = false,
    this.apiKey,
  }) : messages = [], isHovered = false;
}
