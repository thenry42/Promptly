import 'package:http/http.dart' as http;
import 'dart:convert';

class BackendService {
  final String baseUrl = 'http://localhost:8000';

  /// Get the list of available models from the backend
  Future<List<dynamic>> getOllamaModels() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/ollama/models/list'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['models'];
      } else {
        throw Exception('Failed to load models: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting models: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<List<dynamic>> getAnthropicModels(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/anthropic/models/list?api_key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['models'] ?? [];
      } else {
        throw Exception('Failed to load Anthropic models: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting Anthropic models: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<List<dynamic>> getOpenAIModels(String apiKey) async {
    return [];
  }

  Future<List<dynamic>> getMistralModels(String apiKey) async {
    return [];
  }

  Future<List<dynamic>> getGeminiModels(String apiKey) async {
    return [];
  }

  Future<List<dynamic>> getDeepSeekModels(String apiKey) async {
    return [];
  }

}