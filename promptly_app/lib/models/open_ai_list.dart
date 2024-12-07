import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:promptly_app/widgets/settings_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

List<OpenAIModelModel> openAIModels = [];

Future<List<OpenAIModelModel>> getOpenAIModels() async {

  if (openAIModels.isEmpty) {
    try {

      if (openAiKey.isEmpty)
      {
        // Retrieve API KEY from .env
        OpenAI.apiKey = (await getOpenAIKey())!;
      } else {
        // Retrieve API KEY from user input
        OpenAI.apiKey = openAiKey; 
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

Future<String?> getOpenAIKey() async
{
  String? res;
  
  if (openAiKey.isEmpty)
  {
    await dotenv.load();
    res = dotenv.env['OPEN_AI_API_KEY'];
    openAiKey = res!;
    return res;
  }
  return null;
}