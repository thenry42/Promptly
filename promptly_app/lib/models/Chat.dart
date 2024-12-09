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
