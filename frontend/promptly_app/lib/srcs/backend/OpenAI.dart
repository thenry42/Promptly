//import 'package:dart_openai/dart_openai.dart' as openai;
import 'package:openai_dart/openai_dart.dart' as openai;
import 'package:flutter/foundation.dart';
import 'ChatMessage.dart';
import 'Singleton.dart';

// NEED TO GO FROM dart_openai TO openai_dart that is developped by LANGCHAIN
// BETTER FOR API KEY MANAGEMENT

class OpenAI
{
	// ATTRIBUTES -------------------------------------------

	openai.ChatCompletionModel model;

	// CONSTRUCTOR ------------------------------------------

	OpenAI({required this.model});

	// METHODS ----------------------------------------------

	// Generates a message using OpenAI's chat completion API
	Future<ChatMessage> generateOpenAIMessageRequest({
		required List<ChatMessage> messageList,
		required int maxTokens
	}) async {

		final client = openai.OpenAIClient(apiKey: Singleton().openAIKey);

		try {
			// Convert our ChatMessage objects to OpenAI's format
			final List<openai.ChatCompletionMessage> messages = messageList.map((msg) {
				if (msg.sender == 'User') {
					return openai.ChatCompletionMessage.user(
						content: openai.ChatCompletionUserMessageContent.string(msg.message),
					);
				} else {
					return openai.ChatCompletionMessage.assistant(
						content: msg.message,
					);
				}
			}).toList();

			// Create the chat completion request
			final res = await client.createChatCompletion(
				request: openai.CreateChatCompletionRequest(
					model: model,
					messages: messages,
					maxTokens: maxTokens,
				),
			).timeout(const Duration(seconds: 500));

			// Extract the generated message
			String generatedMessage = '';
			if (res.choices.isNotEmpty) {
				generatedMessage = res.choices.first.message.content ?? '';
			}

			return ChatMessage(
				sender: 'Assistant',
				message: generatedMessage,
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

	// Generates a streaming response from OpenAI
	Stream<ChatMessage> generateStreamRequest({
		required List<ChatMessage> messageList,
		required int maxTokens
	}) async* {

		final client = openai.OpenAIClient(apiKey: Singleton().openAIKey);

		try {
			// Convert our ChatMessage objects to OpenAI's format
			final List<openai.ChatCompletionMessage> messages = messageList.map((msg) {
				if (msg.sender == 'User') {
					return openai.ChatCompletionMessage.user(
						content: openai.ChatCompletionUserMessageContent.string(msg.message),
					);
				} else {
					return openai.ChatCompletionMessage.assistant(
						content: msg.message,
					);
				}
			}).toList();

			// Create the streaming chat completion request
			final stream = client.createChatCompletionStream(
				request: openai.CreateChatCompletionRequest(
					model: model,
					messages: messages,
					maxTokens: maxTokens,
				),
			);

			String accumulatedContent = '';
			
			await for (final res in stream) {
				if (res.choices.isNotEmpty && res.choices.first.delta.content != null) {
					accumulatedContent += res.choices.first.delta.content!;
					
					yield ChatMessage(
						sender: 'Assistant',
						message: accumulatedContent,
						timestamp: DateTime.now(),
						rawMessage: res,
					);
				}
			}
		} catch (e) {
			if (kDebugMode) {
				print('Error generating stream: $e');
			}
			yield ChatMessage(
				sender: 'Assistant',
				message: 'Error in stream generation',
				timestamp: DateTime.now(),
				rawMessage: 'Error',
			);
		}
	}

	// TODO: Implement these methods
	// Future<void> generateAudio() async {}
	// Future<void> generateImage() async {}
}



/*
class OpenAI
{
  // ATTRIBUTES -------------------------------------------

  String model;

  // CONSTRUCTOR ------------------------------------------

  OpenAI({required this.model});

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

      String generatedMessage = '';
      if (res.choices.isNotEmpty && res.choices.first.message.content != null) {
        generatedMessage = res.choices.first.message.content!.first.text ?? '';
      }

      return ChatMessage(
        sender: 'Assistant',
        message: generatedMessage,
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
*/