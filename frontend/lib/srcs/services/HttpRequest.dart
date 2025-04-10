import 'package:http/http.dart' as http;
import 'dart:convert';

class BackendService {
  final String baseUrl = 'http://localhost:8000';

  /// Get the list of available models from the backend
  Future<List<dynamic>> getOllamaModelsRequest() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/ollama/models/list'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['models'] ?? [];
      } else {
        throw Exception('Failed to load models: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting models: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<List<dynamic>> getAnthropicModelsRequest(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/anthropic/models/list?api_key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to load Anthropic models: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting Anthropic models: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<List<dynamic>> getOpenAIModelsRequest(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/openai/models/list?api_key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to load OpenAI models: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting OpenAI models: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<List<dynamic>> getMistralModelsRequest(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/mistral/models/list?api_key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to load Mistral models: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting Mistral models: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<List<dynamic>> getGeminiModelsRequest(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/gemini/models/list?api_key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['_page'] ?? [];
      } else {
        throw Exception('Failed to load Gemini models: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting Gemini models: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<List<dynamic>> getDeepSeekModelsRequest(String apiKey) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/deepseek/models/list?api_key=$apiKey'),
        headers: {'Content-Type': 'application/json'},
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['data'] ?? [];
      } else {
        throw Exception('Failed to load DeepSeek models: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting DeepSeek models: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> ollamaCompletionRequest({
    required String modelName,
    required List<Map<String, String>> messages,
    bool stream = false,
  }) async {
    try {
      final body = jsonEncode({
        'model': modelName,
        'messages': messages,
        'stream': stream,
      });

      final response = await http.post(
        Uri.parse('$baseUrl/ollama/chat/completions'),
        headers: {'Content-Type': 'application/json'},
        body: body,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to get completion: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting Ollama completion: $e');
      throw Exception('Network error: $e');
    }
  }
}