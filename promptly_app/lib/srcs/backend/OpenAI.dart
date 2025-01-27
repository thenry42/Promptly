import 'package:dart_openai/dart_openai.dart' as openai;
import 'package:flutter/foundation.dart';
import 'ChatMessage.dart';

class OpenAI
{
  final String apiKey;
  List<openai.OpenAIModelModel> models = [];
  int? maxTokens;
  bool supportToolCalling = false;

  OpenAI({required this.apiKey});

  Future<List<openai.OpenAIModelModel>> getOpenAIModels() async {
    try {
      
      openai.OpenAI.apiKey = apiKey;
      models = await openai.OpenAI.instance.model.list();

    } catch (e) {
      if (kDebugMode) {
        print('Error fetching openAI models: $e');
      }
    }
    return models;
  }

  // Contrary to others LLM providers this function can return null
  Future<openai.OpenAIChatCompletionModel?> generateMessageRequest({
    required Object model,
    required String prompt,
    required List<ChatMessage> messageList,
    required int maxTokens
  }) async {

    try {

      final List<openai.OpenAIChatCompletionChoiceMessageModel> messages = messageList.map((msg) {
        return openai.OpenAIChatCompletionChoiceMessageModel(
          content: [
            openai.OpenAIChatCompletionChoiceMessageContentItemModel.text(msg.message),
          ],
          role: msg.sender == 'User' ? openai.OpenAIChatMessageRole.user : openai.OpenAIChatMessageRole.assistant,
        );
      }).toList();

      openai.OpenAIChatCompletionModel res = await openai.OpenAI.instance.chat.create(
        model: model.toString(),
        messages: messages,
      ).timeout(const Duration(seconds: 500));

      return res;

    } catch (e) {
      if (kDebugMode) {
        print('Error generating completion: $e');
      }
    }
    return null;
  }

  // TO DO :
  // generateStreamRequest()
  // generateAudio()
  // generateImage()

}