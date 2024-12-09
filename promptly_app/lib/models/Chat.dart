/* Conversation class that represents a chat conversation. 
It contains properties related to the conversation's details such as:
  - [title]: The name or title of the conversation.
  - [messages]: A list of [ChatMessage] objects representing all the messages in the conversation.
  - [isHovered]: A boolean to track whether the conversation is currently being hovered over, useful for UI effects.
  - [isOnline]: A boolean indicating whether the conversation is online (uses an API key) or local.
  - [apiKey]: The API key used for online conversations, optional for local ones. */

import 'ChatMessage.dart';

class Chat {

  String title;
  List<ChatMessage> messages = []; // Default value inline
  bool isHovered = false; // Default value inline
  bool isOnline;
  String? apiKey;
  bool isSending;

  // Constructor required inside the class in dart (different from cpp)
  Chat({
    required this.title,
    this.isOnline = false,
    this.apiKey,
    this.isSending = false,
  });
}
