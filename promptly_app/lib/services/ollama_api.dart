import 'package:flutter/foundation.dart';
import 'package:ollama_dart/ollama_dart.dart';

Future<String> generateOllamaCompletion({
  required String model,
  required String prompt
}) async {
  final client = OllamaClient();
  
  try {
    final generatedResponse = await client.generateCompletion(
      request: GenerateCompletionRequest(
        model: model,
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
