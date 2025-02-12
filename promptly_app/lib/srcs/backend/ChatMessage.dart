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
  }) {
    // Set default formatting based on sender
    if (sender.toLowerCase() == 'user') {
      useMarkdown = false;
      usePlainText = true;
    } else if (sender.toLowerCase() == 'assistant') {
      useMarkdown = true;
      usePlainText = false;
    }
  }

  // METHODS ----------------------------------------------

}