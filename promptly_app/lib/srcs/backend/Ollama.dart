import 'package:flutter/foundation.dart';
import 'package:ollama_dart/ollama_dart.dart' as ollama;
import 'ChatMessage.dart';

class Ollama
{
  // CONSTRUCTOR ------------------------------------------
  
  // METHODS ----------------------------------------------
  
  Future<ollama.Message> generateMessageRequest({
    required Object model,
    required String prompt,
    required List<ChatMessage> messageList,
    required int maxTokens
  }) async {

    final client = ollama.OllamaClient();

    try {

      final messages = messageList.map((msg) => ollama.Message(
        role: msg.sender == 'User' ? ollama.MessageRole.user : ollama.MessageRole.assistant,
        content: msg.message,
      )).toList();

      final res = await client.generateChatCompletion(
        request: ollama.GenerateChatCompletionRequest(
          model: model.toString(),
          messages: messages,
        ),
      );

      return res.message;

    } catch (e) {
      if (kDebugMode) {
        print('Error generating completion: $e');
      }

      return const ollama.Message(
        role: ollama.MessageRole.system,
        content: 'Error'
      );
    }
  }

  // TO DO :
  // generateStreamRequest()

}