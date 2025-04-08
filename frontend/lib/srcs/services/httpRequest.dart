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

  /// Get a completion from the backend using the specified model and prompt
  Future<String> getCompletion(String model, String prompt) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/completion'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'model': model,
          'prompt': prompt,
        }),
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['completion']['message']['content'];
      } else {
        throw Exception('Failed to get completion: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting completion: $e');
      throw Exception('Network error: $e');
    }
  }
}