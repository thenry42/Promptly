import 'Ollama.dart';
import 'OpenAI.dart';

class ModelService {
  Future<void> initializeOllamaModels() async {
    try {
      await getOllamaModels();
    } catch (e) {
      print('Error initializing Ollama models: $e');
    }
  }

  Future<void> initializeOpenAiModels() async {
    try {
      await getOpenAIModels();
    } catch (e) {
      print('Error initializing OpenAI models: $e');
    }
  }
}
