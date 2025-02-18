import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'Chat.dart';
import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart' as anthropicsdk;
import 'package:ollama_dart/ollama_dart.dart' as ollama;
import 'package:dart_openai/dart_openai.dart' as openai;
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class Singleton {

  // ATTRIBUTES -------------------------------------------

  late String? anthropicKey = null;
  late String? openAIKey = null;
  List<Chat> chatList = [];
  late List<anthropicsdk.Model> anthropic_models = [];
  late List<ollama.Model> ollama_models = [];
  late List<openai.OpenAIModelModel> openai_models = [];
  late List<String> modelsName = [];
  int selectedChatIndex = 0;
  final List<VoidCallback> _chatSelectionListeners = [];

  double fontSize = 20;
  String fontFamily = 'roboto';

  bool isInitialized = false;

  final _storage = const FlutterSecureStorage();

  // CONSTRUCTOR ------------------------------------------

  static final Singleton _instance = Singleton._internal();
  factory Singleton() => _instance;
  Singleton._internal();

  // METHODS ----------------------------------------------

  Future<void> getAnthropicModels() async {
    // Read and decode the JSON file
    final String jsonString = await rootBundle.loadString('assets/json/models.json');
    final Map<String, dynamic> jsonData = json.decode(jsonString);
    
    // Extract Anthropic models from the JSON and convert to List<anthropicsdk.Model>
    List<anthropicsdk.Model> models = (jsonData['anthropic_models'] as List)
        .map((model) => anthropicsdk.Model.modelId(model['id'] as String))
        .toList();
    
    anthropic_models = models;
  }

  Future<void> getOllamaModels() async {
    try {

      final client = ollama.OllamaClient();
      final response = await client.listModels();
      ollama_models = response.models!.toList();

    } catch (e) {
      if (kDebugMode) {
        print('Error fetching ollama models: $e');
      }
    }
  }

  Future<void> getOpenAIModels() async {
    try {
      // Read and decode the JSON file
      final String jsonString = await rootBundle.loadString('assets/json/models.json');
      final Map<String, dynamic> jsonData = json.decode(jsonString);
      
      // Get the list of model IDs from the JSON file
      final List<String> allowedModelIds = (jsonData['openai_models'] as List)
          .map((model) => model['id'] as String)
          .toList();

      openai.OpenAI.apiKey = openAIKey!;
      final allModels = await openai.OpenAI.instance.model.list();
      
      // Filter models to only include those in our JSON file
      openai_models = allModels
          .where((model) => allowedModelIds.contains(model.id))
          .toList();

    } catch (e) {
      if (kDebugMode) {
        print('Error fetching openAI models: $e');
      }
    }
  }

  Future<void> getModels() async {
    await getAnthropicModels();
    await getOllamaModels();
    await getOpenAIModels();
  }

  Future<void> getModelsName() async {
    for (int i = 0; i < anthropic_models.length; i++) {
      modelsName.add(anthropic_models[i].value.toString());
    }
    for (int i = 0; i < ollama_models.length; i++) {
      modelsName.add(ollama_models[i].model!);
    }
    for (int i = 0; i < openai_models.length; i++) {
      modelsName.add(openai_models[i].id);
    }
  }

  void addChat(Chat chat) {
    chatList.add(chat);
  }

  void removeChat(Chat chat) {
    chatList.remove(chat);
  }

  void addChatSelectionListener(VoidCallback listener) {
    _chatSelectionListeners.add(listener);
  }

  void removeChatSelectionListener(VoidCallback listener) {
    _chatSelectionListeners.remove(listener);
  }

  void setSelectedChatIndex(int index) {
    selectedChatIndex = index;
    // Notify all listeners when chat selection changes
    for (final listener in _chatSelectionListeners) {
      listener();
    }
  }

  Future<void> saveAPIKeys() async {
    if (anthropicKey == null || openAIKey == null) return;
    
    await _storage.write(key: 'anthropic_key', value: anthropicKey!);
    await _storage.write(key: 'openai_key', value: openAIKey!);
  }

  Future<void> loadAPIKeys() async {
    anthropicKey = await _storage.read(key: 'anthropic_key');
    openAIKey = await _storage.read(key: 'openai_key');
    
    if (anthropicKey == null || openAIKey == null) {
      throw Exception('No API keys found');
    }
  }
}