import 'Ollama.dart';
import 'OpenAI.dart';
import 'Anthropic.dart';
import 'package:flutter/foundation.dart';

class ModelService {
  Future<void> initializeOllamaModels() async {
    try {
      await getOllamaModels();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing Ollama models: $e');
      }
    }
  }

  Future<void> initializeOpenAiModels() async {
    try {
      await getOpenAIModels();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing OpenAI models: $e');
      }
    }
  }

  Future<void> initializeAnthropicModels() async {
    try {
      await getAnthropicKey();
    } catch (e) {
      if (kDebugMode) {
        print('Error initializing OpenAI models: $e');
      }
    }
  }
}

String getContextWindow(String modelName) {
  return ('XXX');
}

String getTemp(String modelName) {
  return ('YYY');
}