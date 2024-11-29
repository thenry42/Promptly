import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/foundation.dart';
import 'package:promptly_app/widgets/settings_widget.dart';

List<OpenAIModelModel> openAIModels = [];

Future<List<OpenAIModelModel>> getOpenAIModels() async {

  if (openAIModels.isEmpty) {
    try {

      OpenAI.apiKey = openAiKey;

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