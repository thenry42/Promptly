import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropicsdk;
import 'package:flutter/foundation.dart';
import 'package:promptly_app/srcs/backend/ChatMessage.dart';

class Anthropic
{
  // ATTRIBUTES -------------------------------------------

  final String apiKey;

  // CONSTRUCTOR ------------------------------------------

  Anthropic({required this.apiKey});

  // METHODS ----------------------------------------------

  Future<anthropicsdk.Message> generateMessageRequest({
    required Object model,
    required String prompt,
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

      final res = await client.createMessage(
        request: anthropicsdk.CreateMessageRequest(
          model: anthropicsdk.ModelId(model.toString()),
          messages: messages,
          maxTokens: maxTokens));

      return res;

    } catch (e) {
      if (kDebugMode) {
        print('Error generating completion: $e');
      }

      return const anthropicsdk.Message(
        content: anthropicsdk.MessageContent.text('Error'),
        role: anthropicsdk.MessageRole.assistant);
    }
  }

  // TO DO :
  // generateStreamRequest()
}