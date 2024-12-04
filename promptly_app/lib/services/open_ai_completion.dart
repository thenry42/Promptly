import 'package:flutter/foundation.dart';
import 'package:dart_openai/dart_openai.dart';

Future<String> generateOpenAICompletion({
  required String model,
  required String prompt,
}) async {

  String newModel = model.replaceFirst('openai:', ''); 

  final userMessage = OpenAIChatCompletionChoiceMessageModel(
  content: [
    OpenAIChatCompletionChoiceMessageContentItemModel.text(prompt),
  ],
  role: OpenAIChatMessageRole.user,
  );

  try {
    
    // the actual request.
    OpenAIChatCompletionModel chatCompletion = await OpenAI.instance.chat.create(
      model: newModel,
      messages: [
        userMessage
      ],
    ).timeout(const Duration(seconds: 200));

    if (chatCompletion.choices.isNotEmpty && chatCompletion.choices[0].message.content!.isNotEmpty) {
      return chatCompletion.choices[0].message.content![0].text.toString();
    } else {
      return 'No answer available.';
    }

    /* 
    print(chatCompletion.toString());
    return chatCompletion.choices[0].message.content.toString();
    */

  } catch (e) {
    if (kDebugMode) {
      print('Error generating completion: $e');
    }
  }
  return '';
}