class ChatMessage
{
  late final String sender;
  late final String message;
  late final Object rawMessage;
  late final DateTime timestamp;
  bool useMarkdown = true;
  bool useRaw = false;
  bool usePlainText = false;
}