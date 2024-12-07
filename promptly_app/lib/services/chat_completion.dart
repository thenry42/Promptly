import 'package:ollama_dart/ollama_dart.dart' as ollama;
import 'package:dart_openai/dart_openai.dart' as openai;
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropic;
import 'package:promptly_app/services/ollama_completion.dart';
import 'open_ai_completion.dart';
import 'anthropic_completion.dart';

Future<String> generateChatCompletion({
  required String model,
  required String prompt,
  required Object type
}) async {

  String response = '';

  if (type == ollama.Model) {
    response = await generateOllamaCompletion(model: model, prompt: prompt);
  } else if (type == openai.OpenAIModelModel) {
    response = await generateOpenAICompletion(model: model, prompt: prompt);
  } else if (type == anthropic.Model) {
    response = await generateAnthropicCompletion(model: model, prompt: prompt);
  } else {
    throw Exception('Unsupported model type');
  }

  return response;
}