import 'package:flutter/foundation.dart';
import 'package:ollama_dart/ollama_dart.dart';

List<Model> ollamaModels = [];

Future<List<Model>> getOllamaModels() async { 
  try {
    final client = OllamaClient();
    final response = await client.listModels();

    // Convert to List of Maps with name and type
    final List<Model> modelList = response.models!.toList();
        
    // Clear existing list and add new models
    ollamaModels.clear();
    ollamaModels.addAll(modelList);    
    return ollamaModels;
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching models: $e');
    }
    return ollamaModels;
  }
}

Future<String> generateOllamaCompletion({
  required String model,
  required String prompt,
}) async {
  final client = OllamaClient();

  var tmp = model.split(':');
  var newModel = '${tmp[1]}:${tmp[2]}'; 

  try {

    final generatedResponse = await client.generateCompletion(
      request: GenerateCompletionRequest(
        model: newModel,
        prompt: prompt,
      ),
    );
    
    return generatedResponse.response.toString();
  } catch (e) {
    if (kDebugMode) {
      print('Error generating completion: $e');
    }
    return '';
  }
}
