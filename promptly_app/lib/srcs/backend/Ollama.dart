import 'package:flutter/foundation.dart';
import 'package:ollama_dart/ollama_dart.dart' as ollama;
import 'ChatMessage.dart';

class Ollama
{
  int? maxTokens;
  List<ollama.Model> models = [];
  bool supportToolCalling = false;

  Future<List<ollama.Model>> getOllamaModels() async {
    try {
      final client = ollama.OllamaClient();
      final response = await client.listModels();

      // Convert to List of Maps with name and type
      final List<ollama.Model> models = response.models!.toList();

      return models;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching models: $e');
      }
      return models;
    }
  }

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