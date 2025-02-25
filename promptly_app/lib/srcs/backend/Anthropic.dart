import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropicsdk;
import 'package:flutter/foundation.dart';
import 'package:promptly_app/srcs/backend/ChatMessage.dart';
import 'package:promptly_app/srcs/backend/Singleton.dart';

class Anthropic
{
  // ATTRIBUTES -------------------------------------------

  final String apiKey;
  anthropicsdk.Model model;

  // CONSTRUCTOR ------------------------------------------

  Anthropic({required this.apiKey, required this.model});

  // METHODS ----------------------------------------------

  Future<ChatMessage> generateAnthropicMessageRequest({
    required List<ChatMessage> messageList,
    required int maxTokens
    }) async {

    final client = anthropicsdk.AnthropicClient(apiKey: apiKey);

    try {
      final List<anthropicsdk.Message> messages = messageList.map((msg) {
        return anthropicsdk.Message(
          role: msg.sender == 'User' ? anthropicsdk.MessageRole.user : anthropicsdk.MessageRole.assistant,
          content: anthropicsdk.MessageContent.text(msg.message),
        );
      }).toList();

      final raw = await client.createMessage(
        request: anthropicsdk.CreateMessageRequest(
          model: model,
          messages: messages,
          maxTokens: maxTokens));

      const sender = "Assistant";
      final message = raw.content.text;
      final timestamp = DateTime.now();

      return ChatMessage(sender: sender, message: message, timestamp: timestamp, rawMessage: raw);

    } catch (e) {
      if (kDebugMode) {
        print('Error generating completion: $e');
      }
      return ChatMessage(sender: "Assistant", message: "Error", timestamp: DateTime.now(), rawMessage: "Error");
    }
  }

  // TO DO :
  // generateStreamRequest()
}