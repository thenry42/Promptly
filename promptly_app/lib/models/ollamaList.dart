import 'package:flutter/foundation.dart';
import 'package:ollama_dart/ollama_dart.dart';

List<Map<String, String>> llmList = [];

Future<List<Map<String, String>>> getOllamaModels() async {
  try {
    final client = OllamaClient();
    final response = await client.listModels();
    
    // Convert to List of Maps with name and type
    final List<Map<String, String>> modelList = response.models!
        .map((model) => {
          'name': model.model.toString(),  // Changed from toString() to name
          'type': 'local',
        })
        .toList();
    
    // Clear existing list and add new models
    llmList.clear();
    llmList.addAll(modelList);
    
    return llmList;
  } catch (e) {
    if (kDebugMode) {
      print('Error fetching models: $e');
    }
    return llmList;
  }
}