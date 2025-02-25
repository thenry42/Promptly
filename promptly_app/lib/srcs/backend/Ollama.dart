import 'package:flutter/foundation.dart';
import 'package:ollama_dart/ollama_dart.dart' as ollama;
import 'ChatMessage.dart';
import 'Singleton.dart';

class Ollama
{
  // ATTRIBUTES -------------------------------------------

  String model;

  // CONSTRUCTOR ------------------------------------------
  
  Ollama({required this.model});

  // METHODS ----------------------------------------------

  Future<ChatMessage> generateOllamaMessageRequest({
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
          model: model,
          messages: messages,
        ),
      );

      return ChatMessage(
        sender: 'Assistant',
        message: res.message.content,
        timestamp: DateTime.now(),
        rawMessage: res,
      );

    } catch (e) {
      if (kDebugMode) {
        print('Error generating completion: $e');
      }

      return ChatMessage(
        sender: 'Assistant',
        message: 'Error',
        timestamp: DateTime.now(),
        rawMessage: 'Error',
      );
    }
  }

  // TO DO :
  // generateStreamRequest()

}