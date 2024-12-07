import 'package:ollama_dart/ollama_dart.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:promptly_app/services/ollama_completion.dart';
import 'open_ai_completion.dart';

Future<String> generateChatCompletion({
  required String model,
  required String prompt,
  required Object type
}) async {

  String response = '';

  if (type == Model) {
    response = await generateOllamaCompletion(model: model, prompt: prompt);
  } else if (type == OpenAIModelModel) {
    response = await generateOpenAICompletion(model: model, prompt: prompt);
  } else {
    throw Exception('Unsupported model type');
  }

  return response;
}