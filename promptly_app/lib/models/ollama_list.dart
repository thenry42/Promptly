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
