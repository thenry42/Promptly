import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:promptly_app/widgets/settings_widget.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

List<OpenAIModelModel> openAIModels = [];

Future<List<OpenAIModelModel>> getOpenAIModels() async {

  if (openAIModels.isEmpty) {
    try {

      /*
      if (openAiKey.isEmpty)
      {
        if (kDebugMode)
        {
          print('OpenAI API key missing');
        }
        return [];
      }

      // Retrieve API KEY from user input
      OpenAI.apiKey = openAiKey;
      */

      // Retrieve API KEY from .env
      OpenAI.apiKey = (await getEnvKey())!;

      List<OpenAIModelModel> models = await OpenAI.instance.model.list();
      openAIModels = models;

      // Iterate through the list of models and print their names
      for (var model in models) {
        print('Model Name: ${model.id}');
      }
    
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching openAI models: $e');
      }
    }
  }
  return openAIModels;
}

Future<String?> getEnvKey() async
{
  String? res;

  print('alors');
  await dotenv.load();
  print('peut etre');
  res = dotenv.env['OPEN_AI_API_KEY'];

  if (res == null) {
    print('Problem');
  } else {
    print(res);
  }

  return res;
}