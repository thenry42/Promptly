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

  Future<Map<String, dynamic>> openaiCompletionRequest({
    required String modelName,
    required List<Map<String, String>> messages,
    required String apiKey,
    bool stream = false,
  }) async {
    try {

      if (apiKey.isEmpty) {
        throw Exception('API key is empty');
      }
      
      final Map<String, dynamic> requestBody = {
        'model': modelName,
        'messages': messages,
        'stream': stream,
        'api_key': apiKey,
      };
      
      final body = jsonEncode(requestBody);

      final response = await http.post(
        Uri.parse('$baseUrl/openai/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to get OpenAI completion: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error getting OpenAI completion: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> deepseekCompletionRequest({
    required String modelName,
    required List<Map<String, String>> messages,
    required String apiKey,
    bool stream = false,
  }) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception('DeepSeek API key is empty');
      }
      
      final Map<String, dynamic> requestBody = {
        'model': modelName,
        'messages': messages,
        'api_key': apiKey,
        'stream': stream,
      };
      
      final body = jsonEncode(requestBody);

      final response = await http.post(
        Uri.parse('$baseUrl/deepseek/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to get DeepSeek completion: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error getting DeepSeek completion: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> mistralCompletionRequest({
    required String modelName,
    required List<Map<String, String>> messages,
    required String apiKey,
    bool stream = false,
  }) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception('Mistral API key is empty');
      }
      
      final Map<String, dynamic> requestBody = {
        'model': modelName,
        'messages': messages,
        'api_key': apiKey,
        'stream': stream,
      };
      
      final body = jsonEncode(requestBody);

      final response = await http.post(
        Uri.parse('$baseUrl/mistral/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to get Mistral completion: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error getting Mistral completion: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> anthropicCompletionRequest({
    required String modelName,
    required List<Map<String, String>> messages,
    required String apiKey,
    int maxTokens = 4096,
    bool stream = false,
  }) async {
    try {
      if (apiKey.isEmpty) {
        throw Exception('Anthropic API key is empty');
      }
      
      final Map<String, dynamic> requestBody = {
        'model': modelName,
        'messages': messages,
        'api_key': apiKey,
        'max_tokens': maxTokens,
        'stream': stream,
      };
      
      final body = jsonEncode(requestBody);

      final response = await http.post(
        Uri.parse('$baseUrl/anthropic/chat/completions'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: body,
      );
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data;
      } else {
        throw Exception('Failed to get Anthropic completion: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error getting Anthropic completion: $e');
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> geminiCompletionRequest({
    required String modelName,
    required List<Map<String, String>> messages,
    required String apiKey,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'model': modelName,
        'messages': messages,
        'api_key': apiKey,
      };
      
      final response = await http.post(
        Uri.parse('$baseUrl/gemini/chat/completions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get Gemini completion: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting Gemini completion: $e');
      throw Exception('Network error: $e');
    }
  }
}