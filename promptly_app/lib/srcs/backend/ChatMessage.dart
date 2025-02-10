class ChatMessage
{
  // ATTRIBUTES -------------------------------------------

  final String sender;
  final String message;
  final DateTime timestamp;
  final Object rawMessage;
  
  bool useMarkdown = true;
  bool useRaw = false;
  bool usePlainText = false;

  // CONSTRUCTOR ------------------------------------------

  ChatMessage({
    required this.sender,
    required this.message,
    required this.timestamp,
    required this.rawMessage
  });

  // METHODS ----------------------------------------------

}