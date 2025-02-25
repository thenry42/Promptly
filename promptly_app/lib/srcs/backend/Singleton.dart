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

  late String anthropicKey;
  late String openAIKey;
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
  Singleton._internal() {
    // Initialize API keys and chats asynchronously
    loadAPIKeys().then((_) {
      // Only load chats after API keys are initialized
      return loadChats();
    }).then((_) {
      isInitialized = true;
      if (kDebugMode) {
        print('Singleton initialized successfully');
        print('Loaded ${chatList.length} chats');
      }
    }).catchError((error) {
      if (kDebugMode) {
        print('Error during initialization: $error');
      }
      isInitialized = false;
      chatList = []; // Ensure we have an empty list on error
    });
  }

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

      openai.OpenAI.apiKey = openAIKey;
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

  Future<void> removeChat(int index) async {
    if (index >= 0 && index < chatList.length) {
      try {
        // Remove from memory
        chatList.removeAt(index);
        
        // Update selected index
        if (index <= selectedChatIndex) {
          if (selectedChatIndex >= chatList.length) {
            selectedChatIndex = chatList.isEmpty ? 0 : chatList.length - 1;
          } else {
            selectedChatIndex = selectedChatIndex > 0 ? selectedChatIndex - 1 : 0;
          }
          // Notify listeners of the selection change
          for (final listener in _chatSelectionListeners) {
            listener();
          }
        }
        
        // Save updated list to storage
        await saveChats();
        
        if (kDebugMode) {
          print('Successfully removed chat at index $index and updated storage');
          print('New chat count: ${chatList.length}');
        }
      } catch (e) {
        if (kDebugMode) {
          print('Error removing chat: $e');
        }
        // Attempt to restore consistency between memory and storage
        await loadChats();
        throw Exception('Failed to remove chat: $e');
      }
    }
  }

  Future<void> removeSelectedChat() async {
    await removeChat(selectedChatIndex);
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
    if (anthropicKey == null && openAIKey == null) return;
    
    await _storage.write(key: 'anthropic_key', value: anthropicKey!);
    await _storage.write(key: 'openai_key', value: openAIKey!);
  }

  Future<void> loadAPIKeys() async {
    anthropicKey = (await _storage.read(key: 'anthropic_key')) ?? '';
    openAIKey = (await _storage.read(key: 'openai_key')) ?? '';
  }

  Future<void> saveChats() async {
    try {
      // Convert each chat to a JSON string
      final chatJsonList = chatList.map((chat) => chat.toJson()).toList();
      // Convert the list to a single JSON string
      final String encodedChats = json.encode(chatJsonList);
      // Save to secure storage
      await _storage.write(key: 'saved_chats', value: encodedChats);
      
      if (kDebugMode) {
        print('Saved ${chatList.length} chats');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error saving chats: $e');
      }
    }
  }

  Future<void> loadChats() async {
    try {
      // Read the JSON string from storage
      final String? encodedChats = await _storage.read(key: 'saved_chats');
      if (encodedChats != null) {
        // Decode the JSON string to a List
        final List<dynamic> chatJsonList = json.decode(encodedChats);
        // Convert each JSON object back to a Chat
        chatList = chatJsonList.map((jsonChat) => Chat.fromJson(jsonChat)).toList();
        
        if (kDebugMode) {
          print('Loaded ${chatList.length} chats');
        }
      } else {
        if (kDebugMode) {
          print('No saved chats found');
        }
        chatList = [];
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error loading chats: $e');
      }
      chatList = []; // Initialize empty list if loading fails
    }
  }
}