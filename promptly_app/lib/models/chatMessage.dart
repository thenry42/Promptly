/* ChatMessage class that represent a single chat message
It contains two properties:
  - [sender]: The name or identifier of the person sending the message.
  - [message]: The content of the message sent by the sender. */

class ChatMessage {
  final String sender;
  final String message;

  ChatMessage({required this.sender, required this.message});
}
