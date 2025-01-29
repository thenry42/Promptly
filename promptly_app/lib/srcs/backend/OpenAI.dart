import 'package:dart_openai/dart_openai.dart' as openai;
import 'package:flutter/foundation.dart';
import 'ChatMessage.dart';

class OpenAI
{
  // ATTRIBUTES -------------------------------------------

  final String apiKey;
  String model;

  // CONSTRUCTOR ------------------------------------------

  OpenAI({required this.apiKey, required this.model});

  // METHODS ----------------------------------------------

  // Contrary to others LLM providers this function can return null
  Future<ChatMessage> generateOpenAIMessageRequest({
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
        model: model,
        messages: messages,
      ).timeout(const Duration(seconds: 500));

      return ChatMessage(
        sender: 'Assistant',
        message: res.choices.first.message.content!.join(' '),
        timestamp: DateTime.now(),
        rawMessage: res,
      );

    } catch (e) {
      if (kDebugMode) {
        print('Error generating completion: $e');
      }
    }
    return ChatMessage(
      sender: 'Assistant',
      message: 'Error',
      timestamp: DateTime.now(),
      rawMessage: 'Error',
    );
  }

  // TO DO :
  // generateStreamRequest()
  // generateAudio()
  // generateImage()

}