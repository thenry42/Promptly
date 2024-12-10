import 'package:flutter/foundation.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

List<OpenAIModelModel> openAIModels = [];
String OPEN_AI_API_KEY = '';

Future<List<OpenAIModelModel>> getOpenAIModels() async {

  if (openAIModels.isEmpty) {
    try {
      if (OPEN_AI_API_KEY.isEmpty) {
        
        // Retrieve API KEY from .env
        await dotenv.load();
        String? res = dotenv.env['OPEN_AI_API_KEY'];
        OPEN_AI_API_KEY = res!;
        OpenAI.apiKey = OPEN_AI_API_KEY;

      } else {

        // Retrieve API KEY from user input
        OpenAI.apiKey = OPEN_AI_API_KEY; 
      }

      List<OpenAIModelModel> models = await OpenAI.instance.model.list();
      openAIModels = models;

    } catch (e) {
      if (kDebugMode) {
        print('Error fetching openAI models: $e');
      }
    }
  }
  return openAIModels;
}

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

  } catch (e) {
    if (kDebugMode) {
      print('Error generating completion: $e');
    }
  }
  return 'FATAL ERROR';
}