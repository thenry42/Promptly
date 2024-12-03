import 'package:flutter/foundation.dart';
import 'package:ollama_dart/ollama_dart.dart';
import 'chat_completion.dart';

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
