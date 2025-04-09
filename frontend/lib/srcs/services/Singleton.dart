import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'Chat.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'HttpRequest.dart';

class Singleton {

  // ATTRIBUTES -------------------------------------------

  late String anthropicKey;
  late String openAIKey;
  late String mistralKey;
  late String geminiKey;
  late String deepseekKey;

  var backendService = BackendService();

  List<Chat> chatList = [];
  
  late List<dynamic> anthropic_models = [];
  late List<dynamic> ollama_models = [];
  late List<dynamic> openai_models = [];
  late List<dynamic> mistral_models = [];
  late List<dynamic> gemini_models = [];
  late List<dynamic> deepseek_models = [];

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

  Future<void> getAnthropicModels() async
  {
    // Get the models from the backend API
    var tmp = await backendService.getAnthropicModelsRequest(anthropicKey);
  
    // Only retrieve the models name
    anthropic_models = tmp.map<String>((model) => model['id'] as String).toList();
  }

  Future<void> getOllamaModels() async
  {
    // Get the models from the backend API
    var tmp = await backendService.getOllamaModelsRequest();

    // Only retrieve the models name
    ollama_models = tmp.map<String>((model) => model['model'] as String).toList();
  }

  Future<void> getOpenAIModels() async
  {
    // Get the models from the backend API
    var tmp = await backendService.getOpenAIModelsRequest(openAIKey);

    // Only retrieve the models name
    openai_models = tmp.map<String>((model) => model['id'] as String).toList();
  }

  Future<void> getMistralModels() async
  {
    // Get the models from the backend API
    var tmp = await backendService.getMistralModelsRequest(mistralKey);

    // Only retrieve the models name
    mistral_models = tmp.map<String>((model) => model['id'] as String).toList();
  }

  Future<void> getGeminiModels() async
  {
    // Get the models from the backend API
    var tmp = await backendService.getGeminiModelsRequest(geminiKey);

    // Only retrieve the models name - use 'name' field instead of 'id'
    gemini_models = tmp.map<String>((model) => model['name'] as String).toList();

    // Remove "models/" prefix if it exists
    gemini_models = gemini_models.map<String>((model) => model.startsWith('models/') ? model.substring(7) : model).toList();
  }

  Future<void> getDeepSeekModels() async
  {
    // Get the models from the backend API
    var tmp = await backendService.getDeepSeekModelsRequest(deepseekKey);

    // Only retrieve the models name
    deepseek_models = tmp.map<String>((model) => model['id'] as String).toList();
  }

  Future<void> getModels() async
  {
    // These work to retrieve the models from providers
    // but models and their features need to be parsed
    await getAnthropicModels(); // WORKS
    await getOllamaModels(); // WORKS
    await getOpenAIModels(); // WORKS
    await getMistralModels(); // WORKS
    await getGeminiModels(); // WORKS
    await getDeepSeekModels(); // WORKS
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
    await _storage.write(key: 'mistral_key', value: mistralKey!);
    await _storage.write(key: 'gemini_key', value: geminiKey!);
    await _storage.write(key: 'deepseek_key', value: deepseekKey!);
  }

  Future<void> loadAPIKeys() async {
    anthropicKey = (await _storage.read(key: 'anthropic_key')) ?? '';
    openAIKey = (await _storage.read(key: 'openai_key')) ?? '';
    mistralKey = (await _storage.read(key: 'mistral_key')) ?? '';
    geminiKey = (await _storage.read(key: 'gemini_key')) ?? '';
    deepseekKey = (await _storage.read(key: 'deepseek_key')) ?? '';
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